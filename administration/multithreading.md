---
description: Learn how to run Fluent Bit in multiple threads for improved scalability.
---

# Multithreading

Fluent Bit has one event loop to handle critical operations, like managing
timers, receiving internal messages, scheduling flushes, and handling retries.
This event loop runs in Fluent Bit's main thread.

To free up resources in the main thread, you can configure
[inputs](../pipeline/inputs/README.md) and [outputs](../pipeline/outputs/README.md)
to run in their own self-contained threads. However, inputs and outputs implement
multithreading in distinct ways: inputs can run in **threaded** mode, and outputs
can use one or more **workers**.

## Inputs

When inputs collect telemetry data, they can either perform this process
inside Fluent Bit's main thread or inside a separate dedicated thread. You can
configure this behavior by enabling or disabling the `threaded` setting.

All inputs are capable of running in threaded mode, but certain inputs always
run in threaded mode regardless of configuration. These always-threaded inputs are:

- [Kubernetes Events](../pipeline/inputs/kubernetes-events.md)
- [Node Exporter Metrics](../pipeline/inputs/node-exporter-metrics.md)
- [Process Exporter Metrics](../pipeline/inputs/process-exporter-metrics.md)
- [Windows Exporter Metrics](../pipeline/inputs/windows-exporter-metrics.md)

Inputs are not internally aware of multithreading. If an input runs in threaded
mode, Fluent Bit manages the logistics of that input's thread.

## Outputs

When outputs flush data, they can either perform this operation inside Fluent Bit's
main thread or inside a separate dedicated thread called a _worker_. Each output
can have one or more workers running in parallel, and each worker can handle multiple
concurrent flushes. You can configure this behavior by changing the value of the
`workers` setting.

All outputs are capable of running in multiple workers, and each output has a
a default value of `0`, `1`, or `2` workers. However, even if an output uses
workers by default, you can safely reduce the number of workers below the default
or disable workers entirely.
