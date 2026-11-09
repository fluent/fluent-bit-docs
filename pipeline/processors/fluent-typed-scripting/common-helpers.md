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
local message = log.body:get("message")
if message and message:type() == "string" then
    local ok, parsed = pcall(fb.parse_json, message:value())
    if ok and parsed:type() == "map" then
        log.body = parsed
    else
        return fb.DROP
    end
end
```

This fragment belongs in `process(log)` with `fb` loaded. Catching a parse error with `pcall` lets the policy choose a result; it doesn't roll back earlier edits automatically. An uncaught error invokes the processor's rollback and `error_mode` behavior.

`fb.try_parse_json` and `fb.decode_json` require a build that includes Fluent Bit commit `94ef261ba11bf51b2c5ec57dd486a87db0d2e03c`, such as development revision `e090fbd054c82ae67f12ebe926600827b6cf5f48`. Revision `7ea6759f2` doesn't define these helpers, so the following examples fail there.

`fb.try_parse_json(text)` uses the same parser and limits, but returns `nil, error` instead of raising an error when the text is invalid JSON or isn't a string, including a missing field. JSON `null` and `false` return typed values, so check for `nil` rather than for a false value:

```lua
local message = log.body:get("message")
if message and message:type() == "string" then
    local parsed = fb.try_parse_json(message:value())
    if parsed and parsed:type() == "map" then
        log.body = parsed
    end
end
```

The example reads `message` with `get` and checks its type first, because `get_string` raises an error when the field isn't a string. A number, boolean, or `null` in `message` skips the parsing step instead of failing the callback, and the rest of the policy still runs.

## Decode a JSON field in place

`fb.decode_json(container, key)` replaces one string field with its decoded JSON value. It works with body maps, nested maps, OpenTelemetry attributes, and array elements, and accepts any valid JSON value, including arrays, `null`, and booleans. It returns `true` on success. For a missing or non-string field, or text that isn't valid JSON, it returns `false, error` and leaves the field unchanged.

```lua
fb.decode_json(log.body, "message")
if fb.is_otel(log) then
    fb.decode_json(log.attributes, "payload")
end
```

For example, `{"message":"{\"level\":\"info\"}","host":"web"}` becomes `{"message":{"level":"info"},"host":"web"}`. Strings inside the decoded value aren't decoded again; each one needs its own call. To replace the whole log body with a decoded object instead, use [`fb.unpack_json`](logs.md#log-helpers).

For OpenTelemetry log bodies and attributes, the JSON field helpers reject unsigned integers greater than `9223372036854775807`, including nested values, because OpenTelemetry integers are signed 64-bit values. They return `false, error` without changing the field. `fb.parse_json` and `fb.try_parse_json` keep full unsigned 64-bit support.

The `true` or `false` status of a helper isn't a callback result. To remove a record when decoding fails, return `fb.DROP` explicitly. If a JSON helper exhausts the instruction limit, the callback fails instead of returning `false`, and `error_mode` applies.

## Parse time

`fb.parse_time(text)` parses RFC 3339 text and returns a Lua table `{sec, nsec}` for `log.timestamp`. It accepts `Z` or numeric timezone offsets and up to nine fractional digits. Invalid dates, leap seconds, excess fractional precision, and values outside `0..4294967293` epoch seconds raise errors. The supported calendar-year input range is 1969 through 2107; the resulting epoch seconds must still fit the event range and the platform's timestamp range.

```lua
log.timestamp = fb.parse_time("2026-01-02T03:04:05.123456789Z")
```

## Hash and sign values

`fb.hash64(bytes)` returns a 16-character lowercase XXH3-64 fingerprint of a byte string up to 1 MiB. `fb.hash64_mod(bytes, modulus)` returns the remainder of that 64-bit hash for an integer modulus from `1` to `1000000000`. Use it for stable sampling. `fb.hash64_algorithm` names the fixed algorithm, `xxh3-64-v1-seed0`. Hashes provide no secrecy.

```lua
local user_id = log.body:get("user_id")
if user_id and user_id:type() == "string" and fb.hash64_mod(user_id:value(), 100) >= 10 then
    return fb.DROP
end
```

`fb.hmac_sha256(key_ref, bytes)` returns a 64-character lowercase hexadecimal HMAC-SHA256 of a message up to 1 MiB. `key_ref` names an entry in the processor's `secret_refs` setting, which maps references to environment variable names:

```yaml
processors:
  logs:
    - name: fts
      script: pseudonymize.lua
      secret_refs:
        email-v1: FTS_PSEUDONYM_KEY_V1
```

```lua
local email = log.body:get("email")
if email and email:type() == "string" then
    log.body:set("email", "email-v1:" .. fb.hmac_sha256("email-v1", email:value()))
end
```

Fluent Bit reads each environment variable once during initialization and uses its raw bytes as the key; hexadecimal or Base64 text isn't decoded. Lua code never sees the key. A missing variable or an empty key fails initialization. `secret_refs` supports up to 16 references, and keys up to 4096 bytes. Each reference name must contain 1 to 128 ASCII letters, digits, underscores (`_`), periods (`.`), or hyphens (`-`). Each environment variable name must contain 1 to 128 ASCII letters, digits, or underscores, and can't start with a digit. Set the key as a process environment variable, for example through your orchestrator. Don't put the key in the YAML `env` section, which stores it as plain text in the configuration file. Include the key version in emitted values so you can rotate keys with a new reference.

## Callback constants

`fb.KEEP` commits edits and `fb.DROP` removes the item. Returning nothing also commits edits. These constants aren't the numeric return codes of the Lua filter. See [Errors and limits](errors-and-limits.md#callback-results).
