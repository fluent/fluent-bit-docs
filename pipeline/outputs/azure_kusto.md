---
description: Send logs to Azure Data Explorer (Kusto)
---

# Azure Data Explorer (Kusto)

The Kusto output plugin allows to ingest your logs into an [Azure Data Explorer](https://azure.microsoft.com/en-us/services/data-explorer/) cluster, via the [Queued Ingestion](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/about-kusto-ingest#queued-ingestion) mechanism. This output plugin can also be used to ingest logs into an [Eventhouse](https://blog.fabric.microsoft.com/en-us/blog/eventhouse-overview-handling-real-time-data-with-microsoft-fabric/) cluster in Microsoft Fabric Real Time Analytics.

## For ingesting into Azure Data Explorer:  Creating a Kusto Cluster and Database

You can create an Azure Data Explorer cluster in one of the following ways:

- [Create a free-tier cluster](https://dataexplorer.azure.com/freecluster)
- [Create a fully-featured cluster](https://docs.microsoft.com/en-us/azure/data-explorer/create-cluster-database-portal)

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

```kql
.create table FluentBit (log:dynamic, tag:string, timestamp:datetime)
```

## Optional - Creating an Ingestion Mapping

By default, Kusto will insert incoming ingestions into a table by inferring the mapped table columns, from the payload properties. However, this mapping can be customized by creatng a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping). The plugin can be configured to use an ingestion mapping via the `ingestion_mapping_reference` configuration key.

## Configuration Parameters

| Key                         | Description                                                                                                                                                                                                                      | Default     |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| tenant_id                   | _Required_ - The tenant/domain ID of the AAD registered application.                                                                                                                                                             |             |
| client_id                   | _Required_ - The client ID of the AAD registered application.                                                                                                                                                                    |             |
| client_secret               | _Required_ - The client secret of the AAD registered application ([App Secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-2-create-a-new-application-secret)). |
| ingestion_endpoint          | _Required_ - The cluster's ingestion endpoint, usually in the form `https://ingest-cluster_name.region.kusto.windows.net                                                                                                         |
| database_name               | _Required_ - The database name.                                                                                                                                                                                                  |             |
| table_name                  | _Required_ - The table name.                                                                                                                                                                                                     |             |
| ingestion_mapping_reference | _Optional_ - The name of a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping) that will be used to map the ingested payload into the table columns.           |             |
| log_key                     | Key name of the log content.                                                                                                                                                                                                     | `log`       |
| include_tag_key             | If enabled, a tag is appended to output. The key name is used `tag_key` property.                                                                                                                                                | `On`        |
| tag_key                     | The key name of tag. If `include_tag_key` is false, This property is ignored.                                                                                                                                                    | `tag`       |
| include_time_key            | If enabled, a timestamp is appended to output. The key name is used `time_key` property.                                                                                                                                         | `On`        |
| time_key                    | The key name of time. If `include_time_key` is false, This property is ignored.                                                                                                                                                  | `timestamp` |

### Configuration File

Get started quickly with this configuration file:

```
[OUTPUT]
    Match *
    Name azure_kusto
    Tenant_Id <app_tenant_id>
    Client_Id <app_client_id>
    Client_Secret <app_secret>
    Ingestion_Endpoint https://ingest-<cluster>.<region>.kusto.windows.net
    Database_Name <database_name>
    Table_Name <table_name>
    Ingestion_Mapping_Reference <mapping_name>
```

## Troubleshooting

### 403 Forbidden

If you get a `403 Forbidden` error response, make sure that:

- You provided the correct AAD registered application credentials.
- You authorized the application to ingest into your database or table.
