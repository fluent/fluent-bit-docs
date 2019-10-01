# Service

The _SERVICE_ defines the global behaviour of the [Fluent Bit](http://fluentbit.io) engine.

| name | type | description |
| :--- | :--- | :--- |
| Buffer\_Path | Str | Path to write buffered chunks if enabled |
| Buffer\_Workers | Int | Number of workers to operate on buffer chunks |
| Config\_Watch | Bool | If true, exit on change in config directory |
| Daemon | Bool | If true go to background on start |
| Flush | Int | Interval to flush output \(seconds\) |
| Grace | Int | Wait time \(seconds\) on exit |
| HTTP\_Listen | Str | Address to listen \(e.g. 0.0.0.0\) |
| HTTP\_Port | Int | Port to listen \(e.g. 8888\) |
| HTTP\_Server | Bool | If true enable statistics HTTP server |
| Log\_File | Str | File to log diagnostic output |
| Log\_Level | Int | Diagnostic level \(error/warning/info/debug/trace\) |
| Parsers\_File | Str | Optional 'parsers' config file \(can be multiple\) |
| Plugins\_File | Str | Optional 'plugins' config file \(can be multiple\) |

The _Parsers\_File_ and _Plugins\_File_ are both relative to the directory the main config file is in.

## Example

```text
[SERVICE]
    Flush        5
    Daemon       Off
    Config_Watch On
    Parsers_File parsers.conf
    Parsers_File custom_parsers.conf
```

