---
description: An output plugin to expose Prometheus Metrics
---

# Prometheus exporter

The _Prometheus exporter_ lets you take metrics from Fluent Bit and expose them so a Prometheus instance can scrape them.

The Prometheus exporter works only with metric plugins such as Node Exporter Metrics.


## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:----|:------------|:--------|
| `host` | This is address Fluent Bit will bind to when hosting Prometheus metrics. The `listen` parameter is deprecated in 1.9.0 and later. | `0.0.0.0` |
| `port` | This is the port Fluent Bit will bind to when hosting Prometheus metrics. | `2021` |
| `add_label` | This lets you add custom labels to all metrics exposed through the Prometheus exporter. You can have multiple of these fields. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Get started

The Prometheus exporter works only with metrics captured from metric plugins. In the following example, host metrics are captured by the node exporter metrics plugin and then are routed to Prometheus exporter. In the output plugin, the labels `app="fluent-bit"`and `color="blue"` are added.

{% tabs %}
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
      # add user-defined labels
      add_label:
        - app fluent-bit
        - color blue
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  host            0.0.0.0
  port            2021
  # add user-defined labels
  add_label       app fluent-bit
  add_label       color blue
```

{% endtab %}
{% endtabs %}
