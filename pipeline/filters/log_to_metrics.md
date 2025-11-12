---
description: Generate metrics from logs
---

# Logs to metrics

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=768830f6-8d2d-4231-9e5e-259ce6797ba5"  alt="tracking"/>

The _log to metrics_ filter lets you generate log-derived metrics. It supports modes to count records, provide a gauge for field values, or create a histogram. You can also match or exclude specific records based on regular expression patterns for values or nested values.

This filter doesn't actually act as a record filter and therefore doesn't change or drop records. All records will pass through this filter untouched, and any generated metrics will be emitted into a separate metric pipeline.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default | Format |
|-----|-------------|---------|--------|
| `add_label`  | Adds a custom label `NAME` and set the value to the value of `KEY`. | _none_  | `NAME KEY` |
| `alias` | Sets an alias, use to set multiple instances of the same filter plugin. | _none_  |  |
| `bucket` | Optional for `metric_mode` `histogram`. If not set, default Prometheus-style buckets are used. | _none_ | For example, `0.75`. |
| `discard_logs` | Flag that defines if logs should be discarded after processing. This applies for all logs, whether they have emitted metrics or not. | `false` |  |
| `emitter_name` | Name of the emitter (advanced users). | _none_ |  |
| `emitter_mem_buf_limit` | Set a buffer limit to restrict memory usage of metrics emitter.  | `10M` |  |
| `exclude` | Excludes records in which the content of `KEY` matches the regular expression `REGEX`. | _none_       | `KEY REGEX` |
| `flush_interval_sec`    | The interval for metrics emission, in seconds. If `flush_interval_sec` and `flush_interval_nsec` are either both unset or both set to `0`, the filter emits metrics immediately after each filter match. Otherwise, if either parameter is set to a non-zero value, the filter emits metrics at the specified interval. Longer intervals help lower resource consumption in high-load situations. | `0` |  |
| `flush_interval_nsec`   | The interval for metrics emission, in nanoseconds. This parameter works in conjunction with `flush_interval_sec`.| `0` |  |
| `kubernetes_mode`       | If enabled, adds `pod_id`, `pod_name`, `namespace_name`, `docker_id` and `container_name` to the metric as labels. This option is intended to be used in combination with the [Kubernetes](./kubernetes.md) filter plugin, which fills those fields. | `false`      |  |
| `label_field`           | Includes a record field as label dimension in the metric. | _none_       | Name of record key. Supports [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) notation for nested fields. |
| `log_level`             | Specifies the log level for filter plugin. If not set here, plugin uses global log level in `service` section.| `info`       |  |
| `log_supress_interval`  | Suppresses log messages from filter plugin that appear similar within a specified time interval. Setting to `0` indicates no suppression. | `0`          |  |
| `match` | Set a tag pattern to match records that filter should process. Exact matches or wildcards. | _none_       |  |
| `match_regex`           | Set a regular expression to match tags for filter routing. This allows more flexible matching compared to wildcards. | _none_       |  |
| `metric_description`    | Sets a description for the metric.                                                  | _none_       |  |
| `metric_mode`           | Defines the mode for the metric. Valid values are `counter`, `gauge` or `histogram`.| `counter`    |  |
| `metric_name`           | Sets the name of the metric.                                                        | `a`          |  |
| `metric_namespace`      | Sets the namespace of the metric.                                                   | `log_metric` |  |
| `metric_subsystem`      | Subsystem of the metric.                                                            | _none_       |  |
| `regex`                 | Includes records in which the content of `KEY` matches the regular expression `REGEX`. | _none_       | `KEY REGEX` |
| `tag`                   | Defines the tag for the generated metrics record.                                   | _none_       |  |
| `value_field`           | Required for modes `gauge` and `histogram`. Specifies the record field that holds a numerical value. | _none_       | Name of record key. Supports [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) notation for nested fields. |

## Examples

{% hint style="info" %}

The following examples assume Prometheus is running on the local machine as shown in the Fluent Bit configurations.

{% endhint %}

### Counter

The following example takes records from two `dummy` inputs and counts all messages that pass through the `log_to_metrics` filter. It then generates metric records, which are provided to the `prometheus_exporter` output:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: dummy
      dummy: '{"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}'
      tag: dummy.log

    - name: dummy
      dummy: '{"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}'
      tag: dummy.log2

  filters:
    - name: log_to_metrics
      match: 'dummy.log*'
      tag: test_metric
      metric_mode: counter
      metric_name: count_all_dummy_messages
      metric_description: 'This metric counts dummy messages'

  outputs:
    - name: prometheus_exporter
      match: '*'
      host: 0.0.0.0
      port: 9999
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush              1
  log_level          info

[INPUT]
  Name               dummy
  Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}
  Tag                dummy.log

[INPUT]
  Name               dummy
  Dummy              {"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}
  Tag                dummy.log2

[FILTER]
  name               log_to_metrics
  match              dummy.log*
  tag                test_metric
  metric_mode        counter
  metric_name        count_all_dummy_messages
  metric_description This metric counts dummy messages

[OUTPUT]
  name               prometheus_exporter
  match              *
  host               0.0.0.0
  port               9999
```

{% endtab %}
{% tab title="prometheus.yml" %}

Run this configuration file with Prometheus to collect the metrics from the Fluent Bit configurations.

```yaml
# config
global:
  scrape_interval: 5s

scrape_configs:
  # Scraping Fluent Bit example.
  - job_name: "fluentbit"
    static_configs:
      - targets: ["localhost:9999"]
```

{% endtab %}
{% endtabs %}

You can then use a tool like curl to retrieve the generated metric:

```shell
$ curl -s http://127.0.0.1:9999/metrics


# HELP log_metric_counter_count_all_dummy_messages This metric counts dummy messages
# TYPE log_metric_counter_count_all_dummy_messages counter
log_metric_counter_count_all_dummy_messages 49
```

### Gauge

The `gauge` mode needs a `value_field` to specify where to generate the metric values from. This example also applies a `regex` filter and enables the `kubernetes_mode` option:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: dummy
      dummy: '{"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}'
      tag: dummy.log

    - name: dummy
      dummy: '{"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}'
      tag: dummy.log2

  filters:
    - name: log_to_metrics
      match: 'dummy.log*'
      tag: test_metric
      metric_mode: gauge
      metric_name: current_duration
      metric_description: 'This metric shows the current duration'
      value_field: duration
      kubernetes_mode: on
      regex: 'message .*el.*'
      add_label: app $kubernetes['labels']['app']
      label_field:
        - color
        - shape

  outputs:
    - name: prometheus_exporter
      match: '*'
      host: 0.0.0.0
      port: 9999
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush              1
  log_level          info

[INPUT]
  Name               dummy
  Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}
  Tag                dummy.log

[INPUT]
  Name               dummy
  Dummy              {"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}
  Tag                dummy.log2

[FILTER]
  name               log_to_metrics
  match              dummy.log*
  tag                test_metric
  metric_mode        gauge
  metric_name        current_duration
  metric_description This metric shows the current duration
  value_field        duration
  kubernetes_mode    on
  regex              message .*el.*
  add_label          app $kubernetes['labels']['app']
  label_field        color
  label_field        shape

[OUTPUT]
  name               prometheus_exporter
  match              *
  host               0.0.0.0
  port               9999
```

{% endtab %}
{% tab title="prometheus.yml" %}

Run this configuration file with Prometheus to collect the metrics from the Fluent Bit configurations.

```yaml
# config
global:
  scrape_interval: 5s

scrape_configs:
  # Scraping Fluent Bit example.
  - job_name: "fluentbit"
    static_configs:
      - targets: ["localhost:9999"]
```

{% endtab %}
{% endtabs %}

You can then use a tool like curl to retrieve the generated metric:

```shell
$ curl -s http://127.0.0.1:9999/metrics


# HELP log_metric_gauge_current_duration This metric shows the current duration
# TYPE log_metric_gauge_current_duration gauge
log_metric_gauge_current_duration{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="square"} 60
```

In the resulting output, only one line is printed. Records from the first input plugin are ignored because they don't match the regular expression.

This filter also lets you use multiple rules, which are applied in order. You can have as many `regex` and `exclude` entries as required (see [Grep](./grep.md) filter plugin).

If you execute the example curl command multiple times, the example metric value remains at `60` because the messages generated by the Dummy plugin don't change. In a real-world scenario, the values would change and return to the last processed value.

#### Metric `label_values`

The label sets defined by `add_label` and `label_field` are added to the metric. The lines in the metric represent every combination of labels. Only combinations that are actually used are displayed here.

### Histogram

Similar to the `gauge` mode, the `histogram` mode needs a `value_field` to specify where to generate the metric values from. This example also applies a `regex` filter and enables the `kubernetes_mode` option:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: dummy
      dummy: '{"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}'
      tag: dummy.log

    - name: dummy
      dummy: '{"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}'
      tag: dummy.log2

  filters:
    - name: log_to_metrics
      match: 'dummy.log*'
      tag: test_metric
      metric_mode: histogram
      metric_name: current_duration
      metric_description: 'This metric shows the request duration'
      value_field: duration
      kubernetes_mode: on
      regex: 'message .*el.*'
      add_label: app $kubernetes['labels']['app']
      label_field:
        - color
        - shape

  outputs:
    - name: prometheus_exporter
      match: '*'
      host: 0.0.0.0
      port: 9999
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush              1
  log_level          info

[INPUT]
  Name               dummy
  Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}
  Tag                dummy.log

[INPUT]
  Name               dummy
  Dummy              {"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}
  Tag                dummy.log2

[FILTER]
  name               log_to_metrics
  match              dummy.log*
  tag                test_metric
  metric_mode        histogram
  metric_name        current_duration
  metric_description This metric shows the request duration
  value_field        duration
  kubernetes_mode    on
  regex              message .*el.*
  add_label          app $kubernetes['labels']['app']
  label_field        color
  label_field        shape

[OUTPUT]
  name               prometheus_exporter
  match              *
  host               0.0.0.0
  port               9999
```

{% endtab %}
{% tab title="prometheus.yml" %}

Run this configuration file with Prometheus to collect the metrics from the Fluent Bit configurations.

```yaml
# config
global:
  scrape_interval: 5s

scrape_configs:
  # Scraping Fluent Bit example.
  - job_name: "fluentbit"
    static_configs:
      - targets: ["localhost:9999"]
```

{% endtab %}
{% endtabs %}

You can then use a tool like curl to retrieve the generated metric:

```shell
$ curl -s http://127.0.0.1:2021/metrics


# HELP log_metric_histogram_current_duration This metric shows the request duration
# TYPE log_metric_histogram_current_duration histogram
log_metric_histogram_current_duration_bucket{le="0.005",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.01",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.025",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.05",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.1",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.25",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.5",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="1.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="2.5",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="5.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="10.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="+Inf",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 28
log_metric_histogram_current_duration_sum{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 560
log_metric_histogram_current_duration_count{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="red",shape="circle"} 28
log_metric_histogram_current_duration_bucket{le="0.005",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.01",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.025",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.05",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.1",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.25",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="0.5",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="1.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="2.5",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="5.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="10.0",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 0
log_metric_histogram_current_duration_bucket{le="+Inf",namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 27
log_metric_histogram_current_duration_sum{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 1620
log_metric_histogram_current_duration_count{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",app="app1",color="blue",shape="circle"} 27
```

In the resulting output, there are several buckets by default: `0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0` and `+Inf`. Values are sorted into these buckets. A sum and a counter are also part of this metric. You can specify own buckets in the configuration, like in the following example:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: dummy
      dummy: '{"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}'
      tag: dummy.log

    - name: dummy
      dummy: '{"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}'
      tag: dummy.log2

  filters:
    - name: log_to_metrics
      match: 'dummy.log*'
      tag: test_metric
      metric_mode: histogram
      metric_name: current_duration
      metric_description: 'This metric shows the HTTP request duration as histogram in milliseconds'
      value_field: duration
      kubernetes_mode: on
      bucket:
        - 1
        - 5
        - 10
        - 50
        - 1000
        - 250
        - 500
        - 1000
      regex: 'message .*el.*'
      label_field:
        - color
        - shape

  outputs:
    - name: prometheus_exporter
      match: '*'
      host: 0.0.0.0
      port: 9999
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush              1
  log_level          info

[INPUT]
  Name               dummy
  Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 20, "color": "red", "shape": "circle"}
  Tag                dummy.log

[INPUT]
  Name               dummy
  Dummy              {"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456", "labels":{"app": "app1"}}, "duration": 60, "color": "blue", "shape": "square"}
  Tag                dummy.log2

[FILTER]
  name               log_to_metrics
  match              dummy.log*
  tag                test_metric
  metric_mode        histogram
  metric_name        current_duration
  metric_description This metric shows the HTTP request duration as histogram in milliseconds
  value_field        duration
  kubernetes_mode    on
  bucket             1
  bucket             5
  bucket             10
  bucket             50
  bucket             100
  bucket             250
  bucket             500
  bucket             1000
  regex              message .*el.*
  label_field        color
  label_field        shape

[OUTPUT]
  name               prometheus_exporter
  match              *
  host               0.0.0.0
  port               9999
```

{% endtab %}
{% tab title="prometheus.yml" %}

Run this configuration file with Prometheus to collect the metrics from the Fluent Bit configurations.

```yaml
# config
global:
  scrape_interval: 5s

scrape_configs:
  # Scraping Fluent Bit example.
  - job_name: "fluentbit"
    static_configs:
      - targets: ["localhost:9999"]
```

{% endtab %}
{% endtabs %}

{% hint style="info" %}

The `+Inf` bucket will always be included regardless of the buckets you specify. The buckets in a histogram are cumulative, so a value added to one bucket will be added to all larger buckets, too.

{% endhint %}

This filter also attaches Kubernetes labels to each metric, identical to the behavior of `label_field`. This results in two sets for the histogram.
