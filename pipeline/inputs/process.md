# Process metrics
<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=91b97a84-1cd9-41fb-9189-a4f3b30b6bce" />

The _Process metrics_ input plugin lets you check how healthy a process is. It does so by performing service checks at specified intervals.

This plugin creates metrics that are log-based, such as JSON payloads. For Prometheus-based metrics, see the [Node exporter metrics](../pipeline/inputs/node-exporter-metrics) input plugin.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `Proc_Name` | The name of the target process to check. | _none_ |
| `Interval_Sec` | Specifies the interval between service checks, in seconds. | `1` |
| `Interval_Nsec` | Specifies the interval between service checks, in nanoseconds. This works in conjunction with `Interval_Sec`. | `0` |
| `Alert` | If enabled, the plugin will only generate messages if the target process is down. | `false` |
| `Fd` | If enabled, a number of `fd` is appended to each record. | `true` |
| `Mem` | If enabled, memory usage of the process is appended to each record. | `true` |
| `Threaded` | Specifies whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To start performing the checks, you can run the plugin from the command line or through the configuration file:

The following example checks the health of `crond` process.

```shell
fluent-bit -i proc -p proc_name=crond -o stdout
```

### Configuration file

In your main configuration file, append the following `Input` & `Output` sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: proc
          proc_name: crond
          interval_sec: 1
          interval_nsec: 0
          fd: true
          mem: true

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

## Testing

After Fluent Bit starts running, it outputs the health of the process:

```shell
$ fluent-bit -i proc -p proc_name=fluent-bit -o stdout

Fluent Bit v4.0.3
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/07/01 14:44:47] [ info] [fluent bit] version=4.0.3, commit=f5f5f3c17d, pid=1
[2025/07/01 14:44:47] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/01 14:44:47] [ info] [simd    ] disabled
[2025/07/01 14:44:47] [ info] [cmetrics] version=1.0.3
[2025/07/01 14:44:47] [ info] [ctraces ] version=0.6.6
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] initializing
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] storage_strategy='memory' (memory only)
[2025/07/01 14:44:47] [ info] [sp] stream processor started
[2025/07/01 14:44:47] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
[2025/07/01 14:44:47] [ info] [output:stdout:stdout.0] worker #0 started
[0] proc.0: [1485780297, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1120000, "mem.VmRSS"=>1120000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[1] proc.0: [1485780298, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1148000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[2] proc.0: [1485780299, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1152000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
[3] proc.0: [1485780300, {"alive"=>true, "proc_name"=>"fluent-bit", "pid"=>10964, "mem.VmPeak"=>14740000, "mem.VmSize"=>14740000, "mem.VmLck"=>0, "mem.VmHWM"=>1152000, "mem.VmRSS"=>1148000, "mem.VmData"=>2276000, "mem.VmStk"=>88000, "mem.VmExe"=>1768000, "mem.VmLib"=>2328000, "mem.VmPTE"=>68000, "mem.VmSwap"=>0, "fd"=>18}]
```
