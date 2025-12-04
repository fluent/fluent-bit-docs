# TDA

The `tda` processor applies **Topological Data Analysis (TDA)** – specifically, **persistent homology** – to Fluent Bit’s metrics stream and exports **Betti numbers** that summarize the shape of recent behavior in metric space.

This processor is intended for detecting **phase transitions**, **regime changes**, and **intermittent instabilities** that are hard to see from individual counters, gauges, or standard statistical aggregates. It can, for example, differentiate between a single, one-off failure and an extended period of intermittent failures where the system never settles into a stable regime.

Currently, `tda` works only in the **metrics pipeline** (`processors.metrics`).

---

## Configuration parameters

The `tda` processor supports the following configuration parameters:

| Key           | Description                                                                                                                                                                                          | Default |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `window_size` | Number of samples to keep in the TDA sliding window. This controls how far back in time the topology is estimated.                                                                                   | `60`    |
| `min_points`  | Minimum number of samples required in the window before running TDA. Until this limit is reached, no Betti metrics are emitted.                                                                      | `10`    |
| `embed_dim`   | Delay embedding dimension `m`. `m = 1` disables embedding (original behavior). For example, `m = 3` reconstructs state vectors `(x_t, x_{t-τ}, x_{t-2τ})` as suggested by Takens’ theorem.           | `3`     |
| `embed_delay` | Delay `τ` in samples between successive lags used in delay embedding.                                                                                                                                | `1`     |
| `threshold`   | Distance scale selector. `0` enables an automatic **multi-quantile scan** across several candidate thresholds; a value in `(0, 1)` is interpreted as a single quantile used to pick the Rips radius. | `0`     |

All parameters are optional; defaults are suitable as a starting point for many workloads.

---

## How it works

### 1. Metric aggregation and normalization

On each metrics flush, `tda`:

1. **Groups metrics by `(namespace, subsystem)`**
   All counters, gauges, and untyped metrics are traversed. For each `cmt_map`, the pair `(ns, subsystem)` is hashed and assigned a **feature index**. This produces a fixed-dimensional feature vector of length `feature_dim` (number of `(ns, subsystem)` groups).

2. **Aggregates values per group**
   For each group, all static and labeled metrics are summed into the corresponding feature dimension.

3. **Converts counters to approximate rates**
   The processor keeps the previous raw snapshot `last_vec` and timestamp `last_ts`. For each dimension:

   * `diff = now_raw - prev_raw`
   * `dt_sec = (ts_now - ts_prev) / 1e9`
   * `rate = diff / dt_sec`
     A safeguard ensures `dt_sec > 0`.

4. **Applies signed `log1p` normalization**
   To stabilize very different magnitudes and bursty traffic, each rate is mapped to
   `norm = log1p(|rate|)`, and the sign of `rate` is reattached. This yields a vector that is roughly scale-invariant but still sensitive to relative changes in rates across groups.

The resulting normalized vector is written into a **ring buffer window** (`tda_window`), implemented via a lightweight circular buffer (`lwrb`) that stores timestamped samples. The window maintains at most `window_size` samples; older samples are dropped when the buffer is full.

### 2. Sliding window and delay embedding

Let the ring buffer contain `n_raw` samples and the feature dimension be `D = feature_dim`. To capture temporal structure, `tda` supports an optional **delay embedding**:

* Embedding dimension: `m = embed_dim` (forced to `1` if `embed_dim <= 0`)
* Lag (in integer samples): `τ = embed_delay` (ignored when `m = 1`)

For each valid time index `t`, a reconstructed state vector is built as:

$$
x_t ;\to; (x_t,; x_{t-\tau},; \dots,; x_{t-(m-1)\tau})
$$

where each `x_·` is the **D-dimensional normalized metrics vector** at that time. This yields embedded points in (\mathbb{R}^{mD}).

Because we need all lags to be inside the window, the number of embedded points is:

$$
n_{\text{embed}} = n_{\text{raw}} - (m - 1)\tau
$$

If `n_raw < (m − 1)τ + 1`, TDA is skipped until enough data has accumulated.

This embedding follows the idea of **Takens’ theorem**, which states that, under mild conditions, the dynamics of a system can be reconstructed from delay-embedded observations of a single time series or a low-dimensional observable [2]. In this plugin, the observable is the multi-dimensional vector of aggregated metrics.

Intuitively:

* `embed_dim = 1`: you see only the current “snapshot” geometry.
* `embed_dim > 1`: you expose **loops and recurrent trajectories** in the joint evolution of metrics, which later show up as **H₁ (Betti₁) features**.

### 3. Distance matrix construction

For the embedded points $ x_i \in \mathbb{R}^{mD} $ (`i = 0..n_embed-1`), `tda` builds a **dense Euclidean distance matrix**:

$$
d(i, j) = \left| x_i - x_j \right|_2
$$

The implementation iterates over all pairs `(i, j)` with `i > j`, accumulates squared differences across both feature dimensions and lags, and then takes the square root; the matrix is stored symmetrically with zeros on the diagonal.

### 4. Threshold selection (Rips scale)

Persistent homology requires a **scale parameter** (Rips radius / distance threshold). The plugin supports two modes:

1. **Automatic multi-quantile scan** (`threshold = 0`, default)

   * The off-diagonal distances are collected, sorted, and several quantiles are evaluated, e.g. `q ∈ {0.10, 0.20, …, 0.90}`.
   * For each candidate quantile `q`, a threshold `r_q` is chosen and Betti numbers are computed using Ripser.
   * The plugin prefers the scale where **Betti₁** (loops) is maximized; if all Betti₁ are zero, it falls back to Betti₀ as a secondary indicator.

2. **Fixed quantile mode** (`0 < threshold < 1`)

   * `threshold` is interpreted as a single quantile `q`. The Rips radius is set at this quantile of all pairwise distances.
   * The multi-quantile scan still runs internally for robustness, but reported diagnostics (e.g., debug logs) will reflect the user-selected quantile.

Internally, quantile selection is handled by `tda_choose_threshold_from_dist`, which gathers all `i > j` entries of the distance matrix, sorts them, and picks the specified quantile index.

### 5. Persistent homology via Ripser

Once the compressed lower-triangular distance matrix is built, it is passed to a thin wrapper around **Ripser**, a well-known implementation of Vietoris–Rips persistent homology:

1. **Compression and C API**

   * The dense `n_embed × n_embed` matrix is converted into Ripser’s `compressed_lower_distance_matrix`.
   * The wrapper function `flb_ripser_compute_betti_from_dense_distance` runs Ripser up to `max_dim = 2` (H₀, H₁, H₂), using coefficients in (\mathbb{Z}/2\mathbb{Z}), and accumulates persistence intervals into Betti numbers with a small persistence cutoff to ignore very short-lived noise features.

2. **Interval aggregation**

   * A callback (`interval_recorder`) receives all persistence intervals ((\text{birth}, \text{death})) from Ripser.
   * Intervals with very small persistence are filtered out, and the remaining ones are counted per homology dimension to form Betti numbers.

3. **Multi-scale selection**

   * For each candidate threshold, Betti numbers are computed.
   * The “best” scale is chosen as the one with the largest Betti₁ (loops); if Betti₁ is zero across scales, the plugin picks the scale where Betti₀ is largest.
   * The corresponding Betti₀, Betti₁, and Betti₂ values are then exported as Fluent Bit gauges.

### 6. Exported metrics

`tda` creates (lazily) three gauge metrics in the `fluentbit_tda_*` namespace:

| Metric name            | Type  | Description                                                                                                                                                                                                                                      |
| ---------------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `fluentbit_tda_betti0` | gauge | Approximate Betti₀ – number of connected components (clusters) in the embedded point cloud at the selected scale. Large values indicate fragmentation into many “micro-regimes”.                                                                 |
| `fluentbit_tda_betti1` | gauge | Approximate Betti₁ – number of 1-dimensional loops / cycles in the Rips complex. Non-zero values often signal **recurrent, quasi-periodic, or cycling behavior**, typical of intermittent failure / recovery patterns and other regime switches. |
| `fluentbit_tda_betti2` | gauge | Approximate Betti₂ – number of 2-dimensional voids (higher-order structures). These can appear when the system explores different “surfaces” in state space, e.g., transitioning between distinct operating modes.                               |

Each metric is timestamped with the current time at the moment of TDA computation and is exported via the same metrics context it received, so downstream metric outputs can scrape or forward them like any other Fluent Bit metric.

---

## Interpreting Betti numbers

Topologically, Betti numbers count the number of “holes” of each dimension in a space:

* **Betti₀** – connected components (0-dimensional clusters).
* **Betti₁** – 1-dimensional holes (loops / cycles).
* **Betti₂** – 2-dimensional voids, and so on.

In our context:

* The sliding window of metrics is a **point cloud in phase space**.
* The Rips complex at a given scale connects points that are close in this space.
* Betti numbers summarize the topology of this complex.

Some practical patterns:

1. **Stable regime**

   * Metrics fluctuate near a single attractor.
   * Betti₀ is small (often close to 1–few), Betti₁ and Betti₂ are typically `0` or very small.

2. **Single, one-off failure**

   * A brief outage or spike happens once and resolves.
   * The embedding sees a short excursion but no sustained cycling, so Betti₁ and Betti₂ often remain near `0`.
   * In the provided HTTP example, a single failing chunk does not significantly raise Betti₁/₂.

3. **Intermittent failure / unstable regime**

   * The system repeatedly bounces between “healthy” and “unhealthy” states (e.g., repeated `Connection refused` / `broken connection` errors interspersed with 200 responses).
   * The trajectory in phase space forms **loops**: metrics move away from the healthy region and then return, many times.
   * Betti₁ (and occasionally Betti₂) increases noticeably while this behavior persists, reflecting the emergence of non-trivial cycles in the metric dynamics.

   In the sample output, as the HTTP output oscillates between success and various `Connection refused` / `broken connection` errors, `fluentbit_tda_betti1` and `fluentbit_tda_betti2` grow from small values to larger plateaus (e.g., Betti₁ around 10–13, Betti₂ around 1–2) while Betti₀ also increases. This is a direct signature of a **phase transition** from a stable regime to one with persistent, intermittent instability.

These interpretations are consistent with results from condensed matter physics and dynamical systems, where persistent homology has been used to detect phase transitions and changes in underlying order purely from data [1][2].

---

## Configuration examples

### Basic setup with `fluentbit_metrics`

The following example computes TDA on Fluent Bit’s own internal metrics, using `metrics_selector` to remove a few high-cardinality or uninteresting metrics before feeding them into `tda`:

```yaml
service:
  http_server: On
  http_port: 2021

pipeline:
  inputs:
    - name: dummy
      tag: log.raw
      samples: 10000

    - name: fluentbit_metrics
      tag: metrics.raw

      processors:
        metrics:
          # Optionally exclude metrics you don't want in the TDA feature vector
          - name: metrics_selector
            metric_name: /process_start_time_seconds/
            action: exclude

          - name: metrics_selector
            metric_name: /build_info/
            action: exclude

          # Perform TDA on the remaining metrics
          - name: tda
            # window_size: 60      # optional tuning
            # min_points: 10
            # embed_dim: 3
            # embed_delay: 1
            # threshold: 0        # auto multi-quantile scan

  outputs:
    - name: stdout
      match: '*'
```

With this configuration, you will see time series like:

```text
fluentbit_tda_betti0 = 39
fluentbit_tda_betti1 = 7
fluentbit_tda_betti2 = 0
...
fluentbit_tda_betti0 = 56
fluentbit_tda_betti1 = 13
fluentbit_tda_betti2 = 2
```

These Betti metrics can be scraped by Prometheus, forwarded to an observability backend, and used in alerts (for example, triggering on sudden increases in `fluentbit_tda_betti1` as a signal of emerging instability in the pipeline).

### Emphasizing short-term cycles with delay embedding

To focus on shorter-term cyclic behavior—for example, oscillations in retry logic and error counters—you can lower `window_size` and adjust the embedding parameters:

```yaml
processors:
  metrics:
    - name: tda
      window_size: 30      # shorter temporal horizon
      min_points: 15       # require at least half the window
      embed_dim: 4         # look at 4 successive states
      embed_delay: 1       # each lag = 1 metrics interval
      threshold: 0.2       # use 20th percentile of distances
```

This configuration reconstructs the system in an effective dimension of `4 × feature_dim` and tends to highlight tight loops that occur within roughly 4–10 sampling intervals.

---

## When to use `tda`

`tda` is particularly useful when:

* You suspect **non-linear or multi-modal behavior** in your system (e.g., on/off regimes, congestion collapse, periodic retries).
* Standard indicators (mean, percentiles, error rates) show “noise,” but you want to know whether that noise hides **coherent structure**.
* You want to build alerts not just on “levels” of metrics, but on **changes in the topology** of system behavior – for example:

  * “Raise an alert if Betti₁ remains above 5 for more than 5 minutes.”
  * “Mark windows where Betti₂ becomes non-zero as potential phase transitions.”

Because the plugin operates on an arbitrary selection of metrics (chosen upstream via `metrics_selector` or by how you configure `fluentbit_metrics`), you can tailor the TDA to focus on:

* Network health (latency histograms, connection failures, TLS handshake errors),
* Resource saturation (CPU, memory, buffer usage),
* Pipeline-level signals (retries, DLQ usage, chunk failures),
* Or any other metric subset that meaningfully characterizes the state of your system.

---

## References

1. I. Donato, M. Gori, A. Sarti, “Persistent homology analysis of phase transitions,” *Physical Review E*, 93, 052138, 2016.
2. F. Takens, “Detecting strange attractors in turbulence,” in D. Rand and L.-S. Young (eds.), *Dynamical Systems and Turbulence*, Lecture Notes in Mathematics, vol. 898, Springer, 1981, pp. 366–381.
