# Metrics Selector

The **metric_selector** processor allows you to select metrics to include or exclude (similar to the `grep` filter for logs).

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=326269f3-cfea-472d-9169-1de32c142b90" />

## Configuration Parameters <a id="config"></a>

The native processor plugin supports the following configuration parameters:

| Key         | Description | Default |
| :---------- | :--- | :--- |
| Metric\_Name | Keep metrics in which the metric of name matches with the actual name or the regular expression. | |
| Context | Specify matching context. Currently, metric\_name and delete\_label\_value are only supported. | `Metrics_Name` |
| Action | Specify the action for specified metrics. INCLUDE and EXCLUDE are allowed. | |
| Operation\_Type | Specify the operation type of action for metrics payloads. PREFIX and SUBSTRING are allowed. | |
| Label | Specify a label key and value pair. | |

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

{% tab title="context-delete\_label\_value.yaml" %}
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
{% endtab %}
{% endtabs %}


All processors are only valid with the YAML configuration format. 
Processor configuration should be located under the relevant input or output plugin configuration.

Metric\_Name parameter will translate the strings which is quoted with backslashes `/.../` as Regular expressions.
Without them, users need to specify Operation\_Type whether prefix matching or substring matching.
The default operation is prefix matching.
For example, `/chunks/` will be translated as a regular expression.
