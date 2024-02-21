# Elasticsearch (Bulk API)

The **elasticsearch** input plugin handles both Elasticsearch and OpenSearch Bulk API requests.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default value |
| :--- | :--- | :--- |
| buffer\_max\_size | Set the maximum size of buffer. | 4M |
| buffer\_chunk\_size | Set the buffer chunk size. | 512K |
| tag\_key | Specify a key name for extracting as a tag. | `NULL` |
| meta\_key | Specify a key name for meta information. | "@meta" |
| hostname | Specify hostname or FQDN. This parameter can be used for "sniffing" (auto-discovery of) cluster node information. | "localhost" |
| version  | Specify Elasticsearch server version. This parameter is effective for checking a version of Elasticsearch/OpenSearch server version. | "8.0.0" |

**Note:** The Elasticsearch cluster uses "sniffing" to optimize the connections between its cluster and clients.
Elasticsearch can build its cluster and dynamically generate a connection list which is called "sniffing".
The `hostname` will be used for sniffing information and this is handled by the sniffing endpoint.

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

For large log ingestion on these beat plugins,
users might have to configure rate limiting on those beats plugins
when Fluent Bit indicates that the application is exceeding the size limit for HTTP requests:


```yaml
processors:
  - rate_limit:
      limit: "200/s"
```
