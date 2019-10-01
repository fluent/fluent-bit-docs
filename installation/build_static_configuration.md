# Build with Static Configuration

[Fluent Bit](https://fluentbit.io) in normal operation mode allows to be configurable through [text files](../configuration/file.md) or using specific arguments in the command line, while this is the ideal deployment case, there are scenarios where a more restricted configuration is required: static configuration mode.

Static configuration mode aims to include a built-in configuration in the final binary of Fluent Bit, disabling the usage of external files or flags at runtime.

## Getting Started

### Requirements

The following steps assumes you are familiar with configuring Fluent Bit using text files and you have experience building it from scratch as described in the [Build and Install](build_install.md) section.

#### Configuration Directory

In your file system prepare a specific directory that will be used as an entry point for the build system to lookup and parse the configuration files. It is mandatory that this directory contain as a minimum one configuration file called _fluent-bit.conf_ containing the required [SERVICE](../configuration/file.md#config_section), [INPUT](https://github.com/fluent/fluent-bit-docs/tree/3814724806a7bdb7bc882f57a4e318b167afb487/installation/configuration/file.md#config_input) and [OUTPUT](../configuration/file.md#config_output) sections. As an example create a new _fluent-bit.conf_ file with the following content:

```python
[SERVICE]
    Flush     1
    Daemon    off
    Log_Level info

[INPUT]
    Name      cpu

[OUTPUT]
    Name      stdout
    Match     *
```

the configuration provided above will calculate CPU metrics from the running system and print them to the standard output interface.

#### Build with Custom Configuration

Inside Fluent Bit source code, get into the build/ directory and run CMake appending the FLB\_STATIC\_CONF option pointing the configuration directory recently created, e.g:

```bash
$ cd fluent-bit/build/
$ cmake -DFLB_STATIC_CONF=/path/to/my/confdir/
```

then build it:

```bash
$ make
```

At this point the fluent-bit binary generated is ready to run without necessity of further configuration:

```bash
$ bin/fluent-bit 
Fluent-Bit v0.15.0
Copyright (C) Treasure Data

[2018/10/19 15:32:31] [ info] [engine] started (pid=15186)
[0] cpu.local: [1539984752.000347547, {"cpu_p"=>0.750000, "user_p"=>0.500000, "system_p"=>0.250000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
```

