# Output

The output interface allows to define destinations for the data. Common destinations are remote services, local file system or standard interface within others. Otputs are implemented as plugins and there are many available.

![](../.gitbook/assets/logging_pipeline_output%20%281%29.png)

When an output plugin is loaded, an internal _instance_ is created. Every instance have it own and independent configuration. Configuration keys are often called **properties**.

Every output plugin has its own documentation section where it's specified how it can be used and what properties are available.

For more details, please refer to the [Output Plugins](../output/) section.

