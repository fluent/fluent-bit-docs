---
description: >-
  A plugin based on Prometheus Node Exporter to collect system / host level
  metrics
---

# Node Exporter Metrics

[Prometheus Node Exporter](https://github.com/prometheus/node_exporter) is a popular way to collect system level metrics from operating systems, such as CPU / Disk / Network / Process statistics. Fluent Bit 1.8.0 includes node exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes or agents.

The initial release of Node Exporter Metrics contains a subset of collectors and metrics available from Prometheus Node Exporter and we plan to expand them over time.

**Important note:** Metrics collected with Node Exporter Metrics flow through a separate pipeline from logs and current filters do not operate on top of metrics.

This plugin is supported on Linux-based operating systems for the most part with macOS offering a reduced subset of metrics.
The table below indicates which collector is supported on macOS.


## Configuration

| Key             | Description                                                            | Default   |
| --------------- | ---------------------------------------------------------------------- | --------- |
| scrape_interval | The rate at which metrics are collected from the host operating system | 5 seconds |
| path.procfs     | The mount point used to collect process information and metrics        | /proc/    |
| path.sysfs      | The path in the filesystem used to collect system metrics              | /sys/     |
| collector.cpu.scrape\_interval | The rate in seconds at which cpu metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.cpufreq.scrape\_interval   | The rate in seconds at which cpufreq metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.meminfo.scrape\_interval   | The rate in seconds at which meminfo metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.diskstats.scrape\_interval | The rate in seconds at which diskstats metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.filesystem.scrape\_interval | The rate in seconds at which filesystem metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.uname.scrape\_interval     | The rate in seconds at which uname metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used.| 0 seconds |
| collector.stat.scrape\_interval      | The rate in seconds at which stat metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.time.scrape\_interval      | The rate in seconds at which time metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.loadavg.scrape\_interval   | The rate in seconds at which loadavg metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.vmstat.scrape\_interval   | The rate in seconds at which vmstat metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.thermal_zone.scrape\_interval   | The rate in seconds at which thermal_zone metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.filefd.scrape\_interval   | The rate in seconds at which filefd metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.nvme.scrape\_interval | The rate in seconds at which nvme metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| collector.processes.scrape\_interval | The rate in seconds at which system level of process metrics are collected from the host operating system. If a value greater than 0 is used then it overrides the global default otherwise the global default is used. | 0 seconds |
| metrics | To specify which metrics are collected from the host operating system. These metrics depend on `/proc` or `/sys` fs. The actual values of metrics will be read from `/proc` or `/sys` when needed. cpu, cpufreq, meminfo, diskstats, filesystem, stat, loadavg, vmstat, netdev, and filefd depend on procfs. cpufreq metrics depend on sysfs. | `"cpu,cpufreq,meminfo,diskstats,filesystem,uname,stat,time,loadavg,vmstat,netdev,filefd"` |
| filesystem.ignore\_mount\_point\_regex  | Specify the regex for the mount points to prevent collection of/ignore. | `^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+|var/lib/containers/storage/.+)($|/)`    |
| filesystem.ignore\_filesystem\_type\_regex  | Specify the regex for the filesystem types to prevent collection of/ignore. | `^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$`    |
| diskstats.ignore\_device\_regex | Specify the regex for the diskstats to prevent collection of/ignore. | `^(ram|loop|fd|(h|s|v|xv)d[a-z]|nvme\\d+n\\d+p)\\d+$` |
| systemd_service_restart_metrics | Determines if the collector will include service restart metrics | false |
| systemd_unit_start_time_metrics | Determines if the collector will include unit start time metrics | false |
| systemd_include_service_task_metrics | Determines if the collector will include service task metrics | false |
| systemd_include_pattern | regex to determine which units are included in the metrics produced by the systemd collector | It is not applied unless explicitly set |
| systemd_exclude_pattern | regex to determine which units are excluded in the metrics produced by the systemd collector | `.+\\.(automount|device|mount|scope|slice)"`    |


**Note:** The plugin top-level `scrape_interval` setting is the global default with any custom settings for individual `scrape_intervals` then overriding just that specific metric scraping interval.
Each `collector.xxx.scrape_interval` option only overrides the interval for that specific collector and updates the associated set of provided metrics.

The overridden intervals only change the collection interval, not the interval for publishing the metrics which is taken from the global setting.
For example, if the global interval is set to 5s and an override interval of 60s is used then the published metrics will be reported every 5s but for the specific collector they will stay the same for 60s until it is collected again.
This feature aims to help with down-sampling when collecting metrics.


## Collectors available

The following table describes the available collectors as part of this plugin. All of them are enabled by default and respects the original metrics name, descriptions, and types from Prometheus Exporter, so you can use your current dashboards without any compatibility problem.

> note: the Version column specifies the Fluent Bit version where the collector is available.

| Name              | Description                                                                                      | OS          | Version |
| ----------------- | ------------------------------------------------------------------------------------------------ | ----------- | ------- |
| cpu               | Exposes CPU statistics.                                                                          | Linux,macOS | v1.8    |
| cpufreq           | Exposes CPU frequency statistics.                                                                | Linux       | v1.8    |
| diskstats         | Exposes disk I/O statistics.                                                                     | Linux,macOS | v1.8    |
| filefd            | Exposes file descriptor statistics from `/proc/sys/fs/file-nr`.                                  | Linux       | v1.8.2  |
| filesystem        | Exposes filesystem statistics from `/proc/*/mounts`.                                             | Linux       | v2.0.9  |
| loadavg           | Exposes load average.                                                                            | Linux,macOS | v1.8    |
| meminfo           | Exposes memory statistics.                                                                       | Linux,macOS | v1.8    |
| netdev            | Exposes network interface statistics such as bytes transferred.                                  | Linux,macOS | v1.8.2  |
| stat              | Exposes various statistics from `/proc/stat`. This includes boot time, forks, and interruptions. | Linux       | v1.8    |
| time              | Exposes the current system time.                                                                 | Linux       | v1.8    |
| uname             | Exposes system information as provided by the uname system call.                                 | Linux,macOS | v1.8    |
| vmstat            | Exposes statistics from `/proc/vmstat`.                                                          | Linux       | v1.8.2  |
| systemd collector | Exposes statistics from systemd.                                                                 | Linux       | v2.1.3  |
| thermal_zone      | Expose thermal statistics from `/sys/class/thermal/thermal_zone/*`                               | Linux       | v2.2.1  |
| nvme              | Exposes nvme statistics from `/proc`.                                                            | Linux       | v2.2.0  |
| processes         | Exposes processes statistics from `/proc`.                                                       | Linux       | v2.2.0  |

## Getting Started

### Simple Configuration File

In the following configuration file, the input plugin _node_exporter_metrics collects _metrics every 2 seconds and exposes them through our [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port 2021.

{% tabs %}
{% tab title="fluent-bit.conf" %}
```
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
    name            node_exporter_metrics
    tag             node_metrics
    scrape_interval 2

[OUTPUT]
    name            prometheus_exporter
    match           node_metrics
    host            0.0.0.0
    port            2021

        
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
# Node Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collect host metrics on Linux and expose
# them through a Prometheus HTTP end-point.
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
        - name: node_exporter_metrics
          tag:  node_metrics
          scrape_interval: 2
    outputs:
        - name: prometheus_exporter
          match: node_metrics
          host: 0.0.0.0
          port: 2021
```
{% endtab %}
{% endtabs %}

You can test the expose of the metrics by using _curl:_

```bash
curl http://127.0.0.1:2021/metrics
```

### Container to Collect Host Metrics

When deploying Fluent Bit in a container you will need to specify additional settings to ensure that Fluent Bit has access to the host operating system. The following docker command deploys Fluent Bit with specific mount paths and settings enabled to ensure that Fluent Bit can collect from the host. These are then exposed over port 2021.

```
docker run -ti -v /proc:/host/proc \
               -v /sys:/host/sys   \
               -p 2021:2021        \
               fluent/fluent-bit:1.8.0 \
               /fluent-bit/bin/fluent-bit \
                         -i node_exporter_metrics -p path.procfs=/host/proc -p path.sysfs=/host/sys \
                         -o prometheus_exporter -p "add_label=host $HOSTNAME" \
                         -f 1
```

### Fluent Bit + Prometheus + Grafana

If you like dashboards for monitoring, Grafana is one of the preferred options. In our Fluent Bit source code repository, we have pushed a simple **docker-compose **example. Steps:

#### Get a copy of Fluent Bit source code

```bash
git clone https://github.com/fluent/fluent-bit
cd fluent-bit/docker_compose/node-exporter-dashboard/
```

#### Start the service and view your Dashboard

```
docker-compose up --force-recreate -d --build
```

Now open your browser in the address **http://127.0.0.1:3000**. When asked for the credentials to access Grafana, just use the **admin **username and **admin **password**.**

![](../../.gitbook/assets/updated.png)

Note that by default Grafana dashboard plots the data from the last 24 hours, so just change it to **Last 5 minutes** to see the recent data being collected.

#### Stop the Service

```bash
docker-compose down
```

## Enhancement Requests

Our current plugin implements a sub-set of the available collectors in the original Prometheus Node Exporter, if you would like that we prioritize a specific collector please open a Github issue by using the following template:\
\
\- [in_node_exporter_metrics](https://github.com/fluent/fluent-bit/issues/new?assignees=\&labels=\&template=feature_request.md\&title=in_node_exporter_metrics:%20add%20ABC%20collector)

