# Health

_Health_ input plugin allows you to check how _healthy_ a TCP server is. It does the check by issuing a TCP connection every a certain interval of time.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Host | Name of the target host or IP address to check. |
| Port | TCP port where to perform the connection check. |
| Interval\_Sec | Interval in seconds between the service checks. Default value is _1_. |
| Internal\_Nsec | Specify a nanoseconds interval for service checks, it works in conjunction with the Interval\_Sec configuration key. Default value is _0_. |
| Alert | If enabled, it will only generate messages if the target TCP service is down. By default this option is disabled. |
| Add\_Host | If enabled, hostname is appended to each records. Default value is _false_. |
| Add\_Port | If enabled, port number is appended to each records. Default value is _false_. |

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit generate the checks with the following options:

```bash
$ fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout
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
$ fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout
Fluent Bit v1.8.0
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2021/06/20 08:39:47] [ info] [engine] started (pid=4621)
[2021/06/20 08:39:47] [ info] [storage] version=1.1.1, initializing...
[2021/06/20 08:39:47] [ info] [storage] in-memory
[2021/06/20 08:39:47] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/06/20 08:39:47] [ info] [sp] stream processor started
[0] health.0: [1624145988.305640385, {"alive"=>true}]
[1] health.0: [1624145989.305575360, {"alive"=>true}]
[2] health.0: [1624145990.306498573, {"alive"=>true}]
[3] health.0: [1624145991.305595498, {"alive"=>true}]
```

