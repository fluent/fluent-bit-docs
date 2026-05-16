# Kafka Producer

The _Kafka Producer_ output plugin lets you ingest your records into an [Apache Kafka](https://kafka.apache.org/) service. This plugin uses the official [librdkafka C library](https://github.com/confluentinc/librdkafka).

In Fluent Bit 4.0.4 and later, the Kafka input plugin supports authentication with AWS MSK IAM, enabling integration with Amazon MSK (Managed Streaming for Apache Kafka) clusters that require IAM-based access.

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
| `otlp_logs_partition_by_resource` | When using `otlp_json` or `otlp_proto` format for logs, send each OTLP resource's logs as a separate Kafka message. | `false` |
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

Fluent Bit 4.0.4 and later supports authentication to Amazon MSK (Managed Streaming for Apache Kafka) clusters using AWS IAM for the Kafka output plugin. This lets you securely send data to MSK brokers with AWS credentials, leveraging IAM roles and policies for access control.

### Prerequisites

If you are compiling Fluent Bit from source, ensure the following requirements are met to enable AWS MSK IAM support:

- Build Requirements

| Platform | Requirements |
|----------|-------------|
| **Linux/macOS** | The packages `libsasl2` and `libsasl2-dev` must be installed on your build environment. |
| **Windows** | No additional SASL libraries required. Windows uses the built-in Security Support Provider Interface (SSPI) for SASL authentication, which only requires OpenSSL/TLS to be enabled. |


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

See `aws_msk_iam` and `aws_msk_iam_cluster_arn` in the [configuration parameters](#configuration-parameters) table.

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
