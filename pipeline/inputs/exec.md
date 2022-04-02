# Exec

The **exec** input plugin, allows to execute external program and collects event logs.

## Container support
This plugin will not function in the distroless production images (AMD64 currently) as it needs a functional `/bin/sh` which is not present.
It will function in the 1.8.12 and later `-debug` images though as well as the ARM production images as these include a full shell.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Command | The command to execute. |
| Parser | Specify the name of a parser to interpret the entry as a structured message. |
| Interval\_Sec | Polling interval \(seconds\). |
| Interval\_NSec | Polling interval \(nanosecond\). |
| Buf\_Size | Size of the buffer \(check [unit sizes](https://docs.fluentbit.io/manual/configuration/unit_sizes) for allowed values\) |
| Oneshot | Only run once at startup. This allows collection of data precedent to fluent-bit's startup (bool, default: false) |

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

The following example will read events from the output of _ls_.

```bash
$ fluent-bit -i exec -p 'command=ls /var/log' -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2018/03/21 17:46:49] [ info] [engine] started
[0] exec.0: [1521622010.013470159, {"exec"=>"ConsoleKit"}]
[1] exec.0: [1521622010.013490313, {"exec"=>"Xorg.0.log"}]
[2] exec.0: [1521622010.013492079, {"exec"=>"Xorg.0.log.old"}]
[3] exec.0: [1521622010.013493443, {"exec"=>"anaconda.ifcfg.log"}]
[4] exec.0: [1521622010.013494707, {"exec"=>"anaconda.log"}]
[5] exec.0: [1521622010.013496016, {"exec"=>"anaconda.program.log"}]
[6] exec.0: [1521622010.013497225, {"exec"=>"anaconda.storage.log"}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          exec
    Tag           exec_ls
    Command       ls /var/log
    Interval_Sec  1
    Interval_NSec 0
    Buf_Size      8mb
    Oneshot       false

[OUTPUT]
    Name   stdout
    Match  *
```

