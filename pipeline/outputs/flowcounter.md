# FlowCounter

_FlowCounter_ is the protocol to count records. The **flowcounter** output plugin allows to count up records and its size.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Unit | The unit of duration. \(second/minute/hour/day\) | minute |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```bash
fluent-bit -i cpu -o flowcounter
```

### Configuration File

In your main configuration file append the following Input & Output sections:

```python
[INPUT]
    Name cpu
    Tag  cpu

[OUTPUT]
    Name flowcounter
    Match *
    Unit second
```

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```bash
$ fluent-bit -i cpu -o flowcounter
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2016/12/23 11:01:20] [ info] [engine] started
[out_flowcounter] cpu.0:[1482458540, {"counts":60, "bytes":7560, "counts/minute":1, "bytes/minute":126 }]
```
