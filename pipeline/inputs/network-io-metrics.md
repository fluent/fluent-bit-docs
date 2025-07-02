# Network I/O metrics

The _Network I/O metrics_ (`netif`) input plugin gathers network traffic information of the running system at regular intervals, and reports them.

The Network I/O metrics plugin creates metrics that are log-based, such as JSON payload. For Prometheus-based metrics, see the Node Exporter metrics input plugin.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Interface` | Specify the network interface to monitor. For example, `eth0`. | _none_ |
| `Interval_Sec` | Polling interval (seconds). | `1` |
| `Interval_NSec` | Polling interval (nanosecond). | `0` |
| `Verbose` | If true, gather metrics precisely. | `false` |
| `Test_At_Init` | If true, testing if the network interface is valid at initialization. | `false` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To monitor network traffic from your system, you can run the plugin from the command line or through the configuration file:

### Command line

Run Fluent Bit using a command similar to the following:

```shell
$ fluent-bit -i netif -p interface=eth0 -o stdout
```

Which returns something the following:

```text
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
[0] netif.0: [1499524459.001698260, {"eth0.rx.bytes"=>89769869, "eth0.rx.packets"=>73357, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>4256474, "eth0.tx.packets"=>24293, "eth0.tx.errors"=>0}]
[1] netif.0: [1499524460.002541885, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[2] netif.0: [1499524461.001142161, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[3] netif.0: [1499524462.002612971, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: netif
          tag: netif
          interval_sec: 1
          interval_nsec: 0
          interface: eth0
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name          netif
    Tag           netif
    Interval_Sec  1
    Interval_NSec 0
    Interface     eth0

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

Which calculates using the formula: `Total interval (sec) = Interval_Sec + (Interval_Nsec / 1000000000)`.

For example: `1.5s = 1s + 500000000ns`