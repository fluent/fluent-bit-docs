---
description: Microsoft certified Azure Storage Blob connector
---

# Azure Blob

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The Azure Blob output plugin allows ingesting your records into [Azure Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs/) service. This connector is designed to use the Append Blob and Block Blob API.

The Fluent Bit plugin works with the official Azure Service and can be configured to be used with a service emulator such as [Azurite](https://github.com/Azure/Azurite).

## Azure Storage account

Ensure you have an Azure Storage account. [Azure Blob Storage Tutorial (video)](https://www.youtube.com/watch?v=-sCKnOm8G_g) explains how to set up your account.

## Configuration parameters

Fluent Bit exposes the following configuration properties.

| Key                                    | Description                                                                                                                                                                                                                                                                            | Default                       |
| :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------- |
| `account_name`                         | Azure Storage account name.                                                                                                                                                                                                                                                            | _none_                        |
| `auth_type`                            | Specify the type to authenticate against the service. Supported values: `key`, `sas`.                                                                                                                                                                                                  | `key`                         |
| `auto_create_container`                | If `container_name` doesn't exist in the remote service, enabling this option handles the exception and auto-creates the container.                                                                                                                                                    | `true`                        |
| `azure_blob_buffer_key`                | Set the Azure Blob buffer key which needs to be specified when using multiple instances of Azure Blob output plugin and buffering is enabled.                                                                                                                                          | `key`                         |
| `blob_type`                            | Specify the desired blob type. Supported values: `appendblob`, `blockblob`.                                                                                                                                                                                                            | `appendblob`                  |
| `blob_uri_length`                      | Set the length of the generated blob URI used when creating and uploading objects to Azure Blob Storage.                                                                                                                                                                               | `64`                          |
| `buffer_dir`                           | Specifies the location of directory where the buffered data will be stored.                                                                                                                                                                                                            | `/tmp/fluent-bit/azure-blob/` |
| `buffer_file_delete_early`             | Whether to delete the buffered file early after successful blob creation.                                                                                                                                                                                                              | `false`                       |
| `buffering_enabled`                    | Enable buffering into disk before ingesting into Azure Blob.                                                                                                                                                                                                                           | `false`                       |
| `compress`                             | Sets payload compression in network transfer. Supported values: `gzip`, `zstd`.                                                                                                                                                                                                        | _none_                        |
| `compress_blob`                        | Enables compression in the final `blockblob` file. When enabled without `compress`, it uses GZIP; if `compress` is also set, it inherits that codec. This option isn't compatible when `blob_type` = `appendblob`. Fluent Bit returns a configuration error and fails to start.        | `false`                       |
| `configuration_endpoint_bearer_token`  | Bearer token for the configuration endpoint.                                                                                                                                                                                                                                           | _none_                        |
| `configuration_endpoint_password`      | Basic authentication password for the configuration endpoint.                                                                                                                                                                                                                          | _none_                        |
| `configuration_endpoint_url`           | Configuration endpoint URL.                                                                                                                                                                                                                                                            | _none_                        |
| `configuration_endpoint_username`      | Basic authentication username for the configuration endpoint.                                                                                                                                                                                                                          | _none_                        |
| `container_name`                       | Name of the container that will contain the blobs.                                                                                                                                                                                                                                     | _none_                        |
| `database_file`                        | Absolute path to a database file used to store blob file contexts.                                                                                                                                                                                                                     | _none_                        |
| `date_key`                             | Key name used to store the record timestamp.                                                                                                                                                                                                                                           | `@timestamp`                  |
| `delete_on_max_upload_error`           | Whether to delete the buffer file on maximum upload errors.                                                                                                                                                                                                                            | `false`                       |
| `emulator_mode`                        | To send data to an Azure emulator service like [Azurite](https://github.com/Azure/Azurite), enable this option to format the requests in the expected format.                                                                                                                          | `false`                       |
| `endpoint`                             | When using an emulator, this option lets you specify the absolute HTTP address of such service. For example, `http://127.0.0.1:10000`.                                                                                                                                                 | _none_                        |
| `file_delivery_attempt_limit`          | Maximum number of delivery attempts for a file.                                                                                                                                                                                                                                        | `1`                           |
| `io_timeout`                           | HTTP IO timeout.                                                                                                                                                                                                                                                                       | `60s`                         |
| `part_delivery_attempt_limit`          | Maximum number of delivery attempts for a file part.                                                                                                                                                                                                                                   | `1`                           |
| `part_size`                            | Size of each part when uploading blob files.                                                                                                                                                                                                                                           | `25M`                         |
| `path`                                 | Optional. The path to store your blobs. If your blob name is `myblob`, specify subdirectories for storage using `path`. This option also supports [path templating](#path-templating). For example, setting `path` to `/logs/$TAG/%Y/%m/%d/$UUID` stores blobs under a dynamic prefix. | _none_                        |
| `sas_token`                            | Specify the Azure Storage shared access signatures to authenticate against the service. This configuration property is mandatory when `auth_type` is `sas`.                                                                                                                            | _none_                        |
| `scheduler_max_retries`                | Maximum number of retries for the scheduler send blob.                                                                                                                                                                                                                                 | `3`                           |
| `shared_key`                           | Specify the Azure Storage Shared Key to authenticate against the service. This configuration property is mandatory when `auth_type` is `key`.                                                                                                                                          | _none_                        |
| `store_dir_limit_size`                 | Set the max size of the buffer directory.                                                                                                                                                                                                                                              | `8G`                          |
| `tls`                                  | Enable or disable TLS encryption. Azure service requires this to be set to `on`.                                                                                                                                                                                                       | `off`                         |
| `unify_tag`                            | Whether to create a single buffer file when buffering mode is enabled.                                                                                                                                                                                                                 | `false`                       |
| `upload_file_size`                     | Specifies the size of files to be uploaded in MB.                                                                                                                                                                                                                                      | `200M`                        |
| `upload_part_freshness_limit`          | Maximum lifespan of an uncommitted file part.                                                                                                                                                                                                                                          | `6D`                          |
| `upload_parts_timeout`                 | Timeout for uploading parts of a blob file.                                                                                                                                                                                                                                            | `10M`                         |
| `upload_timeout`                       | Optional. Specify a timeout for uploads. Fluent Bit will start ingesting buffer files which have been created more than `x` minutes and haven't reached `upload_file_size` limit yet.                                                                                                  | `30m`                         |
| `workers`                              | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output.                                                                                                                                                                   | `0`                           |

### Path templating

When `path` is set, Fluent Bit resolves the value as a template (similar to the Amazon S3 output) before each upload. The resolved prefix is persisted alongside buffered files, so retries and restarts keep writing to the same Azure path. Leading and trailing slashes are removed automatically to avoid duplicate separators.

| Token / syntax                                                    | Example output           | Notes                                                                                                                                                                                                                                                                                                                                                    |
| :---------------------------------------------------------------- | :----------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `strftime` directives such as `%Y`, `%m`, `%d`, `%H`, `%M`, `%S` | `2025/12/16/05/42/00`    | Uses the event timestamp when available; falls back to the current Fluent Bit time.                                                                                                                                                                                                                                                                      |
| `%3N`                                                             | `123`                    | Millisecond portion of the event timestamp, zero-padded to three digits.                                                                                                                                                                                                                                                                                 |
| `%9N`, `%L`                                                       | `123456789`              | Nanosecond portion of the event timestamp, zero-padded to nine digits. `%L` is an alias for `%9N`.                                                                                                                                                                                                                                                       |
| `$UUID`                                                           | `a1b2c3d4`               | Eight-character random suffix generated once per blob so all references for that blob share the same value.                                                                                                                                                                                                                                             |
| `$TAG`                                                            | `var.log.containers.app` | Expands to the full tag that matched the output.                                                                                                                                                                                                                                                                                                         |
| `$TAG[n]`                                                         | `app`                    | Expands to the nth component (zero-based) of the tag split on dots. This uses Fluent Bit [record accessor syntax](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md); see its [templating limitations](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md#limitations-of-record_accessor-templating). |

#### Example

```yaml
pipeline:
  outputs:
    - name: azure_blob
      match: '*'
      account_name: YOUR_ACCOUNT_NAME
      shared_key: YOUR_SHARED_KEY
      container_name: logs
      path: "/$TAG[0]/$TAG[4]/%Y/%m/%d/%H/%3N/$UUID"
      buffering_enabled: true
```

If a chunk arrives with the tag `kube.var.log.containers.app-default`, this configuration creates blobs under `kube/app-default/2025/12/16/05/042/abcd1234/...`.

## Get started

Fluent Bit can deliver records to the official service or an emulator.

### Configuration for Azure Storage

The following configuration example generates a random message with a custom tag:

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
    - name: azure_blob
      match: "*"
      account_name: YOUR_ACCOUNT_NAME
      shared_key: YOUR_SHARED_KEY
      path: kubernetes
      container_name: logs
      auto_create_container: on
      tls: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush     1
  Log_Level info

[INPUT]
  Name      dummy
  Dummy     {"name": "Fluent Bit", "year": 2020}
  Samples   1
  Tag       var.log.containers.app-default-96cbdef2340.log

[OUTPUT]
  Name                  azure_blob
  Match                 *
  Account_Name          YOUR_ACCOUNT_NAME
  Shared_Key            YOUR_SHARED_KEY
  Path                  kubernetes
  Container_Name        logs
  Auto_Create_Container on
  Tls                   on
```

{% endtab %}
{% endtabs %}

After you run the configuration file, you will be able to query the data using the Azure Storage Explorer. The example generates the following content in the explorer:

![Azure Blob](../../.gitbook/assets/azure_blob.png)

### Configuring and using Azure Emulator: Azurite

#### Install and run Azurite

1. Install Azurite using `npm`:

   ```shell
   npm install -g azurite
   ```

1. Run the service:

   ```shell
   azurite
   ```

   The command should return results similar to:

   ```text
    Azurite Blob service is starting at http://127.0.0.1:10000
    Azurite Blob service is successfully listening at http://127.0.0.1:10000
    Azurite Queue service is starting at http://127.0.0.1:10001
    Azurite Queue service is successfully listening at http://127.0.0.1:10001
   ```

#### Configuring Fluent Bit for Azurite

[Azurite](https://github.com/Azure/Azurite) comes with a default `account_name` and `shared_key`. Instead of the defaults, be sure to use the specific values provided in the following example:

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
    - name: azure_blob
      match: "*"
      account_name: INSERT_ACCOUNT_NAME
      shared_key: INSERT_SHARED_KEY
      path: kubernetes
      container_name: logs
      auto_create_container: on
      tls: off
      emulator_mode: on
      endpoint: http://127.0.0.1:10000
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush     1
  Log_Level info

[INPUT]
  Name      dummy
  Dummy     {"name": "Fluent Bit", "year": 2020}
  Samples   1
  Tag       var.log.containers.app-default-96cbdef2340.log

[OUTPUT]
  Name                  azure_blob
  Match                 *
  Account_Name          INSERT_ACCOUNT_NAME
  Shared_Key            INSERT_SHARED_KEY
  Path                  kubernetes
  Container_Name        logs
  Auto_Create_Container on
  Tls                   off
  Emulator_Mode         on
  Endpoint              http://127.0.0.1:10000
```

{% endtab %}
{% endtabs %}

After running the Fluent Bit configuration, you will see the data flowing into Azurite:

```shell
$ azurite

Azurite Blob service is starting at http://127.0.0.1:10000
Azurite Blob service is successfully listening at http://127.0.0.1:10000
Azurite Queue service is starting at http://127.0.0.1:10001
Azurite Queue service is successfully listening at http://127.0.0.1:10001
127.0.0.1 - - [03/Sep/2020:17:40:03 +0000] "GET /devstoreaccount1/logs?restype=container HTTP/1.1" 404 -
127.0.0.1 - - [03/Sep/2020:17:40:03 +0000] "PUT /devstoreaccount1/logs?restype=container HTTP/1.1" 201 -
127.0.0.1 - - [03/Sep/2020:17:40:03 +0000] "PUT /devstoreaccount1/logs/kubernetes/var.log.containers.app-default-96cbdef2340.log?comp=appendblock HTTP/1.1" 404 -
127.0.0.1 - - [03/Sep/2020:17:40:03 +0000] "PUT /devstoreaccount1/logs/kubernetes/var.log.containers.app-default-96cbdef2340.log HTTP/1.1" 201 -
127.0.0.1 - - [03/Sep/2020:17:40:04 +0000] "PUT /devstoreaccount1/logs/kubernetes/var.log.containers.app-default-96cbdef2340.log?comp=appendblock HTTP/1.1" 201 -
```
