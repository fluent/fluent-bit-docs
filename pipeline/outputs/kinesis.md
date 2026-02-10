---
description: Send logs to Amazon Kinesis Streams
---

# Amazon Kinesis Data Streams

The Amazon Kinesis Data Streams output plugin lets you ingest your records into the [Kinesis](https://aws.amazon.com/kinesis/data-streams/) service.

This is the documentation for the core Fluent Bit Kinesis plugin written in C. It has all the core features of the [aws/amazon-kinesis-streams-for-fluent-bit](https://github.com/aws/amazon-kinesis-streams-for-fluent-bit) Golang Fluent Bit plugin released in 2019. The original Golang plugin is named `kinesis`, and this new high performance and highly efficient Kinesis plugin is called `kinesis_streams` to prevent conflicts or confusion.

This `kinesis_streams` plugin always uses a random partition key when uploading records to Kinesis through the [PutRecords API](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecords.html).

For information about how AWS credentials are fetched, see [AWS credentials](../../administration/aws-credentials.md).

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `auto_retry_requests` | Immediately retry failed requests to AWS services once. This option doesn't affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which might help improve throughput when there are transient/random networking issues. | `true` |
| `compression` | Compression type for records sent to Kinesis Data Streams. Supported values: `gzip`, `zstd`, `snappy`. See [Compression](#compression). | _none_ |
| `endpoint` | Specify a custom endpoint for the Kinesis API. | _none_ |
| `external_id` | Specify an external ID for the STS API. You can use this option with the `role_arn` parameter if your role requires an external ID. | _none_ |
| `log_key` | By default, the whole log record will be sent to Kinesis. If you specify a key name with this option, then only the value of that key will be sent to Kinesis. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to Kinesis. | _none_ |
| `port` | TCP port of the Kinesis Streams service. | `443` |
| `profile` | AWS profile name to use. | `default` |
| `region` | The AWS region. | _none_ |
| `role_arn` | ARN of an IAM role to assume (for cross-account access). | _none_ |
| `simple_aggregation` | Enable record aggregation to combine multiple records into single API calls. This reduces the number of requests and can improve throughput. | `false` |
| `stream` | The name of the Kinesis stream that you want log records sent to. | _none_ |
| `sts_endpoint` | Custom endpoint for the STS API. | _none_ |
| `time_key` | Add the timestamp to the record under this key. | _none_ |
| `time_key_format` | The strftime compliant format string for the timestamp. Supports millisecond precision with `%3N` and supports nanosecond precision with `%9N` and `%L`. For example, adding `%3N` to support millisecond `%Y-%m-%dT%H:%M:%S.%3N`. This option is used with `time_key`. | `%Y-%m-%dT%H:%M:%S` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Get started

To send records into Amazon Kinesis Data Streams, you can run the plugin from the command line or through the configuration file.

### Command line

The `kinesis_streams` plugin can read the parameters from the command line through the `-p` (property) argument. For example:

```shell
fluent-bit -i cpu -o kinesis_streams -p stream=my-stream -p region=us-west-2 -m '*' -f 1
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: kinesis_streams
      match: '*'
      region: us-east-1
      stream: my-stream
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name   kinesis_streams
  Match  *
  Region us-east-1
  Stream my-stream
```

{% endtab %}
{% endtabs %}

### Permissions

The following AWS IAM permissions are required to use this plugin:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "kinesis:PutRecords"
    ],
    "Resource": "*"
  }]
}
```

## Compression

When you enable compression using the `compression` parameter, records are compressed before upload to Kinesis Data Streams.


{% hint style="info" %}

Each log record is individually compressed by Fluent Bit before sending. Consumers must decompress each record using the same compression format.

{% endhint %}

## Container images

Amazon distributes a container image with Fluent Bit and these plugins.

### GitHub

The [aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit) container image is available on GitHub.

### Amazon ECR Public Gallery

The [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) container image is available on the Amazon ECR Public Gallery. Use the following command to download images with different tags:

```shell
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:TAG
```

Replace `TAG` with the tag of the image you want to download. You can also use the value `latest` to download the latest image.

If you see errors for image pull limits, try to log into the gallery with your AWS credentials:

```shell
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
```

You can use the Fluent Bit SSM Public Parameters to find the Amazon ECR image URI in your region:

```shell
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more details, see the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html).

### Docker Hub

The [aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags) container image is available on Docker Hub.

### More information

For more information, see the [aws-for-fluent-bit README](https://github.com/aws/aws-for-fluent-bit#public-images) on GitHub.
