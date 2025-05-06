# Metrics Selector

The _Metrics Selector_ processor lets you choose which metrics to include or exclude, similar to the [Grep](../pipeline/filters/grep) filter for logs.

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=326269f3-cfea-472d-9169-1de32c142b90" />

## Configuration parameters

The Metrics Selector processor supports the following configuration parameters:

| Key         | Description | Default |
| :---------- | :--- | :--- |
| `metric_name` | The string that determines which metrics are affected by this processor, depending on the active [matching operation](#matching-operations). | |
| `context` | Specifies matching context. Possible values: `metric_name` or `delete_label`. | `metrics_name` |
| `action` | Specifies whether to include or exclude matching metrics. Possible values: `INCLUDE` or `EXCLUDE`. | |
| `operation_type` | Specifies the [matching operation](#matching-operations) to apply to the value of `metric_name`. Possible values: `PREFIX` or `SUBSTRING`. | |
| `label` | Specifies a label key and value pair. | |

## Matching operations

The Metrics Selector processor has two matching operations: prefix matching and substring matching.

### Prefix matching

Prefix matching compares the value of `metric_name` to the beginning of each incoming metric name. For example, `metric_name: fluentbit_input` results in a match for metrics named `fluentbit_input_records`, but not for metrics named `total_fluentbit_input`.

If no `operation_type` value is specified and the value of `metric_name` is a standard string, the Metrics Selector processor defaults to prefix matching.

### Substring matching

Substring matching treats the value of `metric_name` as a regex pattern, and compares this pattern against each incoming metric name accordingly. This pattern can appear anywhere within the name of the incoming metric. For example, `metric_name: bytes` results in a match for metrics named `bytes_total` and metrics named `input_bytes_count`.

If the value of `metric_name` is a string wrapped in forward slashes (for example, `metric_name: /storage..*/`), the Metrics Selector processor defaults to substring matching, regardless of whether an `operation_type` value is specified. This means that a `metric_name` value wrapped in forward slashes will always use substring matching, even if `operation_type` is set to `PREFIX`.

However, if `operation_type` is explicitly set to `SUBSTRING`, you don't need to wrap the value of `metric_name` in forward slashes.

## Configuration examples

The following examples show possible configurations of the Metrics Selector processor.

### Without `context`

```yaml
service:
  flush: 5
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: fluentbit_metrics
      tag: fluentbit.metrics
      scrape_interval: 10

      processors:
        metrics:
          - name: metrics_selector
            metric_name: /storage/
            action: include
          - name: metrics_selector
            metric_name: /fs/
            action: exclude

          - name: labels
            delete: name


  outputs:
    - name: stdout
      match: '*'
```

### With `context`

```yaml
service:
  flush: 5
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: fluentbit_metrics
      tag: fluentbit.metrics
      scrape_interval: 10

      processors:
        metrics:
          - name: metrics_selector
            context: delete_label_value
            label: name stdout.0

          - name: labels
            delete: name


  outputs:
    - name: stdout
      match: '*'
```
