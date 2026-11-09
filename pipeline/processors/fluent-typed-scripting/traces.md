# Traces

The callback `process(span)` runs once per span. An implicit return or `fb.KEEP` commits edits; `fb.DROP` removes the span. Resource and scope edits apply only to the current span.

## Span properties

| Property | Description |
| --- | --- |
| `span.name`, `span.trace_state` | Span name and trace state strings. |
| `span.kind` | Numeric OpenTelemetry kind: 0 unspecified, 1 internal, 2 server, 3 client, 4 producer, 5 consumer. |
| `span.flags` | Numeric span flags. |
| `span.trace_id`, `span.span_id`, `span.parent_span_id` | Hexadecimal ID strings. Trace ID has 32 characters, span and parent IDs have 16. An empty parent ID marks a root span. Nonempty IDs must be nonzero. |
| `span.start_time_unix_nano`, `span.end_time_unix_nano` | Typed exact integer timestamps. Assign integer typed values; an edited end time must not precede the start. |
| `span.attributes` | Typed attribute map. |
| `span.status` | Typed map containing integer `code` and string `message`. Codes: 0 unset, 1 OK, 2 error. |
| `span.events`, `span.links` | Typed arrays of event and link maps. |
| `span.dropped_attributes_count`, `span.dropped_events_count`, `span.dropped_links_count` | Numeric dropped counts. |
| `span.resource.attributes`, `span.resource.schema_url` | Resource context. |
| `span.scope.attributes`, `span.scope.name`, `span.scope.version`, `span.scope.schema_url` | Instrumentation scope context. |
| `span.tag` | Read-only routing tag. |

Update attributes through `set` and `remove`. For status codes, use an integer constructor:

```lua
local fb = require("fluentbit")

function process(span)
    if span.attributes:get_bool("application.failed") == true then
        span.status:set("code", fb.int64(2))
        span.status:set("message", "application failure")
    end
end
```

## Events and links

Event maps contain `name`, `time_unix_nano`, `attributes`, and `dropped_attributes_count`. Link maps contain `trace_id`, `span_id`, `trace_state`, `attributes`, `dropped_attributes_count`, and `flags`.

Unlike the top-level span ID properties, IDs inside typed link maps are bytes. Use `fb.bytes` containing 16 bytes for a trace ID and 8 bytes for a span ID, not hexadecimal text. Each event and link must have an attribute map. Event times must be nonnegative integers.

The following callback redacts nested structured attributes and adds an event:

```lua
local fb = require("fluentbit")

function process(span)
    fb.redact(span.attributes, {"authorization", "password"})
    fb.redact(span.events, {"authorization", "password"})
    fb.redact(span.links, {"authorization", "password"})

    local event = fb.map()
    event:set("name", "policy.applied")
    event:set("time_unix_nano", span.end_time_unix_nano)
    event:set("attributes", fb.map())
    event:set("dropped_attributes_count", fb.uint64(0))
    span.events:append(event)
end
```

Redaction matches keys; it doesn't inspect event names, status messages, or other free-form text. Removing an event or link requires building a replacement array. Set dropped counts deliberately if your policy needs to account for removals; don't assume an array edit updates them.

## Trace topology

Dropping a span doesn't drop its children or the whole trace. Changing a trace ID, span ID, or parent ID doesn't update other spans or links. These changes can create orphaned spans or split a trace. Fluent Typed Scripting (FTS) doesn't repair parent references or perform trace-wide transactions.

Prefer attribute and name normalization when that meets your goal. If you change identifiers or drop spans, define how downstream consumers should interpret the resulting trace structure. See [Recipes](recipes.md#transform-spans) for a complete example that preserves identifiers.
