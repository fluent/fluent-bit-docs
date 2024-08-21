---
description: Modify, Enrich or Drop your records
---

# Filter

In production environments we want to have full control of the data we are collecting, filtering is an important feature that allows us to **alter** the data before delivering it to some destination.

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
    style C stroke:darkred,stroke-width:2px;
```

Filtering is implemented through plugins, so each filter available could be used to match, exclude or enrich your logs with some specific metadata.

We support many filters, A common use case for filtering is Kubernetes deployments. Every Pod log needs to get the proper metadata associated

Very similar to the input plugins, Filters run in an instance context, which has its own independent configuration. Configuration keys are often called **properties**.

For more details about the Filters available and their usage, please refer to the [Filters](https://docs.fluentbit.io/manual/pipeline/filters) section.
