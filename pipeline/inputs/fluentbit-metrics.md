---
description:  A plugin to collect Fluent Bit metrics
---

# Fluent Bit metrics

Fluent Bit exposes [metrics](../../administration/monitoring.md) to let you monitor the internals of your pipeline. The collected metrics can be processed similarly to those from the [Prometheus Node Exporter input plugin](node-exporter-metrics.md). They can be sent to output plugins including [Prometheus Exporter](../outputs/prometheus-exporter.md), [Prometheus Remote Write](../outputs/prometheus-remote-write.md) or [OpenTelemetry](../outputs/opentelemetry.md).

{% hint style="info" %}

Metrics collected with Fluent Bit Metrics flow through a separate pipeline from logs and current filters don't operate on top of metrics.

{% endhint %}

## Configuration parameters

| Key               | Description                                                                                             | Default     |
|-------------------|---------------------------------------------------------------------------------------------------------|-------------|
| `scrape_interval` | The rate at which Fluent Bit internal metrics are collected.                                            | `2` seconds |
| `scrape_on_start` | Scrape metrics upon start, use to avoid waiting for `scrape_interval` for the first round of metrics.   | `false`     |
| `threaded`        | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false`     |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

Run the plugin from the command line using the following command:

```shell
fluent-bit -i fluentbit_metrics -o stdout
```

which returns results like the following:

```text
...
[2025/12/02 08:33:54.689265000] [ info] [input:fluentbit_metrics:fluentbit_metrics.0] initializing
[2025/12/02 08:33:54.689272000] [ info] [input:fluentbit_metrics:fluentbit_metrics.0] storage_strategy='memory' (memory only)
[2025/12/02 08:33:54.689917000] [ info] [output:stdout:stdout.0] worker #0 started
[2025/12/02 08:33:54.690115000] [ info] [sp] stream processor started
[2025/12/02 08:33:54.690204000] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
2025-12-02T07:33:56.692855536Z fluentbit_uptime{hostname="XXXXX.local"} = 2
2025-12-02T07:33:54.687838528Z fluentbit_logger_logs_total{message_type="error"} = 0
2025-12-02T07:33:54.687838528Z fluentbit_logger_logs_total{message_type="warn"} = 0
2025-12-02T07:33:54.690212675Z fluentbit_logger_logs_total{message_type="info"} = 10
2025-12-02T07:33:54.687838528Z fluentbit_logger_logs_total{message_type="debug"} = 0
2025-12-02T07:33:54.687838528Z fluentbit_logger_logs_total{message_type="trace"} = 0
2025-12-02T07:33:54.689222850Z fluentbit_input_bytes_total{name="fluentbit_metrics.0"} = 0
2025-12-02T07:33:54.689222850Z fluentbit_input_records_total{name="fluentbit_metrics.0"} = 0
2025-12-02T07:33:54.689222850Z fluentbit_input_ring_buffer_writes_total{name="fluentbit_metrics.0"} = 0
2025-12-02T07:33:54.689222850Z fluentbit_input_ring_buffer_retries_total{name="fluentbit_metrics.0"} = 0
2025-12-02T07:33:54.689222850Z fluentbit_input_ring_buffer_retry_failures_total{name="fluentbit_metrics.0"} = 0
2025-12-02T07:33:56.692846827Z fluentbit_input_metrics_scrapes_total{name="fluentbit_metrics.0"} = 1
2025-12-02T07:33:54.689563930Z fluentbit_output_proc_records_total{name="stdout.0"} = 0
...
```

### Configuration file

In the following configuration file, the input plugin `fluentbit_metrics` collects metrics every `2` seconds and exposes them through the [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port `2021`.

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
# them through a Prometheus HTTP endpoint.
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
