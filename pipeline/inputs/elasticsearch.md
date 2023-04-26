# Elasticsearch (Bulk API)

The **elasticsearch** input plugin, allows the handling of Elasticsearch and also OpenSearch Bulk API requests.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| buffer\_max\_size | Set the maximum size of buffer. |
| buffer\_chunk\_size | Set the buffer chunk size. |
| tag\_key | Specify a key name for extracting as a tag. |
| meta\_key | Specify a key name for meta information. |
| hostname | Specify hostname or FQDN. This parameter is effective for sniffering node information. |

## Getting Started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can configure Fluent Bit to handle Bulk API requests with the following options:

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
For large bulk ingestions, you may have to increase buffer size with **buffer_max_size** and **buffer_chunk_size** parameters:

```python
[INPUT]
    name elasticsearch
    listen 0.0.0.0
    port 9200
    buffer_max_size 20M
    buffer_chunk_size 5M

[OUTPUT]
    name stdout
    match *
```

#### Ingesting from beats series

Ingesting from beats series agents is also supported.
For example, [Filebeats](https://www.elastic.co/beats/filebeat), [Metricbeat](https://www.elastic.co/beats/metricbeat), and [Winlogbeat](https://www.elastic.co/beats/winlogbeat) are able to ingest their collected data through this plugin.

Note that Fluent Bit's node information is returning as Elasticsearch 8.0.0.

So, users have to specify the following configurations on their beats configurations:

```yaml
output.elasticsearch:
  allow_older_versions: true
  ilm: false
```

From large log ingestions on their beats,
users might have to add addtional settings of processors to use rate limit feature on beats
when Fluent Bit complains that exceeding limit size of HTTP requests:


```yaml
processors:
  - rate_mimit:
    limit: "200/s"
```
