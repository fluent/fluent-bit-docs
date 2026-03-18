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
| `add_label` | This lets you add custom labels to all metrics exposed through the Prometheus exporter. You can have multiple of these fields. | _none_ |
| `add_timestamp` | Add timestamp to every metric honoring collection time. | `false` |
| `host` | IP address or hostname Fluent Bit will bind to when hosting Prometheus metrics. The `listen` parameter is deprecated in 1.9.0 and later. | `0.0.0.0` |
| `port` | TCP port Fluent Bit will bind to when hosting Prometheus metrics. | `2021` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

The Prometheus exporter works only with metrics captured from metric plugins. In the following example, host metrics are captured by the node exporter metrics plugin and then are routed to Prometheus exporter. In the output plugin, the labels `app="fluent-bit"`and `color="blue"` are added.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
# Node Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collect host metrics on Linux and expose
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
# them through a Prometheus HTTP endpoint.
#
# After starting the service try it with:
#
# $ curl http://127.0.0.1:2021/metrics
#
[SERVICE]
  Flush           1
  Log_Level       info

[INPUT]
  Name            node_exporter_metrics
  Tag             node_metrics
  Scrape_Interval 2

[OUTPUT]
  Name            prometheus_exporter
  Match           node_metrics
  Host            0.0.0.0
  Port            2021
  # add user-defined labels
  Add_Label       app fluent-bit
  Add_Label       color blue
```

{% endtab %}
{% endtabs %}
