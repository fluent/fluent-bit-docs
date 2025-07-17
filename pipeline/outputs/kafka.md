# Kafka Producer

The _Kafka Producer_ output plugin lets you ingest your records into an [Apache Kafka](https://kafka.apache.org/) service. This plugin uses the official [librdkafka C library](https://github.com/edenhill/librdkafka).

In Fluent Bit 4.0.4 and later, the Kafka input plugin supports authentication with AWS MSK IAM, enabling integration with Amazon MSK (Managed Streaming for Apache Kafka) clusters that require IAM-based access.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `format` | Specify data format. Available formats: `json`, `msgpack`, `raw`. | `json` |
| `message_key` | Optional key to store the message. | _none_ |
| `message_key_field` | If set, the value of `message_key_field` in the record will indicate the message key. If not set nor found in the record, `message_key` will be used if set. | _none_ |
| `timestamp_key` | Set the key to store the record timestamp | `@timestamp` |
| `timestamp_format` | Specify timestamp format. Allowed values:`double`, `[iso8601](https://en.wikipedia.org/wiki/ISO_8601)` (seconds precision) or `iso8601_ns` (fractional seconds precision). | `double` |
| `brokers` | Single or multiple list of Kafka Brokers. For example, `192.168.1.3:9092`, `192.168.1.4:9092`. | _none_ |
| `topics` | Single entry or list of topics separated by comma (,) that Fluent Bit will use to send messages to Kafka. If only one topic is set, that one will be used for all records. Instead if multiple topics exists, the one set in the record by `Topic_Key` will be used. | `fluent-bit` |
| `topic_key` | If multiple `topics` exist, the value of `Topic_Key` in the record will indicate the topic to use. For example, if `Topic_Key` is `router` and the record is `{"key1": 123, "router": "route_2"}`, Fluent Bit will use `topic _route_2_`. If the value of `Topic_Key` isn't present in `topics`, then the first topic in the `topics` list will indicate the topic to be used. | _none_ |
| `dynamic_topic` | Adds unknown topics (found in `Topic_Key`) to `topics`. In `topics`, only a default topic needs to be configured. | `Off` |
| `queue_full_retries` | Fluent Bit queues data into `rdkafka` library. If the underlying library can't flush the records the queue might fill up, blocking new addition of records. `queue_full_retries` sets the number of local retries to enqueue the data. The interval between retries is 1 second. Setting the `queue_full_retries` value to `0` sets an unlimited number of retries. | `10` |
| `rdkafka.{property}` | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) |  |
| `raw_log_key` | When using the raw format and set, the value of `raw_log_key` in the record will be send to Kafka as the payload. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

Setting `rdkafka.log.connection.close` to `false` and `rdkafka.request.required.acks` to `1` are examples of recommended settings of `librdfkafka` properties.

## Get started

To insert records into Apache Kafka, you can run the plugin from the command line or through the configuration file.

### Command line

The Kafka plugin can read parameters through the `-p` argument (property):

```shell
fluent-bit -i cpu -o kafka -p brokers=192.168.1.3:9092 -p topics=test
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: kafka
      match: '*'
      host: 192.1681.3:9092
      topics: test
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name        kafka
  Match       *
  Brokers     192.168.1.3:9092
  Topics      test
```

{% endtab %}
{% endtabs %}

### Avro support

Fluent Bit comes with support for Avro encoding for the `out_kafka` plugin. Avro support is optional and must be activated at build time by using a build def with `cmake`: `-DFLB_AVRO_ENCODER=On` such as in the following example which activates:

- `out_kafka` with Avro encoding
- Fluent Bit Prometheus
- Metrics using an embedded HTTP endpoint
- Debugging support
- Builds the test suites

```shell
cmake -DFLB_DEV=On -DFLB_OUT_KAFKA=On -DFLB_TLS=On -DFLB_TESTS_RUNTIME=On -DFLB_TESTS_INTERNAL=On -DCMAKE_BUILD_TYPE=Debug -DFLB_HTTP_SERVER=true -DFLB_AVRO_ENCODER=On ../
```

#### Kafka configuration file with Avro encoding

In this example, the Fluent Bit configuration tails Kubernetes logs, updates the log lines with Kubernetes metadata using the Kubernetes filter. It then sends the updated log lines to a Kafka broker encoded with a specific Avro schema.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: kube.*
      alias: some-alias
      path: /logdir/*.log
      db: /dbdir/some.db
      skip_long_lines: on
      refresh_interval: 10
      parser: some-parser

  filters:
    - name: kubernetes
      match: 'kube.*'
      kube_url: https://some_kube_api:443
      kube_ca_file: /certs/ca.crt
      kube_token_file: /tokens/token
      kube_tag_prefix: kube.var.log.containers.
      merge_log: on
      merge_log_key: log_processed

  outputs:
    - name: kafka
      match: '*'
      brokers: 192.168.1.3:9092
      topics: test
      schema_str:  '{"name":"avro_logging","type":"record","fields":[{"name":"timestamp","type":"string"},{"name":"stream","type":"string"},{"name":"log","type":"string"},{"name":"kubernetes","type":{"name":"krec","type":"record","fields":[{"name":"pod_name","type":"string"},{"name":"namespace_name","type":"string"},{"name":"pod_id","type":"string"},{"name":"labels","type":{"type":"map","values":"string"}},{"name":"annotations","type":{"type":"map","values":"string"}},{"name":"host","type":"string"},{"name":"container_name","type":"string"},{"name":"docker_id","type":"string"},{"name":"container_hash","type":"string"},{"name":"container_image","type":"string"}]}},{"name":"cluster_name","type":"string"},{"name":"fabric","type":"string"}]}'
      schema_id: some_schema_id
      rdkafka.client.id: some_client_id
      rdkafka.debug: all
      rdkafka.enable.ssl.certificate.verification: true
      rdkafka.ssl.certificate.location: /certs/some.cert
      rdkafka.ssl.key.location: /certs/some.key
      rdkafka.ssl.ca.location: /certs/some-bundle.crt
      rdkafka.security.protocol: ssl
      rdkafka.request.required.acks: 1
      rdkafka.log.connection.close: false
      format: avro
      rdkafka.log_level: 7
      rdkafka.metadata.broker.list: 192.168.1.3:9092
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

#### Kafka configuration file with `raw`format

This example Fluent Bit configuration file creates example records with the `payloadkey` and `msgkey` keys. The `msgkey` value is used as the Kafka message key, and the `payloadkey` value as the payload.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: example.data
      dummy: '{"payloadkey":"Data to send to kafka", "msgkey": "Key to use in the message"}'

  outputs:
    - name: kafka
      match: '*'
      host: 192.1681.3:9092
      topics: test
      format: raw
      raw_log_key: payloadkey
      message_key_field: msgkey
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
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

{% endtab %}
{% endtabs %}

## AWS MSK IAM authentication

Fluent Bit 4.0.4 and later supports authentication to Amazon MSK (Managed Streaming for Apache Kafka) clusters using AWS IAM for the Kafka output plugin. This lets you securely send data to MSK brokers with AWS credentials, leveraging IAM roles and policies for access control.

### Prerequisites

If you are compiling Fluent Bit from source, ensure the following requirements are met to enable AWS MSK IAM support:

- Build Requirements

  The packages `libsasl2` and `libsasl2-dev` must be installed on your build environment.

- Runtime Requirements:

  - Network Access: Fluent Bit must be able to reach your MSK broker endpoints (AWS VPC setup).
  - AWS Credentials: Provide credentials using any supported AWS method:
    - IAM roles (recommended for EC2, ECS, or EKS)
    - Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
    - AWS credentials file (`~/.aws/credentials`)
    - Instance metadata service (IMDS)

  These credentials are discovered by default when `aws_msk_iam` flag is enabled.

-  IAM Permissions: The credentials must allow access to the target MSK cluster.

### AWS MSK IAM configuration parameters

This plugin supports the following parameters:

| Property                  | Description                                         | Type    | Default                      |
|---------------------------|-----------------------------------------------------|---------|-------------------------------|
| `aws_msk_iam`             | Optional. Enable AWS MSK IAM authentication.         | Boolean | `false`           |
| `aws_msk_iam_cluster_arn` | Full ARN of the MSK cluster for region extraction. Required if `aws_msk_iam` is set.   | String  | _none_ |

### Configuration example


{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: random

  outputs:
    - name: kafka
      match: '*'
      brokers: my-cluster.abcdef.c1.kafka.us-east-1.amazonaws.com:9098
      topics: my-topic
      aws_msk_iam: true
      aws_msk_iam_cluster_arn: arn:aws:kafka:us-east-1:123456789012:cluster/my-cluster/abcdef-1234-5678-9012-abcdefghijkl-s3
```

{% endtab %}
{% endtabs %}

### AWS IAM policy

IAM policies and permissions can be complex and can vary depending on your organization's security requirements. If you are unsure about the correct permissions or best practices, consult with your AWS administrator or an AWS expert who is familiar with MSK and IAM security.

The AWS credentials used by Fluent Bit must have permission to connect to your MSK cluster. Here is a minimal example policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:*",
                "kafka-cluster:DescribeCluster",
                "kafka-cluster:ReadData",
                "kafka-cluster:DescribeTopic",
                "kafka-cluster:Connect"
            ],
            "Resource": "*"
        }
    ]
}
```
