# Memory Metrics

The **mem** input plugin, gathers the information about the memory and swap usage of the running system every certain interval of time and reports the total, buffer and free memory (as reported by [sysinfo](https://man7.org/linux/man-pages/man2/sysinfo.2.html)) and the memory available and cached (as reported by `/proc/meminfo`).

## Getting Started

In order to get memory and swap usage from your system, you can run the plugin from the command line or through the configuration file:

### Command Line

```bash
$ fluent-bit -i mem -t memory -o stdout -m '*'
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/03/03 21:12:35] [ info] [engine] started
[0] memory: [1488543156, {"Mem.total"=>2037988, "Mem.used"=>1890616, "Mem.free"=>147372, "Mem.available"=>1236028, "Mem.buffer"=>92020, "Mem.cache"=>1374616}]
[1] memory: [1488543157, {"Mem.total"=>2037988, "Mem.used"=>1890616, "Mem.free"=>147372, "Mem.available"=>1236028, "Mem.buffer"=>92020, "Mem.cache"=>1374616}]
[2] memory: [1488543158, {"Mem.total"=>2037988, "Mem.used"=>1890616, "Mem.free"=>147372, "Mem.available"=>1236028, "Mem.buffer"=>92020, "Mem.cache"=>1374616}]
[3] memory: [1488543159, {"Mem.total"=>2037988, "Mem.used"=>1890616, "Mem.free"=>147372, "Mem.available"=>1236028, "Mem.buffer"=>92020, "Mem.cache"=>1374616}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name   mem
    Tag    memory

[OUTPUT]
    Name   stdout
    Match  *
```

