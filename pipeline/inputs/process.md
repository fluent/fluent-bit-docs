# Process metrics
<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=91b97a84-1cd9-41fb-9189-a4f3b30b6bce" />

The _Process metrics_ input plugin lets you check how healthy a process is. It does so by performing a service check at a specified interval.

This plugin creates metrics that are log-based, such as JSON payloads. For Prometheus-based metrics, see the [Node exporter metrics](../pipeline/inputs/node-exporter-metrics) input plugin.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `Proc_Name` | The name of the target process to check. |
| `Interval_Sec` | Specifies the interval between service checks, in seconds. Default: `1`. |
| `Interval_Nsec` | Specify the interval between service checks, in nanoseconds. This works in conjunction with `Interval_Sec`. Default: `0`. |
| `Alert` | If enabled, the plugin will only generate messages if the target process is down. Default: `false`. |
| `Fd` | If enabled, a number of `fd` is appended to each record. Default: `true`. |
| `Mem` | If enabled, memory usage of the process is appended to each record. Default: `true`. |
| `Threaded` | Specifies whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

## Getting started

To start performing the checks, you can run the plugin from the command line or through the configuration file:

The following example checks the health of `crond` process.

```bash
$ fluent-bit -i proc -p proc_name=crond -o stdout
```

### Configuration file

In your main configuration file, append the following `Input` & `Output` sections:

```python
[INPUT]
    Name          proc
    Proc_Name     crond
    Interval_Sec  1
    Interval_NSec 0
    Fd            true
    Mem           true

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

After Fluent Bit starts running, it outputs the health of the process:

```bash
$ fluent-bit -i proc -p proc_name=fluent-bit -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/01/30 21:44:56] [ info] [engine] started
[0] proc.0: [1485780297, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1120000, "mem.VmRSS"=>1120000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[1] proc.0: [1485780298, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1148000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[2] proc.0: [1485780299, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1152000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[3] proc.0: [1485780300, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1152000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
```
