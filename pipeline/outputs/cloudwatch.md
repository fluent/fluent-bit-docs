---
description: Send logs and metrics to Amazon CloudWatch
---

# Amazon CloudWatch

![](../../.gitbook/assets/image%20%283%29%20%282%29%20%282%29%20%284%29%20%284%29%20%283%29%20%288%29.png)

The Amazon CloudWatch output plugin allows to ingest your records into the [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html) service. Support for CloudWatch Metrics is also provided via [EMF](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html).

This is the documentation for the core Fluent Bit CloudWatch plugin written in C. It can replace the [aws/amazon-cloudwatch-logs-for-fluent-bit](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit) Golang Fluent Bit plugin released last year. The Golang plugin was named `cloudwatch`; this new high performance CloudWatch plugin is called `cloudwatch_logs` to prevent conflicts/confusion. Check the amazon repo for the Golang plugin for details on the deprecation/migration plan for the original plugin.

## Configuration Parameters

| Key | Description |
| :--- | :--- |
| region | The AWS region. |
| log\_group\_name | The name of the CloudWatch Log Group that you want log records sent to. |
| log\_stream\_name | The name of the CloudWatch Log Stream that you want log records sent to. |
| log\_stream\_prefix | Prefix for the Log Stream name. The tag is appended to the prefix to construct the full log stream name. Not compatible with the log\_stream\_name option. |
| log\_key | By default, the whole log record will be sent to CloudWatch. If you specify a key name with this option, then only the value of that key will be sent to CloudWatch. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to CloudWatch. |
| log\_format | An optional parameter that can be used to tell CloudWatch the format of the data. A value of json/emf enables CloudWatch to extract custom metrics embedded in a JSON payload. See the [Embedded Metric Format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html). |
| role\_arn | ARN of an IAM role to assume \(for cross account access\). |
| auto\_create\_group | Automatically create the log group. Valid values are "true" or "false" \(case insensitive\). Defaults to false. |
| log\_retention\_days | If set to a number greater than zero, and newly create log group's retention policy is set to this many days. Valid values are: \[1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653\] |
| endpoint | Specify a custom endpoint for the CloudWatch Logs API. |
| metric\_namespace | An optional string representing the CloudWatch namespace for the metrics. See `Metrics Tutorial` section below for a full configuration. |
| metric\_dimensions | A list of lists containing the dimension keys that will be applied to all metrics. The values within a dimension set MUST also be members on the root-node. For more information about dimensions, see [Dimension](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_Dimension.html) and [Dimensions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Dimension). In the fluent-bit config, metric\_dimensions is a comma and semicolon separated string. If you have only one list of dimensions, put the values as a comma separated string. If you want to put list of lists, use the list as semicolon separated strings. For example, if you set the value as 'dimension\_1,dimension\_2;dimension\_3', we will convert it as \[\[dimension\_1, dimension\_2\],\[dimension\_3\]\] |
| sts\_endpoint | Specify a custom STS endpoint for the AWS STS API. |

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

### Worker support

Fluent Bit 1.7 adds a new feature called `workers` which enables outputs to have dedicated threads. This `cloudwatch_logs` plugin has partial support for workers. **The plugin can support a single worker; enabling multiple workers will lead to errors/indeterminate behavior.**

Example:

```text
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group On
    workers 1
```

If you enable a single worker, you are enabling a dedicated thread for your CloudWatch output. We recommend starting without workers, evaluating the performance, and then enabling a worker if needed. For most users, the plugin can provide sufficient throughput without workers.

### Metrics Tutorial

Fluent Bit has different input plugins \(cpu, mem, disk, netif\) to collect host resource usage metrics. `cloudwatch_logs` output plugin can be used to send these host metrics to CloudWatch in Embedded Metric Format \(EMF\). If data comes from any of the above mentioned input plugins, `cloudwatch_logs` output plugin will convert them to EMF format and sent to CloudWatch as JSON log. Additionally, if we set `json/emf` as the value of `log_format` config option, CloudWatch will extract custom metrics from embedded JSON payload.

Note: Right now, only `cpu` and `mem` metrics can be sent to CloudWatch.

For using the `mem` input plugin and sending memory usage metrics to CloudWatch, we can consider the following example config file. Here, we use the `aws` filter which adds `ec2_instance_id` and `az` \(availability zone\) to the log records. Later, in the output config section, we set `ec2_instance_id` as our metric dimension.

```text
[SERVICE]
    Log_Level info

[INPUT]
    Name mem
    Tag mem

[FILTER]
    Name aws
    Match *

[OUTPUT]
    Name cloudwatch_logs
    Match *
    log_stream_name fluent-bit-cloudwatch
    log_group_name fluent-bit-cloudwatch
    region us-west-2
    log_format json/emf
    metric_namespace fluent-bit-metrics
    metric_dimensions ec2_instance_id
    auto_create_group true
```

The following config will set two dimensions to all of our metrics- `ec2_instance_id` and `az`.

```text
[FILTER]
    Name aws
    Match *

[OUTPUT]
    Name cloudwatch_logs
    Match *
    log_stream_name fluent-bit-cloudwatch
    log_group_name fluent-bit-cloudwatch
    region us-west-2
    log_format json/emf
    metric_namespace fluent-bit-metrics
    metric_dimensions ec2_instance_id,az
    auto_create_group true
```

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

You can check the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html) for more details

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```text
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).

