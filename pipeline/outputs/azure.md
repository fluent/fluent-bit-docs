---
description: Send logs, metrics to Azure Log Analytics
---

# Azure Log Analytics

Azure output plugin lets you ingest your records into [Azure Log Analytics](https://azure.microsoft.com/en-us/services/log-analytics/) service.

For details about how to setup Azure Log Analytics, see the [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/) documentation.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `Customer_ID` | Customer ID or WorkspaceID string. | _none_ |
| `Shared_Key` | The primary or the secondary Connected Sources client authentication key. | _none_ |
| `Log_Type` | The name of the event type. | `fluentbit` |
| `Log_Type_Key` | If included, the value for this key checked in the record and if present, will overwrite the `log_type`. If not found then the `log_type` value will be used. | _none_ |
| `Time_Key` | Optional. Specify the key name where the timestamp will be stored. | `@timestamp` |
| `Time_Generated` | If enabled, the HTTP request header `time-generated-field` will be included so Azure can override the timestamp with the key specified by `time_key` option. | `off` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

To insert records into an Azure Log Analytics instance, run the plugin from the command line or through the configuration file.

### Command line

The _Azure_ plugin can read the parameters from the command line in the following ways, using the `-p` argument (property):

```shell
fluent-bit -i cpu -o azure -p customer_id=abc -p shared_key=def -m '*' -f 1
```

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: azure
      match: '*'
      customer_id: abc
      shared_key: def
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name        azure
  Match       *
  Customer_ID abc
  Shared_Key  def
```

{% endtab %}
{% endtabs %}

The following example uses the `Log_Type_Key` with [record-accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor), which will read the table name (or event type) dynamically from the Kubernetes label `app`, instead of `Log_Type`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: azure
      match: '*'
      log_type_key: $kubernetes['labels']['app']
      customer_id: abc
      shared_key: def
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name        azure
  Match       *
  Log_Type_Key $kubernetes['labels']['app']
  Customer_ID abc
  Shared_Key  def
```

{% endtab %}
{% endtabs %}
