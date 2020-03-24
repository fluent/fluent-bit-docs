# Counter

_Counter_ is a very simple plugin that counts how many records it's getting upon flush time. Plugin output is as follows:

```text
[TIMESTAMP, NUMBER_OF_RECORDS_NOW] (total = RECORDS_SINCE_IT_STARTED)
```

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```bash
$ fluent-bit -i cpu -o counter
```

### Configuration File

In your main configuration file append the following Input & Output sections:

```python
[INPUT]
    Name cpu
    Tag  cpu

[OUTPUT]
    Name  counter
    Match *
```

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```bash
$ bin/fluent-bit -i cpu -o counter -f 1
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/07/19 11:19:02] [ info] [engine] started
1500484743,1 (total = 1)
1500484744,1 (total = 2)
1500484745,1 (total = 3)
1500484746,1 (total = 4)
1500484747,1 (total = 5)
```

