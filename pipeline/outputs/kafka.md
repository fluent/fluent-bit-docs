# Kafka Producer

The _Kafka Producer_ output plugin lets you ingest your records into an [Apache Kafka](https://kafka.apache.org/) service. This plugin uses the official [librdkafka C library](https://github.com/confluentinc/librdkafka).

In Fluent Bit 4.0.4 and later, the Kafka output plugin supports authentication with AWS MSK IAM, enabling integration with Amazon MSK (Managed Streaming for Apache Kafka) clusters that require IAM-based access.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `aws_msk_iam` | Enable AWS MSK IAM authentication. Requires Fluent Bit 4.0.4 or later. | `false` |
| `aws_msk_iam_cluster_arn` | Full ARN of the MSK cluster used for region extraction. Required when `aws_msk_iam` is enabled. | _none_ |
| `brokers` | Single or multiple list of Kafka brokers. For example, `192.168.1.3:9092`, `192.168.1.4:9092`. | _none_ |
| `client_id` | Client ID to use when connecting to Kafka. | _none_ |
| `dynamic_topic` | Adds unknown topics (found in `topic_key`) to `topics`. Only a default topic needs to be configured in `topics`. | `false` |
| `format` | Specify data format. Available formats: `avro` (requires Avro encoder build option), `gelf`, `json`, `msgpack`, `otlp_json` (supports logs, metrics, and traces events), `otlp_proto` (supports logs, metrics, and traces events), `raw`. | `json` |
| `gelf_full_message_key` | Key to use as the long message for GELF format output. | _none_ |
| `gelf_host_key` | Key to use as the host for GELF format output. | _none_ |
| `gelf_level_key` | Key to use as the log level for GELF format output. | _none_ |
| `gelf_short_message_key` | Key to use as the short message for GELF format output. | _none_ |
| `gelf_timestamp_key` | Key to use as the timestamp for GELF format output. | _none_ |
| `group_id` | Consumer group ID. | _none_ |
| `message_key` | Optional key to store the message. | _none_ |
| `message_key_field` | If set, the value of `message_key_field` in the record will indicate the message key. If not set or not found in the record, `message_key` is used if set. | _none_ |
| `queue_full_retries` | Number of local retries to enqueue data when the `rdkafka` queue is full. The interval between retries is 1 second. Set to `0` for unlimited retries. | `10` |
| `raw_log_key` | When using the `raw` format, the value of `raw_log_key` in the record is sent to Kafka as the payload. | _none_ |
| `rdkafka.{property}` | `{property}` can be any [librdkafka property](https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md). | _none_ |
| `schema_id` | Avro schema ID. Requires the Avro encoder build option. | _none_ |
| `schema_str` | Avro schema string. Requires the Avro encoder build option. | _none_ |
| `timestamp_format` | Specify the timestamp format. Allowed values: `double`, `iso8601` (seconds precision), `iso8601_ns` (nanoseconds precision). | `double` |
| `timestamp_key` | Key to store the record timestamp. | `@timestamp` |
| `topic_key` | If multiple `topics` exist, the value of `topic_key` in the record indicates the topic to use. If the value isn't present in `topics`, the first topic in the list is used. | _none_ |
| `topics` | Single topic or comma-separated list of topics that Fluent Bit will use to send messages to Kafka. If multiple topics are set, the `topic_key` field in the record selects the topic. | `fluent-bit` |
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
      brokers: 192.168.1.3:9092
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
  Parser            some-parser

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
  Schema_Str  {"name":"avro_logging","type":"record","fields":[{"name":"timestamp","type":"string"},{"name":"stream","type":"string"},{"name":"log","type":"string"},{"name":"kubernetes","type":{"name":"krec","type":"record","fields":[{"name":"pod_name","type":"string"},{"name":"namespace_name","type":"string"},{"name":"pod_id","type":"string"},{"name":"labels","type":{"type":"map","values":"string"}},{"name":"annotations","type":{"type":"map","values":"string"}},{"name":"host","type":"string"},{"name":"container_name","type":"string"},{"name":"docker_id","type":"string"},{"name":"container_hash","type":"string"},{"name":"container_image","type":"string"}]}},{"name":"cluster_name","type":"string"},{"name":"fabric","type":"string"}]}
  Schema_Id some_schema_id
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
      brokers: 192.168.1.3:9092
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

In Fluent Bit version 4.0.4 and later, you can use AWS IAM authentication for Amazon MSK clusters. This lets you use your AWS credentials and IAM policies to control access to Kafka topics.

### Prerequisites

To use AWS MSK IAM authentication, you must meet these requirements:

- You must have access to an AWS MSK cluster with IAM authentication enabled.
- You must have valid AWS credentials (IAM role, access keys, or instance profile).
- You must have network connectivity to your MSK brokers.

### Configuration parameters

| Platform | Requirements |
|----------|-------------|
| **Linux/macOS** | The packages `libsasl2` and `libsasl2-dev` must be installed on your build environment. |
| **Windows** | No additional SASL libraries required. Windows uses the built-in Security Support Provider Interface (SSPI) for SASL authentication, which only requires OpenSSL/TLS to be enabled. |


| Property | Description | Default |
| -------- | ----------- | ------- |
| `rdkafka.sasl.mechanism` | Set to `aws_msk_iam` to enable MSK IAM authentication. | _none_ |
| `aws_region` | The name of your AWS region. This value is optional. If you don't set a value, but MSK IAM authentication is enabled, Fluent Bit detects your AWS region from the broker hostname for standard MSK endpoints. | _none_ |

### Basic configuration

For most use cases, the only necessary configuration step is to set `rdkafka.sasl.mechanism` to `aws_msk_iam`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: kafka
      match: '*'
      brokers: b-1.mycluster.kafka.us-east-1.amazonaws.com:9098
      topics: my-topic
      rdkafka.sasl.mechanism: aws_msk_iam
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name     kafka
  Match    *
  Brokers  b-1.mycluster.kafka.us-east-1.amazonaws.com:9098
  Topics   my-topic
  rdkafka.sasl.mechanism aws_msk_iam

{% endtab %}
{% endtabs %}

See `aws_msk_iam` and `aws_msk_iam_cluster_arn` in the [configuration parameters](#configuration-parameters) table.

The AWS region is automatically detected from the broker hostname for standard MSK endpoints.

{% hint style="info" %}

When using `aws_msk_iam`, Fluent Bit automatically sets `rdkafka.security.protocol` to `SASL_SSL`. You don't need to configure it manually.

{% endhint %}

### Using custom DNS or PrivateLink

If you're using custom DNS names or PrivateLink aliases, specify the `aws_region` parameter:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: kafka
      match: '*'
      brokers: my-kafka-endpoint.example.com:9098
      topics: my-topic
      rdkafka.sasl.mechanism: aws_msk_iam
      aws_region: us-east-1
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name     kafka
  Match    *
  Brokers  my-kafka-endpoint.example.com:9098
  Topics   my-topic
  rdkafka.sasl.mechanism aws_msk_iam
  aws_region us-east-1
```

{% endtab %}
{% endtabs %}

### AWS credentials

Fluent Bit uses the standard AWS credentials chain to authenticate:

1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
1. AWS credentials file (`~/.aws/credentials`)
1. IAM instance profile (recommended for EC2)
1. IAM task role (recommended for ECS)
1. IAM service account (recommended for EKS)

### Required IAM permissions

{% hint style="info" %}

For detailed IAM policy configuration, consult your AWS administrator or refer to the [AWS MSK documentation](https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html).

{% endhint %}

Your AWS credentials need the following permissions to produce to MSK topics:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:Connect",
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:WriteData"
      ],
      "Resource": [
        "arn:aws:kafka:REGION:ACCOUNT:cluster/CLUSTER_NAME/CLUSTER_UUID",
        "arn:aws:kafka:REGION:ACCOUNT:topic/CLUSTER_NAME/CLUSTER_UUID/my-topic"
      ]
    }
  ]
}
```

Replace `REGION`, `ACCOUNT`, `CLUSTER_NAME`, `CLUSTER_UUID`, and topic name with your actual values.

{% hint style="info" %}
	
The `CLUSTER_UUID` segment is required in all topic and group ARNs. You can find your cluster's UUID in the MSK console or by describing the cluster with the AWS CLI.
	
{% endhint %}

