# Fluent Typed Scripting (FTS)

{% hint style="info" %}
**Supported event types:** `logs`, `metrics`, `traces`
{% endhint %}

Fluent Typed Scripting (FTS) lets you write policies in Lua with typed access to telemetry. Its configuration name is `fts`. Use it to redact structured fields, normalize log content and OpenTelemetry context, transform metric families, or edit spans.

_Typed_ refers to the telemetry values exposed to the policy, including maps, arrays, binary data, exact 64-bit integers, and nanosecond timestamps. FTS doesn't add static typing to Lua. Type checks happen at runtime.

## Availability

FTS is included in the development source for Fluent Bit 5.2.0 and hasn't shipped in a stable release yet. It isn't included in the 5.1 release series. Use a development build with FTS enabled; don't assume a container tagged `latest` includes it. These pages describe the current implementation on `master`. Check your binary with `fluent-bit --version` and run the [quickstart](fluent-typed-scripting/quickstart.md) to confirm that it contains `fts`.

For a native source build, enable `FLB_PROCESSOR_FTS`, `FLB_LUAJIT`, and `FLB_YYJSON`. FTS defaults to interpreted execution even when built with LuaJIT. See [Build and install](../../installation/downloads/source/build-and-install.md) for general build instructions.

The experimental browser WASM profile also includes FTS when `FLB_WASM_LUA=ON`, the profile default. It uses portable Lua 5.4 and rejects `jit: true`. Setting `FLB_WASM_LUA=OFF` disables both FTS and the Lua filter in that profile. This experimental profile is separate from native support and from the [Wasm filter](../filters/wasm.md).

## Choose FTS

Choose FTS when a transformation needs typed values, per-item rollback, or programmable access to logs, metrics, and traces. Prefer a dedicated processor when its existing operations meet your needs. For an existing Lua filter policy, review [FTS and the Lua filter](fluent-typed-scripting/lua-filter.md) before migrating: their callback and value models differ.

Each signal uses its own processor entry and script under `processors.logs`, `processors.metrics`, or `processors.traces`. A callback receives one log record, one metric family, or one span, respectively. Each processor instance has its own Lua state. FTS doesn't join signals or share globals between those instances.

Processors require [YAML configuration](../../administration/configuring-fluent-bit/yaml.md). Attach FTS to an input or output and place it in the order in which transformations should run. See [Processors](../processors.md) for pipeline placement.

## Get started and reference

1. Run your first transformation with the [Quickstart](fluent-typed-scripting/quickstart.md).
2. Configure the policy and execution limits with [Configuration](fluent-typed-scripting/configuration.md).
3. Learn the value model in [Typed values](fluent-typed-scripting/typed-values.md).
4. Use the signal references for [Logs](fluent-typed-scripting/logs.md), [Metrics](fluent-typed-scripting/metrics.md), and [Traces](fluent-typed-scripting/traces.md).
5. Look up [Common helpers](fluent-typed-scripting/common-helpers.md) and [Errors and limits](fluent-typed-scripting/errors-and-limits.md).
6. Adapt the complete [Recipes](fluent-typed-scripting/recipes.md).
7. Configure built-in blocks without Lua by using [Native recipe blocks](fluent-typed-scripting/native-recipes.md).
