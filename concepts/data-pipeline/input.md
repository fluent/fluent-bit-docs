---
description: The way to gather data from your sources
---

# Input

[Fluent Bit](http://fluentbit.io) provides different _Input Plugins_ to gather information from different sources, some of them just collect data from log files while others can gather metrics information from the operating system. There are many plugins for different needs.

```mermaid
graph LR
    accTitle: Fluent Bit data pipeline
    accDescr: The Fluent Bit data pipeline includes input, a parser, a filter, a buffer, routing, and various outputs.
    A[Input] --> B[Parser]
    B --> C[Filter]
    C --> D[Buffer]
    D --> E((Routing))
    E --> F[Output 1]
    E --> G[Output 2]
    E --> H[Output 3]
    style A stroke:darkred,stroke-width:2px;
```

When an input plugin is loaded, an internal _instance_ is created. Every instance has its own and independent configuration. Configuration keys are often called **properties**.

Every input plugin has its own documentation section where it's specified how it can be used and what properties are available.

For more details, please refer to the [Input Plugins](https://docs.fluentbit.io/manual/pipeline/inputs) section.
