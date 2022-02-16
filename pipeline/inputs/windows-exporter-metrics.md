---
description: >-
  A plugin based on Prometheus Windows Exporter to collect system / host level
  metrics
---

# Windows Exporter Metrics

[Prometheus Windows Exporter](https://github.com/prometheus-community/windows_exporter) is a popular way to collect system level metrics from microsoft windows, such as CPU / Disk / Network / Process statistics. Fluent Bit 1.9.0 includes windows exporter metrics plugin that builds off the Prometheus design to collect system level metrics without having to manage two separate processes or agents.

The initial release of Windows Exporter Metrics contains a single collector available from Prometheus Windows Exporter and we plan to expand it over time.

**Important note:** Metrics collected with Windows Exporter Metrics flow through a separate pipeline from logs and current filters do not operate on top of metrics.


## Configuration 

| Key             | Description                                                            | Default   |
| --------------- | ---------------------------------------------------------------------- | --------- |
| scrape_interval | The rate at which metrics are collected from the host operating system | 5 seconds |

## Collectors available

The following table describes the available collectors as part of this plugin. All of them are enabled by default and respects the original metrics name, descriptions, and types from Prometheus Windows Exporter, so you can use your current dashboards without any compatibility problem.

> note: the Version column specifies the Fluent Bit version where the collector is available.

| Name      | Description                                                                                      | OS      | Version |
| --------- | ------------------------------------------------------------------------------------------------ | ------- | ------- |
| cpu       | Exposes CPU statistics.                                                                          | Windows | v1.9    |

## Getting Started

### Simple Configuration File

In the following configuration file, the input plugin _windows_exporter_metrics collects _metrics every 2 seconds and exposes them through our [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port 2021.

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
    name            windows_exporter_metrics
    tag             node_metrics
    scrape_interval 2

[OUTPUT]
    name            prometheus_exporter
    match           node_metrics
    listen          0.0.0.0
    port            2021

        
```

You can test the expose of the metrics by using _curl:_

```bash
curl http://127.0.0.1:2021/metrics
```

## Enhancement Requests

Our current plugin implements a sub-set of the available collectors in the original Prometheus Windows Exporter, if you would like that we prioritize a specific collector please open a Github issue by using the following template:\
\
\- [in_windows_exporter_metrics](https://github.com/fluent/fluent-bit/issues/new?assignees=\&labels=\&template=feature_request.md\&title=in_windows_exporter_metrics:%20add%20ABC%20collector)

