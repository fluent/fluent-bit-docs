---
description: >-
  A plugin to collect Fluent Bit's own metrics
---

# Fluent Bit Metrics

Fluent Bit exposes its [own metrics](../../administration/monitoring.md) to allow you to monitor the internals of your pipeline.
The collected metrics can be processed similarly to those from the [Prometheus Node Exporter input plugin](node-exporter-metrics.md).
They can be sent to output plugins including [Prometheus Exporter](../outputs/prometheus-exporter.md) or [Prometheus Remote Write](../outputs/prometheus-remote-write.md).

**Important note:** Metrics collected with Node Exporter Metrics flow through a separate pipeline from logs and current filters do not operate on top of metrics.


## Configuration 

| Key             | Description                                                                                               | Default   |
| --------------- | --------------------------------------------------------------------------------------------------------- | --------- |
| scrape_interval | The rate at which metrics are collected from the host operating system                                    | 2 seconds |
| scrape_on_start | Scrape metrics upon start, useful to avoid waiting for 'scrape_interval' for the first round of metrics.  | false     |


## Getting Started

### Simple Configuration File

In the following configuration file, the input plugin _node_exporter_metrics collects _metrics every 2 seconds and exposes them through our [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port 2021.

```
# Fluent Bit Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collects Fluent Bit metrics and exposes
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
    name            fluentbit_metrics
    tag             internal_metrics
    scrape_interval 2

[OUTPUT]
    name            prometheus_exporter
    match           internal_metrics
    host            0.0.0.0
    port            2021

```

You can test the expose of the metrics by using _curl:_

```bash
curl http://127.0.0.1:2021/metrics
```
