# Data pipeline

The Fluent Bit data pipeline incorporates several specific concepts.

## Buffer

The [`buffer`](./buffering.md) phase in the pipeline aims to provide a unified and persistent mechanism to store your data, using the primary in-memory model or the file system-based mode.

## Filter

In production environments you need full control of the data you're collecting. Filtering lets you alter the collected data before delivering it to a destination.
For more details about the Filters available and their usage, see [Filters](https://docs.fluentbit.io/manual/pipeline/filters).

## Inputs
