# Health

_Health_ input plugin allows you to check how _healthy_ a TCP server is. It does the check by issuing a TCP connection every a certain interval of time.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description       |
| -------------|-------------------|
| Host         | Name of the target host or IP address to check. |
| Port         | TCP port where to perform the connection check. |
| Interval\_Sec| Interval in seconds between the service checks. Default value is _1_. |
| Internal\_Nsec| Specify a nanoseconds interval for service checks, it works in conjuntion with the Interval\_Sec configuration key. Default value is _0_.|
| Alert        | If enabled, it will only generate messages if the target TCP service is down. By default this option is disabled.|

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit generate the checks with the following options:

```bash
$ fluent-bit -i health://127.0.0.1:80 -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          health
    Host          127.0.0.1
    Port          80
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you will see some random values in the output interface similar to this:

```bash
$ fluent-bit -i health://127.0.0.1:80 -o stdout
Fluent-Bit v0.9.0
Copyright (C) Treasure Data

[2016/10/07 21:37:51] [ info] [engine] started
[0] health.0: [1475897871, {"alive"=>true}]
[1] health.0: [1475897872, {"alive"=>true}]
[2] health.0: [1475897873, {"alive"=>true}]
[3] health.0: [1475897874, {"alive"=>true}]
```
