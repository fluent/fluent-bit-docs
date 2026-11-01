# Typed values

Fluent Typed Scripting (FTS) exposes telemetry as typed values, not ordinary Lua tables. Checks happen at runtime; Lua itself remains dynamically typed. Load constructors and helpers with `local fb = require("fluentbit")`.

## Maps and arrays

Maps have string keys. Key matching uses exact bytes and is case-sensitive unless a helper documents otherwise. A dot is part of the key: `attributes:get("service.name")` doesn't traverse nested maps. Arrays use indexes starting at 1.

| Method | Applies to | Result or effect |
| --- | --- | --- |
| `v:get(key)` | Map, array | Typed child value. A missing map key returns `nil`; an array index outside `1..v:len()` raises an error. |
| `v:get_string(key)` | Map, array | Lua string; `nil` for a missing map key. A different type raises an error. |
| `v:get_number(key)` | Map, array | Lua number; `nil` for a missing map key. Uses the same precision checks as `number()`. |
| `v:get_bool(key)` | Map, array | Lua boolean; `nil` for a missing map key. A different type raises an error. |
| `v:set(key, value)` | Map, array | Set a value. For maps, replace all entries with that key. For arrays, replace an existing index. |
| `v:remove(key)` | Map | Remove all entries with the key. |
| `v:ensure_map(key)` | Map | Return a child map or create it if missing. An existing non-map value raises an error. |
| `v:append(value)` | Array | Append a value. |
| `v:keys()` | Map | Lua table of keys in entry order. |
| `v:len()` | Map, array | Number of entries. |
| `v:type()` | Any typed value | `map`, `array`, `string`, `bytes`, `bool`, `int64`, `uint64`, `double`, or `null`. |
| `v:value()` | Scalar | Lua scalar; integers are exact decimal strings, bytes are Lua strings, and null is `nil`. Containers raise an error. |
| `v:number()` | Numeric value | Lua number. Rejects integers outside the safe range −(2^53 − 1) through 2^53 − 1. |
| `v:copy()` | Any typed value | Independent writable copy. |

Use `append` to grow arrays. To remove or reorder elements, build a new array and assign it to the containing field.

## Constructors and conversions

| Value | Creates |
| --- | --- |
| `fb.map()` | Empty typed map. |
| `fb.array()` | Empty typed array. |
| `fb.int64(value)` | Signed 64-bit integer from a decimal string or safe integral Lua number. Range: −9223372036854775808 through 9223372036854775807. |
| `fb.uint64(value)` | Unsigned 64-bit integer from a decimal string or safe integral Lua number. Range: 0 through 18446744073709551615. |
| `fb.bytes(text)` | Binary value from a Lua string, including null (`\0`) bytes. |
| `fb.null` | Explicit null value. |

Pass Lua strings, booleans, and finite numbers directly to `set` or `append`. Lua numbers are stored as doubles, including integral numbers. Use the integer constructors to request integer storage. Ordinary Lua tables and `nil` aren't telemetry values. Use typed constructors and `fb.null`; use `remove` to delete a map key.

```lua
local fb = require("fluentbit")

function process(log)
    local body = log.body
    body:set("request_id", fb.uint64("18446744073709551615"))
    body:set("attempts", fb.int64(2))
    body:set("optional", fb.null)
    body:set("payload", fb.bytes("a\0b"))
    local labels = fb.array()
    labels:append("production")
    body:set("labels", labels)

    assert(body:get("request_id"):value() == "18446744073709551615")
    assert(body:get_number("attempts") == 2)
    assert(body:get("optional"):type() == "null")
    assert(body:get("missing") == nil)
end
```

Don't convert an exact integer to a Lua number and then expect to recover its precision. Use decimal strings for large integer constructors and `value()` for exact reads. Numeric strings aren't converted by `get_number`.

OpenTelemetry scalar metric values and attribute integers use signed int64. A typed `uint64` doesn't make every OpenTelemetry field capable of representing the full unsigned range. See [Metrics](metrics.md) and the limits of your output format. JSON output also can't convey a distinction between bytes and strings or between every numeric storage type.

## Value lifetime

Log values and views obtained from them are valid only during that callback. Retaining a log body or child view in a global and using it in a later callback raises an error.

Metric and span values are snapshots made for the callback. They remain readable afterward, but subsequent mutations don't affect committed output or later items. Retaining snapshots also retains their memory.

To retain data deliberately, store `v:copy()`. A copy is independent; editing it doesn't change a committed record. Globals persist for the lifetime of a processor instance, so retained data counts against `memory_limit`. Bound any cache you keep in a policy.

```lua
local previous

function process(log)
    if previous then
        log.body:set("previous", previous)
    end
    local message = log.body:get("message")
    previous = message and message:copy() or nil
end
```

This example retains only the previous message value, keeping the number of retained values bounded.
