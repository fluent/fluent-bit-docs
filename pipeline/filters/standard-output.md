# Standard output

The standard output filter allows printing the data flowing through the filter plugin to `stdout`, which can be used while debugging.

The plugin has no configuration parameters.

## Command line

Use the following command from the command line:

```shell
$ ./fluent-bit -i cpu -F stdout -m '*' -o null
```

Fluent Bit specifies gathering [CPU](../inputs/cpu-metrics.md) usage metrics and prints them out in a human-readable way when they flow through the stdout plugin.

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


[2025/07/03 16:15:34] [ info] [fluent bit] version=4.0.3, commit=3a91b155d6, pid=23196
[2025/07/03 16:15:34] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/03 16:15:34] [ info] [simd    ] disabled
[2025/07/03 16:15:34] [ info] [cmetrics] version=1.0.3
[2025/07/03 16:15:34] [ info] [ctraces ] version=0.6.6
[2025/07/03 16:15:34] [ info] [input:dummy:dummy.0] initializing
[2025/07/03 16:15:34] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2025/07/03 16:15:34] [ info] [output:stdout:stdout.0] worker #0 started
[2025/07/03 16:15:34] [ info] [sp] stream processor started
[0] cpu.0: [1622789640.379532062, {"cpu_p"=>9.000000, "user_p"=>6.500000, "system_p"=>2.500000, "cpu0.p_cpu"=>8.000000, "cpu0.p_user"=>6.000000, "cpu0.p_system"=>2.000000, "cpu1.p_cpu"=>9.000000, "cpu1.p_user"=>6.000000, "cpu1.p_system"=>3.000000}]
[0] cpu.0: [1622789641.379529426, {"cpu_p"=>22.500000, "user_p"=>18.000000, "system_p"=>4.500000, "cpu0.p_cpu"=>34.000000, "cpu0.p_user"=>30.000000, "cpu0.p_system"=>4.000000, "cpu1.p_cpu"=>11.000000, "cpu1.p_user"=>6.000000, "cpu1.p_system"=>5.000000}]
[0] cpu.0: [1622789642.379544020, {"cpu_p"=>26.500000, "user_p"=>16.000000, "system_p"=>10.500000, "cpu0.p_cpu"=>30.000000, "cpu0.p_user"=>24.000000, "cpu0.p_system"=>6.000000, "cpu1.p_cpu"=>22.000000, "cpu1.p_user"=>8.000000, "cpu1.p_system"=>14.000000}]
[0] cpu.0: [1622789643.379507371, {"cpu_p"=>39.500000, "user_p"=>34.500000, "system_p"=>5.000000, "cpu0.p_cpu"=>52.000000, "cpu0.p_user"=>48.000000, "cpu0.p_system"=>4.000000, "cpu1.p_cpu"=>28.000000, "cpu1.p_user"=>21.000000, "cpu1.p_system"=>7.000000}]
^C[2021/06/04 14:54:04] [engine] caught signal (SIGINT)
[2021/06/04 14:54:04] [ info] [input] pausing cpu.0
[2021/06/04 14:54:04] [ warn] [engine] service will stop in 5 seconds
[2021/06/04 14:54:08] [ info] [engine] service stopped
```