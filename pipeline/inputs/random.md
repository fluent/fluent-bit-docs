# Random

_Random_ input plugin generate very simple random value samples using the device interface _/dev/urandom_, if not available it will use a unix timestamp as value.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Samples | If set, it will only generate a specific number of samples. By default this value is set to _-1_, which will generate unlimited samples. |
| Interval\_Sec | Interval in seconds between samples generation. Default value is _1_. |
| Interval\_Nsec | Specify a nanoseconds interval for samples generation, it works in conjunction with the Interval\_Sec configuration key. Default value is _0_. |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

## Getting Started

In order to start generating random samples, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit generate the samples with the following options:

```shell
$ fluent-bit -i random -o stdout
```

### Configuration File

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: random
          samples: -1
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
    Name          random
    Samples      -1
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```shell
$ fluent-bit -i random -o stdout

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
[0] random.0: [1475893654, {"rand_value"=>1863375102915681408}]
[1] random.0: [1475893655, {"rand_value"=>425675645790600970}]
[2] random.0: [1475893656, {"rand_value"=>7580417447354808203}]
[3] random.0: [1475893657, {"rand_value"=>1501010137543905482}]
[4] random.0: [1475893658, {"rand_value"=>16238242822364375212}]
```