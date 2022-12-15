# Backpressure

Under certain scenarios it is possible for logs or data to be ingested or created faster than the ability to flush it to some destinations. One such common scenario is when reading from big log files, especially with a large backlog, and dispatching the logs to a backend over the network, which takes time to respond. This generates backpressure leading to high memory consumption in the service.

In order to avoid backpressure, Fluent Bit implements a mechanism in the engine that restrict the amount of data than an input plugin can ingest, this is done through the configuration parameter **Mem\_Buf\_Limit**.

As described in the [Buffering](../concepts/buffering.md) concepts section, Fluent Bit offers an hybrid mode for data handling: in-memory and filesystem \(optional\).

In `memory` is always available and can be restricted with **Mem\_Buf\_Limit**. If memory reaches this limit and you reach a backpressure scenario, you will not be able to ingest more data until the data chunks that are in memory can be flushed.

Depending on the input plugin in use, this might lead to discard incoming data \(e.g: TCP input plugin\). This can be mitigated by configuring secondary storage on the filesystem using the `storage.type` of `filesystem` \(as described in [Buffering & Storage](buffering-and-storage.md)\). When the limit is reached, all the new data will be stored safety in the file system.

## Mem\_Buf\_Limit

This option is disabled by default and can be applied to all input plugins. Let's explain its behavior using the following scenario:

* Mem\_Buf\_Limit is set to 1MB \(one megabyte\)
* input plugin tries to append 700KB
* engine route the data to an output plugin
* output plugin backend \(HTTP Server\) is down
* engine scheduler will retry the flush after 10 seconds
* input plugin tries to append 500KB

At this exact point, the engine will **allow** appending those 500KB of data into the memory: in total it will have 1.2MB of data buffered. The limit is permissive and will allow a single write past the limit, but once the limit is **exceeded** the following actions are taken:

* block local buffers for the input plugin \(cannot append more data\)
* notify the input plugin invoking a **pause** callback

The engine will protect itself and will not append more data coming from the input plugin in question; Note that it is the responsibility of the plugin to keep state and decide what to do in that _paused_ state.

After some time, usually measured in seconds, if the scheduler was able to flush the initial 700KB of data or it has given up after retrying, that amount of memory is released and the following actions will occur:

* Upon data buffer release \(700KB\), the internal counters get updated
* Counters now are set at 500KB
* Since 500KB is &lt; 1MB it checks the input plugin state
* If the plugin is paused, it invokes a **resume** callback
* input plugin can continue appending more data

## About pause and resume Callbacks

Each plugin is independent and not all of them implements the **pause** and **resume** callbacks. As said, these callbacks are just a notification mechanism for the plugin.

One example of a plugin that implements these callbacks and keeps state correctly is the [Tail Input](../pipeline/inputs/tail.md) plugin. When the **pause** callback is triggered, it pauses its collectors and stops appending data. Upon **resume**, it resumes the collectors and continues ingesting data.
