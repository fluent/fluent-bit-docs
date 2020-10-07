# Amazon Kinesis Data Firehose

The Amazon Kinesis Data Firehose output plugin allows to ingest your records into the [Firehose](https://aws.amazon.com/kinesis/data-firehose/) service.

This is the documentation for the core Fluent Bit Firehose plugin written in C. It can replace the [aws/amazon-kinesis-firehose-for-fluent-bit](https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit) Golang Fluent Bit plugin released last year. The Golang plugin was named `firehose`; this new high performance and highly efficient firehose plugin is called `kinesis_firehose` to prevent conflicts/confusion.

## Configuration Parameters

| Key | Description |
| :--- | :--- |
| region | The AWS region. |
| delivery\_stream | The name of the Kinesis Firehose Delivery stream that you want log records sent to. |
| time\_key | Add the timestamp to the record under this key. By default the timestamp from Fluent Bit will not be added to records sent to Kinesis. |
| time\_key\_format | strftime compliant format string for the timestamp; for example, the default is '%Y-%m-%dT%H:%M:%S'. This option is used with time_key. |
| log\_key | By default, the whole log record will be sent to Firehose. If you specify a key name with this option, then only the value of that key will be sent to Firehose. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to Firehose. |
| role\_arn | ARN of an IAM role to assume \(for cross account access\). |
| auto\_create\_group | Automatically create the log group. Valid values are "true" or "false" \(case insensitive\). Defaults to false. |
| endpoint | Specify a custom endpoint for the Firehose API. |
| sts\_endpoint | Custom endpoint for the STS API. |

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

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

#### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```text
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).
