# Kafka Consumer

The _Kafka_ input plugin enables Fluent Bit to consume messages directly from one or more [Apache Kafka](https://kafka.apache.org/) topics. By subscribing to specified topics, this plugin efficiently collects and forwards Kafka messages for further processing within your Fluent Bit pipeline.

Starting with version 4.0.4, the Kafka input plugin supports authentication with AWS MSK IAM, enabling integration with Amazon MSK (Managed Streaming for Apache Kafka) clusters that require IAM-based access.

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

To subscribe to or collect messages from Apache Kafka, run the plugin from the command line or through the configuration file as shown below.

### Command line

The Kafka plugin can read parameters through the `-p` argument (property):

```shell
$ fluent-bit -i kafka -o stdout -p brokers=192.168.1.3:9092 -p topics=some-topic
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
    Name        kafka
    Brokers     192.168.1.3:9092
    Topics      some-topic
    poll_ms     100

[OUTPUT]
    Name        stdout
    Match       *
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

{% endtab %}
{% endtabs %}

The previous example will connect to the broker listening on `kafka-broker:9092` and subscribe to the `fb-source` topic, polling for new messages every 100 milliseconds.

Since the payload will be in JSON format, the plugin is configured to parse the payload with `format json`.

Every message received is then processed with `kafka.lua` and sent back to the `fb-sink` topic of the same broker.

The example can be executed locally with `make start` in the `examples/kafka_filter` directory (`docker/compose` is used).

## AWS MSK IAM Authentication

*Available since Fluent Bit v4.0.4*

Fluent Bit supports authentication to Amazon MSK (Managed Streaming for Apache Kafka) clusters using AWS IAM. This allows you to securely connect to MSK brokers with AWS credentials, leveraging IAM roles and policies for access control.

### Prerequisites

**Build Requirements**

If you are compiling Fluent Bit from source, ensure the following requirements are met to enable AWS MSK IAM support:

- The packages `libsasl2` and `libsasl2-dev` must be installed on your build environment.

**Runtime Requirements**
- **Network Access:** Fluent Bit must be able to reach your MSK broker endpoints (AWS VPC setup).
- **AWS Credentials:** Provide credentials using any supported AWS method:
  - IAM roles (recommended for EC2, ECS, or EKS)
  - Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
  - AWS credentials file (`~/.aws/credentials`)
  - Instance metadata service (IMDS)

  Note these credentials are discovery by default when `aws_msk_iam` flag is enabled.

- **IAM Permissions:** The credentials must allow access to the target MSK cluster (see example policy below).

### Configuration Parameters

| Property                  | Description                                         | Type    | Required                      |
|---------------------------|-----------------------------------------------------|---------|-------------------------------|
| `aws_msk_iam`             | Enable AWS MSK IAM authentication                   | Boolean | No (default: false)           |
| `aws_msk_iam_cluster_arn` | Full ARN of the MSK cluster for region extraction   | String  | Yes (if `aws_msk_iam` is true)|


### Configuration Example

```yaml
pipeline:
  inputs:
    - name: kafka
      brokers: my-cluster.abcdef.c1.kafka.us-east-1.amazonaws.com:9098
      topics: my-topic
      aws_msk_iam: true
      aws_msk_iam_cluster_arn: arn:aws:kafka:us-east-1:123456789012:cluster/my-cluster/abcdef-1234-5678-9012-abcdefghijkl-s3

  outputs:
    - name: stdout
      match: '*'
```

### Example AWS IAM Policy

> **Note:** IAM policies and permissions can be complex and may vary depending on your organization's security requirements. If you are unsure about the correct permissions or best practices, please consult with your AWS administrator or an AWS expert who is familiar with MSK and IAM security.

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