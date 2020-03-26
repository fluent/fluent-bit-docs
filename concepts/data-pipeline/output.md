---
description: 'Destinations for your data: databases, cloud services and more'
---

# Output

The output interface allows us to define destinations for the data. Common destinations are remote services, local file system or standard interface with others. Outputs are implemented as plugins and there are many available.

![](../../.gitbook/assets/logging_pipeline_output.png)

When an output plugin is loaded, an internal _instance_ is created. Every instance has its own independent configuration. Configuration keys are often called **properties**.

Every output plugin has its own documentation section specifying how it can be used and what properties are available.

For more details, please refer to the [Output Plugins](https://github.com/fluent/fluent-bit-docs/tree/31ef18ea4f94004badcc169d0e12e60967d50ef9/concepts/output/README.md) section.

