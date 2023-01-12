---
description: Generate metrics from logs
---

# Log To Metrics

The _Log To Metrics Filter_ plugin allows you to generate log-derived metrics. It currently supports modes to count records, sum up field values over a record stream or provide a gauge for field values. You can also match or exclude specific records based on regular expression patterns for values or nested values. This filter plugin does not actually act as a record filter and does not change or drop records. All records will pass this filter untouched and generated metrics will be emitted into a seperate metric pipeline.

_Please note that this plugin is an experimental feature and is not recommended for production use. Configuration parameters and plugin functionality are subject to change without notice._


## Configuration Parameters

The plugin supports the following configuration parameters:

| Key |  Description | Mandatory  | Value Format
| :--- | :--- | :--- | :--- 
| tag | Defines the tag for the generated metrics record| Yes | |
| metric_mode | Defines the mode for the metric. Valid values are [`counter`, `sum` or `gauge`] | Yes | |  
| metric_name | Sets the name of the metric. | Yes | |
| metric_description | Sets a help text for the metric. | Yes | |
| label_field | Includes a record field as label dimension in the metric. | | Name of record key. Supports [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) notation for nested fields.
| value_field | Specify the record field that holds a numerical value to either sum up or take as most recent value | Yes, for modes [`sum` and `gauge`] | Name of record key. Supports [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) notation for nested fields.
| kubernetes_mode |  If enabled, it will automatically put pod_id, pod_name, namespace_name, docker_id and container_name into the metric as labels. This option is intended to be used in combination with the [kubernetes](./kubernetes.md) filter plugin, which fills those fields. | | 
| Regex | Include records in which the content of KEY matches the regular expression. | |  KEY  REGEX 
| Exclude | Exclude records in which the content of KEY matches the regular expression. | |  KEY  REGEX 

## Getting Started

The following example takes records from two dummy inputs and counts all messages passing through the `log_to_metrics` filter. It then generates metric records which are provided to the `prometheus_exporter`:

### Configuration - Counter

```python
[SERVICE]
    flush              1
    log_level          info

[INPUT]
    Name               dummy
    Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456"}, "duration": 20, "color": "red", "shape": "circle"}
    Tag                dummy.log

[INPUT]
    Name               dummy
    Dummy              {"message":"hello", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456"}, "duration": 60, "color": "blue", "shape": "square"}
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
    port               2021
```

You can then use e.g. curl command to retrieve the generated metric:
```text
> curl -s http://127.0.0.1:2021/metrics


# HELP log_metric_counter_count_all_dummy_messages This metric counts dummy messages
# TYPE log_metric_counter_count_all_dummy_messages counter
log_metric_counter_count_all_dummy_messages 49
```

### Configuration  - Sum

If you want to sum up values within a record and provide the result as a metric, you have to specify a `value_field` to sum up. In this example we also add two labels via the `label_field` options:
```python
[FILTER]
    name               log_to_metrics
    match              dummy.log*
    tag                test_metric
    metric_mode        sum
    metric_name        sum_up_durations
    metric_description This metric sums up duration field values
    value_field        duration
    label_field        color
    label_field        shape
```

You can then use e.g. curl command to retrieve the generated metric:
```text
> curl -s http://127.0.0.1:2021/metrics


# HELP log_metric_counter_sum_up_durations This metric sums up duration field values
# TYPE log_metric_counter_sum_up_durations counter
log_metric_counter_sum_up_durations{color="red",shape="circle"} 400
log_metric_counter_sum_up_durations{color="blue",shape="square"} 1140
```
#### Metric label_values
As you can see, the label sets defined by `label_field` are added to the metric. The lines in the metric represent every combination of labels. Only actually used combinations are displayed here. To see this, you can add a third `dummy` input (with "color": "blue") to your configuration:

```python
[INPUT]
    Name               dummy
    Dummy              {"message":"dummy", "kubernetes":{"namespace_name": "default", "docker_id": "abc123", "pod_name": "pod1", "container_name": "mycontainer", "pod_id": "def456"}, "duration": 20, "color": "blue", "shape": "circle"}
    Tag                dummy.log
```

The metric output would then look like:
```text
> curl -s http://127.0.0.1:2021/metrics

# HELP log_metric_counter_sum_up_durations This metric sums up duration field values
# TYPE log_metric_counter_sum_up_durations counter
log_metric_counter_sum_up_durations{color="red",shape="circle"} 140
log_metric_counter_sum_up_durations{color="blue",shape="circle"} 120
log_metric_counter_sum_up_durations{color="blue",shape="square"} 360
```

### Configuration  - Gauge

Similar to the `sum` mode, `gauge` needs a `value_field` specified, where the current metric values are generated from. In this example we also apply a regex filter and enable the `kubernetes_mode` option:
```python
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
    label_field        color
    label_field        shape
```
You can then use e.g. curl command to retrieve the generated metric:
```text
> curl -s http://127.0.0.1:2021/metrics


# HELP log_metric_gauge_current_duration This metric shows the current duration
# TYPE log_metric_gauge_current_duration gauge
log_metric_gauge_current_duration{namespace_name="default",pod_name="pod1",container_name="mycontainer",docker_id="abc123",pod_id="def456",color="blue",shape="square"} 60
```

As you can see in the output, only one line is printed, as the records from the first input plugin are ignored, as they do not match the regex.

The filter also allows to use multiple rules which are applied in order, you can have many _Regex_ and _Exclude_ entries as required (see [grep](./grep.md) filter plugin).

If you execute the above `curl` command multiple times, you see, that in this example the metric value stays at `60`, as the messages generated by the dummy plugin are not changing. In a real-world scenario the values would change and return the last processed value.

You can also see, that all the kubernetes labels have been attached to the metric, idential to the behavior of `label_field` described in [the previous chapter](#metric-label_values)
