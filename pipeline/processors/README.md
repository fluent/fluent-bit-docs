# Processors

Processors are components that modify, transform, or enhance data as it flows
through Fluent Bit. Unlike [filters](../filters/README.md), processors are
tightly coupled to inputs, which means they execute immediately and avoid
creating a performance bottleneck.

Additionally, filters can be implemented in a way that mimics the behavior of
processors, but processors can't be implemented in a way that mimics filters.

{% hint style="info" %}

**Note:** Processors can be enabled only by using the YAML configuration format. Classic mode configuration format 
doesn't support processors.

{% endhint %}

## Available processors

Fluent Bit offers the following processors:

- [Content Modifier](content-modifier.md): Manipulate the content, metadata, and
  attributes of logs and traces.
- [Labels](labels.md): Add, update, or delete metric labels.
- [Metrics Selector](metrics-selector.md): Choose which metrics to keep or discard.
- [OpenTelemetry Envelope](opentelemetry-envelope.md): Transform logs into an
  OpenTelemetry-compatible format.
- [Sampling](sampling.md): Trace sampling designed with a pluggable architecture,
  allowing easy extension to support multiple sampling strategies and backends.
- [SQL](sql.md): Use SQL queries to extract log content.
- [Filters](filters.md): Any filter can be used as a processor.

## Features

Compatible processors include the following features:

- [Conditional Processing](conditional-processing.md): Selectively apply processors
  to logs based on the value of fields that those logs contain.