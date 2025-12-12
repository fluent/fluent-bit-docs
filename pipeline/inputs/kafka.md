# Kafka

The _Kafka_ input plugin enables Fluent Bit to consume messages directly from one or more [Apache Kafka](https://kafka.apache.org/) topics. By subscribing to specified topics, this plugin efficiently collects and forwards Kafka messages for further processing within your Fluent Bit pipeline.

Starting with version 4.0.4, the Kafka input plugin supports authentication with AWS MSK IAM, enabling integration with Amazon MSK (Managed Streaming for Apache Kafka) clusters that require IAM-based access.

This plugin uses the official [librdkafka C library](https://github.com/edenhill/librdkafka) as a built-in dependency.

## Configuration parameters

| Key                  | Description                                                                                                                              | Default      |
|:---------------------|:-----------------------------------------------------------------------------------------------------------------------------------------|:-------------|
| `brokers`            | Single or multiple list of Kafka Brokers. For example: `192.168.1.3:9092`, `192.168.1.4:9092`.                                           | _none_       |
| `buffer_max_size`    | Specify the maximum size of buffer per cycle to poll Kafka messages from subscribed topics. To increase throughput, specify larger size. | `4M`         |
| `client_id`          | Client id passed to librdkafka.                                                                                                          | _none_       |
| `enable_auto_commit` | Rely on Kafka auto-commit and commit messages in batches.                                                                                | `false`      |
| `format`             | Serialization format of the messages. If set to `json`, the payload will be parsed as JSON.                                              | `none`       |
| `group_id`           | Group id passed to librdkafka.                                                                                                           | `fluent-bit` |
| `poll_ms`            | Kafka brokers polling interval in milliseconds.                                                                                          | `500`        |
| `poll_timeout_ms`    | Timeout in milliseconds for Kafka consumer poll operations. Only effective when `threaded` is enabled.                                   | `1`          |
| `rdkafka.{property}` | `{property}` can be any [librdkafka properties](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md).                    | _none_       |
| `threaded`           | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                  | `false`      |
| `topics`             | Single entry or list of comma-separated topics (`,`) that Fluent Bit will subscribe to.                                                  | _none_       |

## Get started

To subscribe to or collect messages from Apache Kafka, run the plugin from the command line or through the configuration file as shown in the following examples.

### Command line

The Kafka plugin can read parameters through the `-p` argument (property):

```shell
fluent-bit -i kafka -o stdout -p brokers=192.168.1.3:9092 -p topics=some-topic
```

### Configuration file (recommended)

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: kafka
      brokers: 192.168.1.3:9092
      topics: some-topic
      poll_ms: 100

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name     kafka
  Brokers  192.168.1.3:9092
  Topics   some-topic
  Poll_ms  100

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

#### Example of using Kafka input and output plugins

The Fluent Bit source repository contains a full example of using Fluent Bit to process Kafka records:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: kafka
      brokers: kafka-broker:9092
      topics: fb-source
      poll_ms: 100
      format: json

  filters:
    - name: lua
      match: '*'
      script: kafka.lua
      call: modify_kafka_message

  outputs:
    - name: kafka
      brokers: kafka-broker:9092
      topics: fb-sink
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name     kafka
  Brokers  kafka-broker:9092
  Topics   fb-source
  Poll_ms  100
  Format   json

[FILTER]
  Name    lua
  Match   *
  Script  kafka.lua
  Call    modify_kafka_message

[OUTPUT]
  Name    kafka
  Brokers kafka-broker:9092
  Topics  fb-sink
```

{% endtab %}
{% endtabs %}

The previous example will connect to the broker listening on `kafka-broker:9092` and subscribe to the `fb-source` topic, polling for new messages every 100 milliseconds.

Since the payload will be in JSON format, the plugin is configured to parse the payload with `format json`.

Every message received is then processed with `kafka.lua` and sent back to the `fb-sink` topic of the same broker.

The example can be executed locally with `make start` in the `examples/kafka_filter` directory (`docker/compose` is used).

## AWS MSK IAM authentication

Starting with version 4.0.4, Fluent Bit supports AWS IAM authentication for Amazon MSK clusters. This allows you to use your AWS credentials and IAM policies to control access to Kafka topics.

### Prerequisites

- Access to an AWS MSK cluster with IAM authentication enabled
- Valid AWS credentials (IAM role, access keys, or instance profile)
- Network connectivity to your MSK brokers

### Configuration parameters [#config-aws]

| Property | Description | Default |
| -------- | ----------- | ------- |
| `rdkafka.sasl.mechanism` | Set to `aws_msk_iam` to enable MSK IAM authentication | _none_ |
| `aws_region` | AWS region (optional, automatically detected from broker hostname for standard MSK endpoints) | auto-detected |

### Basic configuration

For most use cases, simply set `rdkafka.sasl.mechanism` to `aws_msk_iam`:

```yaml
pipeline:
  inputs:
    - name: kafka
      brokers: boot-abc123.c1.kafka-serverless.us-east-1.amazonaws.com:9098
      topics: my-topic
      rdkafka.sasl.mechanism: aws_msk_iam
```

The AWS region is automatically detected from the broker hostname for standard MSK endpoints.

**Note:** When using `aws_msk_iam`, Fluent Bit automatically sets `rdkafka.security.protocol` to `SASL_SSL`. You don't need to configure it manually.

### Using custom DNS or PrivateLink

If you're using custom DNS names or PrivateLink aliases, specify the `aws_region` parameter:

```yaml
pipeline:
  inputs:
    - name: kafka
      brokers: my-kafka-endpoint.example.com:9098
      topics: my-topic
      rdkafka.sasl.mechanism: aws_msk_iam
      aws_region: us-east-1
```

### AWS credentials

Fluent Bit uses the standard AWS credentials chain to authenticate:

1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
2. AWS credentials file (`~/.aws/credentials`)
3. IAM instance profile (recommended for EC2)
4. IAM task role (recommended for ECS)
5. IAM service account (recommended for EKS)

### Required IAM permissions

Your AWS credentials need the following permissions to consume from MSK topics:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:Connect",
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:ReadData",
        "kafka-cluster:DescribeGroup",
        "kafka-cluster:AlterGroup"
      ],
      "Resource": [
        "arn:aws:kafka:REGION:ACCOUNT:cluster/CLUSTER_NAME/CLUSTER_UUID",
        "arn:aws:kafka:REGION:ACCOUNT:topic/CLUSTER_NAME/CLUSTER_UUID/my-topic",
        "arn:aws:kafka:REGION:ACCOUNT:group/CLUSTER_NAME/CLUSTER_UUID/fluent-bit"
      ]
    }
  ]
}
```

Replace `REGION`, `ACCOUNT`, `CLUSTER_NAME`, `CLUSTER_UUID`, and topic/group names with your actual values.

**Note:** The `CLUSTER_UUID` segment is required in all topic and group ARNs. You can find your cluster's UUID in the MSK console or by describing the cluster with the AWS CLI.

{% hint style="info" %}
For detailed IAM policy configuration, consult your AWS administrator or refer to the [AWS MSK documentation](https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html).
{% endhint %}
