# Fluent Typed Scripting (FTS)

The _Fluent Typed Scripting_ (FTS) processor runs telemetry policies written in Lua. Policies get typed access to each record and its context: integer widths, binary values, and nanosecond timestamps are preserved, and OpenTelemetry resources, scopes, and attributes are exposed as properties instead of raw metadata.

FTS supports logs, metrics, and traces. Its configuration name is `fts`.

| Signal  | Callback          | Called once per |
| ------- | ----------------- | --------------- |
| Logs    | `process(log)`    | Log record      |
| Metrics | `process(metric)` | Metric family   |
| Traces  | `process(span)`   | Span            |

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml.md) support processors.

{% endhint %}

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `call` | Name of the Lua callback function. | `process` |
| `code` | Inline Lua policy. Set either `script` or `code`. | _none_ |
| `error_mode` | Action to take on an item when its policy fails. `drop` removes the item, `keep` forwards the original item. | `drop` |
| `instruction_limit` | Maximum number of Lua instructions for each callback and during script load. The minimum value is `1000`. A value of `0` is allowed only when `jit` is `true`. | `1000000` |
| `jit` | Enable the LuaJIT compiler. Requires `instruction_limit` set to `0`. | `false` |
| `memory_limit` | Maximum memory for the policy, including the Lua heap and the typed values it holds. The minimum value is `262144` bytes. | `32M` |
| `output_limit` | Maximum serialized size of one processed batch. The minimum value is `65536` bytes. | `64M` |
| `script` | Path to the Lua policy file. Set either `script` or `code`. | _none_ |

Size suffixes are decimal. For example, `64K` is 64000 bytes.

Use one processor entry and one script for each signal type.

## Get started

The following example receives OpenTelemetry logs, drops health check requests, redacts sensitive keys, and adds attributes to logs that carry OpenTelemetry context.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: opentelemetry
      port: 4318

      processors:
        logs:
          - name: fts
            script: policy.lua

  outputs:
    - name: stdout
      match: '*'
      format: otlp_json
```

{% endtab %}
{% tab title="policy.lua" %}

```lua
local fb = require("fluentbit")

function process(log)
    if log.body:get_string("path") == "/health" then
        return fb.DROP
    end

    fb.redact(log.body, {"authorization", "password", "access_token"})

    if fb.is_otel(log) then
        log.resource.attributes:set("deployment.environment.name", "production")
        log.attributes:set("sanitized", true)
    end
end
```

{% endtab %}
{% endtabs %}

## Callback results

| Return value | Effect |
| ------------ | ------ |
| `fb.DROP` | Remove the item. |
| `nil` or `fb.KEEP` | Commit all changes made by the callback. |
| Lua error | Roll back every change made by the callback, then apply `error_mode`. |

Changes are transactional for each item. Edits to the body, metadata, timestamp, resource, and scope are committed or rolled back together.

For logs, if a processed batch exceeds `output_limit`, the whole batch is treated as failed: `drop` discards it and `keep` forwards the original batch. For metrics and traces, the limit is checked for each item. An item whose result doesn't fit follows `error_mode`, and the whole batch fails only when the kept original items don't fit either. Internal failures, such as a batch that can't be decoded, apply `error_mode` to the whole batch.

A batch is the set of records handed to one callback run. Small chunks are processed as one batch. Larger buffers, such as complete chunks reaching output processors, are processed in batches of about 64&nbsp;KiB or 1024 records, so decoded records never hold more than one batch in memory. Groups, such as one OpenTelemetry resource and scope, are never split across batches.

A group can also span appends, for example when its start and end markers arrive in separate forward messages. A group still open at the end of a batch stays open for the records that follow. Records that arrive before the end marker of a group opened earlier are processed without a context, keep their place in that group, and can't set one.

{% hint style="warning" %}

For privacy policies such as redaction, keep the default `error_mode` value of `drop`. With `keep`, an item whose policy fails is forwarded unmodified.

{% endhint %}

## Typed values

Bodies, attributes, and other structured fields are typed maps and arrays.

### Map and array methods

| Method | Applies to | Description |
| ------ | ---------- | ----------- |
| `v:append(value)` | Array | Append a value. |
| `v:copy()` | Any | Return an independent, writable copy. |
| `v:ensure_map(key)` | Map | Return the child map, creating it when missing. |
| `v:get(key)` | Map, array | Return the child value, or `nil` when missing. Array indexes start at `1`. |
| `v:get_bool(key)` | Map | Return the Boolean value, or `nil` when missing. |
| `v:get_number(key)` | Map | Return the numeric value as a Lua number, or `nil` when missing. |
| `v:get_string(key)` | Map | Return the string value, or `nil` when missing. Fails on another type. |
| `v:keys()` | Map | Return a Lua table with the keys in order. |
| `v:len()` | Map, array | Return the number of entries. |
| `v:number()` | Numeric | Return a Lua number. Fails when an integer is beyond ±(2^53 − 1). |
| `v:remove(key)` | Map | Remove every entry with that key. |
| `v:set(key, value)` | Map, array | Set a value. Replaces every entry with the same key. |
| `v:type()` | Any | Return `map`, `array`, `string`, `bytes`, `bool`, `int64`, `uint64`, `double`, or `null`. |
| `v:value()` | Scalar | Return the Lua value. 64-bit integers are returned as exact decimal strings. |

Keys match exact bytes. A dot in a key has no special meaning.

### Constructors

| Constructor | Creates |
| ----------- | ------- |
| `fb.array()` | Empty array. |
| `fb.bytes(s)` | Binary value. |
| `fb.int64(v)` | Signed 64-bit integer from a decimal string or a safe Lua integer. |
| `fb.map()` | Empty map. |
| `fb.null` | Null value. |
| `fb.uint64(v)` | Unsigned 64-bit integer from a decimal string or a safe Lua integer. |

Lua strings, Booleans, and numbers can be passed to `set` and `append` directly. Lua numbers are stored as doubles, so use `fb.int64` or `fb.uint64` for integers. Lua tables and `nil` aren't values. Use `fb.map()`, `fb.array()`, and `fb.null` instead.

### Value lifetime

Log values passed to a callback, and the views obtained from them, are valid only during that callback. Using one later raises an error. Metric and span values are snapshots made for the callback. They stay readable afterward, but changing them never affects later items or committed output, and keeping them retains their memory. To keep data between callbacks, store `v:copy()`. Copies are independent: changing them never changes a committed record.

Lua globals persist for the lifetime of the processor instance.

## Logs

| Property | Description |
| -------- | ----------- |
| `log.attributes` | OpenTelemetry log attributes. |
| `log.body` | Record body map. Can be replaced with another map. |
| `log.context.attributes`, `.metadata` | Group attributes and metadata of grouped logs that aren't OpenTelemetry logs. |
| `log.metadata` | Record metadata map. |
| `log.resource.attributes`, `.schema_url` | OpenTelemetry resource. |
| `log.scope.attributes`, `.name`, `.version`, `.schema_url` | OpenTelemetry instrumentation scope. |
| `log.tag` | Routing tag. Read-only. |
| `log.timestamp` | `{sec, nsec}` table. Assign a new table to change the event time. |

OpenTelemetry properties exist only for logs that carry OpenTelemetry context, such as logs received by the [OpenTelemetry](../inputs/opentelemetry.md) input. Use `fb.is_otel(log)` to check. To give other logs OpenTelemetry context, place the [OpenTelemetry envelope](opentelemetry-envelope.md) processor before FTS.

Resource, scope, and context changes apply only to the current record. Record order is preserved.

### Log helpers

| Helper | Description |
| ------ | ----------- |
| `fb.is_otel(log)` | Returns `true` when the log has OpenTelemetry context. |
| `fb.log_field(log, name)` | Read an OpenTelemetry log field such as `severity_number`, `trace_id`, or `observed_timestamp`. |
| `fb.set_severity(log, level)` | Set severity text and number from a level name: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, and common aliases. |
| `fb.set_trace_context(log, trace_hex, span_hex)` | Set the trace and span IDs from hexadecimal strings. IDs must be nonzero. |

### Parse an embedded JSON message

The following policy parses a JSON document stored in the `message` key, redacts sensitive keys, replaces the record body, and sets the severity and timestamp from the parsed values:

```lua
local fb = require("fluentbit")

function process(log)
    local text = log.body:get_string("message")
    if not text or not text:match("^%s*{") then
        return
    end

    local ok, app = pcall(fb.parse_json, text)
    if not ok then
        return fb.DROP
    end

    fb.redact(app, {"authorization", "password"})
    log.body = app

    if fb.is_otel(log) then
        local level = app:get_string("level")
        if level then
            fb.set_severity(log, level)
        end

        local time = app:get_string("time")
        if time then
            log.timestamp = fb.parse_time(time)
        end
    end
end
```

## Metrics

`process(metric)` runs once for each metric family. Resource and scope changes apply only to that family.

```lua
local fb = require("fluentbit")

function process(metric)
    if metric.name == "http.server.duration" then
        metric.name = "http.server.request.duration"
        fb.scale_metric(metric, 0.001, "s")
    end

    for i = 1, metric.datapoints:len() do
        metric.datapoints:get(i):get("attributes"):remove("request.id")
    end
end
```

| Property | Description |
| -------- | ----------- |
| `metric.aggregation_temporality` | `unspecified`, `delta`, or `cumulative`. |
| `metric.datapoints` | Array of data point maps. |
| `metric.is_monotonic` | Monotonicity of a sum. |
| `metric.name`, `.description`, `.unit` | Family identity. |
| `metric.resource`, `metric.scope` | Same properties as for logs. |
| `metric.type` | `gauge`, `sum`, `histogram`, `exponential_histogram`, or `summary`. Only gauge and sum can be converted into each other. |

Data point maps use OpenTelemetry field names in snake case, such as `attributes`, `time_unix_nano`, `start_time_unix_nano`, `as_int`, `as_double`, `count`, `sum`, `bucket_counts`, `explicit_bounds`, `quantile_values`, and `exemplars`. Timestamps and counts are exact integers. Histogram buckets are counts for each bucket.

Removing a data point attribute can make two series identical, which fails the policy. Use `fb.aggregate_metric` to combine them deliberately.

### Metric helpers

| Helper | Description |
| ------ | ----------- |
| `fb.aggregate_metric(metric, keys, op)` | Keep only the listed attributes and combine equal series. `op` is `sum`, or for gauges also `min`, `max`, `mean`, or `count`. |
| `fb.copy_metric(metric, name, description, unit)` | Emit a copy of the family with a new name. |
| `fb.extract_metric(metric, field, name, monotonic)` | Emit a sum derived from the `count`, `sum`, or `avg` of a histogram or summary. |
| `fb.merge_histogram_buckets(metric, bounds)` | Merge histogram buckets into a subset of the existing bounds. |
| `fb.metric_value(point)` | Return the scalar value of a gauge or sum data point. |
| `fb.scale_metric(metric, factor, unit)` | Multiply values by a positive factor and optionally set the unit. Applies to gauges, sums, histograms, and summaries, including bounds and exemplars. |
| `fb.set_metric_value(point, value)` | Set the scalar value of a data point. |

Emitted families follow the original family and continue through the pipeline. They aren't passed to the callback again. Returning `fb.DROP` removes the original family and keeps the emitted families. An error discards both.

Scalar values use the OpenTelemetry `int64` and `double` types. Native unsigned 64-bit values up to 2^63 − 1 are passed to the policy as `int64`. Families with larger values aren't passed to the policy, and `error_mode` decides whether they're kept unchanged or dropped. With `keep`, if such a family has the same name as a family the policy produces, the batch fails so the original families are forwarded instead of being merged.

## Traces

`process(span)` runs once for each span. Resource and scope changes apply only to that span.

```lua
local fb = require("fluentbit")

function process(span)
    if span.attributes:get_string("http.route") == "/health" then
        return fb.DROP
    end

    fb.redact(span.attributes, {"authorization", "password"})
    fb.redact(span.events, {"authorization", "password"})
end
```

| Property | Description |
| -------- | ----------- |
| `span.attributes` | Attribute map. |
| `span.dropped_attributes_count`, `.dropped_events_count`, `.dropped_links_count` | Dropped counts. |
| `span.events`, `span.links` | Arrays of event and link maps. |
| `span.name`, `.trace_state`, `.kind`, `.flags` | Span fields. `kind` is the numeric OpenTelemetry span kind. |
| `span.resource`, `span.scope` | Same properties as for logs. |
| `span.start_time_unix_nano`, `.end_time_unix_nano` | Exact nanosecond timestamps. The end must not precede the start. |
| `span.status` | Map with `code` and `message`. |
| `span.trace_id`, `.span_id`, `.parent_span_id` | Hexadecimal IDs. An empty parent ID marks a root span. |

Dropping spans or changing IDs can break the parent and child relationships between spans. FTS doesn't repair parent references.

## Common helpers

| Helper | Description |
| ------ | ----------- |
| `fb.keep_keys(map, keys)` | Remove every key not listed. |
| `fb.parse_json(text)` | Parse a JSON document into typed values. Integer widths are preserved. Duplicate keys and nesting beyond 64 levels are rejected. Input is limited to 1&nbsp;MiB. |
| `fb.parse_time(text)` | Parse an RFC 3339 timestamp into `{sec, nsec}`. |
| `fb.redact(value, keys, replacement)` | Replace the values of matching keys in nested maps and arrays. Key matching is case-insensitive. The default replacement is `[REDACTED]`. |

Key-based redaction doesn't inspect free-form strings. Secrets embedded in message text need an explicit string policy.

## Limits and sandbox

- Values can have at most 64 levels of nesting.
- OpenTelemetry strings and keys must be valid UTF-8 without null (`\0`) characters. Use `fb.bytes` for binary data.
- Only `require("fluentbit")` is available. The file system, process, foreign function interface (FFI), debug, coroutine, and module loading libraries are disabled, as are `print`, `xpcall`, `getfenv`, `setfenv`, and `module`. `collectgarbage` accepts only `collect`, `count`, and `step`.
- The instruction limit counts Lua instructions, not elapsed time. Lua string pattern functions run in C and aren't interrupted, so avoid unbounded patterns on untrusted input.
- With `jit` set to `true` there is no CPU limit. Use it only for policies whose execution time you control.
- The sandbox isn't a security boundary. Treat policies as trusted configuration.
- Each processor instance has its own Lua state.

## Diagnostics

Each batch logs at most five policy errors plus a summary count. The processor error metric counts batches with handled policy failures, and the drop metrics count removed records.

## Build requirements

FTS is enabled by default with the `FLB_PROCESSOR_FTS` build option. It's built only when LuaJIT (`FLB_LUAJIT`) and the bundled JSON parser (`FLB_YYJSON`) are also enabled.
