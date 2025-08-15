# Data pipeline

The Fluent Bit data pipeline incorporates several specific concepts.

## Buffer

The [`buffer`](./buffering.md) phase in the pipeline aims to provide a unified and persistent mechanism to store your data, using the primary in-memory model or the file system-based mode.

## Filter

In production environments you need full control of the data you're collecting. Filtering lets you alter the collected data before delivering it to a destination.
For more details about the Filters available and their usage, see [Filters](../pipeline/filters.md).

## Inputs

Fluent Bit provides [input plugins](../pipeline/inputs.md) to gather information from different sources. Some plugins collect data from log
files, while others can gather metrics information from the operating system. There
are many plugins to suit different needs.

## Outputs

[Outputs](../pipeline/outputs.md) let you define destinations for your data. Common
destinations are remote services, local file systems, or other standard interfaces.
Outputs are implemented as plugins.

## Parsers

[Parsers](../pipeline.parsers.md) convert unstructured data to structured data. Use a parser to set a structure to the incoming data by using input plugins as data is collected.

## Route

[Routing](../pipeline/router.md) is a core feature that lets you route your data through filters and then to one or multiple destinations. The router relies on the concept of [Tags](../concepts/key-concepts#tag.md) and [Matching](../concepts/key-concepts#match.md) rules.
