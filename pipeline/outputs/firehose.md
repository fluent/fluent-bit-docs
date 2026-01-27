---
description: Send logs to Amazon Kinesis Firehose
---

# Amazon Kinesis Data Firehose

The _Amazon Kinesis Data Firehose_ output plugin lets you ingest your records into the [Firehose](https://aws.amazon.com/kinesis/data-firehose/) service.

This is the documentation for the core Fluent Bit Firehose plugin written in C. It can replace the [aws/amazon-kinesis-firehose-for-fluent-bit](https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit) Golang Fluent Bit plugin. The Golang plugin was named `firehose`. This new Firehose plugin is called `kinesis_firehose` to prevent conflicts/confusion.

See [AWS credentials](https://docs.fluentbit.io/manual/administration/aws-credentials) for details on how AWS credentials are fetched.

## Configuration parameters

This plugin uses the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | --------- |
| `auto_retry_requests` | Immediately retry failed requests to AWS services once. This option doesn't affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which can help improve throughput when there are transient/random networking issues. | `true` |
| `compression` | Compression type for records sent to Firehose. Supported values: `gzip`, `zstd`, `snappy`. `arrow` is also available if Apache Arrow was enabled at compile time. See the [Compression](#compression). | _none_ |
| `delivery_stream` | The name of the Kinesis Firehose Delivery stream that you want log records sent to. | _none_ |
| `endpoint` | Specify a custom endpoint for the Firehose API. | _none_ |
| `external_id` | Specify an external ID for the STS API. You can use this option with the `role_arn` parameter if your role requires an external ID. | _none_ |
| `log_key` | By default, the whole log record will be sent to Firehose. If you specify a key name with this option, then only the value of that key will be sent to Firehose. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to Firehose. | _none_ |
| `profile` | AWS profile name to use. | `default` |
| `region` | The AWS region. | _none_ |
| `role_arn` | ARN of an IAM role to assume (for cross-account access). | _none_ |
| `simple_aggregation` | Enable record aggregation to combine multiple records into single API calls. This reduces the number of requests and can improve throughput. | `false` |
| `sts_endpoint` | Custom endpoint for the STS API. | _none_ |
| `time_key` | Add the timestamp to the record under this key. By default, the timestamp from Fluent Bit won't be added to records sent to Kinesis. | _none_ |
| `time_key_format` | strftime compliant format string for the timestamp; for example, the default is `%Y-%m-%dT%H:%M:%S`. Supports millisecond precision with `%3N` and nanosecond precision with `%9N` and `%L`. For example, adding `%3N` to support millisecond `%Y-%m-%dT%H:%M:%S.%3N`. This option is used with `time_key`. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Get started

To send records into Amazon Kinesis Data Firehose, you can run the plugin from the command line or through the configuration file.

### Command line

The Firehose plugin can read the parameters from the command line through the `-p` argument (property).

```shell
fluent-bit -i cpu -o kinesis_firehose -p delivery_stream=my-stream -p region=us-west-2 -m '*' -f 1
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: kinesis_firehose
      match: '*'
      region: us-east-1
      delivery_stream: my-stream
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name            kinesis_firehose
  Match           *
  Region          us-east-1
  Delivery_Stream my-stream
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
      "firehose:PutRecordBatch"
    ],
    "Resource": "*"
  }]
}
```

## Compression

When you enable compression using the `compression` parameter, records are compressed before upload to Kinesis Firehose.

{% hint style="info" %}

Fluent Bit compresses each log record individually before sending to Firehose. Firehose then buffers multiple records and delivers them as complete files to the destination. Consumers receive these files (not individual records). If destination-level compression is enabled in Firehose (for example, S3 `CompressionFormat`), consumers must first decompress the file and then decompress each record. If destination-level compression is disabled, only per-record decompression is required.

{% endhint %}

### Worker support

Fluent Bit 1.7 added a new feature called `workers` which enables outputs to have dedicated threads. This `kinesis_firehose` plugin fully supports workers.

Example:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: kinesis_firehose
      match: '*'
      region: us-east-1
      delivery_stream: my-stream
      workers: 2
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name            kinesis_firehose
  Match           *
  Region          us-east-1
  Delivery_Stream my-stream
  Workers         2
```

{% endtab %}
{% endtabs %}

{% hint style="info" %}

If you enable a single worker, you are enabling a dedicated thread for your Firehose output. Fluent Bit recommends starting with without workers, evaluating the performance, and then adding workers one at a time until you reach your desired/needed throughput. For most users, no workers or a single worker will be sufficient.

{% endhint %}

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

#### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

#### Amazon ECR Public Gallery

[aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit)

Fluent Bit images are available in Amazon ECR Public Gallery. You can download images with different tags by following command:

```shell
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:<tag>
```

For example, you can pull the image with latest version by:

```shell
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:latest
```

If you see errors for image pull limits, try log into public ECR with your AWS credentials:

```shell
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
```

You can check the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html) for more details.

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use Fluent Bit SSM Public Parameters to find the Amazon ECR image URI in your region:

```shell
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit GitHub repository](https://github.com/aws/aws-for-fluent-bit#public-images).
