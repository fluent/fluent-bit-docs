# Configuration

Fluent Typed Scripting (FTS) uses the configuration name `fts`. Attach a processor entry under the signal it processes. See the [quickstart](quickstart.md) for a complete pipeline.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `call` | Name of the Lua callback. The script must define this function before initialization finishes. | `process` |
| `code` | Inline Lua policy. Set exactly one of `script`, `code`, or `recipe`. | _none_ |
| `context` | Log context that `recipe` steps accept: `native`, `otel`, or `any`. Any other value fails validation. | `any` |
| `error_mode` | Action after a policy failure: `drop` removes the item; `keep` forwards the original item without edits. Values are case-sensitive. | `drop` |
| `instruction_limit` | Lua instruction budget for each callback and script initialization. With `jit: false`, the range is `1000` through `2147483647`. With `jit: true`, must be `0`. | `1000000` |
| `jit` | Enable LuaJIT compilation. Requires a LuaJIT runtime and `instruction_limit: 0`. | `false` |
| `memory_limit` | Maximum policy memory in bytes, including the Lua heap and retained typed values. Minimum: `262144` bytes. | `32M` |
| `output_limit` | Maximum serialized size of a processed batch. Minimum: `65536` bytes. Records held by stateful recipe steps count toward `state_limit` instead. See the signal-specific failure behavior in [Errors and limits](errors-and-limits.md#output-limit). | `64M` |
| `packages_dir` | Directory that contains trusted local Lua packs. Required when `packs` is set. Relative paths resolve against the Fluent Bit process working directory, not the configuration file directory. | _none_ |
| `packs` | List of local pack manifest paths, relative to `packages_dir`. Requires `recipe` and `packages_dir`. Packs are loaded only from local files. | _none_ |
| `recipe` | Ordered list of built-in recipe steps. Set exactly one of `script`, `code`, or `recipe`. Requires `recipe_version: 1` and `jit: false`. | _none_ |
| `recipe_version` | Recipe grammar version. Only `1` is supported. | `1` |
| `script` | Path to a Lua policy file. Set exactly one of `script`, `code`, or `recipe`. | _none_ |
| `secret_refs` | Map of HMAC key references to environment variable names, resolved once during initialization. Used by `fb.hmac_sha256`. See [Hash and sign values](common-helpers.md#hash-and-sign-values). | _none_ |
| `state_commit` | Commit mode for stateful recipe steps. The only accepted value is `local`, and it requires `recipe`. State is volatile and local to the processor instance. | _none_ |
| `state_limit` | Maximum native state memory for stateful recipe steps, including provisional entries and bookkeeping. | `1M` |

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

Startup fails when more than one of `script`, `code`, and `recipe` is set, none is set, the callback is missing, a limit is invalid, or the script fails during initialization. `error_mode` handles processing failures; it doesn't make an invalid configuration usable.

Recipe and pack settings have their own requirements. Startup fails when `packs` is set without both `recipe` and `packages_dir`, when `recipe` is combined with a `recipe_version` other than `1` or with `jit: true`, when `context` isn't `native`, `otel`, or `any`, or when `state_commit` is set without `recipe` or to a value other than `local`.

To enable LuaJIT compilation on a native LuaJIT build, set both `jit: true` and `instruction_limit: 0`. Setting only one fails validation. Portable Lua, including the experimental browser WASM runtime, rejects `jit: true`. See [Runtime restrictions](errors-and-limits.md#runtime-restrictions) before choosing these settings.
