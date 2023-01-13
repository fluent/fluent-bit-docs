# Elasticsearch (Bulk API)

The **elasticsearch** input plugin, allows to handle Elasticsearch and also OpenSearch Bulk API requests.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| buffer\_max\_size | Set the maximum size of buffer. |
| buffer\_chunk\_size | Set the buffer chunk size. |
| tag\_key | Specify a key name for extracting as a tag. |
| meta\_key | Specify a key name for meta information. |
| hostname | Specify hostname or FQDN. This parameter is affective for sniffering node information. |

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit handles Bulk API requests with the following options:

```bash
$ fluent-bit -i elasticsearch -p port=9200 -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    name elasticsearch
    listen 0.0.0.0
    port 9200

[OUTPUT]
    name stdout
    match *
```

As described above, the plugin will handle ingested Bulk API requests.
For large bulk ingestions, you may have to increase buffer size with **buffer_max_size** parameter:

```python
[INPUT]
    name elasticsearch
    listen 0.0.0.0
    port 9200
    buffer_max_size 20M

[OUTPUT]
    name stdout
    match *
```
