# Errors and limits

Fluent Typed Scripting (FTS) policies are trusted configuration. The restricted runtime reduces available operations, but its sandbox isn't a security boundary. Review policies before deploying them.

## Callback results

| Result | Effect |
| --- | --- |
| No return, `nil`, or `fb.KEEP` | Commit the item's edits. |
| `fb.DROP` | Remove the item. Metric emissions remain. |
| Uncaught Lua error, invalid return, or invalid telemetry edit | Roll back edits and apply `error_mode`. |

Transactions cover one log record, metric family, or span, including its resource and scope edits. For logs, body, metadata, context, and timestamp edits commit or roll back together. Metric emissions are discarded on an error. A transaction doesn't include other callbacks or restore Lua globals modified by the policy.

With `error_mode: drop`, the failed item is removed. With `error_mode: keep`, the original item is forwarded without the policy's edits. For a redaction policy, `keep` can forward secrets. Leave the default `drop` when that outcome is unacceptable.

A caught error, such as a failed `pcall(fb.parse_json, text)`, lets the callback continue. Earlier edits remain unless the callback ultimately fails. Instruction budget exhaustion can't be caught to continue an endless loop.

## Memory and instruction limits

The [configuration reference](configuration.md#configuration-parameters) lists defaults and valid ranges.

`memory_limit` accounts for the Lua heap and typed values held by the policy. It isn't a limit on the whole Fluent Bit process, input chunks, or output buffers. Retained globals, copies, and metric/span snapshots consume this budget.

`instruction_limit` counts Lua instructions during script initialization and each callback, using a hook in steps of 1,000 instructions. It isn't an elapsed-time deadline. Lua string patterns execute in C and aren't interrupted by the instruction hook. Avoid patterns whose runtime can grow without a defined bound on untrusted input.

`jit: true` requires `instruction_limit: 0`, removing the instruction budget. Use it only when you control policy execution time. LuaJIT compilation isn't available in the portable Lua runtime. No throughput or latency improvement is guaranteed by these settings.

## Output limit

`output_limit` bounds serialized output from a processed batch. Failure behavior depends on the signal:

| Signal | Behavior when transformed output doesn't fit |
| --- | --- |
| Logs | The whole batch fails. `drop` discards the batch; `keep` forwards the original batch. |
| Metrics and traces | The overflowing item follows `error_mode`. The whole batch fails if retained original items don't fit either. |

Internal failures that FTS detects after a batch is decoded, such as failing to build the policy output, apply `error_mode` to the whole batch. A record that can't be decoded is handled earlier, by the processor layer: the records decoded before it are kept and processed, and the rest of the batch is discarded. In that case, `error_mode: keep` can't restore the original batch.

A processing batch isn't the same as a callback invocation: one batch can invoke the callback many times. Small chunks are processed as one batch. Larger log buffers, including chunks passed to output processors, are processed in batches of about 64 KiB or 1,024 records. A group received within one input append isn't split across batches, so a group can exceed those targets. A group whose start and end markers arrive in separate appends can remain open across batches. Records received inside a group opened in an earlier batch don't receive a context view. See [Logs](logs.md#opentelemetry-context) for details.

## Value and format limits

- Typed values support at most 64 levels of nesting.
- `parse_json` input is limited to 1 MiB and rejects duplicate keys.
- OpenTelemetry strings and keys must be valid UTF-8 without null (`\0`) characters. Use typed bytes for binary data.
- OpenTelemetry integer fields have their own signed or unsigned ranges. A successful typed constructor doesn't guarantee that an arbitrary signal field accepts that value.
- Invalid metric layouts, duplicate series/windows introduced by edits, invalid IDs, and invalid timestamps can fail a policy. See [Metrics](metrics.md) and [Traces](traces.md).

## Runtime restrictions

Only `require("fluentbit")` is available. Filesystem, process, foreign function interface, debug, coroutine, and general module-loading libraries aren't available. The runtime also removes `print`, `xpcall`, `getfenv`, `setfenv`, `module`, and dynamic code-loading functions such as `load`, `loadfile`, `loadstring`, and `dofile`.

Policies can use the restricted base, `math`, `string`, and `table` functions. `collectgarbage` accepts only `collect`, `count`, and `step`. Each processor instance has its own Lua state; globals persist across callbacks within that instance.

The experimental browser WASM profile uses the portable Lua 5.4 interpreter with the same typed-value model and policy limits. It rejects `jit: true`. See [Availability](../fluent-typed-scripting.md#availability) for the build distinction.

## Diagnostics

Each batch logs at most five policy errors plus a summary count. A low number of error messages doesn't imply that only five records failed. The processor error metric counts batches with handled policy failures, and drop metrics count removed records.

If output disappears, check policy errors, expected field types, `error_mode`, and all three budgets. A startup failure instead points to configuration, script loading, initialization limits, or an unavailable runtime feature.
