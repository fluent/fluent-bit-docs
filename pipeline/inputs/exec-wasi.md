# Exec WASI

The _Exec WASI_ input plugin lets you execute Wasm programs that are WASI targets like external programs and collect event logs from there.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                | Description                                                                                                                                  | Default |
|:-------------------|:---------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| `accessible_paths` | Specify the allowed list of paths to be able to access paths from Wasm programs.                                                             | `.`     |
| `buf_size`         | Size of the buffer. Review [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values.                       | `4096`  |
| `interval_nsec`    | Polling interval (nanosecond).                                                                                                               | `0`     |
| `interval_sec`     | Polling interval (seconds).                                                                                                                  | `1`     |
| `oneshot`          | Execute the command only once at startup.                                                                                                    | `false` |
| `parser`           | Specify the name of a parser to interpret the entry as a structured message.                                                                 |         |
| `threaded`         | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                      | `false` |
| `wasi_path`        | The location of a Wasm program file.                                                                                                         |         |
| `wasm_heap_size`   | Size of the heap size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values.  | `8192`  |
| `wasm_stack_size`  | Size of the stack size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values. | `8192`  |

## Configuration examples

Here is a configuration example.

`in_exec_wasi` can handle parsers. To retrieve from structured data from a Wasm program, you must create a `parser.conf`:

The `time_format` should be aligned for the format your using for timestamps.

This example assumes the Wasm program writes JSON style strings to `stdout`.

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: wasi
    format: json
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L %z'
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name        wasi
  Format      json
  Time_Key    time
  Time_Format %Y-%m-%dT%H:%M:%S.%L %z
```

{% endtab %}
{% endtabs %}

Then, you can specify the `parsers.conf` in the main Fluent Bit configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  daemon: off
  parsers_file: parsers.yaml
  log_level: info
  http_server: off
  http_listen: 0.0.0.0
  http_port: 2020

pipeline:
  inputs:
    - name: exec_wasi
      tag: exec.wasi.local
      wasi_path: /path/to/wasi/program.wasm
      # Note: run from the 'wasi_path' location.
      accessible_paths: /path/to/accessible

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush        1
  Daemon       Off
  Parsers_File parsers.conf
  Log_Level    info
  HTTP_Server  Off
  HTTP_Listen  0.0.0.0
  HTTP_Port    2020

[INPUT]
  Name exec_wasi
  Tag  exec.wasi.local
  WASI_Path /path/to/wasi/program.wasm
  Accessible_Paths .,/path/to/accessible
  Parser wasi

[OUTPUT]
  Name  stdout
  Match *

```

{% endtab %}
{% endtabs %}
