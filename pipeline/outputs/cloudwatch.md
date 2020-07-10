# Amazon CloudWatch

The Amazon CloudWatch output plugin allows to ingest your records into the [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html) service. Support for CloudWatch Metrics is also provided via [EMF](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html).

This is the documentation for the core Fluent Bit CloudWatch plugin written in C. It can replace the [aws/amazon-cloudwatch-logs-for-fluent-bit](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit) Golang Fluent Bit plugin released last year. The Golang plugin was named `cloudwatch`; this new high performance CloudWatch plugin is called `cloudwatch_logs` to prevent conflicts/confusion. Check the amazon repo for the Golang plugin for details on the deprecation/migration plan for the original plugin.

## Configuration Parameters

| Key | Description |
| :--- | :--- |
| region | The AWS region. |
| log_group_name | The name of the CloudWatch Log Group that you want log records sent to. |
| log_stream_name| The name of the CloudWatch Log Stream that you want log records sent to. |
| log_stream_prefix|  Prefix for the Log Stream name. The tag is appended to the prefix to construct the full log stream name. Not compatible with the log_stream_name option. |
| log_key |  By default, the whole log record will be sent to CloudWatch. If you specify a key name with this option, then only the value of that key will be sent to CloudWatch. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to CloudWatch. |
| log_format |  An optional parameter that can be used to tell CloudWatch the format of the data. A value of json/emf enables CloudWatch to extract custom metrics embedded in a JSON payload. See the [Embedded Metric Format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html). |
| role_arn |  ARN of an IAM role to assume (for cross account access). |
| auto_create_group | Automatically create the log group. Valid values are "true" or "false" (case insensitive). Defaults to false. |
| endpoint | Specify a custom endpoint for the CloudWatch Logs API. |

## Getting Started

In order to send records into Amazon Cloudwatch, you can run the plugin from the command line or through the configuration file:

### Command Line

The **cloudwatch** plugin, can read the parameters from the command line through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -o cloudwatch_logs -p log_group_name=group -p log_stream_name=stream -p region=us-west-2 -m '*' -f 1
```

### Configuration File

In your main configuration file append the following _Output_ section:

```text
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group On
```

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

##### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

##### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

##### Amazon ECR

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).
