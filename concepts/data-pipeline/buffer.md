---
description: Data processing with reliability
---

# Buffer

The [`buffer`](../buffering.md) phase in the pipeline aims to provide a unified and
persistent mechanism to store your data, using the primary in-memory model or the
file system-based mode.

The `buffer` phase contains the data in an immutable state, meaning that no other
filter can be applied.

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

Buffered data uses the Fluent Bit internal binary representation, which isn't raw text.

Fluent Bit offers a buffering mechanism in the file system that acts as a backup
system to avoid data loss in case of system failures.
