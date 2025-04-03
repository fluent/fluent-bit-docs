# Processors

Processors are components that modify, transform, or enhance data as it flows through Fluent Bit. 
Unlike [filters](../filters/README.md), processors are tightly coupled to inputs, which means they
execute immediately and avoid creating a performance bottleneck.

Additionally, filters can be implemented in a way that mimics the behavior of processors, but
processors can't be implemented in a way that mimics filters.

## Available processors

Fluent Bit offers the following processors:

- [Content Modifier](content-modifier.md): Manipulate the content, metadata, and attributes of logs and traces.
- [Labels](labels.md): Add, update, or delete metric labels.
- [Metrics Selector](metrics-selector.md): Choose which metrics to keep or discard.
- [OpenTelemetry Envelope](opentelemetry-envelope.md): Transform logs into an OpenTelemetry-compatible format.
- [SQL](sql.md): Process records using SQL queries

## Features

- [Conditional Processing](conditional-processing.md): Apply processors only to records that meet specific conditions