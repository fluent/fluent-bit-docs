---
description: A plugin based on Prometheus Windows Exporter to collect system and host level metrics
---

# Windows Exporter metrics

[Prometheus Windows Exporter](https://github.com/prometheus-community/windows_exporter) is a popular way to collect system level metrics from Microsoft Windows, such as CPU, Disk, Network, and Process statistics. Fluent Bit 1.9.0 and later includes the Windows Exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes or agents.

The initial release of Windows Exporter metrics contains a single collector available from Prometheus Windows Exporter.

Metrics collected with Windows Exporter metrics flow through a separate pipeline from logs and current filters don't operate on top of metrics.

## Configuration

| Key             | Description                                                            | Default   |
| --------------- | ---------------------------------------------------------------------- | --------- |
| `scrape_interval` | The rate at which metrics are collected. | `5 seconds` |
| `we.logical_disk.allow_disk_regex` | Specify the regular expression for logical disk metrics to allow collection of.  | `"/.+/"` (all) |
| `we.logical_disk.deny_disk_regex` | Specify the regular expression for logical disk metrics to prevent collection of or ignore.  | `NULL` (all) |
| `we.net.allow_nic_regex` | Specify the regular expression for network metrics captured by the name of the NIC. | `"/.+/"` (all) |
| `we.service.where` | Specify the `WHERE` clause for retrieving service metrics.  | `NULL` |
| `we.service.include` | Specify the key value pairs for the include condition for the `WHERE` clause of service metrics. | `NULL`   |
| `we.service.exclude` | Specify the key value pairs for the exclude condition for the `WHERE` clause of service metrics. | `NULL`   |
| `we.process.allow_process_regex` | Specify the regular expression covering the process metrics to collect. | `"/.+/"` (all) |
| `we.process.deny_process_regex`  | Specify the regular expression for process metrics to prevent collection of or ignore. | `NULL` (all) |
| `collector.cpu.scrape_interval` | The rate in seconds at which `cpu` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.net.scrape_interval` | The rate in seconds at which `net` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.logical_disk.scrape_interval` | The rate in seconds at which `logical_disk` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.cs.scrape_interval` | The rate in seconds at which `cs` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.os.scrape_interval`| The rate in seconds at which `os` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.thermalzone.scrape_interval`| The rate in seconds at which `thermalzone` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.cpu_info.scrape_interval`| The rate in seconds at which `cpu_info` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.logon.scrape_interval`   | The rate in seconds at which `logon` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.system.scrape_interval`  | The rate in seconds at which `system` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.service.scrape_interval`  | The rate in seconds at which `service` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.memory.scrape_interval`  | The rate in seconds at which `memory` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.paging_file.scrape_interval`  | The rate in seconds at which `paging_file` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `collector.process.scrape_interval`  | The rate in seconds at which `process` metrics are collected. Values greater than `0` override the global default. Otherwise, the global default is used. | `0 seconds` |
| `metrics` | Specify which metrics are collected. | `"cpu,cpu_info,os,net,logical_disk,cs,thermalzone,logon,system,service"` |

## Collectors available

The following table describes the available collectors as part of this plugin. All collectors are enabled by default and respect the original metrics name, descriptions, and types from Prometheus Windows Exporter, so you can use your current dashboards without any compatibility problem.

The Version column specifies the Fluent Bit version where the collector is available.

| Name          | Description                                                                                      | OS      | Version |
| ------------- | ------------------------------------------------------------------------------------------------ | ------- | ------- |
| `cpu`           | Exposes CPU statistics.                                                                          | Windows | v1.9    |
| `net`           | Exposes Network statistics.                                                                      | Windows | v2.0.8  |
| `logical_disk` | Exposes `logical_disk` statistics.                                                                | Windows | v2.0.8  |
| `cs`            | Exposes `cs` statistics.                                                                         | Windows | v2.0.8  |
| `os`            | Exposes OS statistics.                                                                           | Windows | v2.0.8  |
| `thermalzone`   | Exposes `thermalzone` statistics.                                                                | Windows | v2.0.8  |
| `cpu_info`     | Exposes `cpu_info` statistics.                                                                    | Windows | v2.0.8  |
| `logon`         | Exposes `logon` statistics.                                                                      | Windows | v2.0.8  |
| `system`        | Exposes `system` statistics.                                                                     | Windows | v2.0.8  |
| `service`       | Exposes `service` statistics.                                                                    | Windows | v2.1.6  |
| `memory`        | Exposes `memory` statistics.                                                                       | Windows | v2.1.9 |
| `paging_file`   | Exposes `paging_file` statistics.                                                                 | Windows | v2.1.9  |
| `process`       | Exposes `process` statistics.                                                                      | Windows | v2.1.9 |

## Threading

This input always runs in its own [thread](../../administration/multithreading.md#inputs).

## Get started

### Configuration file

In the following configuration file, the input plugin `windows_exporter_metrics` collects `metrics` every two seconds and exposes them through the [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port `2021`.

```text
# Node Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collect host metrics on Linux and expose
# them through a Prometheus HTTP end-point.
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

You can test the expose of the metrics by using `curl`:

```shell
curl http://127.0.0.1:2021/metrics
```

### Service where clause

Windows service collector will retrieve all of the service information for the local node or container.
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

## Enhancement requests

The plugin implements a subset of the available collectors in the original Prometheus Windows Exporter. If you would like a specific collector prioritized, open a Github issue by using the following template:

- [`in_windows_exporter_metrics`](https://github.com/fluent/fluent-bit/issues/new?assignees=\&labels=\&template=feature_request.md\&title=in_windows_exporter_metrics:%20add%20ABC%20collector)
