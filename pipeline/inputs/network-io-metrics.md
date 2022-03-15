# Network I/O Metrics

The **netif** input plugin gathers network traffic information of the running system every certain interval of time, and reports them.

The Network I/O Metrics plugin creates metrics that are log-based \(I.e. JSON payload\). If you are looking for Prometheus-based metrics please see the Node Exporter Metrics input plugin. 

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Interface | Specify the network interface to monitor. e.g. eth0 | |
| Interval\_Sec | Polling interval \(seconds\). | 1 |
| Interval\_NSec | Polling interval \(nanosecond\). | 0 |
| Verbose | If true, gather metrics precisely. | false |
| Test\_At\_Init | If true, testing if the network interface is valid at initialization. | false |

## Getting Started

In order to monitor network traffic from your system, you can run the plugin from the command line or through the configuration file:

### Command Line

```bash
$ bin/fluent-bit -i netif -p interface=eth0 -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/07/08 23:34:18] [ info] [engine] started
[0] netif.0: [1499524459.001698260, {"eth0.rx.bytes"=>89769869, "eth0.rx.packets"=>73357, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>4256474, "eth0.tx.packets"=>24293, "eth0.tx.errors"=>0}]
[1] netif.0: [1499524460.002541885, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[2] netif.0: [1499524461.001142161, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[3] netif.0: [1499524462.002612971, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name          netif
    Tag           netif
    Interval_Sec  1
    Interval_NSec 0
    Interface     eth0
[OUTPUT]
    Name   stdout
    Match  *
```

Note: Total interval \(sec\) = Interval\_Sec + \(Interval\_Nsec / 1000000000\).

e.g. 1.5s = 1s + 500000000ns

