---
description: Send logs to Azure Log Analytics using Logs Ingestion API
---

# Azure Logs Ingestion API

Azure Logs Ingestion plugin lets you ingest your records using [Logs Ingestion API in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview) to supported [Azure tables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview#supported-tables) or to [custom tables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/create-custom-table#create-a-custom-table) that you create.

The Logs ingestion API requires the following components:

- A Data Collection Endpoint (DCE)
- A Data Collection Rule (DCR) and
- A Log Analytics Workspace

To visualize the basic logs ingestion operation, see the following image:

![Log ingestion overview](../../.gitbook/assets/azure-logs-ingestion-overview.png)

To get more details about how to set up these components, refer to the following documentation:

- [Azure Logs Ingestion API](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview)
- [Send data to Azure Monitor Logs with Logs ingestion API (setup DCE, DCR and Log Analytics)](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal)

## Configuration parameters

| Key | Description | Default |
| :------------ | :------------------------- | :------ |
| `tenant_id` | The tenant ID of the Azure Active Directory (AAD) application. | _none_ |
| `client_id` | The client ID of the AAD application. | _none_ |
| `client_secret` | The client secret of the AAD application ([App Secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-2-create-a-new-application-secret)). | _none_ |
| `dce_url` | Data Collection Endpoint(DCE) URL. | _none_ |
| `dcr_id` | Data Collection Rule (DCR) [immutable ID](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal#collect-information-from-the-dcr). | _none_ |
| `table_name` | The name of the custom log table (include the `_CL` suffix as well if applicable) | _none_ |
| `time_key` | Optional. Specify the key name where the timestamp will be stored. | `@timestamp` |
| `time_generated` | Optional. If enabled, will generate a timestamp and append it to JSON. The key name is set by the `time_key` parameter. | `true` |
| `compress` | Optional. Enable HTTP payload gzip compression. | `true` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

To send records into an Azure Log Analytics using Logs Ingestion API the following resources needs to be created:

- A Data Collection Endpoint (DCE) for ingestion
- A Data Collection Rule (DCR) for data transformation
- Either an [Azure tables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview#supported-tables) or [custom tables](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/create-custom-table#create-a-custom-table)
- An app registration with client secrets (for DCR access).

Follow [this guideline](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal) to set up the DCE, DCR, app registration and a custom table.

### Configuration file

Use this configuration file to get started:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      path: /path/to/your/sample.log
      tag: sample
      key: RawData

    # Or use other plugins
    #- name: cpu
    #  tag: sample

  filters:
    - name: modify
      match: sample
      # Add a json key named "Application":"fb_log"
      add: Application fb_log

  outputs:
    # Enable this section to see your json-log format
    #- name: stdout
    #  match: '*'

    - name: azure_logs_ingestion
      match: sample
      client_id: XXXXXXXX-xxxx-yyyy-zzzz-xxxxyyyyzzzzxyzz
      client_secret: some.secret.xxxzzz
      tenant_id: XXXXXXXX-xxxx-yyyy-zzzz-xxxxyyyyzzzzxyzz
      dce_url: https://log-analytics-dce-XXXX.region-code.ingest.monitor.azure.com
      dcr_id: dcr-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      table_name: ladcr_CL
      time_generated: true
      time_key: Time
      compress: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name    tail
  Path    /path/to/your/sample.log
  Tag     sample
  Key     RawData

# Or use other plugins
#[INPUT]
#  Name    cpu
#  Tag     sample

[FILTER]
  Name modify
  Match sample
  # Add a json key named "Application":"fb_log"
  Add Application fb_log

# Enable this section to see your json-log format
#[OUTPUT]
#  Name stdout
#  Match *

[OUTPUT]
  Name            azure_logs_ingestion
  Match           sample
  client_id       XXXXXXXX-xxxx-yyyy-zzzz-xxxxyyyyzzzzxyzz
  client_secret   some.secret.xxxzzz
  tenant_id       XXXXXXXX-xxxx-yyyy-zzzz-xxxxyyyyzzzzxyzz
  dce_url         https://log-analytics-dce-XXXX.region-code.ingest.monitor.azure.com
  dcr_id          dcr-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  table_name      ladcr_CL
  time_generated  true
  time_key        Time
  Compress        true
```

{% endtab %}
{% endtabs %}

Set up your DCR transformation based on the JSON output from the Fluent Bit pipeline (input, parser, filter, output).
