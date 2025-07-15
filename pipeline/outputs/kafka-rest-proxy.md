# Kafka REST Proxy

The **kafka-rest** output plugin, allows to flush your records into a [Kafka REST Proxy](http://docs.confluent.io/current/kafka-rest/docs/index.html) server. The following instructions assumes that you have a fully operational Kafka REST Proxy and Kafka services running in your environment.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target Kafka REST Proxy server | 127.0.0.1 |
| Port | TCP port of the target Kafka REST Proxy server | 8082 |
| Topic | Set the Kafka topic | fluent-bit |
| Partition | Set the partition number \(optional\) |  |
| Message\_Key | Set a message key \(optional\) |  |
| Time\_Key | The Time\_Key property defines the name of the field that holds the record timestamp. | @timestamp |
| Time\_Key\_Format | Defines the format of the timestamp. | %Y-%m-%dT%H:%M:%S |
| Include\_Tag\_Key | Append the Tag name to the final record. | Off |
| Tag\_Key | If Include\_Tag\_Key is enabled, this property defines the key name for the tag. | \_flb-key |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The Kafka REST Proxy output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Getting Started

In order to insert records into a Kafka REST Proxy service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **kafka-rest** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```shell
fluent-bit -i cpu -t cpu -o kafka-rest -p host=127.0.0.1 -p port=8082 -m '*'
```

### Configuration File

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