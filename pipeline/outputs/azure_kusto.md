---
description: Send logs to Azure Data Explorer (Kusto)
---

# Azure Data Explorer

The _Kusto_ output plugin lets you ingest your logs into an [Azure Data Explorer](https://azure.microsoft.com/en-us/services/data-explorer/) cluster, using the [Queued Ingestion](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/api/netfx/about-kusto-ingest#queued-ingestion) mechanism. This output plugin can also be used to ingest logs into an [Eventhouse](https://blog.fabric.microsoft.com/en-us/blog/eventhouse-overview-handling-real-time-data-with-microsoft-fabric/) cluster in Microsoft Fabric Real Time Analytics.

## Ingest into Azure Data Explorer: create a Kusto cluster and database

Create an Azure Data Explorer cluster in one of the following ways:

- [Create a free-tier cluster](https://dataexplorer.azure.com/freecluster)
- [Create a fully featured cluster](https://docs.microsoft.com/en-us/azure/data-explorer/create-cluster-database-portal)

## Ingest into Microsoft Fabric real time analytics: create an Eventhouse cluster and KQL database

Create an Eventhouse cluster and a KQL database using the following steps:

- [Create an Eventhouse cluster](https://learn.microsoft.com/en-us/training/modules/query-data-kql-database-microsoft-fabric/)
- [Create a KQL database](https://learn.microsoft.com/en-us/training/modules/query-data-kql-database-microsoft-fabric/)

## Create an Azure registered application

Fluent Bit uses the application's credentials to ingest data into your cluster.

- [Register an application](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#register-an-application)
- [Add a client secret](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret)
- [Authorize the app in your database](https://learn.microsoft.com/en-us/azure/app-service/overview-authentication-authorization)

## Create a table

Fluent Bit ingests the event data into Kusto in a JSON format. By default, the table includes 3 properties:

- `log` - the actual event payload.
- `tag` - the event tag.
- `timestamp` - the event timestamp.

A table with the expected schema must exist in order for data to be ingested properly.

```shell
.create table FluentBit (log:dynamic, tag:string, timestamp:datetime)
```

## Optional - create an ingestion mapping

By default, Kusto will insert incoming ingestion data into a table by inferring the mapped table columns, from the payload properties. However, this mapping can be customized by creating a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping). The plugin can be configured to use an ingestion mapping using the `ingestion_mapping_reference` configuration key.

## Configuration parameters

| Key  | Description | Default |
|------|-------------|--------|
| `alias`                                | Sets an alias, use to define multiple instances of the same output plugin.      | _none_                         |
| `auth_type`                            | Set the authentication type: `service_principal`, `managed_identity`, or `workload_identity`. For `managed_identity`, use `system` as `client_id` for `system-assigned identity`, or specify the managed identity's client ID. | `service_principal`            |
| `azure_kusto_buffer_key`               | When buffering is `true`, set the Azure Kusto buffer key which must be specified when using multiple instances of Azure Kusto output plugin and buffering is enabled.                                                          | `key`                          |
| `blob_uri_length`                      | Set the length of generated blob URI before ingesting to Kusto.              | `64`                           |
| `buffer_dir`                           | When buffering is `true`, specifies the location of directory where the buffered data will be stored.                                                 | `/tmp/fluent-bit/azure-kusto/` |
| `buffering_enabled`                    | Enable buffering into disk before ingesting into Azure Kusto.                | `false`                        |
| `buffer_file_delete_early`             | When buffering is `true`, whether to delete the buffered file early after successful blob creation.                                                   | `false`                        |
| `unify_tag`                            | Optional. This creates a single buffer file when the buffering mode is `On`. | `On`                           |
| `client_id`                            | Required if `managed_identity_client_id` isn't set. The client ID of the AAD registered application.                                                  | _none_                         |
| `client_secret`                        | Set the client secret (Application Password) of the AAD application used for authentication.                                                          | _none_                         |
| `compression_enabled`                  | If enabled, sends compressed HTTP payload (gzip) to Kusto.                   | `true`                         |
| `database_name`                        | The database name.                                                           | _none_                         |
| `delete_on_max_upload_error`           | When buffering is `true`, whether to delete the buffer file on maximum upload errors.                                                                 | `false`                        |
| `host`                                 | IP address or hostname of the target HTTP server.                            | `127.0.0.1`                    |
| `io_timeout`                           | Configure the HTTP IO timeout for uploads.                                   | `60s`                          |
| `include_tag_key`                      | If enabled, a tag is appended to output. The key name is used `tag_key` property.                                                                     | `true`                         |
| `include_time_key`                     | If enabled, a timestamp is appended to output. The key name is used `time_key` property.                                                              | `true`                         |
| `ingestion_endpoint`                   | The cluster's ingestion endpoint, usually in the form `https://ingest-cluster_name.region.kusto.windows.net`.                                         | _none_                         |
| `ingestion_endpoint_connect_timeout`   | The connection timeout of various Kusto endpoints in seconds.                | `60`                           |
| `ingestion_mapping_reference`          | The name of a [JSON ingestion mapping](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/mappings#json-mapping) that will be used to map the ingested payload into the table columns.                      | _none_                         |
| `ingestion_resources_refresh_interval` | Set the Azure Kusto ingestion resources refresh interval.                    | `3600`                         |
| `log_key`                              | Key name of the log content.                                                 | `log`                          |
| `log_level`                            | Specifies the log level for output plugin. If not set here, plugin uses global log level in `service` section.                                        | `info`                         |
| `log_supress_interval`                 | Suppresses log messages from output plugin that appear similar within a specified time interval. `0` no suppression.                                  | `0`                            |
| `match`                                | Set a tag pattern to match records that output should process. Exact matches or wildcards (for example `*`).                                          | _none_                         |
| `match_regex`                          | Set a regular expression to match tags for output routing. This allows more flexible matching compared to wildcards.                           | _none_                         |
| `net.connect_timeout`                  | Set maximum time allowed to establish a connection, this time includes the TLS handshake.                                                             | `10s`                          |
| `net.connect_timeout_log_error`        | On connection timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message.                                    | `true`                         |
| `net.dns.mode`                         | Select the primary DNS connection type (TCP or UDP).                         | _none_                         |
| `net.dns.prefer_ipv4`                  | Select the primary DNS resolver type (LEGACY or ASYNC).                      | `false`                        |
| `net.dns.prefer_ipv6`                  | Prioritize IPv6 DNS results when trying to establish a connection.           | `false`                        |
| `net.dns.resolver`                     | Select the primary DNS resolver type (LEGACY or ASYNC).                      | _none_                         |
| `net.io_timeout`                       | Set maximum time a connection can stay idle while assigned.                  | `0s`                           |
| `net.keepalive`                        | Enable or disable `Keepalive` support.                                       | `false`                        |
| `net.keepalive_idle_timeout`           | Set maximum time allowed for an idle `Keepalive` connection..                | `false`                        |
| `net.max_worker_connections`           | Set the maximum number of active TCP connections that can be used per worker thread.                                                                  | `0`                            |
| `net.proxy_env_ignore`                 | Ignore the environment variables `HTTP_PROXY`, `HTTPS_PROXY` and `NO_PROXY` when set.                                                                 | `false`                        |
| `net.source_address`                   | Specify network address to bind for data traffic.                            | _none_                         |
| `net.tcp_keepalive`                    | Enable or disable Keepalive support.                                         | `off`                          |
| `net.tcp_keepalive_interval`           | Interval between TCP keepalive probes when no response is received on a `keepidle` probe.                                                               | `-1`                           |
| `net.keepalive_max_recycle`            | Set maximum number of times a keepalive connection can be used before it's retried.                                                                  | `2000`                         |
| `net.tcp_keepalive_probes`             | Number of unacknowledged probes to consider a connection dead.               | `-1`                           |
| `net.tcp_keepalive_time`               | Interval between the last data packet sent and the first TCP keepalive probe.| `-1`                           |
| `net.max_worker_connections`           | Set the maximum number of active TCP connections that can be used per worker thread.                                                                  | `0`                            |
| `port`                                 | TCP port of the target HTTP server.                                          | `0`                            |
| `retry_limit`                          | Set retry limit for output plugin when delivery fails. Integer, `no_limits`, `false`, or `off` to disable, or `no_retries` to disable retries entirely.                                                                        | `1`                            |
| `scheduler_max_retries`                | Optional. When buffering is `On`, set the maximum number of retries for ingestion using the scheduler.                                                | `3`                            |
| `store_dir_limit_size`                 | When buffering is `true`, set the max size of the buffer directory.          | `8G`                           |
| `tag_key`                              | The key name of tag. If `include_tag_key` is false, This property is ignored.| `tag`                          |
| `table_name`                           | The table name.                                                              | _none_                         |
| `tenant_id`                            | Required if `managed_identity_client_id` isn't set. The tenant/domain ID of the AAD registered application.                                           | _none_                         |
| `time_key`                             | The key name of time. If `include_time_key` is false, this property is ignored.                                                                       | `timestamp`                    |
| `tls`                                  | Enable or disable TLS/SSL support.                                           | `off`                          |
| `tls.ca_file`                          | Absolute path to CA certificate file.                                        | _none_                         |
| `tls.ca_path`                          | Absolute path to scan for certificate files.                                 | _none_                         |
| `tls.crt_file`                        | Absolute path to Certificate file.                                           | _none_                         |
| `tls.ciphers`                          | Specify TLS ciphers up to TLSv1.2.                                           | _none_                         |
| `tls.debug`                            | Set TLS debug level. Accepts `0` (No debug), `1`(Error), `2` (State change), `3` (Informational) and `4` (Verbose).                                   | `1`                            |
| `tls.key_file`                         | Absolute path to private Key file.                                           | _none_                         |
| `tls.key_passwd`                       | Optional password for tls.key_file file.                                     | _none_                         |
| `tls.max_version`                      | Specify the maximum version of TLS.                                          | _none_                         |
| `tls.min_version`                      | Specify the minimum version of TLS.                                          | _none_                         |
| `tls.verify_hostname`                  | Enable or disable to verify hostname.                                        | `off`                          |
| `tls.vhost`                            | Hostname to be used for TLS SNI extension.                                   | _none_                         |
| `tls.verify`                           | Force certificate validation.                                                | `on`                           |
| `tls.windows.certstore_name`           | Sets the `certstore` name on an output (Windows).                              | _none_                         |
| `tls.windows.use_enterprise_store`     | Sets whether using enterprise certificate store or not on an output (Windows).                                                                        | _none_                         |
| `unify_tag`                            | This creates a single buffer file when the buffering mode is `true`.         | `true`                         |
| `upload_file_size`                     | Specifies the size of files to be uploaded in megabytes.                     | `200MB`                        |
| `upload_timeout`                       | Optionally specify a timeout for uploads. Fluent Bit will start ingesting buffer files which have been created more than x minutes and haven't reached `upload_file_size` limit yet.                                           | `30m`                          |
| `workload_identity_token_file`         | Set the token path for workload identity authentication.                     | _none_                         |

### Configuration file

Get started with this configuration file:

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
  Name                                  azure_kusto
  Match                                 *
  Tenant_Id                             <app_tenant_id>
  Client_Id                             <app_client_id>
  Client_Secret                         <app_secret>
  Ingestion_Endpoint                    https://ingest-<cluster>.<region>.kusto.windows.net
  Database_Name                         <database_name>
  Table_Name                            <table_name>
  Ingestion_Mapping_Reference           <mapping_name>
  ingestion_endpoint_connect_timeout    <ingestion_endpoint_connect_timeout>
  compression_enabled                   <compression_enabled>
  ingestion_resources_refresh_interval  <ingestion_resources_refresh_interval>
  buffering_enabled                     On
  upload_timeout                        2m
  upload_file_size                      125M
  azure_kusto_buffer_key                kusto1
  buffer_file_delete_early              Off
  unify_tag                             On
  buffer_dir                            /var/log/
  store_dir_limit_size                  16GB
  blob_uri_length                       128
  scheduler_max_retries                 3
  delete_on_max_upload_error            Off
  io_timeout                            60s
```

{% endtab %}
{% endtabs %}

## Troubleshooting

### `403 Forbidden`

If you get a `403 Forbidden` error response, make sure that:

- You provided the correct AAD registered application credentials.
- You authorized the application to ingest into your database or table.
