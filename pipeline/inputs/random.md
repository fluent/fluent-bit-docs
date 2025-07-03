# Random

The _Random_ input plugin generates random value samples using the device interface `/dev/urandom`. If that interface is unavailable, it uses a Unix timestamp as a value.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `Samples` | Specifies the number of samples to generate. The default value of `-1` generates unlimited samples. | `-1` |
| `Interval_Sec` | Specifies the interval between generated samples, in seconds. | `1` |
| `Interval_Nsec` | Specifies the interval between generated samples, in nanoseconds. This works in conjunction with `Interval_Sec`. | `0` |
| `Threaded` | Specifies whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To start generating random samples, you can either run the plugin from the command line or through a configuration file.

### Command line

Use the following command line options to generate samples.

```shell
$ fluent-bit -i random -o stdout
```

### Configuration file

The following examples are sample configuration files for this input plugin:

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

After Fluent Bit starts running, it generates reports in the output interface:

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
