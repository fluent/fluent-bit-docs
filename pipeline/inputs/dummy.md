# Dummy

The **dummy** input plugin, generates dummy events. It is useful for testing, debugging, benchmarking and getting started with Fluent Bit.

## Configuration Parameters

The plugin supports the following configuration parameters:

## Getting Started

You can run the plugin from the command line or through the configuration file:

| Key | Description |
| :--- | :--- |
| Dummy | Dummy JSON record. Default: `{"message":"dummy"}` |
| Start\_time\_sec | Dummy base timestamp in seconds. Default: 0 |
| Start\_time\_nsec | Dummy base timestamp in nanoseconds. Default: 0 |
| Rate | Events number generated per second. Default: 1 |
| Samples | If set, the events number will be limited. e.g. If Samples=3, the plugin only generates three events and stops. |

### Command Line

```bash
$ fluent-bit -i dummy -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/07/06 21:55:29] [ info] [engine] started
[0] dummy.0: [1499345730.015265366, {"message"=>"dummy"}]
[1] dummy.0: [1499345731.002371371, {"message"=>"dummy"}]
[2] dummy.0: [1499345732.000267932, {"message"=>"dummy"}]
[3] dummy.0: [1499345733.000757746, {"message"=>"dummy"}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name   dummy
    Tag    dummy.log

[OUTPUT]
    Name   stdout
    Match  *
```

