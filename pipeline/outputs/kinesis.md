---
description: Send logs to Amazon Kinesis Streams
---

# Amazon Kinesis Data Streams

The Amazon Kinesis Data Streams output plugin allows to ingest your records into the [Kinesis](https://aws.amazon.com/kinesis/data-streams/) service.

This is the documentation for the core Fluent Bit Kinesis plugin written in C. It has all the core features of the [aws/amazon-kinesis-streams-for-fluent-bit](https://github.com/aws/amazon-kinesis-streams-for-fluent-bit) Golang Fluent Bit plugin released in 2019. The Golang plugin was named `kinesis`; this new high performance and highly efficient kinesis plugin is called `kinesis_streams` to prevent conflicts/confusion.

Currently, this `kinesis_streams` plugin will always use a random partition key when uploading records to kinesis via the [PutRecords API](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecords.html).

See [here](https://github.com/fluent/fluent-bit-docs/tree/43c4fe134611da471e706b0edb2f9acd7cdfdbc3/administration/aws-credentials.md) for details on how AWS credentials are fetched.

## Configuration Parameters

| Key | Description |
| :--- | :--- |
| region | The AWS region. |
| stream | The name of the Kinesis Streams Delivery stream that you want log records sent to. |
| time\_key | Add the timestamp to the record under this key. By default the timestamp from Fluent Bit will not be added to records sent to Kinesis. |
| time\_key\_format | strftime compliant format string for the timestamp; for example, the default is '%Y-%m-%dT%H:%M:%S'. Supports millisecond precision with '%3N' and supports nanosecond precision with '%9N' and '%L'; for example, adding '%3N' to support millisecond '%Y-%m-%dT%H:%M:%S.%3N'. This option is used with time\_key. |
| log\_key | By default, the whole log record will be sent to Kinesis. If you specify a key name with this option, then only the value of that key will be sent to Kinesis. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to Kinesis. |
| role\_arn | ARN of an IAM role to assume \(for cross account access\). |
| endpoint | Specify a custom endpoint for the Kinesis API. |
| port | TCP port of the Kinesis Streams service. Defaults to port `443`. |
| sts\_endpoint | Custom endpoint for the STS API. |
| auto\_retry\_requests | Immediately retry failed requests to AWS services once. This option does not affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which may help improve throughput when there are transient/random networking issues. This option defaults to `true`. |
| external\_id | Specify an external ID for the STS API, can be used with the role_arn parameter if your role requires an external ID. |
| profile | AWS profile name to use. Defaults to `default`. |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. Default: `1`. |

## Getting Started

In order to send records into Amazon Kinesis Data Streams, you can run the plugin from the command line or through the configuration file:

### Command Line

The **kinesis\_streams** plugin, can read the parameters from the command line through the **-p** argument \(property\), e.g:

```shell
fluent-bit -i cpu -o kinesis_streams -p stream=my-stream -p region=us-west-2 -m '*' -f 1
```

### Configuration File

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
          
    outputs:
        - name: kinesis_steams
          match: '*'
          region: us-east-1
          stream: my-stream
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
    Name  kinesis_streams
    Match *
    region us-east-1
    stream my-stream
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

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

#### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

#### Amazon ECR Public Gallery

[aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit)

Our images are available in Amazon ECR Public Gallery. You can download images with different tags by following command:

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

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```shell
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).