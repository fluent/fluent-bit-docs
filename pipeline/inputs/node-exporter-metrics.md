---
description: >-
  A plugin based on prometheus node exporter to collect system / host level
  metrics
---

# Node Exporter Metrics

[Prometheus Node Exporter](https://github.com/prometheus/node_exporter) is a popular way to collect system level metrics from operating systems, such as CPU / Disk / Network / Process statistics. Fluent Bit 1.8.0 includes node exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes.

The initial release of Node Exporter Metrics contains a subset of metrics available from Prometheus Node Exporter and we plan to expand them over time.

**Important note:** Metrics collected with Node Exporter Metrics flow through a separate pipeline from logs and current filters do not operate on top of metrics.

This plugin is currently only supported on Linux based operating systems

| Key | Description | Default |
| :--- | :--- | :--- |
| scrape\_interval | The rate at which metrics are collected from the host operating system | 5 seconds |
| path.procfs | The mount point used to collect process information and metrics | /proc/ |
| path.sysfs | The path in the filesystem used to collect system metrics  | /sys/ |

## Getting Started

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
    name            node_exporter_metrics
    tag             node_metrics
    scrape_interval 2

[OUTPUT]
    name            prometheus_exporter
    match           node_metrics
    listen          0.0.0.0
    port            2021
    # add user-defined labels
    add_label       app fluent-bit
    add_label       color blue
```

## Using a container to collect host metrics

When deploying Fluent Bit in a container you will need to specify additional settings to ensure that Fluent Bit has access to the host operating system. The following docker command deploys Fluent Bit with specific mount paths and settings enabled to ensure that Fluent Bit can collect from the host. These are then exposed over port 2021.

```text
docker run -ti -v /proc:/host/proc \
               -v /sys:/host/sys   \
               -p 2021:2021        \
               fluent/fluent-bit:1.8.0 \
               /fluent-bit/bin/fluent-bit \
                         -i node_exporter_metrics -p path.procfs=/host/proc -p path.sysfs=/host/sys \
                         -o prometheus_exporter -p "add_label=host $HOSTNAME" \
                         -f 1
```

