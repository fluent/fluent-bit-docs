# Exec Wasi

The **exec_wasi** input plugin, allows to execute WASM program that is WASI target like as external program and collects event logs from there.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| WASI\_Path | The place of a WASM program file. |
| Parser | Specify the name of a parser to interpret the entry as a structured message. |
| Accessible\_Paths | Specify the whilelist of paths to be able to access paths from WASM programs. |
| Interval\_Sec | Polling interval \(seconds\). |
| Interval\_NSec | Polling interval \(nanosecond\). |
| Buf\_Size | Size of the buffer \(check [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values\) |
| Oneshot | Only run once at startup. This allows collection of data precedent to fluent-bit's startup (bool, default: false) |

## Configuration Examples

Here is a configuration example.
in\_exec\_wasi can handle parser.
To retrieve from structured data from WASM program, you have to create parser.conf:

Note that `Time_Format` should be aligned for the format of your using timestamp.
In this documents, we assume that WASM program should write JSON style strings into stdout.


```python
[PARSER]
    Name        wasi
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L %z
```

Then, you can specify the above parsers.conf in the main fluent-bit configuration:

```python
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
