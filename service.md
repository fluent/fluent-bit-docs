# Service

The _SERVICE_ defines the global behaviour of the [Fluent Bit](http://fluentbit.io) engine.

| name | type | description |
| :--- | :--- | :--- |
| Daemon | Bool | If true go to background on start |
| Flush | Int | Interval to flush output \(seconds\) |
| Grace | Int | Wait time \(seconds\) on exit |
| HTTP\_Listen | Str | Address to listen \(e.g. 0.0.0.0\) |
| HTTP\_Port | Int | Port to listen \(e.g. 8888\) |
| HTTP\_Server | Bool | If true enable statistics HTTP server |
| Log\_File | Str | File to log diagnostic output |
| Log\_Level | Str | Diagnostic level \(error/warning/info/debug/trace\) |
| Parsers\_File | Str | Optional 'parsers' config file \(can be multiple\) |
| Plugins\_File | Str | Optional 'plugins' config file \(can be multiple\) |

Note that _Parsers\_File_ and _Plugins\_File_ are both relative to the directory the main config file is in.

## Storage and Buffering Configuration

In addition to the properties listed in the table above, the Storage and Buffering options are extensively documented in the following section:

* [Storage & Buffering](configuration/buffering.md)

## Configuration Example

```text
[SERVICE]
    Flush        1
    Daemon       Off
    Config_Watch On
    Parsers_File parsers.conf
    Parsers_File custom_parsers.conf
```

