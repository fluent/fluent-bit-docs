# Topological data analysis (`TDA`)

This processor applies [Topological Data Analysis](https://en.wikipedia.org/wiki/Topological_data_analysis) (`TDA`) to incoming metrics using a sliding window and `Ripser` persistent homology. It computes Betti numbers that characterize the topological shape of the metric signal over time, which can surface structural patterns (such as recurring cycles or anomalies) that traditional statistical methods miss.

The processor operates only on metrics. Log and trace records pass through unchanged.

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml.md) support processors.

{% endhint %}

## How it works

On each flush, the processor:

1. Aggregates incoming metrics into a feature vector by collapsing each unique `(namespace, subsystem)` pair into a single value. Counters are converted to log-scaled rates; gauges are used directly.
2. Appends the feature vector to a sliding ring-buffer window of up to `window_size` samples.
3. Optionally applies delay embedding (controlled by `embed_dim` and `embed_delay`) to reconstruct attractor geometry from the time series.
4. Once the window holds at least `min_points` samples, builds a pairwise Euclidean distance matrix over the embedded points and runs `Ripser` to compute persistent homology.
5. Scans across multiple distance thresholds (or uses the quantile supplied in `threshold`) and emits the Betti numbers that show the strongest topological signal.

The output is three gauge metrics added to the same metrics context:

| Metric | Description |
| ------ | ----------- |
| `fluentbit_tda_betti0` | Betti number β₀—number of connected components in the Vietoris-Rips complex. |
| `fluentbit_tda_betti1` | Betti number β₁—number of independent loops (1-cycles). Elevated values suggest cyclic or periodic patterns. |
| `fluentbit_tda_betti2` | Betti number β₂—number of enclosed voids (2-cycles). |

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `window_size` | Number of samples to keep in the sliding window. | `60` |
| `min_points` | Minimum number of samples that must be in the window before `Ripser` runs. | `10` |
| `embed_dim` | Delay embedding dimension `m`. Setting `m=1` disables delay embedding and uses the raw feature vectors directly. For `m>1`, each point in the distance matrix is constructed from `m` consecutive lagged snapshots (for example, `m=3` → `x_t`, `x_{t-1}`, `x_{t-2}`). | `3` |
| `embed_delay` | Lag `τ` in samples between successive delays in the embedding. Ignored when `embed_dim=1`. | `1` |
| `threshold` | Distance scale selector. `0` triggers an automatic multi-quantile scan that picks the threshold maximizing β₁ (or β₀ when all β₁ are zero). A value in `(0, 1)` is treated as a quantile of the pairwise distance distribution and used directly as the `Ripser` threshold. | `0` |

## Configuration example

The following example scrapes Prometheus metrics and runs `TDA` on the ingested data before forwarding to an OpenTelemetry endpoint:

```yaml
service:
  flush: 10
  log_level: info

pipeline:
  inputs:
    - name: prometheus_scrape
      host: 127.0.0.1
      port: 9090
      scrape_interval: 10s
      tag: prom.metrics

      processors:
        metrics:
          - name: tda
            window_size: 60
            min_points: 10
            embed_dim: 3
            embed_delay: 1
            threshold: 0

  outputs:
    - name: opentelemetry
      match: 'prom.metrics'
      host: otel-collector
      port: 4318
```

To disable delay embedding and run `TDA` directly on the raw metric vectors, set `embed_dim: 1`:

```yaml
processors:
  metrics:
    - name: tda
      window_size: 120
      min_points: 20
      embed_dim: 1
```

To fix the distance threshold at a specific quantile of the pairwise distances (for example, the thirtieth percentile), set `threshold` to a value between 0 and 1:

```yaml
processors:
  metrics:
    - name: tda
      window_size: 60
      min_points: 10
      threshold: 0.3
```
