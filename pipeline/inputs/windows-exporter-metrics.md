---
description: A plugin based on Prometheus Windows Exporter to collect system and host level metrics
---

# Windows exporter metrics

[Prometheus Windows exporter](https://github.com/prometheus-community/windows_exporter) is a popular way to collect system level metrics from Microsoft Windows, such as CPU, Disk, Network, and Process statistics. Fluent Bit 1.9.0 and later includes the Windows Exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes or agents.

The initial release of Windows Exporter metrics contains a single collector available from Prometheus Windows Exporter.

{% hint style="info" %}

Metrics collected with Windows Exporter metrics flow through a separate pipeline from logs and current filters don't operate on top of metrics. This plugin is only supported on Windows operating systems as it uses Windows Management Instrumentation (WMI) to access the relevant metrics.

{% endhint %}

## Configuration

`scrape_interval` sets the default for all scrapes. To set granular scrape intervals, set the specific interval. For example, `collector.cpu.scrape_interval`. When using a granular scrape interval, if a value greater than `0` is used, it overrides the global default. Otherwise, the global default is used.

The plugin top-level `scrape_interval` setting is the global default. Any custom settings for individual `scrape_intervals` override that specific metric scraping interval.

Each `collector.xxx.scrape_interval` option only overrides the interval for that specific collector and updates the associated set of provided metrics.

Overridden intervals only change the collection interval, not the interval for publishing the metrics which is taken from the global setting.

For example, if the global interval is set to `5` and an override interval of `60` is used, the published metrics will be reported every five seconds. However, the specific collector will stay the same for 60 seconds until it's collected again.

This helps with down-sampling when collecting metrics.

| Key                                      | Description                                                                                                                                                    | Default                                                                  |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `scrape_interval`                        | The rate in seconds at which metrics are collected from the Windows host.                                                                                     | `5`                                                                      |
| `we.logical_disk.allow_disk_regex`       | Specify the regular expression for logical disk metrics to allow collection of.                                                                                | `"/.+/"` (all)                                                           |
| `we.logical_disk.deny_disk_regex`        | Specify the regular expression for logical disk metrics to prevent collection of or ignore.                                                                    | `NULL` (all)                                                             |
| `we.net.allow_nic_regex`                 | Specify the regular expression for network metrics captured by the name of the NIC.                                                                            | `"/.+/"` (all)                                                           |
| `we.service.where`                       | Specify the `WHERE` clause for retrieving service metrics.                                                                                                     | `NULL`                                                                   |
| `we.service.include`                     | Specify the key value pairs for the include condition for the `WHERE` clause of service metrics.                                                               | `NULL`                                                                   |
| `we.service.exclude`                     | Specify the key value pairs for the exclude condition for the `WHERE` clause of service metrics.                                                               | `NULL`                                                                   |
| `we.process.allow_process_regex`         | Specify the regular expression covering the process metrics to collect.                                                                                        | `"/.+/"` (all)                                                           |
| `we.process.deny_process_regex`          | Specify the regular expression for process metrics to prevent collection of or ignore.                                                                         | `NULL` (all)                                                             |
| `collector.cpu.scrape_interval`          | The rate in seconds at which `cpu` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.          | `0`                                                                      |
| `collector.net.scrape_interval`          | The rate in seconds at which `net` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.          | `0`                                                                      |
| `collector.logical_disk.scrape_interval` | The rate in seconds at which `logical_disk` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0`                                                                      |
| `collector.cs.scrape_interval`           | The rate in seconds at which `cs` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.           | `0`                                                                      |
| `collector.os.scrape_interval`           | The rate in seconds at which `os` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.           | `0`                                                                      |
| `collector.thermalzone.scrape_interval`  | The rate in seconds at which `thermalzone` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.  | `0`                                                                      |
| `collector.cpu_info.scrape_interval`     | The rate in seconds at which `cpu_info` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.     | `0`                                                                      |
| `collector.logon.scrape_interval`        | The rate in seconds at which `logon` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.        | `0`                                                                      |
| `collector.system.scrape_interval`       | The rate in seconds at which `system` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.       | `0`                                                                      |
| `collector.service.scrape_interval`      | The rate in seconds at which `service` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.      | `0`                                                                      |
| `collector.memory.scrape_interval`       | The rate in seconds at which `memory` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.       | `0`                                                                      |
| `collector.paging_file.scrape_interval`  | The rate in seconds at which `paging_file` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.  | `0`                                                                      |
| `collector.process.scrape_interval`      | The rate in seconds at which `process` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.      | `0`                                                                      |
| `collector.tcp.scrape_interval`          | The rate in seconds at which `tcp` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.          | `0`                                                                      |
| `collector.cache.scrape_interval`        | The rate in seconds at which `cache` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used.        | `0`                                                                      |
| `metrics`                                | Specify which metrics are collected. Comma-separated list of collector names.                                                                                  | `"cpu,cpu_info,os,net,logical_disk,cs,cache,thermalzone,logon,system,service,memory,paging_file,process,tcp"` |

## Collectors available

The following table describes the available collectors as part of this plugin. All collectors are enabled by default and respect the original metrics name, descriptions, and types from Prometheus Windows Exporter, so you can use your current dashboards without any compatibility problem.

The Version column specifies the Fluent Bit version where the collector is available.

| Name           | Description                                                                                                 | OS      | Version |
|----------------|-------------------------------------------------------------------------------------------------------------|---------|---------|
| `cpu`          | Exposes CPU statistics including utilization, interrupts, and DPCs.                                        | Windows | v1.9    |
| `net`          | Exposes network interface statistics such as bytes transferred, packets, and errors.                       | Windows | v2.0.8  |
| `logical_disk` | Exposes logical disk statistics including read/write operations, latency, and free space.                 | Windows | v2.0.8  |
| `cs`           | Exposes computer system statistics including model, manufacturer, and system type.                        | Windows | v2.0.8  |
| `os`           | Exposes operating system statistics including version, build number, and service pack information.        | Windows | v2.0.8  |
| `thermalzone`  | Exposes thermal zone statistics including temperature readings.                                            | Windows | v2.0.8  |
| `cpu_info`     | Exposes CPU information including model, cores, threads, and clock speed.                                 | Windows | v2.0.8  |
| `logon`        | Exposes logon session statistics including active sessions and session types.                             | Windows | v2.0.8  |
| `system`       | Exposes system-level statistics including uptime, processes, and threads.                                  | Windows | v2.0.8  |
| `service`      | Exposes Windows service statistics including service state, start mode, and status.                      | Windows | v2.1.6  |
| `memory`       | Exposes memory statistics including available, cached, and committed bytes.                               | Windows | v2.1.9  |
| `paging_file`  | Exposes paging file statistics including usage, peak usage, and allocation.                                | Windows | v2.1.9  |
| `process`      | Exposes process-level statistics including CPU usage, memory consumption, handles, and threads per process. | Windows | v2.1.9  |
| `tcp`          | Exposes TCP connection statistics including active connections, segments, and errors.                       | Windows | v4.1.0  |
| `cache`        | Exposes cache statistics including cache hits, misses, and utilization.                                   | Windows | v4.1.0  |

## Threading

This input always runs in its own [thread](../../administration/multithreading.md#inputs).

## Get started

### Configuration file

In the following configuration file, the input plugin `windows_exporter_metrics` collects `metrics` every two seconds and exposes them through the [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port `2021`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
# Windows Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collects Windows host metrics and exposes
# them through a Prometheus HTTP endpoint.
#
# After starting the service try it with:
#
# $ curl http://127.0.0.1:2021/metrics
#
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: node_metrics
      scrape_interval: 2

  outputs:
    - name: prometheus_exporter
      match: node_metrics
      port: 2021
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
# Windows Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collects Windows host metrics and exposes
# them through a Prometheus HTTP endpoint.
#
# After starting the service try it with:
#
# $ curl http://127.0.0.1:2021/metrics
#
[SERVICE]
  flush           1
  log_level       info

[INPUT]
  name            windows_exporter_metrics
  tag             node_metrics
  scrape_interval 2

[OUTPUT]
  name            prometheus_exporter
  match           node_metrics
  host            0.0.0.0
  port            2021
```

{% endtab %}
{% endtabs %}

You can test the expose of the metrics by using `curl`:

```shell
curl http://127.0.0.1:2021/metrics
```

### Filtering disk and network metrics

The Windows Exporter metrics plugin supports filtering logical disk and network interface metrics using regular expressions.

#### Logical disk filtering

Use `we.logical_disk.allow_disk_regex` and `we.logical_disk.deny_disk_regex` to control which logical disks are included in the metrics.

Example configuration to only collect metrics from C: and D: drives:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: windows_metrics
      we.logical_disk.allow_disk_regex: "^(C|D):$"
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name                        windows_exporter_metrics
  tag                         windows_metrics
  we.logical_disk.allow_disk_regex ^(C|D):$
```

{% endtab %}
{% endtabs %}

#### Network interface filtering

Use `we.net.allow_nic_regex` to filter network interfaces by name.

Example configuration to only collect metrics from Ethernet and Wi-Fi adapters:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: windows_metrics
      we.net.allow_nic_regex: "(Ethernet|Wi-Fi)"
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name            windows_exporter_metrics
  tag             windows_metrics
  we.net.allow_nic_regex (Ethernet|Wi-Fi)
```

{% endtab %}
{% endtabs %}

#### Process filtering

Use `we.process.allow_process_regex` and `we.process.deny_process_regex` to control which processes are included in the metrics.

Example configuration to exclude system processes:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: windows_metrics
      we.process.deny_process_regex: "(System|Idle|svchost)"
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name                      windows_exporter_metrics
  tag                       windows_metrics
  we.process.deny_process_regex (System|Idle|svchost)
```

{% endtab %}
{% endtabs %}

### Service where clause

Windows service collector will retrieve all the service information for the local node or container.
`we.service.where`, `we.service.include`, and `we.service.exclude` can be used to filter the service metrics.

To filter these metrics, users should specify a `WHERE` clause.
This syntax is defined in [the WMI Query Language (WQL)](https://learn.microsoft.com/en-us/windows/win32/wmisdk/wql-sql-for-wmi).

Here is how these parameters should work:

#### `we.service.where`

`we.service.where` is handled as a raw `WHERE` clause.
For example, when a user specifies the parameter as follows:

```text
we.service.where Status!='OK'
```

This creates a WMI query like so:

```sql
SELECT * FROM Win32_Service WHERE Status!='OK'
```

The WMI mechanism will then handle it and return the information which has a `not OK` status in this example.

### `we.service.include`

When defined, the `we.service.include` is interpreted into a `WHERE` clause.
If multiple key-value pairs are specified, the values will be concatenated with `OR`.
Also, if the values contain `%` character then a `LIKE` operator will be used in the clause instead of the `=` operator.
When a user specifies the parameter as follows:

```text
we.service.include {"Name":"docker","Name":"%Svc%", "Name":"%Service"}
```

The parameter will be interpreted as:

```text
(Name='docker' OR Name LIKE '%Svc%' OR Name LIKE '%Service')
```

The WMI query will be called with the translated parameter as:

```sql
SELECT * FROM Win32_Service WHERE (Name='docker' OR Name LIKE '%Svc%' OR Name LIKE '%Service')
```

### `we.service.exclude`

When defined, the `we.service.exclude` is interpreted into a `WHERE` clause.
If multiple key-value pairs are specified, the values will be concatenated with `AND`.

Also, if the values contain `%` character then a `LIKE` operator will be used in the translated clause instead of the `!=` operator.
When a user specifies the parameter as follows:

```text
we.service.exclude {"Name":"UdkUserSvc%","Name":"webthreatdefusersvc%","Name":"XboxNetApiSvc"}
```

The parameter will be interpreted as:

```sql
(NOT Name LIKE 'UdkUserSvc%' AND NOT Name LIKE 'webthreatdefusersvc%' AND Name!='XboxNetApiSvc')
```

The WMI query will be called with the translated parameter as:

```sql
SELECT * FROM Win32_Service WHERE (NOT Name LIKE 'UdkUserSvc%' AND NOT Name LIKE 'webthreatdefusersvc%' AND Name!='XboxNetApiSvc')
```

### Advanced usage

`we.service.where`, `we.service.include`, and `we.service.exclude` can all be used at the same time subject to the following rules.

1. `we.service.include` translated and applied into the where clause in the service collector
2. `we.service.exclude` translated and applied into the where clause in the service collector
    1. If the `we.service.include` is applied, translated `we.service.include` and `we.service.exclude` conditions are concatenated with `AND`.
1. `we.service.where` is handled as-is into the where clause in the service collector .
    1. If either of the previous parameters is applied, the clause will be applied with `AND (` _the value of `we.service.where`_ `)`.

For example, when a user specifies the parameter as follows:

```text
we.service.include {"Name":"docker","Name":"%Svc%", "Name":"%Service"}
we.service.exclude {"Name":"UdkUserSvc%","Name":"XboxNetApiSvc"}
we.service.where NOT Name LIKE 'webthreatdefusersvc%'
```

The WMI query will be called with the translated parameter as:

```sql
 SELECT * FROM Win32_Service WHERE (Name='docker' OR Name LIKE '%Svc%' OR Name LIKE '%Service') AND (NOT Name LIKE 'UdkUserSvc%' AND Name!='XboxNetApiSvc') AND (NOT Name LIKE 'webthreatdefusersvc%')
```

### Selecting specific collectors

You can configure the plugin to collect only specific metrics by using the `metrics` parameter. Use this to reduce resource usage or focus on specific system components.

Example configuration to collect only CPU, memory, and disk metrics:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: windows_metrics
      metrics: "cpu,memory,logical_disk"
      scrape_interval: 5
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name            windows_exporter_metrics
  tag             windows_metrics
  metrics         cpu,memory,logical_disk
  scrape_interval 5
```

{% endtab %}
{% endtabs %}

### Custom scrape intervals per collector

You can set different scrape intervals for individual collectors to optimize resource usage. For example, you might want to collect CPU metrics more frequently than system information.

Example configuration with custom intervals:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: windows_exporter_metrics
      tag: windows_metrics
      scrape_interval: 10
      collector.cpu.scrape_interval: 5
      collector.memory.scrape_interval: 5
      collector.system.scrape_interval: 60
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name                        windows_exporter_metrics
  tag                         windows_metrics
  scrape_interval             10
  collector.cpu.scrape_interval 5
  collector.memory.scrape_interval 5
  collector.system.scrape_interval 60
```

{% endtab %}
{% endtabs %}

In this example, CPU and memory metrics are collected every 5 seconds, while system metrics are collected every 60 seconds. The global `scrape_interval` of 10 seconds determines how often metrics are published to the output.

## Requirements and permissions

The Windows Exporter metrics plugin uses Windows Management Instrumentation (WMI) to collect metrics. The following requirements apply:

- **Operating System**: Windows only (Windows 7/Server 2008 R2 or later)
- **Permissions**: The Fluent Bit process must have appropriate permissions to query WMI. Most metrics can be collected with standard user permissions, but some collectors may require elevated privileges.
- **WMI Service**: The Windows Management Instrumentation service must be running.

If you encounter permission errors, try running Fluent Bit with administrator privileges or ensure the service account has the necessary WMI query permissions.

## Enhancement requests

The plugin implements a subset of the available collectors in the original Prometheus Windows Exporter. If you would like a specific collector prioritized, open a GitHub issue by using the following template:

- [`in_windows_exporter_metrics`](https://github.com/fluent/fluent-bit/issues/new?assignees=\&labels=\&template=feature_request.md\&title=in_windows_exporter_metrics:%20add%20ABC%20collector)
