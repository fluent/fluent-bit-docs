---
description:  A plugin to collect Fluent Bit metrics
---

# Fluent Bit metrics

Fluent Bit exposes [metrics](../../administration/monitoring.md) to let you monitor the internals of your pipeline. The collected metrics can be processed similarly to those from the [Prometheus Node Exporter input plugin](node-exporter-metrics.md). They can be sent to output plugins including [Prometheus Exporter](../outputs/prometheus-exporter.md), [Prometheus Remote Write](../outputs/prometheus-remote-write.md) or [OpenTelemetry](../outputs/opentelemetry.md).

{% hint style="info" %}

Metrics collected with Node Exporter Metrics flow through a separate pipeline from logs and current filters don't operate on top of metrics.

{% endhint %}

## Configuration

| Key             | Description                                                               | Default   |
| --------------- | --------------------------------------------------------------------------| --------- |
| `scrape_interval` | The rate at which metrics are collected from the host operating system. | `2` seconds |
| `scrape_on_start` | Scrape metrics upon start, use to avoid waiting for `scrape_interval` for the first round of metrics.  | `false` |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

### Configuration file

In the following configuration file, the input plugin `node_exporter_metrics` collects metrics every `2` seconds and exposes them through the [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port `2021`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
    
pipeline:
    inputs:
        - name: fluentbit_metrics
          tag: internal_metrics
          scrape_interval: 2

    outputs:
        - name: prometheus_exporter
          match: internal_metrics
          host: 0.0.0.0
          port: 2021
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

You can test the expose of the metrics by using `curl`:

```shell
curl http://127.0.0.1:2021/metrics
```