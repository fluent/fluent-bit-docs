# Processors

Processors are components that modify, transform, or enhance data as it flows through Fluent Bit. Unlike [filters](filters.md), processors are tightly coupled to inputs, which means they execute immediately and avoid creating a performance bottleneck.

Additionally, filters can be implemented in a way that mimics the behavior of processors, but processors can't be implemented in a way that mimics filters.

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml/configuration-file.md) support processors.

{% endhint %}

## Available processors

Fluent Bit offers the following processors:

- [Content modifier](./processors/content-modifier.md): Manipulate the content, metadata, and attributes of logs and traces.
- [Labels](./processors/labels.md): Add, update, or delete metric labels.
- [Metrics selector](./processors/metrics-selector.md): Choose which metrics to keep or discard.
- [OpenTelemetry envelope](./processors/opentelemetry-envelope.md): Transform logs into an OpenTelemetry-compatible format.
- [Sampling](./processors/sampling.md): Apply head or tail sampling to incoming traces.
- [SQL](./processors/sql.md): Use SQL queries to extract log content.
- [Filters as processors](filters.md): Use filters as processors.

## Features

Compatible processors include the following features:

- [Conditional processing](./processors/conditional-processing.md): Selectively apply processors to logs based on the value of fields that those logs contain.
