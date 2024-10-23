# Process Metrics

The Process Metrics input plugin lets you gather metrics from a process. When using a process name like a non-numeric process parameter, the process metrics plugin  tracks all processes that match.

The Process metrics plugin creates `cmetrics` based metrics. For log-based metrics like JSON payload,  use the [Process Log Based Metrics](pipeline/inputs/process.md) plugin instead.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key     | Description                                                                              |
| :---    | :---                                                                                     |
| Process | Name or PID the target Process to check, defaults to the current instance of fluent-bit. |

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

The following example will check the health of `crond` process.

```bash
$ fluent-bit -i proc_metrics -p process=crond -o stdout
```

### Configuration File

In your main configuration file append the following `Input` and  `Output` sections:

```python
[INPUT]
    Name          proc_metrics
    Process       crond

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you can see the metrics for the process:

```bash
$ fluent-bit -i proc_metrics -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2021/09/21 11:54:24] [ info] [engine] started (pid=1705018)
[2021/09/21 11:54:24] [ info] [storage] version=1.1.1, initializing...
[2021/09/21 11:54:24] [ info] [storage] in-memory
[2021/09/21 11:54:24] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/09/21 11:54:24] [ info] [cmetrics] version=0.2.1
[2021/09/21 11:54:24] [ info] [sp] stream processor started
2021-09-21T14:54:25.224786230Z proc_metrics_io_rchar{pid="1705018",cmdline="fluent-bit"} = 44965
2021-09-21T14:54:25.224786230Z proc_metrics_io_wchar{pid="1705018",cmdline="fluent-bit"} = 25367
2021-09-21T14:54:25.224786230Z proc_metrics_io_syscr{pid="1705018",cmdline="fluent-bit"} = 41
2021-09-21T14:54:25.224786230Z proc_metrics_io_syscw{pid="1705018",cmdline="fluent-bit"} = 18
2021-09-21T14:54:25.224786230Z proc_metrics_io_read_bytes{pid="1705018",cmdline="fluent-bit"} = 2818048
2021-09-21T14:54:25.224786230Z proc_metrics_io_write_bytes{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:25.224786230Z proc_metrics_io_cancelled_write_bytes{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:25.224786230Z proc_metrics_mem_size{pid="1705018",cmdline="fluent-bit"} = 13040
2021-09-21T14:54:25.224786230Z proc_metrics_mem_resident{pid="1705018",cmdline="fluent-bit"} = 2771
2021-09-21T14:54:25.224786230Z proc_metrics_mem_shared{pid="1705018",cmdline="fluent-bit"} = 2285
2021-09-21T14:54:25.224786230Z proc_metrics_mem_trs{pid="1705018",cmdline="fluent-bit"} = 1486
2021-09-21T14:54:25.224786230Z proc_metrics_mem_lrs{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:25.224786230Z proc_metrics_mem_drs{pid="1705018",cmdline="fluent-bit"} = 8231
2021-09-21T14:54:25.224786230Z proc_metrics_mem_dt{pid="1705018",cmdline="fluent-bit"} = 0
^C[2021/09/21 11:54:31] [engine] caught signal (SIGINT)
2021-09-21T14:54:30.224519586Z proc_metrics_io_rchar{pid="1705018",cmdline="fluent-bit"} = 45773
2021-09-21T14:54:30.224519586Z proc_metrics_io_wchar{pid="1705018",cmdline="fluent-bit"} = 26821
2021-09-21T14:54:30.224519586Z proc_metrics_io_syscr{pid="1705018",cmdline="fluent-bit"} = 67
2021-09-21T14:54:30.224519586Z proc_metrics_io_syscw{pid="1705018",cmdline="fluent-bit"} = 25
2021-09-21T14:54:30.224519586Z proc_metrics_io_read_bytes{pid="1705018",cmdline="fluent-bit"} = 2818048
2021-09-21T14:54:30.224519586Z proc_metrics_io_write_bytes{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:30.224519586Z proc_metrics_io_cancelled_write_bytes{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:30.224519586Z proc_metrics_mem_size{pid="1705018",cmdline="fluent-bit"} = 13040
2021-09-21T14:54:30.224519586Z proc_metrics_mem_resident{pid="1705018",cmdline="fluent-bit"} = 2771
2021-09-21T14:54:30.224519586Z proc_metrics_mem_shared{pid="1705018",cmdline="fluent-bit"} = 2285
2021-09-21T14:54:30.224519586Z proc_metrics_mem_trs{pid="1705018",cmdline="fluent-bit"} = 1486
2021-09-21T14:54:30.224519586Z proc_metrics_mem_lrs{pid="1705018",cmdline="fluent-bit"} = 0
2021-09-21T14:54:30.224519586Z proc_metrics_mem_drs{pid="1705018",cmdline="fluent-bit"} = 8231
2021-09-21T14:54:30.224519586Z proc_metrics_mem_dt{pid="1705018",cmdline="fluent-bit"} = 0
[2021/09/21 11:54:31] [ warn] [engine] service will stop in 5 seconds
[2021/09/21 11:54:32] [error] [input:proc_metrics:proc_metrics.0] could not append metrics
[2021/09/21 11:54:33] [error] [input:proc_metrics:proc_metrics.0] could not append metrics
[2021/09/21 11:54:34] [error] [input:proc_metrics:proc_metrics.0] could not append metrics
[2021/09/21 11:54:35] [error] [input:proc_metrics:proc_metrics.0] could not append metrics
[2021/09/21 11:54:36] [ info] [engine] service stopped
```
