# Configuration

Fluent Typed Scripting (FTS) uses the configuration name `fts`. Attach a processor entry under the signal it processes. See the [quickstart](quickstart.md) for a complete pipeline.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `call` | Name of the Lua callback. The script must define this function before initialization finishes. | `process` |
| `code` | Inline Lua policy. Set exactly one of `code` or `script`. | _none_ |
| `error_mode` | Action after a policy failure: `drop` removes the item; `keep` forwards the original item without edits. Values are case-sensitive. | `drop` |
| `instruction_limit` | Lua instruction budget for each callback and script initialization. With `jit: false`, the range is `1000` through `2147483647`. With `jit: true`, must be `0`. | `1000000` |
| `jit` | Enable LuaJIT compilation. Requires a LuaJIT runtime and `instruction_limit: 0`. | `false` |
| `memory_limit` | Maximum policy memory in bytes, including the Lua heap and retained typed values. Minimum: `262144` bytes. | `32M` |
| `output_limit` | Maximum serialized size of a processed batch. Minimum: `65536` bytes. See the signal-specific failure behavior in [Errors and limits](errors-and-limits.md#output-limit). | `64M` |
| `script` | Path to a Lua policy file. Set exactly one of `script` or `code`. | _none_ |

Size suffixes use decimal multipliers: `64K` is 64,000 bytes, less than the minimum `output_limit`. Use `65536` or a larger value. `32M` is 32,000,000 bytes and `64M` is 64,000,000 bytes.

FTS has no `workers` parameter. Its execution follows the input or output that it's attached to.

## Inline policies

Use a YAML block scalar for an inline policy:

```yaml
pipeline:
  inputs:
    - name: dummy
      samples: 1
      processors:
        logs:
          - name: fts
            code: |
              function process(log)
                  log.body:set("environment", "production")
              end
  outputs:
    - name: stdout
      match: '*'
      format: json_lines
```

## Separate signals

For an input that receives multiple signals, use separate entries and scripts. The following fragment belongs inside an input or output configuration:

```yaml
processors:
  logs:
    - name: fts
      script: logs.lua
  metrics:
    - name: fts
      script: metrics.lua
  traces:
    - name: fts
      script: traces.lua
```

Each script can define `process`, because each instance has its own Lua state. A logs script receives a log, a metrics script receives a family, and a traces script receives a span. There is no shared callback that receives all three signals.

## Invalid combinations

Startup fails when both `script` and `code` are set, neither is set, the callback is missing, a limit is invalid, or the script fails during initialization. `error_mode` handles processing failures; it doesn't make an invalid configuration usable.

To enable LuaJIT compilation on a native LuaJIT build, set both `jit: true` and `instruction_limit: 0`. Setting only one fails validation. Portable Lua, including the experimental browser WASM runtime, rejects `jit: true`. See [Runtime restrictions](errors-and-limits.md#runtime-restrictions) before choosing these settings.
