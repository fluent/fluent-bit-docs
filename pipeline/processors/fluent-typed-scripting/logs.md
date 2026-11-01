# Logs

The callback `process(log)` runs once per log record. An implicit return or `fb.KEEP` commits edits; `fb.DROP` removes the record. See [Errors and limits](errors-and-limits.md) for rollback behavior.

## Log properties

| Property | Description |
| --- | --- |
| `log.body` | Typed body map. Can be replaced with another typed map. |
| `log.metadata` | Typed record metadata map. Mutate its entries; don't replace the root. |
| `log.timestamp` | Lua table with `sec` and `nsec`. Assign a new table to change event time. |
| `log.tag` | Read-only routing tag. |
| `log.attributes` | Typed OpenTelemetry log attribute map, when OpenTelemetry context is present. |
| `log.resource.attributes`, `log.resource.schema_url` | OpenTelemetry resource attributes and schema URL. |
| `log.scope.attributes`, `log.scope.name`, `log.scope.version`, `log.scope.schema_url` | OpenTelemetry instrumentation scope. |
| `log.context.attributes`, `log.context.metadata` | Typed group maps for grouped logs, including non-OpenTelemetry groups. |

Use `set` and `remove` on attributes. Don't replace context roots or OpenTelemetry aliases, change the transport schema, or edit transport resource and scope identifiers. Use semantic properties to change resource and scope data.

## Event time and metadata

Change event time through `log.timestamp`, not the raw OpenTelemetry timestamp metadata. Seconds must be in the log event range, `0` through `4294967293` on platforms with 64-bit `time_t` (`2147483647` with 32-bit `time_t`); nanoseconds must be `0` through `999999999`. For example:

```lua
local fb = require("fluentbit")

function process(log)
    local time = log.body:get("time")
    if time and time:type() == "string" then
        local ok = pcall(function()
            log.timestamp = fb.parse_time(time:value())
        end)
        if not ok then
            log.metadata:set("invalid_time", true)
        end
    end
    log.metadata:set("policy", "normalize-time")
end
```

A record whose `time` field is missing, isn't a string, or can't be parsed keeps its original event time. The policy flags unparsable values in metadata instead of failing the callback, because an uncaught error from `fb.parse_time` would apply `error_mode` and, with the default `drop`, remove the record.

For OpenTelemetry logs, changing `log.timestamp` also updates the event timestamp metadata. `observed_timestamp` is a separate field and isn't changed by this assignment.

## OpenTelemetry context

Use `fb.is_otel(log)` before reading or editing OpenTelemetry properties. Logs from the [OpenTelemetry input](../../inputs/opentelemetry.md) can carry this context. For ordinary logs, place the [OpenTelemetry envelope](../opentelemetry-envelope.md) processor before Fluent Typed Scripting (FTS) under `processors.logs`.

```lua
local fb = require("fluentbit")

function process(log)
    if fb.is_otel(log) then
        log.resource.attributes:set("deployment.environment.name", "production")
        log.scope.name = "application-policy"
        log.attributes:set("sanitized", true)
        fb.set_severity(log, "info")
    end
end
```

Resource, scope, and group context edits apply only to the current record. Record order is preserved. A group that spans input appends can remain open across batches. Records received inside a group opened in an earlier batch have no context view and can't set one; guard access instead of assuming every grouped record has editable context.

## Log helpers

| Helper | Description |
| --- | --- |
| `fb.is_otel(log)` | Whether the log carries OpenTelemetry context. |
| `fb.attributes(log)` | The OpenTelemetry log attribute map; requires OpenTelemetry context. Equivalent to `log.attributes`. |
| `fb.set_severity(log, level)` | Set severity text and number. Accepts case-insensitive `trace` (1), `debug` (5), `info` (9), `warn` (13), `error` (17), and `fatal` (21). Also accepts `information`, `informational`, `warning`, and `critical`. Preserves the supplied text. |
| `fb.set_trace_context(log, trace_hex, span_hex)` | Set correlation IDs. Trace ID must have 32 hexadecimal characters and span ID 16; neither can be all zero. |
| `fb.log_field(log, name)` | Read an OpenTelemetry field as a typed value, or `nil` if absent. Requires OpenTelemetry context. |

Use `log_field` for fields such as `severity_number`, `severity_text`, `trace_id`, `span_id`, `trace_flags`, `timestamp`, `observed_timestamp`, and `event_name`. IDs read this way are typed bytes; `value()` returns binary data, not hexadecimal text.

```lua
fb.set_trace_context(log,
    "0102030405060708090a0b0c0d0e0f10", "0102030405060708")
local severity = fb.log_field(log, "severity_number")
if severity and severity:number() >= 17 then
    log.attributes:set("needs_review", true)
end
```

This fragment belongs in an OpenTelemetry log callback. See [Common helpers](common-helpers.md) for JSON parsing, redaction, and time parsing, and [Recipes](recipes.md#redact-logs) for a complete pipeline.
