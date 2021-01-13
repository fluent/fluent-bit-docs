# Kafka

Kafka output plugin allows to ingest your records into an [Apache Kafka](https://kafka.apache.org/) service. This plugin use the official [librdkafka C library](https://github.com/edenhill/librdkafka) \(built-in dependency\)

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| format | Specify data format, options available: json, msgpack. | json |
| message\_key | Optional key to store the message |  |
| message\_key\_field | If set, the value of Message\_Key\_Field in the record will indicate the message key. If not set nor found in the record, Message\_Key will be used \(if set\). |  |
| timestamp\_key | Set the key to store the record timestamp | @timestamp |
| timestamp\_format | 'iso8601' or 'double' | double |
| brokers | Single of multiple list of Kafka Brokers, e.g: 192.168.1.3:9092, 192.168.1.4:9092. |  |
| topics | Single entry or list of topics separated by comma \(,\) that Fluent Bit will use to send messages to Kafka. If only one topic is set, that one will be used for all records. Instead if multiple topics exists, the one set in the record by Topic\_Key will be used. | fluent-bit |
| topic\_key | If multiple Topics exists, the value of Topic\_Key in the record will indicate the topic to use. E.g: if Topic\_Key is _router_ and the record is {"key1": 123, "router": "route\_2"}, Fluent Bit will use topic _route\_2_. Note that if the value of Topic\_Key is not present in Topics, then by default the first topic in the Topics list will indicate the topic to be used. |  |
| dynamic\_topic | adds unknown topics \(found in Topic\_Key\) to Topics. So in Topics only a default topic needs to be configured | Off |
| queue\_full\_retries | Fluent Bit queues data into rdkafka library, if for some reason the underlying library cannot flush the records the queue might fills up blocking new addition of records. The `queue_full_retries` option set the number of local retries to enqueue the data. The default value is 10 times, the interval between each retry is 1 second. Setting the `queue_full_retries` value to `0` set's an unlimited number of retries. | 10 |
| rdkafka.{property} | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) |  |

> Setting `rdkafka.log.connection.close` to `false` and `rdkafka.request.required.acks` to 1 are examples of recommended settings of librdfkafka properties.

## Getting Started

In order to insert records into Apache Kafka, you can run the plugin from the command line or through the configuration file:

### Command Line

The **kafka** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -o kafka -p brokers=192.168.1.3:9092 -p topics=test
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name  cpu

[OUTPUT]
    Name        kafka
    Match       *
    Brokers     192.168.1.3:9092
    Topics      test
```

