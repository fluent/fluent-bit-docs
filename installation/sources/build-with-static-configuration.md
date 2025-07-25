# Build with static configuration

[Fluent Bit](https://fluentbit.io) in normal operation mode is configurable through text files or using specific arguments in the command line. Although this is the ideal deployment case, there are scenarios where a more restricted configuration is required. Static configuration mode restricts configuration ability.

Static configuration mode includes a built-in configuration in the final binary of Fluent Bit, disabling the usage of external files or flags at runtime.

## Get started

### Requirements

The following steps assume you are familiar with configuring Fluent Bit using text files and you have experience building it from scratch as described in [Build and Install](build-and-install.md).

#### Configuration directory

In your file system, prepare a specific directory that will be used as an entry point for the build system to lookup and parse the configuration files. This directory must contain a minimum of one configuration file called `fluent-bit.conf` containing the required [SERVICE](/administration/configuring-fluent-bit/yaml/service-section.md), [INPUT](/concepts/data-pipeline/input.md), and [OUTPUT](/concepts/data-pipeline/output.md) sections.

As an example, create a new `fluent-bit.yaml` file or `fluent-bit.conf` file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    daemon: off
    log_level: info

pipeline:
    inputs:
        - name: cpu

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

This configuration calculates CPU metrics from the running system and prints them to the standard output interface.

#### Build with custom configuration

1. Go to the Fluent Bit source code build directory:

   ```bash copy
   cd fluent-bit/build/
   ```

1. Run CMake, appending the `FLB_STATIC_CONF` option pointing to
   the configuration directory recently created:

   ```bash copy
   cmake -DFLB_STATIC_CONF=/path/to/my/confdir/
   ```

1. Build Fluent Bit:

   ```bash copy
   make
   ```

The generated `fluent-bit` binary is ready to run without additional configuration:

```bash
$ bin/fluent-bit
Fluent-Bit v0.15.0
Copyright (C) Treasure Data

[2018/10/19 15:32:31] [ info] [engine] started (pid=15186)
[0] cpu.local: [1539984752.000347547, {"cpu_p"=>0.750000, "user_p"=>0.500000, "system_p"=>0.250000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
```
