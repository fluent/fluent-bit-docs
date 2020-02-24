# Service Configuration

The _SERVICE_ defines the global behaviour of the [Fluent Bit](http://fluentbit.io) engine.

| name         | type | description                                       |
| :----------- | :--- | :------------------------------------------------ |
| Daemon       | Bool | If true go to background on start                 |
| Flush        | Int  | Interval to flush output (seconds)                |
| Grace        | Int  | Wait time (seconds) on exit                       |
| HTTP_Listen  | Str  | Address to listen (e.g. 0.0.0.0)                  |
| HTTP_Port    | Int  | Port to listen (e.g. 8888)                        |
| HTTP_Server  | Bool | If true enable statistics HTTP server             |
| Log_File     | Str  | File to log diagnostic output                     |
| Log_Level    | Str  | Diagnostic level (error/warning/info/debug/trace) |
| Parsers_File | Str  | Optional 'parsers' config file (can be multiple)  |
| Plugins_File | Str  | Optional 'plugins' config file (can be multiple)  |

Note that _Parsers_File_ and _Plugins_File_ are both relative to the directory the main config file is in.

## Storage and Buffering Configuration

In addition to the properties listed in the table above, the Storage and Buffering options are extensively documented in the following section:

- [Storage & Buffering](../configuration/buffering.md)

## Configuration Example

```
[SERVICE]
    Flush        1
    Daemon       Off
    Parsers_File parsers.conf
    Parsers_File custom_parsers.conf
```
