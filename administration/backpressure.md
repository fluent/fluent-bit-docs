# Backpressure

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=63e37cfe-9ce3-4a18-933a-76b9198958c1" />

It's possible for Fluent Bit to ingest or create data faster than it can flush that data to the intended destinations. This creates a condition known as _backpressure_.

Fluent Bit can accommodate a certain amount of backpressure by [buffering](../pipeline/buffering.md) that data until it can be processed and routed. However, if Fluent Bit continues buffering new data to temporary storage faster than it can flush old data, that storage will eventually reach capacity.

Strategies for managing backpressure vary depending on the [buffering mode](../pipeline/buffering.md#buffering-modes) for each active input plugin. Because of this, choosing the right buffering mode is also a key part of managing backpressure.

## Manage backpressure for memory-only buffering

If one or more active input plugins use [memory-only buffering](../pipeline/buffering.md#buffering-modes#memory-only-buffering), use the following settings to manage backpressure.

{% hint style="warning" %}
Some input plugins are prone to data loss after `mem_buf_limit` capacity is reached during memory-only buffering. If you need to avoid data loss, consider using [filesystem buffering](../pipeline/buffering.md#buffering-modes#filesystem-buffering) instead.
{% endhint %}

### Set `mem_buf_limit` for input plugins

For input plugins that use memory-only buffering, you can configure the `mem_buf_limit` setting to enforce a limit for how much data that plugin can buffer to memory.

{% hint style="info" %}
This setting doesn't affect how much data can be buffered to memory by plugins that use filesystem buffering.
{% endhint %}

When the specified `mem_buf_limit` capacity is reached, Fluent Bit will stop buffering data from that source plugin until enough buffered chunks are flushed. Most plugins emit a log message that says `[warn] [input] <PLUGIN NAME> paused (mem buf overlimit)` when buffering pauses.

After more memory becomes available, Fluent Bit will resume buffering data from that source plugin. Most plugins emit a log message that says `[info] [input] <PLUGIN NAME> resume (mem buf overlimit)` when buffering resumes.

#### Behavior when capacity is reached

The following example demonstrates what happens when an input plugin with memory-only buffering reaches its `mem_buf_limit` capacity:

- The input plugin's `mem_buf_limit` is set to `1MB`.
- The input plugin tries to append 700&nbsp;KB.
- The engine routes the data to an output plugin.
- The output plugin's backend is down, which means it won't accept the data.
- Engine scheduler retries the flush after 10 seconds.
- The input plugin tries to append 500&nbsp;KB.

In this situation, the engine allows appending those 500&nbsp;KB of data into the memory, with a total of 1.2&nbsp;MB of data buffered. The limit is permissive and will allow a single write past the capacity of `mem_buf_limit`. When the limit is exceeded, Fluent Bit takes the following actions:

- It blocks local buffers for the input plugin (can't append more data).
- It notifies the input plugin, invoking a `pause` callback.

The engine protects itself and won't append more data coming from the input plugin in question. It's the responsibility of the plugin to keep state and decide what to do in a `paused` state.

In a few seconds, if the scheduler was able to flush the initial 700&nbsp;KB of data or it has given up after retrying, that amount of memory is released and the following actions occur:

- Upon data buffer release (700&nbsp;KB), the internal counters get updated.
- Counters now are set at 500&nbsp;KB.
- Because 500&nbsp;KB is less than 1&nbsp;MB, it checks the input plugin state.
- If the plugin is paused, it invokes a `resume` callback.
- The input plugin can continue appending more data.

## Manage backpressure for filesystem buffering

If one or more active input plugins use [filesystem buffering](../pipeline/buffering.md#buffering-modes#memory-only-buffering), use the following settings to manage backpressure.

### Set `storage.max_chunks_up` and `storage.backlog.mem_limit` in global settings

In the [`serivce` section](../administration/configuring-fluent-bit/yaml/service-section.md) of your Fluent Bit configuration file, you can configure the `storage.max_chunks_up` and `storage.backlog.mem_limit` settings. Both settings dictate how much data can be buffered to memory by input plugins that use filesystem buffering, and are combined limits shared by all applicable input plugins.

{% hint style="info" %}
These settings don't affect how much data can be buffered to memory by plugins that use memory-only buffering.
{% endhint %}

When either the specified `storage.max_chunks_up` or `storage.backlog.mem_limit` capacity is reached, all input plugins that use filesystem buffering will stop buffering data to memory until more memory becomes available. Whether these input plugins continue buffering data to the filesystem depends on each plugin's specified `storage.pause_on_chunks_overlimit` value.

### Set `storage.pause_on_chunks_overlimit` for input plugins

For input plugins that use filesystem buffering, you can configure the `storage.pause_on_chunks_overlimit` setting to specify how each plugin should behave after the global `storage.max_chunks_up` or `storage.backlog.mem_limit` capacity is reached.

If `storage.pause_on_chunks_overlimit` is set to `off` for an input plugin, the input plugin will stop buffering data to memory but continue buffering data to the filesystem.

If `storage.pause_on_chunks_overlimit` is set to `on` for an input plugin, the input plugin will stop both memory buffering and filesystem buffering until more memory becomes available.

### Set `storage.total_limit_size` for output plugins

Fluent Bit implements the concept of logical queues for buffered chunks. Based on its tag, a chunk can be routed to multiple destinations. Fluent Bit keeps an internal reference from where each chunk was created and where it needs to go. To limit the number of queued chunks, set the `storage.total_limit_size` for any active output plugins that route data ingested by input plugins that use filesystem buffering.

Network failures or latency in third-party services is common for output destinations. In some cases, a chunk is tagged for multiple destinations with varying response times, or one destination is generating more backpressure than others. If an output plugin reaches its configured `storage.total_limit_size` capacity, the oldest chunk from its queue will be discarded to make room for new data.
