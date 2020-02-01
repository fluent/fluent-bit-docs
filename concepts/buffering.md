---
description: Performance and data safety
---

# Buffering

When [Fluent Bit](https://fluentbit.io) process data, it uses the system memory \(heap\) as a primary and temporal place to store the record logs before they get delivered, on this private memory area the records are processed. 

Buffering refers to the ability to store the records somewhere, and while they are processed and delivered, still be able to store more. Buffering in memory is the fastest mechanism, but there are certain scenarios where the mechanism requires special strategies to deal with [backpressure](../administration/backpressure.md), data safety or reduce memory consumption by the service in constraint environments.

Fluent Bit as buffering strategies, offers a primary buffering mechanism in **memory** and an optional secondary one using the **file system**. With this hybrid solution you can adjust to any use case safety and keep a high performance while processing your data.

Both mechanisms are not exclusive and when the data is ready to be processed or delivered it will be always **in memory**, while other data in the queue might be in the file system until is ready to be processed and moved up to memory. 

To learn more about the buffering configuration in Fluent Bit, please jump to the [Buffering & Storage](../administration/buffering-and-storage.md) section.

