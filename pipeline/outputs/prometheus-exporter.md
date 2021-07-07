---
description: An output plugin to expose Prometheus Metrics
---

# Prometheus Exporter

The prometheus exporter allows you to take metrics from Fluent Bit and expose them such that a Prometheus instance can scrape them. 

Important Note: The prometheus exporter only works with metric  plugins, such as Node Exporter Metrics

| Key | Description | Default |
| :--- | :--- | :--- |
| listen | This is address Fluent Bit will bind to when hosting prometheus metrics | 0.0.0.0 |
| port | This is the port Fluent Bit will bind to when hosting prometheus metrics | 2021 |
| add\_label | This allows you to add custom labels to all metrics exposed through the prometheus exporter. You may have multiple of these fields |  |

## Getting Started

The Prometheus exporter only works with metrics captured from metric plugins. In the following example, host metrics are captured by the node exporter metrics plugin and then are routed to prometheus exporter. Within the output plugin two labels are added `app="fluent-bit"`and `color="blue"`

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

