# Fluent Typed Scripting (FTS) and the Lua filter

Fluent Typed Scripting (FTS) and the [Lua filter](../../filters/lua.md) both run Lua policies, but expose different APIs. FTS means typed access to telemetry; it doesn't add static typing to Lua.

| Requirement | FTS | Lua filter |
| --- | --- | --- |
| Signals | Logs, metrics, and traces, with a separate processor entry and script for each signal. | Logs. |
| Placement | Processor attached to an input or output, configured in YAML. | Filter with tag matching, or a [filter used as a processor](../filters.md). Classic and YAML filter configuration are supported. |
| Value model | Typed maps, arrays, null, bytes, and exact integer values. | Lua tables and values, with options such as `type_int_key`, `type_array_key`, and `enable_flb_null`. |
| Timestamp precision | Log `{sec, nsec}` table; exact typed nanoseconds in metric and span fields. | `time_as_table` option for log `{sec, nsec}` precision. |
| OpenTelemetry log context | Semantic resource, scope, and log attribute properties. | Extended callback supports group metadata and record metadata. |
| Callback result | Mutate an item; return nothing, `fb.KEEP`, or `fb.DROP`. | Return status code, timestamp, and record; extended callback also returns metadata. |
| Splitting a log into multiple records | No log emission API. | Supported by returning an array of records. |
| Metric transformations | Family/datapoint edits, aggregation, copies, and derived metrics. | Not supported. |
| Span transformations | Span, event, link, resource, and scope edits. | Not supported. |
| Failure handling | Per-item rollback and `error_mode`, plus batch failure rules. | `protected_mode` catches script exceptions. |
| Runtime access | Restricted libraries; instruction, policy memory, and serialized output budgets. | Existing Lua runtime and filter configuration model; doesn't expose the FTS budgets. |

Choose FTS when preserving telemetry types, working with metric families or spans, or using its rollback and limits is central to your policy. Keep the Lua filter when you need log splitting, classic configuration, or compatibility with an established filter script. Both can work with OpenTelemetry log metadata; this capability alone isn't a reason to migrate.

## Migrate a policy

1. Replace the filter callback signature with `process(log)`, `process(metric)`, or `process(span)`.
2. Replace Lua-table field access with typed methods, for example `log.body:get_string("message")` and `log.body:set("message", text)`.
3. Replace numeric filter status codes with the FTS callback results. An implicit return commits edits.
4. Use integer, bytes, null, map, and array constructors where needed.
5. Review module dependencies against [Runtime restrictions](errors-and-limits.md#runtime-restrictions).
6. Test the success and failure paths, especially `error_mode: keep` for policies that remove sensitive data.

There is no automatic script compatibility. Start with the [quickstart](quickstart.md) and use the [signal references](../fluent-typed-scripting.md#get-started-and-reference) for the destination API.
