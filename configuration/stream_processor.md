# Stream Processor

Fluent Bit v1.1 comes with a new and optional Stream Processor Engine that allows to do data processing through SQL queries. This article covers the format of the expected configuration file.

For more details about the Stream Processor Engine use please refer to the following guide:

* [https://docs.fluentbit.io/stream-processing/](https://docs.fluentbit.io/stream-processing/)

## Concepts

The stream processor can be configured through defining Tasks which have a name and an execution SQL statement:

| Concept | Description |
| :--- | :--- |
| Task | Definition of a Stream Processor task to be executed. A task is defined through a section called _STREAM\_TASK_. |
| Name | Tasks have a name for debugging and testing purposes. |
| Exec | SQL statement to be executed when a Task runs. |

## Streams File Configuration

The Stream Processor is configured through a _streams file_ that is referenced from the main _fluent-bit.conf_ configuration file through the _Streams\_File_ key. The content of the streams file must have the following format specified in the table below:

| Section | Key | Description | Mandatory? |
| :--- | :--- | :--- | :--- |
| STREAM\_TASK |  |  |  |
|  | Name | Set a name for the task in question. The value is used as a reference only. | Yes |
|  | Exec | SQL statement to be executed by the task. Note that the SQL statement must be finished with a semicolon.  The SQL statement **must** be set in one single line \(no multiline support in the configuration\) | Yes |

## Configuration Example

Consider the following _fluent-bit.conf_ configuration file:

```text
[SERVICE]
    Flush        1
    Log_Level    info
    Streams_File stream_processor.conf

[INPUT]
    Name         cpu
    alias        cpu_data

[OUTPUT]
    Name         stdout
    Match        results
```

Now creates a _stream\_processor.conf_ configuration file with the following content:

```text
[STREAM_TASK]
    Name   cpu_test
    Exec   CREATE STREAM cpu WITH (tag='results') AS SELECT AVG(cpu_p) from STREAM:cpu_data WINDOW TUMBLING (5 SECOND);
```

On the query there are a few things happening:

* Fluent Bit will gather CPU usage metrics through [CPU input plugin](../input/cpu.md) \(metrics are calculated by default every second\).
* Stream Processor have a Task attached to any incoming Stream of data called _cpu\_data_ \(check the alias set in the Input section\).
* Stream Processor will aggregate the value of _cpu\_p_ record field and calculate it average during a window of 5 seconds. 
* Stream Processor every 5 seconds will send the results back into Fluent Bit pipeline with a tag called _results_.
* Fluent Bit output section will match _results_ tagged records and print them to the standard output interface.

You should see the following output in your terminal:

```text
$ bin/fluent-bit -c fluent-bit.conf 
Fluent Bit v1.1.0
Copyright (C) Treasure Data

[2019/05/17 11:26:34] [ info] [storage] initializing...
[2019/05/17 11:26:34] [ info] [storage] in-memory
[2019/05/17 11:26:34] [ info] [storage] normal synchronization mode, checksum disabled
[2019/05/17 11:26:34] [ info] [engine] started (pid=16769)
[2019/05/17 11:26:34] [ info] [sp] stream processor started
[2019/05/17 11:26:34] [ info] [sp] registered task: cpu_test
[0] results: [1558085199.000175517, {"AVG(cpu_p)"=>2.750000}]
[0] results: [1558085204.000151430, {"AVG(cpu_p)"=>3.400000}]
[0] results: [1558085209.000131753, {"AVG(cpu_p)"=>1.700000}]
[0] results: [1558085214.000147562, {"AVG(cpu_p)"=>3.500000}]
[0] results: [1558085219.000118591, {"AVG(cpu_p)"=>2.050000}]
[0] results: [1558085224.000179645, {"AVG(cpu_p)"=>26.375000}]
```

If you want to learn more about our Stream Processor engine please read the [official guide](https://docs.fluentbit.io/stream-processing/).

