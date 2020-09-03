# Azure Blob Storage

The Azure Blob output plugin allows to ingest your records into [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/) service. This connector is designed to use the newest Append Blob API. 

Our plugin works with the official Azure Service and also can be configured to be used also with a service emulator such as [Azurite](https://github.com/Azure/Azurite).

## Azure Storage Account

Before to get started, make sure you already have an Azure Storage account. As a reference you can follow the following link which explain step-by-step how to setup your account:

- [Azure Blob Storage Tutorial (Video)](https://www.youtube.com/watch?v=-sCKnOm8G_g)

## Configuration Parameters

We expose different configuration properties, the following table list all the options available, read the next section for specific details for different configurations for the official service or the emulator.

| Key | Description | default |
| :--- | :--- | :--- |
| account_name | Azure Storage account name. This configuration property is mandatory |  |
| shared_key | Specify the Azure Storage Shared Key to authenticate against the service. This configuration property is mandatory. | |
| container_name | Name of the container that will contain the blobs. This configuration property is mandatory |  |
| auto_create_container | If ```container_name``` does not exists in the remote service, enabling this option will handle the exception and auto create the container. | on |
| path | Optional path to store your blobs. If your blob name is ```myblob```, you can specify sub-directories where to store it using path, so setting path to ```/logs/kubernetes``` will store your blob in ```/logs/kubernetes/myblob```. |  |
| emulator_mode | If you desire to send data to an Azure emulator service like [Azurite](https://github.com/Azure/Azurite), enable this option so the plugin will format the requests to the expected format. | off |
| endpoint | If you are using an emulator, this option allows to specify the absolute HTTP address of such service. e.g: https://127.0.0.1:10000. |  |
| tls | Enable or disable TLS encryption. Note that Azure service requires this to be turned on. | off |

## Getting Started

As mentioned above, you can either deliver records to the official service or an emulator. Below we have two examples for each use case.

### Configuration for Azure Storage Service

The following configuration example, generates a random message with a custom tag:

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

After you run the configuration file above, you will be able to query the data using the Azure Storage Explorer, the example above will generate the following content in the explorer:

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

[Azurite](https://github.com/Azure/Azurite) comes with a default ```account_name``` and ```shared_key```, make sure to use the specific values provided in the example below (do an exact copy/paste):

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

after running that Fluent Bit configuration you will see the data flowing in into Azurite:

```
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

