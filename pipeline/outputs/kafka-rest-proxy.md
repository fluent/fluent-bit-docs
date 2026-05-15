# Kafka REST proxy

The _Kafka rest_ (`kafka-rest`) output plugin lets you flush your records into a [Kafka REST Proxy](https://docs.confluent.io/platform/current/kafka-rest/index.html) server. The following instructions assume you have an operational Kafka REST Proxy and Kafka services running in your environment.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `avro_http_header` | Include Avro header in the HTTP request. | `false` |
| `host` | IP address or hostname of the target Kafka REST Proxy server. | `127.0.0.1` |
| `include_tag_key` | Append the tag name to the final record. | `false` |
| `message_key` | Optional message key to set. | _none_ |
| `partition` | Optional partition number. | `-1` |
| `port` | TCP port of the target Kafka REST Proxy server. | `8082` |
| `tag_key` | If `include_tag_key` is enabled, defines the key name for the tag. | `_flb-key` |
| `time_key` | Name of the field that holds the record timestamp. | `@timestamp` |
| `time_key_format` | Format of the timestamp. | `%Y-%m-%dT%H:%M:%S` |
| `topic` | Set the Kafka topic. | `fluent-bit` |
| `url_path` | Optional HTTP URL path for the target web server. For example, `/something`. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The Kafka REST Proxy output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To insert records into a Kafka REST Proxy service, you can run the plugin from the command line or through the configuration file.

### Command line

The Kafka REST plugin can read the parameters from the command line through the `-p` argument (property):

```shell
fluent-bit -i cpu -t cpu -o kafka-rest -p host=127.0.0.1 -p port=8082 -m '*'
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: kafka-rest
      match: '*'
      host: 127.0.0.1
      port: 8082
      topic: fluent-bit
      message_key: my_key
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name        kafka-rest
    Match       *
    Host        127.0.0.1
    Port        8082
    Topic       fluent-bit
    Message_Key my_key
```

{% endtab %}
{% endtabs %}
