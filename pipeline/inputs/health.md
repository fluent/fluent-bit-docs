# Health

The _Health_ input plugin lets you check how healthy a TCP server is. It checks by issuing a TCP connection at regular intervals.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Host` | Name of the target host or IP address. | _none_ |
| `Port` | TCP port where to perform the connection request. | _none_ |
| `Interval_Sec` | Interval in seconds between the service checks.| `1` |
| `Internal_Nsec` | Specify a nanoseconds interval for service checks. Works in conjunction with the `Interval_Sec` configuration key. | `0` |
| `Alert` | If enabled, it generates messages if the target TCP service is down. | `false` |
| `Add_Host` | If enabled, hostname is appended to each records. | `false` |
| `Add_Port` | If enabled, port number is appended to each records. | `false` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can let Fluent Bit generate the checks with the following options:

```shell
$ fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: health
          host: 127.0.0.1
          port: 80
          interval_sec: 1
          interval_nsec: 0
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name          health
    Host          127.0.0.1
    Port          80
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see some random values in the output interface similar to this:

```shell
$ fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout

Fluent Bit v4.0.0
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/06/30 16:12:06] [ info] [fluent bit] version=4.0.0, commit=3a91b155d6, pid=91577
[2025/06/30 16:12:06] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/06/30 16:12:06] [ info] [simd    ] disabled
[2025/06/30 16:12:06] [ info] [cmetrics] version=0.9.9
[2025/06/30 16:12:06] [ info] [ctraces ] version=0.6.2
[2025/06/30 16:12:06] [ info] [input:health:health.0] initializing
[2025/06/30 16:12:06] [ info] [input:health:health.0] storage_strategy='memory' (memory only)
[2025/06/30 16:12:06] [ info] [sp] stream processor started
[2025/06/30 16:12:06] [ info] [output:stdout:stdout.0] worker #0 started
[0] health.0: [1624145988.305640385, {"alive"=>true}]
[1] health.0: [1624145989.305575360, {"alive"=>true}]
[2] health.0: [1624145990.306498573, {"alive"=>true}]
[3] health.0: [1624145991.305595498, {"alive"=>true}]
```