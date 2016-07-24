# Standard Output

The __stdout__ output plugin allows to print to the standard output the data received through the _input_ plugin. Their usage is very simple as follows:

```bash
$ bin/fluent-bit -i cpu -o stdout -v
```

We have specified to gather [CPU](../input/cpu.md) usage metrics and print them out to the standard output in a human readable way:

```bash
Fluent-Bit v0.8.3
Copyright (C) Treasure Data

[2016/07/24 21:20:22] [ info] starting engine
[2016/07/24 21:20:22] [debug] [router] default match rule cpu.0:stdout.0
[0] (null): [1469362823, {"cpu_p"=>0.000000, "user_p"=>0.000000, "system_p"=>0.000000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000}]
[1] (null): [1469362824, {"cpu_p"=>2.000000, "user_p"=>2.000000, "system_p"=>0.000000, "cpu0.p_cpu"=>2.000000, "cpu0.p_user"=>2.000000, "cpu0.p_system"=>0.000000}]
[2] (null): [1469362825, {"cpu_p"=>1.000000, "user_p"=>1.000000, "system_p"=>0.000000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000}]
[3] (null): [1469362826, {"cpu_p"=>1.000000, "user_p"=>1.000000, "system_p"=>0.000000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000}]
```

No more, no less, it just works.
