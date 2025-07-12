---
description: Send logs to Azure Data Explorer (Kusto)
---

# Azure Data Explorer (Kusto)

The Kusto output plugin allows to ingest your logs into an [Azure Data Explorer](https://azure.microsoft.com/en-us/services/data-explorer/) cluster, via the [Queued Ingestion](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/about-kusto-ingest#queued-ingestion) mechanism. This output plugin can also be used to ingest logs into an [Eventhouse](https://blog.fabric.microsoft.com/en-us/blog/eventhouse-overview-handling-real-time-data-with-microsoft-fabric/) cluster in Microsoft Fabric Real Time Analytics.

## For ingesting into Azure Data Explorer:  Creating a Kusto Cluster and Database

You can create an Azure Data Explorer cluster in one of the following ways:

- [Create a free-tier cluster](https://dataexplorer.azure.com/freecluster)
- [Create a fully featured cluster](https://docs.microsoft.com/en-us/azure/data-explorer/create-cluster-database-portal)

## For ingesting into Microsoft Fabric Real Time Analytics : Creating an Eventhouse Cluster and KQL Database

You can create an Eventhouse cluster and a KQL database follow the following steps:

- [Create an Eventhouse cluster](https://docs.microsoft.com/en-us/azure/data-explorer/eventhouse/create-eventhouse-cluster)
- [Create a KQL database](https://docs.microsoft.com/en-us/azure/data-explorer/eventhouse/create-database)

## Creating an Azure Registered Application

Fluent-Bit will use the application's credentials, to ingest data into your cluster.

- [Register an Application](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#register-an-application)
- [Add a client secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret)
- [Authorize the app in your database](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/access-control/principals-and-identity-providers#azure-ad-tenants)

## Creating a Table

Fluent-Bit ingests the event data into Kusto in a JSON format, that by default will include 3 properties:

- `log` - the actual event payload.
- `tag` - the event tag.
- `timestamp` - the event timestamp.

A table with the expected schema must exist in order for data to be ingested properly.

```sql
.create table FluentBit (log:dynamic, tag:string, timestamp:datetime)
```

## Optional - Creating an Ingestion Mapping

By default, Kusto will insert incoming ingestions into a table by inferring the mapped table columns, from the payload properties. However, this mapping can be customized by creating a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping). The plugin can be configured to use an ingestion mapping via the `ingestion_mapping_reference` configuration key.

## Configuration Parameters

| Key                         | Description                                                                                                                                                                                                                      | Default     |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| tenant_id                   | _Required if `managed_identity_client_id` is not set_ - The tenant/domain ID of the AAD registered application.                                                                                                                                                             |             |
| client_id                   | _Required if `managed_identity_client_id` is not set_ - The client ID of the AAD registered application.                                                                                                                                                                    |             |
| client_secret               | _Required if `managed_identity_client_id` is not set_ - The client secret of the AAD registered application ([App Secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-2-create-a-new-application-secret)). |
| managed_identity_client_id  | _Required if `tenant_id`, `client_id`, and `client_secret` are not set_ - The managed identity ID to authenticate with. Set to `SYSTEM` for system-assigned managed identity, or set to the MI client ID (GUID) for user-assigned managed identity.                                                                                                                                                                   |             |
| ingestion_endpoint          | _Required_ - The cluster's ingestion endpoint, usually in the form `https://ingest-cluster_name.region.kusto.windows.net                                                                                                         |
| database_name               | _Required_ - The database name.                                                                                                                                                                                                  |             |
| table_name                  | _Required_ - The table name.                                                                                                                                                                                                     |             |
| ingestion_mapping_reference | _Optional_ - The name of a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping) that will be used to map the ingested payload into the table columns.           |             |
| log_key                     | Key name of the log content.                                                                                                                                                                                                     | `log`       |
| include_tag_key             | If enabled, a tag is appended to output. The key name is used `tag_key` property.                                                                                                                                                | `On`        |
| tag_key                     | The key name of tag. If `include_tag_key` is false, This property is ignored.                                                                                                                                                    | `tag`       |
| include_time_key            | If enabled, a timestamp is appended to output. The key name is used `time_key` property.                                                                                                                                         | `On`        |
| time_key                    | The key name of time. If `include_time_key` is false, This property is ignored.                                                                                                                                                  | `timestamp` |
| ingestion_endpoint_connect_timeout                    | The connection timeout of various Kusto endpoints in seconds.                                                                                                                                                  | `60` |
| compression_enabled         | If enabled, sends compressed HTTP payload (gzip) to Kusto.                                                                                                                                                  | `true` |
| ingestion_resources_refresh_interval                    | The ingestion resources refresh interval of Kusto endpoint in seconds.
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| buffering_enabled           | _Optional_ - Enable buffering into disk before ingesting into Azure Kusto. | `Off` |
| buffer_dir                  | _Optional_ - When buffering is `On`, specifies the location of directory where the buffered data will be stored. | `/tmp/fluent-bit/azure-kusto/` |
| upload_timeout              | _Optional_ - When buffering is `On`, specifies a timeout for uploads. Fluent Bit will start ingesting buffer files which have been created more than x minutes and haven't reached `upload_file_size` limit. | `30m` |
| upload_file_size            | _Optional_ - When buffering is `On`, specifies the size of files to be uploaded in MBs. | `200MB` |
| azure_kusto_buffer_key     | _Optional_ - When buffering is `On`, set the Azure Kusto buffer key which must be specified when using multiple instances of Azure Kusto output plugin and buffering is enabled. | `key` |
| store_dir_limit_size        | _Optional_ - When buffering is `On`, set the max size of the buffer directory. | `8GB` |
| buffer_file_delete_early    | _Optional_ - When buffering is `On`, whether to delete the buffered file early after successful blob creation. | `Off` |
| unify_tag                   | _Optional_ - This creates a single buffer file when the buffering mode is `On`. | `On` |
| blob_uri_length             | _Optional_ - Set the length of generated blob URI before ingesting to Kusto. | `64` |
| scheduler_max_retries       | _Optional_ - When buffering is `On`, set the maximum number of retries for ingestion using the scheduler. | `3` |
| delete_on_max_upload_error  | _Optional_ - When buffering is `On`, whether to delete the buffer file on maximum upload errors. | `Off` |
| io_timeout                  | _Optional_ - Configure the HTTP IO timeout for uploads. | `60s` |

### Configuration File

Get started quickly with this configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
    
pipeline:
  inputs:
    - name: dummy
      dummy: '{"name": "Fluent Bit", "year": 2020}'
      samples: 1
      tag: var.log.containers.app-default-96cbdef2340.log      
      
  outputs:
    - name: azure_kusto
      match: '*'
      tenant_id: <app_tenant_id>
      client_id: <app_client_id>
      client_secret: <app_secret>
      ingestion_endpoint: https://ingest-<cluster>.<region>.kusto.windows.net
      database_name: <database_name>
      table_name: <table_name>
      ingestion_mapping_reference: <mapping_name>
      ingestion_endpoint_connect_timeout: <ingestion_endpoint_connect_timeout>
      compression_enabled: <compression_enabled>
      ingestion_resources_refresh_interval: <ingestion_resources_refresh_interval>
      buffering_enabled: on
      upload_timeout: 2m
      upload_file_size: 125M
      azure_kusto_buffer_key: kusto1
      buffer_file_delete_early: off
      unify_tag: on
      buffer_dir: /var/log/
      store_dir_limit_size: 16GB
      blob_uri_length: 128
      scheduler_max_retries: 3
      delete_on_max_upload_error: off
      io_timeout: 60s 
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name azure_kusto
  Match *
  Tenant_Id <app_tenant_id>
  Client_Id <app_client_id>
  Client_Secret <app_secret>
  Ingestion_Endpoint https://ingest-<cluster>.<region>.kusto.windows.net
  Database_Name <database_name>
  Table_Name <table_name>
  Ingestion_Mapping_Reference <mapping_name>
  ingestion_endpoint_connect_timeout <ingestion_endpoint_connect_timeout>
  compression_enabled <compression_enabled>
  ingestion_resources_refresh_interval <ingestion_resources_refresh_interval>
  buffering_enabled On
  upload_timeout 2m
    upload_file_size 125M
    azure_kusto_buffer_key kusto1
    buffer_file_delete_early Off
    unify_tag On
    buffer_dir /var/log/
    store_dir_limit_size 16GB
    blob_uri_length 128
    scheduler_max_retries 3
    delete_on_max_upload_error Off
    io_timeout 60s

```

{% endtab %}
{% endtabs %}

## Troubleshooting

### 403 Forbidden

If you get a `403 Forbidden` error response, make sure that:

- You provided the correct AAD registered application credentials.
- You authorized the application to ingest into your database or table.