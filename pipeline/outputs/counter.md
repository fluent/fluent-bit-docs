# Counter

_Counter_ is a very simple plugin that counts how many records it's getting upon flush time. Plugin output is as follows:

```text
[TIMESTAMP, NUMBER_OF_RECORDS_NOW] (total = RECORDS_SINCE_IT_STARTED)
```

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```shell
fluent-bit -i cpu -o counter
```

### Configuration File

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: cpu
          
    outputs:
        - name: counter
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name cpu
    Tag  cpu

[OUTPUT]
    Name  counter
    Match *
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```shell
$ bin/fluent-bit -i cpu -o counter -f 1

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


[2025/07/11 16:49:57] [ info] [fluent bit] version=4.0.3, commit=37b6e9eda2, pid=52469
[2025/07/11 16:49:57] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/11 16:49:57] [ info] [simd    ] disabled
[2025/07/11 16:49:57] [ info] [cmetrics] version=1.0.3
[2025/07/11 16:49:57] [ info] [ctraces ] version=0.6.6
[2025/07/11 16:49:57] [ info] [sp] stream processor started
[2025/07/11 16:49:57] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
1500484743,1 (total = 1)
1500484744,1 (total = 2)
1500484745,1 (total = 3)
1500484746,1 (total = 4)
1500484747,1 (total = 5)
```