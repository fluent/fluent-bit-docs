---
description: Send logs to Amazon Kinesis Firehose
---

# Amazon Kinesis Data Firehose

![](../../.gitbook/assets/image%20%288%29.png)

The Amazon Kinesis Data Firehose output plugin allows to ingest your records into the [Firehose](https://aws.amazon.com/kinesis/data-firehose/) service.

This is the documentation for the core Fluent Bit Firehose plugin written in C. It can replace the [aws/amazon-kinesis-firehose-for-fluent-bit](https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit) Golang Fluent Bit plugin released last year. The Golang plugin was named `firehose`; this new high performance and highly efficient firehose plugin is called `kinesis_firehose` to prevent conflicts/confusion.

See [here](https://github.com/fluent/fluent-bit-docs/tree/43c4fe134611da471e706b0edb2f9acd7cdfdbc3/administration/aws-credentials.md) for details on how AWS credentials are fetched.

## Configuration Parameters

| Key | Description |
| :--- | :--- |
| region | The AWS region. |
| delivery\_stream | The name of the Kinesis Firehose Delivery stream that you want log records sent to. |
| time\_key | Add the timestamp to the record under this key. By default the timestamp from Fluent Bit will not be added to records sent to Kinesis. |
| time\_key\_format | strftime compliant format string for the timestamp; for example, the default is '%Y-%m-%dT%H:%M:%S'. This option is used with time\_key. |
| log\_key | By default, the whole log record will be sent to Firehose. If you specify a key name with this option, then only the value of that key will be sent to Firehose. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to Firehose. |
| compression | Compression type for Firehose records. Each log record is individually compressed and sent to Firehose. 'gzip' and 'arrow' are the supported values. 'arrow' is only an available if Apache Arrow was enabled at compile time. Defaults to no compression. |
| role\_arn | ARN of an IAM role to assume \(for cross account access\). |
| endpoint | Specify a custom endpoint for the Firehose API. |
| sts\_endpoint | Custom endpoint for the STS API. |
| auto\_retry\_requests | Immediately retry failed requests to AWS services once. This option does not affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which may help improve throughput when there are transient/random networking issues. This option defaults to `true`. |

## Getting Started

In order to send records into Amazon Kinesis Data Firehose, you can run the plugin from the command line or through the configuration file:

### Command Line

The **firehose** plugin, can read the parameters from the command line through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -o kinesis_firehose -p delivery_stream=my-stream -p region=us-west-2 -m '*' -f 1
```

### Configuration File

In your main configuration file append the following _Output_ section:

```text
[OUTPUT]
    Name  kinesis_firehose
    Match *
    region us-east-1
    delivery_stream my-stream
```

### Worker support

Fluent Bit 1.7 adds a new feature called `workers` which enables outputs to have dedicated threads. This `kinesis_firehose` plugin fully supports workers.

Example:

```text
[OUTPUT]
    Name  kinesis_firehose
    Match *
    region us-east-1
    delivery_stream my-stream
    workers 2
```

If you enable a single worker, you are enabling a dedicated thread for your Firehose output. We recommend starting with without workers, evaluating the performance, and then adding workers one at a time until you reach your desired/needed throughput. For most users, no workers or a single worker will be sufficient.

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

#### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

#### Amazon ECR Public Gallery

[aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit)

Our images are available in Amazon ECR Public Gallery. You can download images with different tags by following command:

```text
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:<tag>
```

For example, you can pull the image with latest version by:

```text
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:latest
```

If you see errors for image pull limits, try log into public ECR with your AWS credentials:

```text
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
```

You can check the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html) for more details.

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```text
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).

