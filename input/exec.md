# Exec

The __exec__ input plugin, allows to execute external program and collects event logs.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key           | Description |
| --------------|-------------|
| Command       | The command to execute. |
| Parser        | Specify the name of a parser to interpret the entry as a structured message.|
| Interval_Sec  | Polling interval (seconds). |
| Interval_NSec | Polling interval (nanosecond). |

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

The following example will read events from the output of _ls_.

```bash
$ fluent-bit -i exec -p 'command=ls /var/log' -o stdout
Fluent-Bit v0.13.0
Copyright (C) Treasure Data

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

[OUTPUT]
    Name   stdout
    Match  *
```
