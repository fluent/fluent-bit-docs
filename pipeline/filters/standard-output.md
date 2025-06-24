# Standard output

The standard output filter allows printing the data flowing through the filter plugin to `stdout`, which can be used while debugging.

The plugin has no configuration parameters.

## Command line

Use the following command from the command line:

```shell
fluent-bit -i cpu -F stdout -m '*' -o null
```

Fluent Bit specifies gathering [CPU](../inputs/cpu-metrics.md) usage metrics and prints them out in a human-readable way when they flow through the stdout plugin.

```text
Fluent Bit v1.x.x
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2021/06/04 14:53:59] [ info] [engine] started (pid=3236719)
[2021/06/04 14:53:59] [ info] [storage] version=1.1.1, initializing...
[2021/06/04 14:53:59] [ info] [storage] in-memory
[2021/06/04 14:53:59] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/06/04 14:53:59] [ info] [sp] stream processor started
[0] cpu.0: [1622789640.379532062, {"cpu_p"=>9.000000, "user_p"=>6.500000, "system_p"=>2.500000, "cpu0.p_cpu"=>8.000000, "cpu0.p_user"=>6.000000, "cpu0.p_system"=>2.000000, "cpu1.p_cpu"=>9.000000, "cpu1.p_user"=>6.000000, "cpu1.p_system"=>3.000000}]
[0] cpu.0: [1622789641.379529426, {"cpu_p"=>22.500000, "user_p"=>18.000000, "system_p"=>4.500000, "cpu0.p_cpu"=>34.000000, "cpu0.p_user"=>30.000000, "cpu0.p_system"=>4.000000, "cpu1.p_cpu"=>11.000000, "cpu1.p_user"=>6.000000, "cpu1.p_system"=>5.000000}]
[0] cpu.0: [1622789642.379544020, {"cpu_p"=>26.500000, "user_p"=>16.000000, "system_p"=>10.500000, "cpu0.p_cpu"=>30.000000, "cpu0.p_user"=>24.000000, "cpu0.p_system"=>6.000000, "cpu1.p_cpu"=>22.000000, "cpu1.p_user"=>8.000000, "cpu1.p_system"=>14.000000}]
[0] cpu.0: [1622789643.379507371, {"cpu_p"=>39.500000, "user_p"=>34.500000, "system_p"=>5.000000, "cpu0.p_cpu"=>52.000000, "cpu0.p_user"=>48.000000, "cpu0.p_system"=>4.000000, "cpu1.p_cpu"=>28.000000, "cpu1.p_user"=>21.000000, "cpu1.p_system"=>7.000000}]
^C[2021/06/04 14:54:04] [engine] caught signal (SIGINT)
[2021/06/04 14:54:04] [ info] [input] pausing cpu.0
[2021/06/04 14:54:04] [ warn] [engine] service will stop in 5 seconds
[2021/06/04 14:54:08] [ info] [engine] service stopped
```
