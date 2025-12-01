# Exec

The _Exec_ input plugin lets you execute external programs and collects event logs.

{% hint style="warning" %}

This plugin invokes commands using a shell. Its inputs are subject to shell metacharacter substitution. Careless use of untrusted input in command arguments could lead to malicious command execution.

{% endhint %}

## Container support

This plugin needs a functional `/bin/sh` and won't function in all the distro-less production images.

The debug images use the same binaries so even though they have a shell, there is no support for this plugin as it's compiled out.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                   | Description                                                                                                                                                                                                                                                                          | Default |
|:----------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| `buf_size`            | Size of the buffer. See [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values.                                                                                                                                                                  | `4096`  |
| `command`             | The command to execute, passed to [popen](https://man7.org/linux/man-pages/man3/popen.3.html) without any additional escaping or processing. Can include pipelines, redirection, command-substitution, or other information.                                                         | _none_  |
| `exit_after_oneshot`  | Exit as soon as the one-shot command exits. This allows the `exec` plugin to be used as a wrapper for another command, sending the target command's output to any Fluent Bit sink, then exits. When enabled, `oneshot` is automatically set to `true`.                               | `false` |
| `interval_nsec`       | Polling interval (nanoseconds).                                                                                                                                                                                                                                                      | `0`     |
| `interval_sec`        | Polling interval (seconds).                                                                                                                                                                                                                                                          | `1`     |
| `oneshot`             | Only run once at startup. This allows collection of data precedent to Fluent Bit startup.                                                                                                                                                                                            | `false` |
| `parser`              | Specify the name of a parser to interpret the entry as a structured message.                                                                                                                                                                                                         | _none_  |
| `propagate_exit_code` | Cause Fluent Bit to exit with the exit code of the command exited by this plugin. Follows [shell conventions for exit code propagation](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html). Requires `exit_after_oneshot=true`.                                    | `false` |
| `threaded`            | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                              | `false` |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

The following example will read events from the output of _ls_.

```shell
fluent-bit -i exec -p 'command=ls /var/log' -o stdout
```

which should return something like the following:

```text
...
[0] exec.0: [1521622010.013470159, {"exec"=>"ConsoleKit"}]
[1] exec.0: [1521622010.013490313, {"exec"=>"Xorg.0.log"}]
[2] exec.0: [1521622010.013492079, {"exec"=>"Xorg.0.log.old"}]
[3] exec.0: [1521622010.013493443, {"exec"=>"anaconda.ifcfg.log"}]
[4] exec.0: [1521622010.013494707, {"exec"=>"anaconda.log"}]
[5] exec.0: [1521622010.013496016, {"exec"=>"anaconda.program.log"}]
[6] exec.0: [1521622010.013497225, {"exec"=>"anaconda.storage.log"}]
...
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
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
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

## Use as a command wrapper

To use Fluent Bit with the `exec` plugin to wrap another command, use the `exit_after_oneshot` and `propagate_exit_code` options:

{% tabs %}
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
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

Fluent Bit will output:

```text
...
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
...
```

then exits with exit code 1.

Translation of command exit codes to Fluent Bit exit code follows [the usual shell rules for exit code handling](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html). Like with a shell, there is no way to differentiate between the command exiting on a signal and the shell exiting on a signal. Similarly, there is no way to differentiate between normal exits with codes greater than `125` and abnormal or signal exits reported by Fluent Bit or the shell. Wrapped commands should use exit codes between `0` and `125` inclusive to allow reliable identification of normal exit. If the command is a pipeline, the exit code will be the exit code of the last command in the pipeline unless overridden by shell options.

### Parsing command output

By default, the `exec` plugin emits one message per command output line, with a single field `exec` containing the full message. Use the `parser` option to specify the name of a parser configuration to use to process the command input.

### Security concerns

{% hint style="warning" %}

Take great care with shell quoting and escaping when wrapping commands.

{% endhint %}

A script like the following can ruin your day if someone passes it the argument `$(rm -rf /my/important/files; echo "deleted your stuff!")'`

```shell
#!/bin/bash
# This is a DANGEROUS example of what NOT to do, NEVER DO THIS
exec fluent-bit \
  -o stdout \
  -i exec \
  -p exit_after_oneshot=true \
  -p propagate_exit_code=true \
  -p command='myscript $*'
```

The previous script would be safer if written with:

```shell
  -p command='echo '"$(printf '%q' "$@")" \
```

It's generally best to avoid dynamically generating the command or handling untrusted arguments.
