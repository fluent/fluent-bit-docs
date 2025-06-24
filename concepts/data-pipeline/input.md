---
description: The way to gather data from your sources
---

# Input

[Fluent Bit](http://fluentbit.io) provides input plugins to gather information from
different sources. Some plugins collect data from log files, while others can
gather metrics information from the operating system. There are many plugins to suit
different needs.

```mermaid
graph LR
    accTitle: Fluent Bit data pipeline
    accDescr: A diagram of the Fluent Bit data pipeline, which includes input, a parser, a filter, a buffer, routing, and various outputs.
    A[Input] --> B[Parser]
    B --> C[Filter]
    C --> D[Buffer]
    D --> E((Routing))
    E --> F[Output 1]
    E --> G[Output 2]
    E --> H[Output 3]
    style A stroke:darkred,stroke-width:2px;
```

When an input plugin loads, an internal _instance_ is created. Each instance has its
own independent configuration. Configuration keys are often called _properties_.

Every input plugin has its own documentation section that specifies how to use it
and what properties are available.

For more details, see [Input Plugins](https://docs.fluentbit.io/manual/pipeline/inputs).
