# Metrics Selector

The **metric_selector** processor allows you to select metrics to include or exclude (similar to the `grep` filter for logs).

## Configuration Parameters <a id="config"></a>

The native processor plugin supports the following configuration parameters:

| Key         | Description | Default |
| :---------- | :--- | :--- |
| Metric\_Name | Keep metrics in which the metric of name matches with the actual name or the regular expression. | |
| Context | Specify matching context. Currently, metric_name is only supported. | `Metrics_Name` |
| Action | Specify the action for specified metrics. INCLUDE and EXCLUDE are allowed. | |
| Operation\_Type | Specify the operation type of action for metrics payloads. PREFIX and SUBSTRING are allowed. | |

## Configuration Examples <a id="config_example"></a>

Here is a basic configuration example.

{% tabs %}
{% tab title="fluent-bit.yaml" %}
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
{% endtab %}
{% endtabs %}


Note that processor is only effective on the YAML format. Also, processor elements should be located under input or output plguins' definitions.

Metric\_Name parameter will translate the strings which is quoted with backslashes `/.../` as Regular expressions.
Without them, users need to specify Operation\_Type whether prefix matching or substring matching.
The default operation is prefix matching.
