# Back Pressure

In certain environments is common to see that logs or data being ingested is faster than the ability to flush it to some destinations. The common case is reading from big log files and dispatching the logs to a backend over the network which takes some time to respond, this generate backpressure leading to a high memory consumption in the service.

In order to avoid back pressure, Fluent Bit implements a mechanism in the engine that restrict the amount of data than an input plugin can ingest, this is done through the configuration parameter __Mem_Buf_Limit__.

## Mem_Buf_Limit

This option is disabled by default and can be applied to all input plugins. Let's explain it behavior using the following scenario:

- Mem\_Buf\_Limit is set to 1MB (one megabyte)
- input plugin tries to append 700KB
- engine route the data to an output plugin
- output plugin backend (HTTP Server) is down
- engine scheduler will retry the flush after 10 seconds
- input plugin tries to append 500KB

At this exact point, the engine will __allow__ to append those 500KB of data into the engine: in total we have 1.2MB. The options works in a permisive mode before to reach the limit, but the limit is__exceeded__ the following actions are taken:

- block local buffers for the input plugin (cannot append more data)
- notify the input plugin invoking a __pause__ callback

The engine will protect it self and will not append more data coming from the input plugin in question; Note that is the plugin responsability to keep their state and take some decisions about what to do on that _paused_ state.

After some seconds if the scheduler was able to flush the initial 700KB of data or it gave up after retrying, that amount memory is released and internally the following actions happens:

- Upon data buffer release (700KB), the internal counters get updated
- Counters now are set at 500KB
- Since 500KB is < 1MB it check the input plugin state
- If the plugin is paused, it invoke a __resume__ callback
- input plugin can continue appending more data

## About pause and resume Callbacks

Each plugin is independent and not all of them implements the __pause__ and __resume__ callbacks. As said, these callbacks are just a notification mechanism for the plugin.

The plugin who implements and keep a good state is the [Tail Input](../input/tail.md) plugin. When the __pause__ callback is triggered, it stop their collectors and stop appending data. Upon __resume__, it re-enable the collectors.
