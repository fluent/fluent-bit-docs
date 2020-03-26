# Variables

Fluent Bit supports the usage of environment variables in any value associated to a key when using a configuration file.

The variables are case sensitive and can be used in the following format:

```text
${MY_VARIABLE}
```

When Fluent Bit starts, the configuration reader will detect any request for `${MY_VARIABLE}` and will try to resolve its value.

## Example

Create the following configuration file \(`fluent-bit.conf`\):

```text
[SERVICE]
    Flush        1
    Daemon       Off
    Log_Level    info

[INPUT]
    Name cpu
    Tag  cpu.local

[OUTPUT]
    Name  ${MY_OUTPUT}
    Match *
```

Open a terminal and set the environment variable:

```bash
$ export MY_OUTPUT=stdout
```

> The above command set the 'stdout' value to the variable `MY_OUTPUT`.

Run Fluent Bit with the recently created configuration file:

```text
$ bin/fluent-bit -c fluent-bit.conf
Fluent-Bit v0.11.0
Copyright (C) Treasure Data

[2017/04/03 12:25:25] [ info] [engine] started
[0] cpu.local: [1491243925, {"cpu_p"=>1.750000, "user_p"=>1.750000, "system_p"=>0.000000, "cpu0.p_cpu"=>3.000000, "cpu0.p_user"=>2.000000, "cpu0.p_system"=>1.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>4.000000, "cpu2.p_user"=>4.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
```

As you can see the service worked properly as the configuration was valid.

