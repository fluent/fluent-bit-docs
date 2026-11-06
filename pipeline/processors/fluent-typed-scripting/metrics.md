# Metrics

The callback `process(metric)` runs once per metric family, including all its data points. An implicit return or `fb.KEEP` commits edits; `fb.DROP` removes the original family. Resource and scope edits apply only to that family.

## Metric properties

| Property | Description |
| --- | --- |
| `metric.name`, `metric.description`, `metric.unit` | Family name, description, and unit strings. Changing the unit alone doesn't scale values. |
| `metric.type` | `gauge`, `sum`, `histogram`, `exponential_histogram`, or `summary`. Only gauge and sum can be converted into each other by assignment. |
| `metric.datapoints` | Typed array of datapoint maps. Can be replaced with another typed array. |
| `metric.aggregation_temporality` | `unspecified`, `delta`, or `cumulative`. Not applicable to gauge or summary. |
| `metric.is_monotonic` | Boolean, applicable only to sums. |
| `metric.resource.attributes`, `metric.resource.schema_url` | Resource context. |
| `metric.scope.attributes`, `metric.scope.name`, `metric.scope.version`, `metric.scope.schema_url` | Instrumentation scope context. |
| `metric.tag` | Read-only routing tag. |

Converting a gauge to a sum initializes cumulative temporality and `is_monotonic: false`. Choose temporality and monotonicity deliberately; a type change doesn't calculate deltas or reconstruct counter history. Negative edited values aren't valid for a monotonic sum.

## Data points

Datapoint maps use OpenTelemetry field names in snake case. Use typed methods to read and edit them.

| Fields | Meaning |
| --- | --- |
| `attributes` | Typed map identifying the series. |
| `time_unix_nano`, `start_time_unix_nano` | Exact nonnegative integer timestamps. An edited end time must not precede the start time. |
| `as_int`, `as_double` | Scalar gauge or sum value; exactly one must be present. |
| `count`, `sum`, `min`, `max` | Distribution fields where supported. Counts use exact integers. |
| `bucket_counts`, `explicit_bounds` | Explicit histogram arrays. Counts are per bucket, not cumulative; there must be one more count than bound, and counts must total `count`. |
| `scale`, `zero_count`, `zero_threshold`, `positive`, `negative` | Exponential histogram fields. Positive and negative bucket maps contain `offset` and `bucket_counts`. |
| `quantile_values` | Summary array of maps with `quantile` and `value`. |
| `exemplars`, `flags` | Exemplars and datapoint flags where supported by the metric type. |

Explicit histogram data points in a family must have matching layouts. Summary data points must have matching quantile layouts. Edited histogram bounds must increase; edited summary quantiles must increase within `0..1`. Exponential histograms allow at most 65,535 buckets on each side and edited scale values from −10 through 20. Invalid edits fail the policy.

Scalar metric values use OpenTelemetry int64 and double types. Native unsigned values up to 9223372036854775807 are exposed as int64. A family containing larger native unsigned values isn't passed to the callback: `error_mode` determines whether to retain or drop it.

## Units and scaling

Use `fb.scale_metric` to change both values and units. For example, convert milliseconds to seconds:

```lua
local fb = require("fluentbit")

function process(metric)
    if metric.name == "http.server.duration" then
        metric.name = "http.server.request.duration"
        fb.scale_metric(metric, 0.001, "s")
    end
end
```

Scaling uses Lua numbers and can fail when an integer is outside the safe conversion range. It supports gauge, sum, explicit histogram, and summary families, including bounds, quantile values, and exemplars where applicable. It rejects exponential histograms because scaling requires bucket remapping.

## Series collisions and aggregation

Removing an attribute can make previously distinct series identical within a time window. Fluent Typed Scripting (FTS) rejects edits that create duplicate series/windows. Don't rely on implicit overwrite or combination.

Use `fb.aggregate_metric` to keep selected attributes and deliberately combine matching data points:

```lua
local fb = require("fluentbit")

function process(metric)
    if metric.name == "http.requests" and metric.type == "sum" then
        fb.aggregate_metric(metric, {"service.name", "http.request.method"}, "sum")
    end
end
```

Aggregation happens within the current family and callback. It doesn't combine families, batches, resources, scopes, or different start/end timestamp pairs. Within a group, flags must match. Histogram layouts must match. Integer addition checks for overflow. This is dimension aggregation, not a time-window store.

## Metric helpers

| Helper | Description |
| --- | --- |
| `fb.metric_value(point)` | Typed `as_int` or `as_double` value, or `nil` if neither exists. |
| `fb.set_metric_value(point, value)` | Set the scalar value and remove the other scalar representation. Accepts a finite Lua number or typed numeric value; OpenTelemetry range validation still applies. |
| `fb.scale_metric(metric, factor, unit)` | Multiply supported values by a finite positive factor; optionally set the unit. |
| `fb.aggregate_metric(metric, keys, op, max_exemplars)` | Keep only the keys in the Lua table and combine equal series/windows. Default `op`: `sum`. Supports gauge, sum, and explicit histogram. Gauge also supports `min`, `max`, `mean`, and `count`; `count` changes the unit to `1`. Optional `max_exemplars`, an integer from `0` through `128`, keeps at most that many exemplars per combined point, in input order. When omitted, all exemplars are kept. Kept exemplars retain their attributes, even for dropped keys. |
| `fb.merge_histogram_buckets(metric, bounds)` | Merge explicit histogram buckets. Bounds must be an increasing subset of existing bounds; accepts a Lua table or typed array. |
| `fb.copy_metric(metric, name, description, unit)` | Emit an independent copy. Optional arguments replace identity fields. Returns the emitted family for further edits. |
| `fb.extract_metric(metric, field, name, monotonic)` | Emit a derived family from a histogram, exponential histogram, or summary. `field` is `count`, `sum`, or `avg`; optional `name` defaults to the original name plus `.` and the field. Returns the family, or `nil` if no data points qualify. |

`extract_metric` emits a sum for `count` or `sum`, and a gauge for `avg`. Count uses unit `1` and defaults to monotonic; extracted sum defaults to non-monotonic. The optional `monotonic` argument applies to count and sum. Average uses sum/count and omits zero-count points. It doesn't average summary quantiles. Numeric conversions can fail for large integers.

Emitted families follow the original through subsequent pipeline stages and aren't passed to this callback again. Returning `fb.DROP` removes the original but retains emissions. An error rolls back the original and discards emissions. See [Errors and limits](errors-and-limits.md) and the complete [metric recipe](recipes.md#normalize-and-aggregate-metrics).
