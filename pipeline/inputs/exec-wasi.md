# Exec Wasi

The _Exec Wasi_ input plugin lets you execute Wasm programs that are WASI targets like external programs and collect event logs from there.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `WASI_Path` | The location of a Wasm program file. |
| `Parser` | Specify the name of a parser to interpret the entry as a structured message. |
| `Accessible_Paths` | Specify the allowed list of paths to be able to access paths from WASM programs. |
| `Interval_Sec` | Polling interval (seconds). |
| `Interval_NSec` | Polling interval (nanosecond). |
| `Wasm_Heap_Size` | Size of the heap size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |
| `Wasm_Stack_Size` | Size of the stack size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |
| `Buf_Size` | Size of the buffer See [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |
| `Oneshot` | Only run once at startup. This allows collection of data precedent to the Fluent Bit startup (Boolean, default: `false`). |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

## Configuration examples

Here is a configuration example.

`in_exec_wasi` can handle parsers. To retrieve from structured data from a WASM program, you must create a `parser.conf`:

The `Time_Format` should be aligned for the format of your using timestamp.

This example assumes the WASM program writes JSON style strings to `stdout`.

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