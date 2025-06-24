---
description: Learn about destinations for your data, such as databases and cloud services.
---

# Output

The output interface lets you define destinations for your data. Common destinations
are remote services, local file systems, or other standard interfaces. Outputs are
implemented as plugins.

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
    style F stroke:darkred,stroke-width:2px;
    style G stroke:darkred,stroke-width:2px;
    style H stroke:darkred,stroke-width:2px;
```

When an output plugin is loaded, an internal _instance_ is created. Every instance
has its own independent configuration. Configuration keys are often called
_properties_.

Every output plugin has its own documentation section specifying how it can be used and what properties are available.

For more details, see [Output Plugins](https://docs.fluentbit.io/manual/pipeline/outputs).
