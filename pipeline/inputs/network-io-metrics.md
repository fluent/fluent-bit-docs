# Network I/O metrics

The _Network I/O metrics_ (`netif`) input plugin gathers network traffic information of the running system at regular intervals, and reports them.

The Network I/O metrics plugin creates metrics that are log-based, such as JSON payload. For Prometheus-based metrics, see the Node Exporter metrics input plugin.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key             | Description                                                                                             | Default |
|:----------------|:--------------------------------------------------------------------------------------------------------|:--------|
| `Interface`     | Specify the network interface to monitor. For example, `eth0`.                                          | _none_  |
| `Interval_Sec`  | Polling interval (seconds).                                                                             | `1`     |
| `Interval_NSec` | Polling interval (nanosecond).                                                                          | `0`     |
| `Verbose`       | If true, gather metrics precisely.                                                                      | `false` |
| `Test_At_Init`  | If true, testing if the network interface is valid at initialization.                                   | `false` |
| `Threaded`      | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To monitor network traffic from your system, you can run the plugin from the command line or through the configuration file:

### Command line

Run Fluent Bit using a command similar to the following:

```shell
fluent-bit -i netif -p interface=eth0 -o stdout
```

Which returns something the following:

```text
...
[0] netif.0: [1499524459.001698260, {"eth0.rx.bytes"=>89769869, "eth0.rx.packets"=>73357, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>4256474, "eth0.tx.packets"=>24293, "eth0.tx.errors"=>0}]
[1] netif.0: [1499524460.002541885, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[2] netif.0: [1499524461.001142161, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
[3] netif.0: [1499524462.002612971, {"eth0.rx.bytes"=>98, "eth0.rx.packets"=>1, "eth0.rx.errors"=>0, "eth0.tx.bytes"=>98, "eth0.tx.packets"=>1, "eth0.tx.errors"=>0}]
...
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: netif
      tag: netif
      interval_sec: 1
      interval_nsec: 0
      interface: eth0
      
  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

Which calculates using the formula: `Total interval (sec) = Interval_Sec + (Interval_Nsec / 1000000000)`.

For example: `1.5s = 1s + 500000000ns`