---
description: Performance and Data Safety
---

# Buffering

When [Fluent Bit](https://fluentbit.io) processes data, it uses the system memory \(heap\) as a primary and temporary place to store the record logs before they get delivered, in this private memory area the records are processed.

Buffering refers to the ability to store the records somewhere, and while they are processed and delivered, still be able to store more. Buffering in memory is the fastest mechanism, but there are certain scenarios where it requires special strategies to deal with [backpressure](../administration/backpressure.md), data safety or reduce memory consumption by the service in constrained environments.

{% hint style="info" %}
Network failures or latency on third party service is pretty common, and on scenarios where we cannot deliver data fast enough as we receive new data to process, we likely will face backpressure.

Our buffering strategies are designed to solve problems associated with backpressure and general delivery failures.
{% endhint %}

Fluent Bit as buffering strategies go, offers a primary buffering mechanism in **memory** and an optional secondary one using the **file system**. With this hybrid solution you can accomodate any use case safely and keep a high performance while processing your data.

Both mechanisms are not mutally exclusive and when the data is ready to be processed or delivered it will always be **in memory**, while other data in the queue might be in the file system until is ready to be processed and moved up to memory.

To learn more about the buffering configuration in Fluent Bit, please jump to the [Buffering & Storage](../administration/buffering-and-storage.md) section.

