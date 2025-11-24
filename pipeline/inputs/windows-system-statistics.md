# Windows system statistics (winstat)

The _Windows System Statistics_ (`winstat`) input plugin collects system-level statistics from Windows environments, including CPU usage, memory consumption, disk I/O, and network activity. This plugin uses Windows Performance Counters to gather real-time system metrics.

{% hint style="info" %}

This plugin is only available on Windows operating systems and requires appropriate permissions to access Windows Performance Counters.

{% endhint %}

## Configuration parameters

The plugin supports the following configuration parameters:

| Key             | Description                                                                                             | Default |
|:----------------|:--------------------------------------------------------------------------------------------------------|:--------|
| `Interval_Sec`  | Polling interval in seconds.                                                                            | `1`     |
| `Interval_NSec` | Polling interval in nanoseconds.                                                                        | `0`     |
| `Threaded`      | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Metrics collected

The `winstat` plugin collects the following system statistics:

| Metric Category | Description                                                                 |
|:----------------|:----------------------------------------------------------------------------|
| CPU             | CPU usage percentage, including user and system time                      |
| Memory          | Memory usage including total, available, and used memory                  |
| Disk            | Disk I/O statistics including read/write operations and throughput       |
| Network         | Network interface statistics including bytes sent/received and packet counts |

## Get started

To collect Windows system statistics, you can run the plugin from the command line or through the configuration file:

### Command line

You can run the plugin from the command line:

```shell
fluent-bit -i winstat -o stdout
```

Which returns information similar to the following:

```text
...
[0] winstat: [1699123456.123456789, {"cpu.usage"=>15.3, "cpu.user"=>10.2, "cpu.system"=>5.1, "memory.total"=>8192, "memory.available"=>4096, "memory.used"=>4096, "disk.read_bytes"=>1024000, "disk.write_bytes"=>512000, "network.bytes_sent"=>2048000, "network.bytes_recv"=>1024000}]
[1] winstat: [1699123457.123456789, {"cpu.usage"=>16.1, "cpu.user"=>11.0, "cpu.system"=>5.1, "memory.total"=>8192, "memory.available"=>4080, "memory.used"=>4112, "disk.read_bytes"=>1025000, "disk.write_bytes"=>515000, "network.bytes_sent"=>2050000, "network.bytes_recv"=>1025000}]
...
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: winstat
      tag: winstat
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
  Name          winstat
  Tag           winstat
  Interval_Sec  1
  Interval_NSec 0

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

Total interval (sec) = `Interval_Sec` + (`Interval_NSec` / 1000000000)

For example: `1.5s` = `1s` + `500000000ns`

## Notes

- The `winstat` plugin requires Windows Performance Counters access. Ensure Fluent Bit is running with appropriate permissions.
- This plugin is Windows-only and won't work on Linux, macOS, or other operating systems.
- For Prometheus-based metrics collection on Windows, consider using the [Windows Exporter Metrics](windows-exporter-metrics.md) input plugin instead.
