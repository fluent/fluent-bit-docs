# Backpressure

In certain environments is common to see that logs or data being ingested is faster than the ability to flush it to some destinations. The common case is reading from big log files and dispatching the logs to a backend over the network which takes some time to respond, this generate backpressure leading to a high memory consumption in the service.

In order to avoid backpressure, Fluent Bit implements a mechanism in the engine that restrict the amount of data than an input plugin can ingest, this is done through the configuration parameter **Mem\_Buf\_Limit**.

{% hint style="info" %}
As described in the [Buffering](../concepts/buffering.md) concepts section, Fluent Bit offers an hybrid mode for data handling: in-memory and filesystem \(optional\).

In `memory` is always available and can be restricted with **Mem\_Buf\_Limit**. If your plugin gets restricted because of the configuration and you are under a backpressure scenario, you won't be able to ingest more data until the data chunks that are in memory can flushed.

Depending of the input plugin type in use, this might lead to discard incoming data \(e.g: TCP input plugin\), but you can rely on the secondary filesystem buffering to be safe.

If in addition to Mem\_Buf\_Limit the input plugin defined a `storage.type` of `filesystem` \(as described in [Buffering & Storage](buffering-and-storage.md)\), when the limit is reached, all the new data will be stored safety in the file system.
{% endhint %}

## Mem\_Buf\_Limit

This option is disabled by default and can be applied to all input plugins. Let's explain it behavior using the following scenario:

* Mem\_Buf\_Limit is set to 1MB \(one megabyte\)
* input plugin tries to append 700KB
* engine route the data to an output plugin
* output plugin backend \(HTTP Server\) is down
* engine scheduler will retry the flush after 10 seconds
* input plugin tries to append 500KB

At this exact point, the engine will **allow** to append those 500KB of data into the engine: in total we have 1.2MB. The options works in a permissive mode before to reach the limit, but the limit is **exceeded** the following actions are taken:

* block local buffers for the input plugin \(cannot append more data\)
* notify the input plugin invoking a **pause** callback

The engine will protect it self and will not append more data coming from the input plugin in question; Note that is the plugin responsibility to keep their state and take some decisions about what to do on that _paused_ state.

After some seconds if the scheduler was able to flush the initial 700KB of data or it gave up after retrying, that amount memory is released and internally the following actions happens:

* Upon data buffer release \(700KB\), the internal counters get updated
* Counters now are set at 500KB
* Since 500KB is &lt; 1MB it checks the input plugin state
* If the plugin is paused, it invokes a **resume** callback
* input plugin can continue appending more data

## About pause and resume Callbacks

Each plugin is independent and not all of them implements the **pause** and **resume** callbacks. As said, these callbacks are just a notification mechanism for the plugin.

The plugin who implements and keep a good state is the [Tail Input](../pipeline/inputs/tail.md) plugin. When the **pause** callback is triggered, it stop their collectors and stop appending data. Upon **resume**, it re-enable the collectors.

