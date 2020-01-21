# Memory Usage

The **mem** input plugin, gathers the information about the memory and swap usage of the running system every certain interval of time and reports the total amount of memory and the amount of free available.

## Getting Started

In order to get memory and swap usage from your system, you can run the plugin from the command line or through the configuration file:

### Command Line

```bash
$ fluent-bit -i mem -t memory -o stdout -m '*'
Fluent-Bit v0.11.0
Copyright (C) Treasure Data

[2017/03/03 21:12:35] [ info] [engine] started
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[1] memory: [1488543157, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[2] memory: [1488543158, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[3] memory: [1488543159, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
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

