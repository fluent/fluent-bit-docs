# Common helpers

Load the Fluent Typed Scripting (FTS) module with `local fb = require("fluentbit")`. The following helpers operate on typed values. For signal-specific helpers, see [Logs](logs.md#log-helpers) and [Metrics](metrics.md#metric-helpers). See [Typed values](typed-values.md#constructors-and-conversions) for constructors.

## Redact structured fields

`fb.redact(value, keys, replacement)` recursively replaces values of matching keys in nested maps and arrays. `keys` is a Lua table of key names. Matching is case-insensitive. The default replacement is `[REDACTED]`.

```lua
fb.redact(log.body, {"authorization", "password", "access_token"})
```

For a custom replacement:

```lua
fb.redact(log.body, {"password"}, "removed")
```

This helper doesn't search inside strings. It won't remove a password embedded in `message: "password=example-secret"`. Write and test a separate string policy for known text formats, or remove the text field when appropriate. Keep `error_mode: drop` for redaction policies when forwarding an unmodified failed item would expose sensitive data.

## Keep selected keys

`fb.keep_keys(map, keys)` removes every key not listed in the Lua table `keys`. Matching is case-sensitive. This helper acts on the supplied map only; it isn't recursive.

```lua
fb.keep_keys(log.body, {"message", "level", "service.name"})
```

## Parse JSON

`fb.parse_json(text)` returns a typed value, preserving integer widths. Input is limited to 1 MiB and nesting to 64 levels. Duplicate keys and invalid JSON raise errors. A valid JSON document can produce a scalar or array, so check the result before assigning a log body.

```lua
local text = log.body:get_string("message")
if text then
    local ok, parsed = pcall(fb.parse_json, text)
    if ok and parsed:type() == "map" then
        log.body = parsed
    else
        return fb.DROP
    end
end
```

This fragment belongs in `process(log)` with `fb` loaded. Catching a parse error with `pcall` lets the policy choose a result; it doesn't roll back earlier edits automatically. An uncaught error invokes the processor's rollback and `error_mode` behavior.

## Parse time

`fb.parse_time(text)` parses RFC 3339 text and returns a Lua table `{sec, nsec}` for `log.timestamp`. It accepts `Z` or numeric timezone offsets and up to nine fractional digits. Invalid dates, leap seconds, excess fractional precision, and values outside `0..4294967293` epoch seconds raise errors. The supported calendar-year input range is 1969 through 2107; the resulting epoch seconds must still fit the event range and the platform's timestamp range.

```lua
log.timestamp = fb.parse_time("2026-01-02T03:04:05.123456789Z")
```

## Callback constants

`fb.KEEP` commits edits and `fb.DROP` removes the item. Returning nothing also commits edits. These constants aren't the numeric return codes of the Lua filter. See [Errors and limits](errors-and-limits.md#callback-results).
