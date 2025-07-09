# Memory metrics

The  _Memory_ (`mem`) input plugin gathers information about the memory and swap usage of the running system every certain interval of time and reports the total amount of memory and the amount of free available.

## Get started

To get memory and swap usage from your system, you can run the plugin from the command line or through the configuration file:

### Command line

Run the following command from the command line, noting this is for a Linux machine:

```shell
fluent-bit -i mem -t memory -o stdout -m '*'
```

Which outputs information similar to:

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
[0] memory: [[1751381087.225589224, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381088.228411537, {}], {"Mem.total"=>3986708, "Mem.used"=>560708, "Mem.free"=>3426000, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381089.225600084, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
[0] memory: [[1751381090.228345064, {}], {"Mem.total"=>3986708, "Mem.used"=>561480, "Mem.free"=>3425228, "Swap.total"=>0, "Swap.used"=>0, "Swap.free"=>0}]
```

## Threading

You can enable the `threaded` setting to run this input in its own
[thread](../../administration/multithreading.md#inputs).

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mem
          tag: memory

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name   mem
    Tag    memory

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}