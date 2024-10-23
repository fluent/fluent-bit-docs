# Exec

The **exec** input plugin, allows to execute external program and collects event logs.

**WARNING**: Because this plugin invokes commands via a shell, its inputs are
subject to shell metacharacter substitution. Careless use of untrusted input in
command arguments could lead to malicious command execution.

## Container support

This plugin will not function in all the distroless production images as it needs a functional `/bin/sh` which is not present.
The debug images use the same binaries so even though they have a shell, there is no support for this plugin as it is compiled out.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Command | The command to execute, passed to [popen(...)](https://man7.org/linux/man-pages/man3/popen.3.html) without any additional escaping or processing. May include pipelines, redirection, command-substitution, etc. |
| Parser | Specify the name of a parser to interpret the entry as a structured message. |
| Interval\_Sec | Polling interval \(seconds\). |
| Interval\_NSec | Polling interval \(nanosecond\). |
| Buf\_Size | Size of the buffer \(check [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values\) |
| Oneshot | Only run once at startup. This allows collection of data precedent to fluent-bit's startup (bool, default: false) |
| Exit\_After\_Oneshot | Exit as soon as the one-shot command exits. This allows the exec plugin to be used as a wrapper for another command, sending the target command's output to any fluent-bit sink(s) then exiting. (bool, default: false) |
| Propagate\_Exit\_Code | When exiting due to Exit\_After\_Oneshot, cause fluent-bit to exit with the exit code of the command exited by this plugin. Follows [shell conventions for exit code propagation](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html). (bool, default: false) |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

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

{% tabs %}
{% tab title="fluent-bit.conf" %}
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
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: exec
          tag: exec_ls
          command: ls /var/log
          interval_sec: 1
          interval_nsec: 0
          buf_size: 8mb
          oneshot: false

    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

## Use as a command wrapper

To use `fluent-bit` with the `exec` plugin to wrap another command, use the
`Exit_After_Oneshot` and `Propagate_Exit_Code` options, e.g.:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```
[INPUT]
    Name                exec
    Tag                 exec_oneshot_demo
    Command             for s in $(seq 1 10); do echo "count: $s"; sleep 1; done; exit 1
    Oneshot             true
    Exit_After_Oneshot  true
    Propagate_Exit_Code true

[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: exec
          tag: exec_oneshot_demo
          command: 'for s in $(seq 1 10); do echo "count: $s"; sleep 1; done; exit 1'
          oneshot: true
          exit_after_oneshot: true
          propagate_exit_code: true

    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

`fluent-bit` will output

```
[0] exec_oneshot_demo: [[1681702172.950574027, {}], {"exec"=>"count: 1"}]
[1] exec_oneshot_demo: [[1681702173.951663666, {}], {"exec"=>"count: 2"}]
[2] exec_oneshot_demo: [[1681702174.953873724, {}], {"exec"=>"count: 3"}]
[3] exec_oneshot_demo: [[1681702175.955760865, {}], {"exec"=>"count: 4"}]
[4] exec_oneshot_demo: [[1681702176.956840282, {}], {"exec"=>"count: 5"}]
[5] exec_oneshot_demo: [[1681702177.958292246, {}], {"exec"=>"count: 6"}]
[6] exec_oneshot_demo: [[1681702178.959508200, {}], {"exec"=>"count: 7"}]
[7] exec_oneshot_demo: [[1681702179.961715745, {}], {"exec"=>"count: 8"}]
[8] exec_oneshot_demo: [[1681702180.963924140, {}], {"exec"=>"count: 9"}]
[9] exec_oneshot_demo: [[1681702181.965852990, {}], {"exec"=>"count: 10"}]
```

then exit with exit code 1.

Translation of command exit code(s) to `fluent-bit` exit code follows
[the usual shell rules for exit code handling](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html).
Like with a shell, there is no way to differentiate between the command exiting
on a signal and the shell exiting on a signal, and no way to differentiate
between normal exits with codes greater than 125 and abnormal or signal exits
reported by fluent-bit or the shell. Wrapped commands should use exit codes
between 0 and 125 inclusive to allow reliable identification of normal exit.
If the command is a pipeline, the exit code will be the exit code of the last
command in the pipeline unless overridden by shell options.

### Parsing command output

By default the `exec` plugin emits one message per command output line, with a
single field `exec` containing the full message. Use the `Parser` directive to
specify the name of a parser configuration to use to process the command input.

### Security concerns

**Take great care with shell quoting and escaping when wrapping commands**.
A script like

```bash
#!/bin/bash
# This is a DANGEROUS example of what NOT to do, NEVER DO THIS
exec fluent-bit \
  -o stdout \
  -i exec \
  -p exit_after_oneshot=true \
  -p propagate_exit_code=true \
  -p command='myscript $*'
```

can ruin your day if someone passes it the argument
`$(rm -rf /my/important/files; echo "deleted your stuff!")'`

The above script would be safer if written with:

```bash
  -p command='echo '"$(printf '%q' "$@")" \
```

... but it's generally best to avoid dynamically generating the command or
handling untrusted arguments to it at all.
