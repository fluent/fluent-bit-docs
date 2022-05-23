# Random

_Random_ input plugin generate very simple random value samples using the device interface _/dev/urandom_, if not available it will use a unix timestamp as value.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Samples | If set, it will only generate a specific number of samples. By default this value is set to _-1_, which will generate unlimited samples. |
| Interval\_Sec | Interval in seconds between samples generation. Default value is _1_. |
| Interval\_Nsec | Specify a nanoseconds interval for samples generation, it works in conjunction with the Interval\_Sec configuration key. Default value is _0_. |

## Getting Started

In order to start generating random samples, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit generate the samples with the following options:

```bash
$ fluent-bit -i random -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          random
    Samples      -1
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```bash
$ fluent-bit -i random -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2016/10/07 20:27:34] [ info] [engine] started
[0] random.0: [1475893654, {"rand_value"=>1863375102915681408}]
[1] random.0: [1475893655, {"rand_value"=>425675645790600970}]
[2] random.0: [1475893656, {"rand_value"=>7580417447354808203}]
[3] random.0: [1475893657, {"rand_value"=>1501010137543905482}]
[4] random.0: [1475893658, {"rand_value"=>16238242822364375212}]
```

