# Filter

In production environments we want to have full control of the data we are collecting, filtering is an important feature that allows to __alter__ the data before to deliver it to some destination.

![](../diagrams/logging_pipeline_filter.png)

Filtering is implemented through plugins, so each filter available could be used to match, exclude or enrich your logs with some specific metadata.

Very similar to the input plugins, Filters runs in an instance context, which it have it own and independent configuration. Configuration keys are often called __properties__.

For more details about the Filters available and it usage, please refer to the [Filters](../filter/README.md) section.
