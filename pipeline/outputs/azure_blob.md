---
description: Official and Microsoft Certified Azure Storage Blob connector
---

# Azure Blob

The Azure Blob output plugin allows ingesting your records into [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/) service. This connector is designed to use the Append Blob and Block Blob API.

Our plugin works with the official Azure Service and also can be configured to be used with a service emulator such as [Azurite](https://github.com/Azure/Azurite).

## Azure Storage Account

Before getting started, make sure you already have an Azure Storage account. As a reference, the following link explains step-by-step how to set up your account:

* [Azure Blob Storage Tutorial \(Video\)](https://www.youtube.com/watch?v=-sCKnOm8G_g)

## Configuration Parameters

We expose different configuration properties. The following table lists all the options available, and the next section has specific configuration details for the official service or the emulator.

| Key | Description | default |
| :--- | :--- | :--- |
| account\_name | Azure Storage account name. This configuration property is mandatory |  |
| auth\_type | Specify the type to authenticate against the service. Fluent Bit supports `key` and `sas`. | key |
| shared\_key | Specify the Azure Storage Shared Key to authenticate against the service. This configuration property is mandatory when `auth_type` is `key`. |  |
| sas\_token | Specify the Azure Storage shared access signatures to authenticate against the service. This configuration property is mandatory when `auth_type` is `sas`. |  |
| container\_name | Name of the container that will contain the blobs. This configuration property is mandatory |  |
| blob\_type | Specify the desired blob type. Fluent Bit supports `appendblob` and `blockblob`. | appendblob |
| auto\_create\_container | If `container_name` does not exist in the remote service, enabling this option will handle the exception and auto-create the container. | on |
| path | Optional path to store your blobs. If your blob name is `myblob`, you can specify sub-directories where to store it using path, so setting path to `/logs/kubernetes` will store your blob in `/logs/kubernetes/myblob`. |  |
| compress | Sets payload compression in network transfer. Only value supported is: `gzip` | |
| compress\_blob | Enables GZIP compression in the final `blockblob` file. This option is not compatible when `blob_type` = `appendblob`  | |
| emulator\_mode | If you want to send data to an Azure emulator service like [Azurite](https://github.com/Azure/Azurite), enable this option so the plugin will format the requests to the expected format. | off |
| endpoint | If you are using an emulator, this option allows you to specify the absolute HTTP address of such service. e.g: [http://127.0.0.1:10000](http://127.0.0.1:10000). |  |
| tls | Enable or disable TLS encryption. Note that Azure service requires this to be turned on. | off |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| buffering\_enabled | Enable buffering into disk before ingesting into Azure Blob. | false |
| buffer\_dir | Specifies the location of directory where the buffered data will be stored. | /tmp/fluent-bit/azure-blob/ |
| upload\_timeout | Optionally specify a timeout for uploads. Fluent Bit will start ingesting buffer files which have been created more than x minutes and haven't reached upload_file_size limit yet. | 30m |
| upload\_file\_size | Specifies the size of files to be uploaded in MBs. | 200M |
| azure\_blob\_buffer\_key | Set the azure blob buffer key which needs to be specified when using multiple instances of azure blob output plugin and buffering is enabled. | key |
| store\_dir\_limit\_size | Set the max size of the buffer directory. | 8G |
| buffer\_file\_delete\_early | Whether to delete the buffered file early after successful blob creation. | false |
| blob\_uri\_length | Set the length of generated blob uri before ingesting to Azure Kusto. | 64 |
| unify\_tag | Whether to create a single buffer file when buffering mode is enabled. | false |
| scheduler\_max\_retries | Maximum number of retries for the scheduler send blob. | 3 |
| delete\_on\_max\_upload\_error | Whether to delete the buffer file on maximum upload errors. | false |
| io\_timeout | HTTP IO timeout. | 60s |

## Getting Started

As mentioned above, you can either deliver records to the official service or an emulator. Below we have an example for each use case.

### Configuration for Azure Storage Service

The following configuration example generates a random message with a custom tag:

```python
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      dummy
    dummy     {"name": "Fluent Bit", "year": 2020}
    samples   1
    tag       var.log.containers.app-default-96cbdef2340.log

[OUTPUT]
    name                  azure_blob
    match                 *
    account_name          YOUR_ACCOUNT_NAME
    shared_key            YOUR_SHARED_KEY
    path                  kubernetes
    container_name        logs
    auto_create_container on
    tls                   on
```

After you run the configuration file above, you will be able to query the data using the Azure Storage Explorer. The example above will generate the following content in the explorer:

![](../../.gitbook/assets/azure_blob.png)

### Configuring and using Azure Emulator: Azurite

#### Install and run Azurite

The quickest way to get started is to install Azurite using npm:

```bash
$ npm install -g azurite
```

then run the service:

```bash
$ azurite
Azurite Blob service is starting at http://127.0.0.1:10000
Azurite Blob service is successfully listening at http://127.0.0.1:10000
Azurite Queue service is starting at http://127.0.0.1:10001
Azurite Queue service is successfully listening at http://127.0.0.1:10001
```

#### Configuring Fluent Bit for Azurite

[Azurite](https://github.com/Azure/Azurite) comes with a default `account_name` and `shared_key`, so make sure to use the specific values provided in the example below \(do an exact copy/paste\):

```python
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      dummy
    dummy     {"name": "Fluent Bit", "year": 2020}
    samples   1
    tag       var.log.containers.app-default-96cbdef2340.log

[OUTPUT]
    name                  azure_blob
    match                 *
    account_name          devstoreaccount1
    shared_key            Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==
    path                  kubernetes
    container_name        logs
    auto_create_container on
    tls                   off
    emulator_mode         on
    endpoint              http://127.0.0.1:10000
```

after running that Fluent Bit configuration you will see the data flowing into Azurite:

```text
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
