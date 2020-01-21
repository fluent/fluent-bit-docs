# Overview

Stream Processing is the ability to query continuous data streams while they are still in motion. [Fluent Bit](https://fluentbit.io) implements a Streaming SQL Engine that can be used for such process.

In order to understand how Stream Processing works in Fluent Bit, we will go through a quick overview of Fluent Bit architecture and how the data goes through the pipeline.

## Fluent Bit Data Pipeline

[Fluent Bit](https://fluentbit.io) collects and process logs (records) from different input sources and allows to parse and filter these records before they hit the Storage interface. One data is processed and it's in a safe state (either in memory or the file system), the records are routed through the proper output destinations.

> Most of the phases in the pipeline are implemented through plugins: Input, Filter and Output.

![](../imgs/flb_pipeline.png)

The Filtering interface is good to perform specific record modifications like append or remove a key, enrich with specific metadata (e.g: Kubernetes Filter) or discard records based on specific conditions. Just after the data will not have any further modification and hits the Storage, optionally, will be redirected to the Stream Processor.

## Stream Processor 

The Stream Processor is an independent subsystem that check for new records hitting the Storage interface. By configuration the Stream Processor will attach to records coming from a specific Input plugin (stream) or by applying Tag and Matching rules.

>  Every _Input_ instance is considered a __Stream__, that stream collects data and ingest records into the pipeline. 

![](../imgs/flb_pipeline_sp.png)

By configuring specific SQL queries (Structured Query Language), the user can perform specific tasks like key selections, filtering and data aggregation within others. Note that there is __no__ database concept here, everything is **schema-less** and happens **in-memory**, for hence the concept of _Tables_ as in common relational databases don't exists. 

One of the powerful features of Fluent Bit Stream Processor is that allows to create new streams of data  using the results from a previous SQL query, these results are re-ingested back into the pipeline to be consumed again for the Stream Processor (if desired) or routed to output destinations such any common record by using Tag/Matching rules (tip: stream processor results can be Tagged!)

