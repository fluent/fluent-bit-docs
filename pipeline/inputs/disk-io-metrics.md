# Disk I/O Metrics

The **disk** input plugin, gathers the information about the disk throughput of the running system every certain interval of time and reports them.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Interval\_Sec | Polling interval \(seconds\).  | 1 |
| Interval\_NSec | Polling interval \(nanosecond\). | 0 |
| Dev\_Name | Device name to limit the target. \(e.g. sda\). If not set, _in\_disk_ gathers information from all of disks and partitions. | all disks |

## Getting Started

In order to get disk usage from your system, you can run the plugin from the command line or through the configuration file:

### Command Line

```bash
$ fluent-bit -i disk -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/01/28 16:58:16] [ info] [engine] started
[0] disk.0: [1485590297, {"read_size"=>0, "write_size"=>0}]
[1] disk.0: [1485590298, {"read_size"=>0, "write_size"=>0}]
[2] disk.0: [1485590299, {"read_size"=>0, "write_size"=>0}]
[3] disk.0: [1485590300, {"read_size"=>0, "write_size"=>11997184}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          disk
    Tag           disk
    Interval_Sec  1
    Interval_NSec 0
[OUTPUT]
    Name   stdout
    Match  *
```

Note: Total interval \(sec\) = Interval\_Sec + \(Interval\_Nsec / 1000000000\).

e.g. 1.5s = 1s + 500000000ns

