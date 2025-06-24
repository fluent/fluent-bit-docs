# Kafka

The _Kafka_ input plugin subscribes to one or more Kafka topics to collect messages from an [Apache Kafka](https://kafka.apache.org/) service.

This plugin uses the official [librdkafka C library](https://github.com/edenhill/librdkafka) as a built-in dependency.

## Configuration parameters

| Key | Description | default |
| :--- | :--- | :--- |
| `brokers` | Single or multiple list of Kafka Brokers. For example: `192.168.1.3:9092`, `192.168.1.4:9092`. | _none_ |
| `topics` | Single entry or list of comma-separated topics (`,`) that Fluent Bit will subscribe to. | _none_ |
| `format` | Serialization format of the messages. If set to `json`, the payload will be parsed as JSON. | _none_ |
| `client_id` | Client id passed to librdkafka. | _none_ |
| `group_id` | Group id passed to librdkafka. | `fluent-bit` |
| `poll_ms` | Kafka brokers polling interval in milliseconds. | `500` |
| `Buffer_Max_Size` | Specify the maximum size of buffer per cycle to poll Kafka messages from subscribed topics. To increase throughput, specify larger size. | `4M` |
| `rdkafka.{property}` | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) | _none_ |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To subscribe to or collect messages from Apache Kafka, run the plugin from the command line or through the configuration file:

### Command line

The Kafka plugin can read parameters through the `-p` argument (property):

```shell
fluent-bit -i kafka -o stdout -p brokers=192.168.1.3:9092 -p topics=some-topic
```

### Configuration file

In your main configuration file append the following `Input` and `Output` sections:

```text
[INPUT]
    Name        kafka
    Brokers     192.168.1.3:9092
    Topics      some-topic
    poll_ms     100

[OUTPUT]
    Name        stdout
```

#### Example of using Kafka input and output plugins

The Fluent Bit source repository contains a full example of using Fluent Bit to process Kafka records:

```text
[INPUT]
    Name kafka
    brokers kafka-broker:9092
    topics fb-source
    poll_ms 100
    format json

[FILTER]
    Name    lua
    Match   *
    script  kafka.lua
    call    modify_kafka_message

[OUTPUT]
    Name kafka
    brokers kafka-broker:9092
    topics fb-sink
```

The previous example will connect to the broker listening on `kafka-broker:9092` and subscribe to the `fb-source` topic, polling for new messages every 100 milliseconds.

Since the payload will be in JSON format, the plugin is configured to parse the payload with `format json`.

Every message received is then processed with `kafka.lua` and sent back to the `fb-sink` topic of the same broker.

The example can be executed locally with `make start` in the `examples/kafka_filter` directory (`docker/compose` is used).
