# Backpressure

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=63e37cfe-9ce3-4a18-933a-76b9198958c1" />

Under certain scenarios it is possible for logs or data to be ingested or created faster than the ability to flush it to some destinations. One such common scenario is when reading from big log files, especially with a large backlog, and dispatching the logs to a backend over the network, which takes time to respond. This generates backpressure leading to high memory consumption in the service.

In order to avoid backpressure, Fluent Bit implements a mechanism in the engine that restricts the amount of data that an input plugin can ingest, this is done through the configuration parameters **Mem\_Buf\_Limit** and **storage.Max\_Chunks\_Up**.

As described in the [Buffering](../concepts/buffering.md) concepts section, Fluent Bit offers two modes for data handling: in-memory only (default) and in-memory + filesystem \(optional\).

The default `storage.type memory` buffer can be restricted with **Mem\_Buf\_Limit**. If memory reaches this limit and you reach a backpressure scenario, you will not be able to ingest more data until the data chunks that are in memory can be flushed. The input will be paused and Fluent Bit will [emit](https://github.com/fluent/fluent-bit/blob/v2.0.0/src/flb_input_chunk.c#L1334) a `[warn] [input] {input name or alias} paused (mem buf overlimit)` log message. Depending on the input plugin in use, this might lead to discard incoming data \(e.g: TCP input plugin\). The tail plugin can handle pause without data loss; it will store its current file offset and resume reading later. When buffer memory is available, the input will resume collecting/accepting logs and Fluent Bit will [emit](https://github.com/fluent/fluent-bit/blob/v2.0.0/src/flb_input_chunk.c#L1277) a `[info] [input] {input name or alias} resume (mem buf overlimit)` message. 

This risk of data loss can be mitigated by configuring secondary storage on the filesystem using the `storage.type` of `filesystem` \(as described in [Buffering & Storage](buffering-and-storage.md)\). Initially, logs will be buffered to *both* memory and filesystem. When the `storage.max_chunks_up` limit is reached, all the new data will be stored safely only in the filesystem. Fluent Bit will stop enqueueing new data in memory and will only buffer to the filesystem. Please note that when `storage.type filesystem` is set, the `Mem_Buf_Limit` setting no longer has any effect, instead, the `[SERVICE]` level `storage.max_chunks_up` setting controls the size of the memory buffer. 

## Mem\_Buf\_Limit

This option is disabled by default and can be applied to all input plugins. Please note that `Mem_Buf_Limit` only applies with the default `storage.type memory`. Let's explain its behavior using the following scenario:

* Mem\_Buf\_Limit is set to 1MB \(one megabyte\)
* input plugin tries to append 700KB
* engine route the data to an output plugin
* output plugin backend \(HTTP Server\) is down
* engine scheduler will retry the flush after 10 seconds
* input plugin tries to append 500KB

At this exact point, the engine will **allow** appending those 500KB of data into the memory; in total it will have 1.2MB of data buffered. The limit is permissive and will allow a single write past the limit, but once the limit is **exceeded** the following actions are taken:

* block local buffers for the input plugin \(cannot append more data\)
* notify the input plugin invoking a **pause** callback

The engine will protect itself and will not append more data coming from the input plugin in question; note that it is the responsibility of the plugin to keep state and decide what to do in that _paused_ state.

After some time, usually measured in seconds, if the scheduler was able to flush the initial 700KB of data or it has given up after retrying, that amount of memory is released and the following actions will occur:

* Upon data buffer release \(700KB\), the internal counters get updated
* Counters now are set at 500KB
* Since 500KB is &lt; 1MB it checks the input plugin state
* If the plugin is paused, it invokes a **resume** callback
* input plugin can continue appending more data

## storage.max\_chunks\_up

Please note that when `storage.type filesystem` is set, the `Mem_Buf_Limit` setting no longer has any effect, instead, the `[SERVICE]` level `storage.max_chunks_up` setting controls the size of the memory buffer. 

The setting behaves similarly to the above scenario with `Mem_Buf_Limit` when the non-default `storage.pause_on_chunks_overlimit` is enabled. 

When (default) `storage.pause_on_chunks_overlimit` is disabled, the input will not pause when the memory limit is reached. Instead, it will switch to only buffering logs in the filesystem. The disk spaced used for filesystem buffering can be limited with `storage.total_limit_size`.

See the [Buffering & Storage](buffering-and-storage.md) docs for more information.

## About pause and resume Callbacks

Each plugin is independent and not all of them implements the **pause** and **resume** callbacks. As said, these callbacks are just a notification mechanism for the plugin.

One example of a plugin that implements these callbacks and keeps state correctly is the [Tail Input](../pipeline/inputs/tail.md) plugin. When the **pause** callback is triggered, it pauses its collectors and stops appending data. Upon **resume**, it resumes the collectors and continues ingesting data. Tail will track the current file offset when it pauses and resume at the same position. If the file has not been deleted or moved, it can still be read.

With the default `storage.type memory` and `Mem_Buf_Limit`, the following log messages will be emitted for pause and resume:

```
[warn] [input] {input name or alias} paused (mem buf overlimit)
[info] [input] {input name or alias} resume (mem buf overlimit)
```

With `storage.type filesystem` and `storage.max_chunks_up`, the following log messages will be emitted for pause and resume:

```
[input] {input name or alias} paused (storage buf overlimit
[input] {input name or alias} resume (storage buf overlimit
```
