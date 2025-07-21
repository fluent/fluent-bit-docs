# Disk I/O metrics

The _Disk_ input plugin gathers the information about the disk throughput of the running system every certain interval of time and reports them.

The _Disk I/O metrics_ plugin creates metrics that are log-based, such as JSON payload. For Prometheus-based metrics, see the Node Exporter Metrics input plugin.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Interval_Sec` | Polling interval (seconds).  | `1` |
| `Interval_NSec` | Polling interval (nanosecond). | `0` |
| `Dev_Name` | Device name to limit the target (for example, `sda`). If not set, `in_disk` gathers information from all of disks and partitions. | all disks |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

In order to get disk usage from your system, you can run the plugin from the command line or through the configuration file:

### Command line

You can run the plugin from the command line:

```shell
fluent-bit -i disk -o stdout
```

Which returns information like the following:

```text
...
[0] disk.0: [1485590297, {"read_size"=>0, "write_size"=>0}]
[1] disk.0: [1485590298, {"read_size"=>0, "write_size"=>0}]
[2] disk.0: [1485590299, {"read_size"=>0, "write_size"=>0}]
[3] disk.0: [1485590300, {"read_size"=>0, "write_size"=>11997184}]
...
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: disk
      tag: disk
      interval_sec: 1
      interval_nsec: 0

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name          disk
  Tag           disk
  Interval_Sec  1
  Interval_NSec 0

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

Total interval (sec) = `Interval_Sec` + `(Interval_Nsec` / 1000000000)

For example: `1.5s` = `1s` + `500000000ns`