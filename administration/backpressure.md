# Backpressure

It's possible for logs or data to be ingested or created faster than the ability to flush it to some destinations. A common scenario is when reading from big log files, especially with a large backlog, and dispatching the logs to a backend over the network, which takes time to respond. This generates _backpressure_, leading to high memory consumption in the service.

To avoid backpressure, Fluent Bit implements a mechanism in the engine that restricts the amount of data an input plugin can ingest. Restriction is done through the configuration parameters `Mem_Buf_Limit` and `storage.Max_Chunks_Up`.

As described in the [Buffering](../concepts/buffering.md) concepts section, Fluent Bit offers two modes for data handling: in-memory only (default) and in-memory and filesystem (optional).

The default `storage.type memory` buffer can be restricted with `Mem_Buf_Limit`. If memory reaches this limit and you reach a backpressure scenario, you won't be able to ingest more data until the data chunks that are in memory can be flushed. The input pauses and Fluent Bit [emits](https://github.com/fluent/fluent-bit/blob/v2.0.0/src/flb_input_chunk.c#L1334) a `[warn] [input] {input name or alias} paused (mem buf overlimit)` log message.

Depending on the input plugin in use, this might cause incoming data to be discarded (for example, TCP input plugin). The tail plugin can handle pauses without data loss, storing its current file offset and resuming reading later. When buffer memory is available, the input resumes accepting logs. Fluent Bit [emits](https://github.com/fluent/fluent-bit/blob/v2.0.0/src/flb_input_chunk.c#L1277) a `[info] [input] {input name or alias} resume (mem buf overlimit)` message.

Mitigate the risk of data loss by configuring secondary storage on the filesystem using the `storage.type` of `filesystem` (as described in [Buffering and Storage](buffering-and-storage.md)). Initially, logs will be buffered to both memory and the filesystem. When the `storage.max_chunks_up` limit is reached, all new data will be stored in the filesystem. Fluent Bit stops queueing new data in memory and buffers only to the filesystem. When `storage.type filesystem` is set, the `Mem_Buf_Limit` setting no longer has any effect. Instead, the `[SERVICE]` level `storage.max_chunks_up` setting controls the size of the memory buffer.

## `Mem_Buf_Limit`

`Mem_Buf_Limit` applies only with the default `storage.type memory`. This option is disabled by default and can be applied to all input plugins.

As an example situation:

- `Mem_Buf_Limit` is set to `1MB`.
- The input plugin tries to append 700&nbsp;KB.
- The engine routes the data to an output plugin.
- The output plugin backend (HTTP Server) is down.
- Engine scheduler retries the flush after 10 seconds.
- The input plugin tries to append 500&nbsp;KB.

In this situation, the engine allows appending those 500&nbsp;KB of data into the memory, with a total of 1.2&nbsp;MB of data buffered. The limit is permissive and will allow a single write past the limit. When the limit is exceeded, the following actions are taken:

- Block local buffers for the input plugin (can't append more data).
- Notify the input plugin, invoking a `pause` callback.

The engine protects itself and won't append more data coming from the input plugin in question. It's the responsibility of the plugin to keep state and decide what to do in a `paused` state.

In a few seconds, if the scheduler was able to flush the initial 700&nbsp;KB of data or it has given up after retrying, that amount of memory is released and the following actions occur:

- Upon data buffer release (700&nbsp;KB), the internal counters get updated.
- Counters now are set at 500&nbsp;KB.
- Because 500&nbsp;KB is less than 1&nbsp;MB, it checks the input plugin state.
- If the plugin is paused, it invokes a `resume` callback.
- The input plugin can continue appending more data.

## `storage.max_chunks_up`

The `[SERVICE]` level `storage.max_chunks_up` setting controls the size of the memory buffer. When `storage.type filesystem` is set, the `Mem_Buf_Limit` setting no longer has an effect.

The setting behaves similar to the `Mem_Buf_Limit` scenario when the non-default `storage.pause_on_chunks_overlimit` is enabled.

When (default) `storage.pause_on_chunks_overlimit` is disabled, the input won't pause when the memory limit is reached. Instead, it switches to buffering logs only in the filesystem. Limit the disk spaced used for filesystem buffering with `storage.total_limit_size`.

See [Buffering and Storage](buffering-and-storage.md) docs for more information.

## About pause and resume callbacks

Each plugin is independent and not all of them implement `pause` and `resume` callbacks. These callbacks are a notification mechanism for the plugin.

One example of a plugin that implements these callbacks and keeps state correctly is the [Tail Input](../pipeline/inputs/tail.md) plugin. When the `pause` callback triggers, it pauses its collectors and stops appending data. Upon `resume`, it resumes the collectors and continues ingesting data. Tail tracks the current file offset when it pauses, and resumes at the same position. If the file hasn't been deleted or moved, it can still be read.

With the default `storage.type memory` and `Mem_Buf_Limit`, the following log messages emit for `pause` and `resume`:

```text
[warn] [input] {input name or alias} paused (mem buf overlimit)
[info] [input] {input name or alias} resume (mem buf overlimit)
```

With `storage.type filesystem` and `storage.max_chunks_up`, the following log messages emit for `pause` and `resume`:

```text
[input] {input name or alias} paused (storage buf overlimit)
[input] {input name or alias} resume (storage buf overlimit)
```