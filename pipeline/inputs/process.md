# Process Metrics
<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=91b97a84-1cd9-41fb-9189-a4f3b30b6bce" />

_Process_ input plugin allows you to check how healthy a process is. It does so by performing a service check at every certain interval of time specified by the user.

The Process metrics plugin creates metrics that are log-based, such as JSON payload.
For Prometheus-based metrics, see the Node Exporter Metrics input plugin.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Proc\_Name | Name of the target Process to check. |
| Interval\_Sec | Interval in seconds between the service checks. Default value is _1_. |
| Interval\_Nsec | Specify a nanoseconds interval for service checks, it works in conjunction with the Interval\_Sec configuration key. Default value is _0_. |
| Alert | If enabled, it will only generate messages if the target process is down. By default this option is disabled. |
| Fd | If enabled, a number of fd is appended to each records. Default value is true. |
| Mem | If enabled, memory usage of the process is appended to each records. Default value is true. |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

The following example will check the health of _crond_ process.

```bash
$ fluent-bit -i proc -p proc_name=crond -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

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

Once Fluent Bit is running, you will see the health of process:

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
