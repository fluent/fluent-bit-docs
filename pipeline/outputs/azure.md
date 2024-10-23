---
description: 'Send logs, metrics to Azure Log Analytics'
---

# Azure Log Analytics

![](../../.gitbook/assets/image%20%287%29.png)

Azure output plugin allows to ingest your records into [Azure Log Analytics](https://azure.microsoft.com/en-us/services/log-analytics/) service.

To get more details about how to setup Azure Log Analytics, please refer to the following documentation: [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/)

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Customer\_ID | Customer ID or WorkspaceID string. |  |
| Shared\_Key | The primary or the secondary Connected Sources client authentication key. |  |
| Log\_Type | The name of the event type. | fluentbit |
| Log_Type_Key | If included, the value for this key will be looked upon in the record and if present, will over-write the `log_type`. If not found then the `log_type` value will be used. | |
| Time\_Key | Optional parameter to specify the key name where the timestamp will be stored. | @timestamp |
| Time\_Generated | If enabled, the HTTP request header 'time-generated-field' will be included so Azure can override the timestamp with the key specified by 'time_key' option. | off |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Getting Started

In order to insert records into an Azure Log Analytics instance, you can run the plugin from the command line or through the configuration file:

### Command Line

The **azure** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -o azure -p customer_id=abc -p shared_key=def -m '*' -f 1
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name  cpu

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID abc
    Shared_Key  def
```

Another example using the `Log_Type_Key` with [record-accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor), which will read the table name (or event type) dynamically from kubernetes label `app`, instead of `Log_Type`:

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
