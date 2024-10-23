---
description: Data processing with reliability
---

# Buffer

Previously defined in the [Buffering](../buffering.md) concept section, the `buffer` phase in the pipeline aims to provide a unified and persistent mechanism to store your data, either using the primary in-memory model or using the filesystem based mode.

The `buffer` phase already contains the data in an immutable state, meaning that no other filter can be applied.

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
    style D stroke:darkred,stroke-width:2px;
```

{% hint style="info" %}
Note that buffered data is not raw text, it's in Fluent Bit's internal binary representation.
{% endhint %}

Fluent Bit offers a buffering mechanism in the file system that acts as a _backup system_ to avoid data loss in case of system failures.
