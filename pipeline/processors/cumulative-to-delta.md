# Cumulative to delta

The _cumulative to delta_ processor converts cumulative monotonic metrics to delta values. Use it when scraping metrics from sources that expose cumulative counters and histograms (such as Prometheus endpoints), but your downstream destination expects delta-style values.

The processor operates only on metrics. Log and trace records pass through unchanged.

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml.md) support processors.

{% endhint %}

## What gets converted

The processor converts the following cumulative metric types to delta:

- **Monotonic sums (counters)**: cumulative counters whose value can only increase, or reset to zero on restart.
- **Histograms**: cumulative histogram bucket counts and sums.
- **Exponential histograms**: cumulative exponential (sparse) histogram bucket counts and sums.

Non-monotonic sums (OTLP sums with `allow_reset=true`) are passed through unchanged, because they can decrease arbitrarily and aren't suitable for delta conversion.

All other metric types (gauges, summaries) pass through unchanged.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `drop_first` | Compatibility option. Used only when `initial_value` is `unset`. When `true`, the first sample for each new series is dropped. When `false`, the first sample is emitted as-is. | `true` |
| `drop_on_reset` | When `true`, drops the sample when a counter or histogram reset is detected (that's when the new value is lower than the last recorded value). | `true` |
| `initial_value` | Controls what happens with the first sample seen for a new series. Accepted values: `auto`, `keep`, `drop`. When unset, the `drop_first` compatibility option is used instead. | `unset` |
| `max_series` | Maximum number of unique series whose state is tracked in memory. When the limit is reached, the oldest series is evicted. Set to `0` to disable size-based eviction. | `65536` |
| `max_staleness` | How long to retain per-series state after a series stops reporting. Accepts time values such as `30s`, `5m`, `1h`. Set to `0` to disable staleness eviction. | `1h` |

### `initial_value` behavior

The first time a series is seen, the processor has no prior value to subtract from, so it can't produce a valid delta. The `initial_value` option controls what the processor emits (or drops) at that point.

| Value | Behavior |
| ----- | -------- |
| `drop` | The first sample for each new series is always dropped. The series state is recorded, and subsequent samples are converted normally. |
| `keep` | The first sample is emitted with its cumulative value unchanged. This is equivalent to treating zero as the implicit prior value. |
| `auto` | Samples whose start timestamp predates the processor start time are dropped (they represent metrics that existed before Fluent Bit started). Samples whose start timestamp is at or after the processor start time are kept. Recommended for scraping long-running processes that have been exporting metrics for longer than this Fluent Bit instance has been running. |
| `unset` (default) | Falls back to the `drop_first` option for backwards compatibility. `drop_first: true` (the default) behaves identically to `drop`. `drop_first: false` behaves identically to `keep`. |

### Reset detection

A reset is detected when a new cumulative value is lower than the last recorded value for the same series (for example, after a process restart). When `drop_on_reset` is `true` (the default), the sample that triggered the reset is dropped and the new value is stored as the new baseline. The next sample after a reset produces a valid delta.

### Out-of-order samples

Samples with a timestamp equal to or earlier than the last recorded timestamp for the same series are dropped. This prevents negative or zero deltas from being emitted due to late-arriving data.

### Staleness and memory bounds

The processor maintains a per-series state table. To prevent unbounded memory growth:

- Series that haven't reported for longer than `max_staleness` are evicted. When a previously evicted series reappears, it's treated as a new series and `initial_value` applies.
- When the total number of tracked series reaches `max_series`, the oldest series is evicted before the new one is added.

## Configuration example

The following example scrapes Prometheus metrics and converts cumulative counters and histograms to delta values before forwarding to an OpenTelemetry endpoint:

```yaml
service:
  flush: 5
  log_level: info

pipeline:
  inputs:
    - name: prometheus_scrape
      host: 127.0.0.1
      port: 9090
      scrape_interval: 30s
      tag: prom.metrics

      processors:
        metrics:
          - name: cumulative_to_delta
            initial_value: auto
            drop_on_reset: true

  outputs:
    - name: opentelemetry
      match: 'prom.metrics'
      host: otel-collector
      port: 4318
```

To preserve the first sample for every series instead of dropping it, set `initial_value: keep` inside the input's `processors.metrics` block:

```yaml
pipeline:
  inputs:
    - name: prometheus_scrape
      host: 127.0.0.1
      port: 9090
      scrape_interval: 30s
      tag: prom.metrics

      processors:
        metrics:
          - name: cumulative_to_delta
            initial_value: keep

  outputs:
    - name: opentelemetry
      match: 'prom.metrics'
      host: otel-collector
      port: 4318
```

To use the `drop_first` compatibility mode explicitly (equivalent to the default behavior), omit `initial_value` and set `drop_first` inside the input's `processors.metrics` block:

```yaml
pipeline:
  inputs:
    - name: prometheus_scrape
      host: 127.0.0.1
      port: 9090
      scrape_interval: 30s
      tag: prom.metrics

      processors:
        metrics:
          - name: cumulative_to_delta
            drop_first: true

  outputs:
    - name: opentelemetry
      match: 'prom.metrics'
      host: otel-collector
      port: 4318
```
