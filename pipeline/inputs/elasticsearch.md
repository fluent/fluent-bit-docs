# Elasticsearch

The _Elasticsearch_ input plugin handles both Elasticsearch and OpenSearch Bulk API requests.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                 | Description                                                                                                                              | Default value |
|:--------------------|:-----------------------------------------------------------------------------------------------------------------------------------------|:--------------|
| `buffer_chunk_size` | Set the buffer chunk size.                                                                                                               | `512K`        |
| `buffer_max_size`   | Set the maximum size of buffer.                                                                                                          | `4M`          |
| `hostname`          | Specify hostname or fully qualified domain name. This parameter can be used for "sniffing" (auto-discovery of) cluster node information. | `localhost`   |
| `http2`             | Enable HTTP/2 support.                                                                                                                   | `true`        |
| `listen`            | The address to listen on.                                                                                                                | `0.0.0.0`     |
| `meta_key`          | Specify a key name for meta information.                                                                                                 | `@meta`       |
| `port`              | The port for Fluent Bit to listen on.                                                                                                    | `9200`        |
| `tag_key`           | Specify a key name for extracting as a tag.                                                                                              | `NULL`        |
| `threaded`          | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                  | `false`       |
| `version`           | Specify the Elasticsearch version that Fluent Bit reports to clients during sniffing and API requests.                                   | `8.0.0`       |

### TLS / SSL

The Elasticsearch input plugin supports TLS/SSL for receiving data from Beats agents or other clients over encrypted connections. For more details about the properties available and general configuration, refer to [Transport Security](../../administration/transport-security.md).

When configuring TLS for Elasticsearch ingestion, common options include:

- `tls.verify`: Enable or disable certificate validation for incoming connections.
- `tls.ca_file`: Specify a CA certificate to validate client certificates when using mutual TLS (mTLS).
- `tls.crt_file` and `tls.key_file`: Provide the server certificate and private key.

### Sniffing

Elasticsearch clients use a process called "sniffing" to automatically discover cluster nodes. When a client connects, it can query the cluster to retrieve a list of available nodes and their addresses. This allows the client to distribute requests across the cluster and adapt when nodes join or leave.

The `hostname` parameter specifies the hostname or fully qualified domain name that Fluent Bit returns during sniffing requests. Clients use this information to build their connection list. Set this value to match how clients should reach this Fluent Bit instance (for example, an external IP or load balancer address rather than `localhost` in production environments).

## Get started

In order to start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can configure Fluent Bit to handle Bulk API requests with the following options:

```shell
fluent-bit -i elasticsearch -p port=9200 -o stdout
```

### Configuration file

In your configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: elasticsearch
      listen: 0.0.0.0
      port: 9200

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name   elasticsearch
  listen 0.0.0.0
  port   9200

[OUTPUT]
  name  stdout
  match *
```

{% endtab %}
{% endtabs %}

As described previously, the plugin will handle ingested Bulk API requests. For large bulk ingestion, you might have to increase buffer size using the `buffer_max_size` and `buffer_chunk_size` parameters:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: elasticsearch
      listen: 0.0.0.0
      port: 9200
      buffer_max_size: 20M
      buffer_chunk_size: 5M

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name              elasticsearch
  listen            0.0.0.0
  port              9200
  buffer_max_size   20M
  buffer_chunk_size 5M

[OUTPUT]
  name  stdout
  match *
```

{% endtab %}
{% endtabs %}

#### Ingesting from beats series

Ingesting from beats series agents is also supported. For example, [Filebeats](https://www.elastic.co/beats/filebeat), [Metricbeat](https://www.elastic.co/beats/metricbeat), and [Winlogbeat](https://www.elastic.co/beats/winlogbeat) are able to ingest their collected data through this plugin.

The Fluent Bit node information is returning as Elasticsearch 8.0.0.

Users must specify the following configurations on their beats configurations:

```yaml
output.elasticsearch:
  allow_older_versions: true
  ilm: false
```

For large log ingestion on these beat plugins, users might have to configure rate limiting on those beats plugins when Fluent Bit indicates that the application is exceeding the size limit for HTTP requests:

```yaml
processors:
  - rate_limit:
      limit: "200/s"
```
