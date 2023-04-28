# Kafka

The Kafka input plugin allows subscribing to one or more Kafka topics to collect messages from an [Apache Kafka](https://kafka.apache.org/) service.
This plugin uses the official [librdkafka C library](https://github.com/edenhill/librdkafka) \(built-in dependency\).

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| brokers | Single of multiple list of Kafka Brokers, e.g: 192.168.1.3:9092, 192.168.1.4:9092. |  |
| topics | Single entry or list of topics separated by comma \(,\) that Fluent Bit will subscribe to. |  |
| client\_id | Client id passed to librdkafka. | |
| group\_id | Group id passed to librdkafka. | fluent-bit |
| poll\_ms | Kafka brokers polling interval in milliseconds. | 500 |
| rdkafka.{property} | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) |  |

## Getting Started

In order to subscribe/collect messages from Apache Kafka, you can run the plugin from the command line or through the configuration file:

### Command Line

The **kafka** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i kafka -o stdout -p brokers=192.168.1.3:9092 -p topics=some-topic
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name        kafka
    Brokers     192.168.1.3:9092
    Topics      some-topic
    poll_ms     100

[OUTPUT]
    Name        stdout
```

#### Example of using kafka input/output plugins

The fluent-bit source repository contains a full example of using fluent-bit to process kafka records: 

```text
[INPUT]
    Name kafka
    brokers kafka-broker:9092
    topics fb-source
    poll_ms 100

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

The above will connect to the broker listening on `kafka-broker:9092` and subscribe to the `fb-source` topic, polling for new messages every 100 milliseconds.

Every message received is then processed with `kafka.lua` and sent back to the `fb-sink` topic of the same broker.

The example can be executed locally with `make start` in the `examples/kafka_filter` directory (docker/compose is used).
