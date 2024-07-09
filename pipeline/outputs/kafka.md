# Kafka

Kafka output plugin allows to ingest your records into an [Apache Kafka](https://kafka.apache.org/) service. This plugin use the official [librdkafka C library](https://github.com/edenhill/librdkafka) \(built-in dependency\)

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| format | Specify data format, options available: json, msgpack, raw. | json |
| message\_key | Optional key to store the message |  |
| message\_key\_field | If set, the value of Message\_Key\_Field in the record will indicate the message key. If not set nor found in the record, Message\_Key will be used \(if set\). |  |
| timestamp\_key | Set the key to store the record timestamp | @timestamp |
| timestamp\_format | Specify timestamp format, should be 'double', '[iso8601](https://en.wikipedia.org/wiki/ISO_8601)' (seconds precision) or 'iso8601_ns' (fractional seconds precision) | double |
| brokers | Single or multiple list of Kafka Brokers, e.g: 192.168.1.3:9092, 192.168.1.4:9092. |  |
| topics | Single entry or list of topics separated by comma \(,\) that Fluent Bit will use to send messages to Kafka. If only one topic is set, that one will be used for all records. Instead if multiple topics exists, the one set in the record by Topic\_Key will be used. | fluent-bit |
| topic\_key | If multiple Topics exists, the value of Topic\_Key in the record will indicate the topic to use. E.g: if Topic\_Key is _router_ and the record is {"key1": 123, "router": "route\_2"}, Fluent Bit will use topic _route\_2_. Note that if the value of Topic\_Key is not present in Topics, then by default the first topic in the Topics list will indicate the topic to be used. |  |
| dynamic\_topic | adds unknown topics \(found in Topic\_Key\) to Topics. So in Topics only a default topic needs to be configured | Off |
| queue\_full\_retries | Fluent Bit queues data into rdkafka library, if for some reason the underlying library cannot flush the records the queue might fills up blocking new addition of records. The `queue_full_retries` option set the number of local retries to enqueue the data. The default value is 10 times, the interval between each retry is 1 second. Setting the `queue_full_retries` value to `0` set's an unlimited number of retries. | 10 |
| rdkafka.{property} | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) |  |
| raw\_log\_key | When using the raw format and set, the value of raw\_log\_key in the record will be send to kafka as the payload. | |
| workers              | This setting improves the throughput and performance of data forwarding by enabling concurrent data processing and transmission to the kafka output broker destination. | 0 |

> Setting `rdkafka.log.connection.close` to `false` and `rdkafka.request.required.acks` to 1 are examples of recommended settings of librdfkafka properties.

## Getting Started

In order to insert records into Apache Kafka, you can run the plugin from the command line or through the configuration file:

### Command Line

The **kafka** plugin can read parameters through the **-p** argument \(property\), e.g:

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

### Avro Support

Fluent-bit comes with support for avro encoding for the out_kafka plugin.
Avro support is optional and must be activated at build-time by using a
build def with cmake: `-DFLB_AVRO_ENCODER=On` such as in the following
example which activates:

* out_kafka with avro encoding
* fluent-bit's prometheus
* metrics via an embedded http endpoint
* debugging support
* builds the test suites

```
cmake -DFLB_DEV=On -DFLB_OUT_KAFKA=On -DFLB_TLS=On -DFLB_TESTS_RUNTIME=On -DFLB_TESTS_INTERNAL=On -DCMAKE_BUILD_TYPE=Debug -DFLB_HTTP_SERVER=true -DFLB_AVRO_ENCODER=On ../
```

#### Kafka Configuration File with Avro Encoding

This is example fluent-bit config tails kubernetes logs, decorates the
log lines with kubernetes metadata via the kubernetes filter, and then
sends the fully decorated log lines to a kafka broker encoded with a
specific avro schema.

```text
[INPUT]
    Name              tail
    Tag               kube.*
    Alias             some-alias
    Path              /logdir/*.log
    DB                /dbdir/some.db
    Skip_Long_Lines   On
    Refresh_Interval  10
    Parser some-parser

[FILTER]
    Name                kubernetes
    Match               kube.*
    Kube_URL            https://some_kube_api:443
    Kube_CA_File        /certs/ca.crt
    Kube_Token_File     /tokens/token
    Kube_Tag_Prefix     kube.var.log.containers.
    Merge_Log           On
    Merge_Log_Key       log_processed

[OUTPUT]
    Name        kafka
    Match       *
    Brokers     192.168.1.3:9092
    Topics      test
    Schema_str  {"name":"avro_logging","type":"record","fields":[{"name":"timestamp","type":"string"},{"name":"stream","type":"string"},{"name":"log","type":"string"},{"name":"kubernetes","type":{"name":"krec","type":"record","fields":[{"name":"pod_name","type":"string"},{"name":"namespace_name","type":"string"},{"name":"pod_id","type":"string"},{"name":"labels","type":{"type":"map","values":"string"}},{"name":"annotations","type":{"type":"map","values":"string"}},{"name":"host","type":"string"},{"name":"container_name","type":"string"},{"name":"docker_id","type":"string"},{"name":"container_hash","type":"string"},{"name":"container_image","type":"string"}]}},{"name":"cluster_name","type":"string"},{"name":"fabric","type":"string"}]}
    Schema_id some_schema_id
    rdkafka.client.id some_client_id
    rdkafka.debug All
    rdkafka.enable.ssl.certificate.verification true

    rdkafka.ssl.certificate.location /certs/some.cert
    rdkafka.ssl.key.location /certs/some.key
    rdkafka.ssl.ca.location /certs/some-bundle.crt
    rdkafka.security.protocol ssl
    rdkafka.request.required.acks 1
    rdkafka.log.connection.close false

    Format avro
    rdkafka.log_level 7
    rdkafka.metadata.broker.list 192.168.1.3:9092
```

#### Kafka Configuration File with Raw format

This example Fluent Bit configuration file creates example records with the
_payloadkey_ and _msgkey_ keys. The _msgkey_ value is used as the Kafka message
key, and the _payloadkey_ value as the payload.


```text
[INPUT]
    Name example
    Tag  example.data
    Dummy {"payloadkey":"Data to send to kafka", "msgkey": "Key to use in the message"}


[OUTPUT]
    Name        kafka
    Match       *
    Brokers     192.168.1.3:9092
    Topics      test
    Format      raw

    Raw_Log_Key       payloadkey
    Message_Key_Field msgkey
```
