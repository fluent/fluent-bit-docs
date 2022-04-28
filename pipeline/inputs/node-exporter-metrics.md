---
description: >-
  A plugin based on Prometheus Node Exporter to collect system / host level
  metrics
---

# Node Exporter Metrics

[Prometheus Node Exporter](https://github.com/prometheus/node_exporter) is a popular way to collect system level metrics from operating systems, such as CPU / Disk / Network / Process statistics. Fluent Bit 1.8.0 includes node exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes or agents.

The initial release of Node Exporter Metrics contains a subset of collectors and metrics available from Prometheus Node Exporter and we plan to expand them over time.

**Important note:** Metrics collected with Node Exporter Metrics flow through a separate pipeline from logs and current filters do not operate on top of metrics.

This plugin is currently only supported on Linux based operating systems\


## Configuration 

| Key             | Description                                                            | Default   |
| --------------- | ---------------------------------------------------------------------- | --------- |
| scrape_interval | The rate at which metrics are collected from the host operating system | 5 seconds |
| path.procfs     | The mount point used to collect process information and metrics        | /proc/    |
| path.sysfs      | The path in the filesystem used to collect system metrics              | /sys/     |

## Collectors available

The following table describes the available collectors as part of this plugin. All of them are enabled by default and respects the original metrics name, descriptions, and types from Prometheus Exporter, so you can use your current dashboards without any compatibility problem.

> note: the Version column specifies the Fluent Bit version where the collector is available.

| Name      | Description                                                                                      | OS     | Version |
| --------- | ------------------------------------------------------------------------------------------------ | ------ | ------- |
| cpu       | Exposes CPU statistics.                                                                          | Linux  | v1.8    |
| cpufreq   | Exposes CPU frequency statistics.                                                                | Linux  | v1.8    |
| diskstats | Exposes disk I/O statistics.                                                                     | Linux  | v1.8    |
| filefd    | Exposes file descriptor statistics from `/proc/sys/fs/file-nr`.                                  | Linux  | v1.8.2  |
| loadavg   | Exposes load average.                                                                            | Linux  | v1.8    |
| meminfo   | Exposes memory statistics.                                                                       | Linux  | v1.8    |
| netdev    | Exposes network interface statistics such as bytes transferred.                                  | Linux  | v1.8.2  |
| stat      | Exposes various statistics from `/proc/stat`. This includes boot time, forks, and interruptions. | Linux  | v1.8    |
| time      | Exposes the current system time.                                                                 | Linux  | v1.8    |
| uname     | Exposes system information as provided by the uname system call.                                 | Linux  | v1.8    |
| vmstat    | Exposes statistics from `/proc/vmstat`.                                                          | Linux  | v1.8.2  |

## Getting Started

### Simple Configuration File

In the following configuration file, the input plugin _node_exporter_metrics collects _metrics every 2 seconds and exposes them through our [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port 2021.

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

