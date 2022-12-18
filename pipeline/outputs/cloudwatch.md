---
description: Send logs and metrics to Amazon CloudWatch
---

# Amazon CloudWatch

![](<../../.gitbook/assets/image (3) (2) (2) (4) (4) (3) (1).png>)

The Amazon CloudWatch output plugin allows to ingest your records into the [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html) service. Support for CloudWatch Metrics is also provided via [EMF](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch\_Embedded\_Metric\_Format\_Specification.html).

This is the documentation for the core Fluent Bit CloudWatch plugin written in C. It can replace the [aws/amazon-cloudwatch-logs-for-fluent-bit](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit) Golang Fluent Bit plugin released last year. The Golang plugin was named `cloudwatch`; this new high performance CloudWatch plugin is called `cloudwatch_logs` to prevent conflicts/confusion. Check the amazon repo for the Golang plugin for details on the deprecation/migration plan for the original plugin.

See [here](https://github.com/fluent/fluent-bit-docs/tree/43c4fe134611da471e706b0edb2f9acd7cdfdbc3/administration/aws-credentials.md) for details on how AWS credentials are fetched.

## Configuration Parameters

| Key                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| region                | The AWS region.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| log\_group\_name      | The name of the CloudWatch Log Group that you want log records sent to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| log\_group\_template  | Template for Log Group name using Fluent Bit [record\_accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax. This field is optional and if configured it overrides the `log_group_name`. If the template translation fails, an error is logged and the `log_group_name` (which is still required) is used instead. See the tutorial below for an example.                                                                                                                                                                                                                                                                                                                                                                                                                        |
| log\_stream\_name     | The name of the CloudWatch Log Stream that you want log records sent to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| log\_stream\_prefix   | Prefix for the Log Stream name. The tag is appended to the prefix to construct the full log stream name. Not compatible with the log\_stream\_name option.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| log\_stream\_template | Template for Log Stream name using Fluent Bit [record\_accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax. This field is optional and if configured it overrides the other log stream options. If the template translation fails, an error is logged and the log\_stream\_name or log\_stream\_prefix are used instead (and thus one of those fields is still required to be configured). See the tutorial below for an example.                                                                                                                                                                                                                                                                                                                                              |
| log\_key              | By default, the whole log record will be sent to CloudWatch. If you specify a key name with this option, then only the value of that key will be sent to CloudWatch. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to CloudWatch.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| log\_format           | An optional parameter that can be used to tell CloudWatch the format of the data. A value of json/emf enables CloudWatch to extract custom metrics embedded in a JSON payload. See the [Embedded Metric Format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch\_Embedded\_Metric\_Format\_Specification.html).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| role\_arn             | ARN of an IAM role to assume (for cross account access).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| auto\_create\_group   | Automatically create the log group. Valid values are "true" or "false" (case insensitive). Defaults to false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| log\_retention\_days  | If set to a number greater than zero, and newly create log group's retention policy is set to this many days. Valid values are: \[1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| endpoint              | Specify a custom endpoint for the CloudWatch Logs API.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| metric\_namespace     | An optional string representing the CloudWatch namespace for the metrics. See `Metrics Tutorial` section below for a full configuration.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| metric\_dimensions    | A list of lists containing the dimension keys that will be applied to all metrics. The values within a dimension set MUST also be members on the root-node. For more information about dimensions, see [Dimension](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API\_Dimension.html) and [Dimensions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch\_concepts.html#Dimension). In the fluent-bit config, metric\_dimensions is a comma and semicolon separated string. If you have only one list of dimensions, put the values as a comma separated string. If you want to put list of lists, use the list as semicolon separated strings. For example, if you set the value as 'dimension\_1,dimension\_2;dimension\_3', we will convert it as \[\[dimension\_1, dimension\_2],\[dimension\_3]] |
| sts\_endpoint         | Specify a custom STS endpoint for the AWS STS API.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| auto\_retry\_requests | Immediately retry failed requests to AWS services once. This option does not affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which may help improve throughput when there are transient/random networking issues. This option defaults to `true`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| external\_id | Specify an external ID for the STS API, can be used with the role_arn parameter if your role requires an external ID.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |

## Getting Started

In order to send records into Amazon Cloudwatch, you can run the plugin from the command line or through the configuration file:

### Command Line

The **cloudwatch** plugin, can read the parameters from the command line through the **-p** argument (property), e.g:

```
$ fluent-bit -i cpu -o cloudwatch_logs -p log_group_name=group -p log_stream_name=stream -p region=us-west-2 -m '*' -f 1
```

### Configuration File

In your main configuration file append the following _Output_ section:

```
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group On
```

### Permissions

The following AWS IAM permissions are required to use this plugin:

```
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogStream",
			"logs:CreateLogGroup",
			"logs:PutLogEvents"
		],
		"Resource": "*"
	}]
}
```

### Worker support

Fluent Bit 1.7 adds a new feature called `workers` which enables outputs to have dedicated threads. This `cloudwatch_logs` plugin has partial support for workers. **The plugin can support a single worker; enabling multiple workers will lead to errors/indeterminate behavior.**

Example:

```
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

### Log Stream and Group Name templating using record\_accessor syntax

Sometimes, you may want the log group or stream name to be based on the contents of the log record itself. This plugin supports templating log group and stream names using Fluent Bit [record\_accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax.

Here is an example usage, for a common use case- templating log group and stream names based on Kubernetes metadata.

Recall that the kubernetes filter can add metadata which will look like the following:

```
kubernetes: {
    annotations: {
        "kubernetes.io/psp": "eks.privileged"
    },
    container_hash: "<some hash>",
    container_name: "myapp",
    docker_id: "<some id>",
    host: "ip-10-1-128-166.us-east-2.compute.internal",
    labels: {
        app: "myapp",
        "pod-template-hash": "<some hash>"
    },
    namespace_name: "my-namespace",
    pod_id: "198f7dd2-2270-11ea-be47-0a5d932f5920",
    pod_name: "myapp-5468c5d4d7-n2swr"
}
```

Using record\_accessor, we can build a template based on this object.

Here is our output configuration:

```
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region us-east-1
    log_group_name fallback-group
    log_stream_prefix fallback-stream
    auto_create_group On
    log_group_template application-logs-$kubernetes['host'].$kubernetes['namespace_name']
    log_stream_template $kubernetes['pod_name'].$kubernetes['container_name']
```

With the above kubernetes metadata, the log group name will be `application-logs-ip-10-1-128-166.us-east-2.compute.internal.my-namespace`. And the log stream name will be `myapp-5468c5d4d7-n2swr.myapp`.

If the kubernetes structure is not found in the log record, then the `log_group_name` and `log_stream_prefix` will be used instead, and Fluent Bit will log an error like:

```
[2022/06/30 06:09:29] [ warn] [record accessor] translation failed, root key=kubernetes
```

### Metrics Tutorial

Fluent Bit has different input plugins (cpu, mem, disk, netif) to collect host resource usage metrics. `cloudwatch_logs` output plugin can be used to send these host metrics to CloudWatch in Embedded Metric Format (EMF). If data comes from any of the above mentioned input plugins, `cloudwatch_logs` output plugin will convert them to EMF format and sent to CloudWatch as JSON log. Additionally, if we set `json/emf` as the value of `log_format` config option, CloudWatch will extract custom metrics from embedded JSON payload.

Note: Right now, only `cpu` and `mem` metrics can be sent to CloudWatch.

For using the `mem` input plugin and sending memory usage metrics to CloudWatch, we can consider the following example config file. Here, we use the `aws` filter which adds `ec2_instance_id` and `az` (availability zone) to the log records. Later, in the output config section, we set `ec2_instance_id` as our metric dimension.

```
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

```
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

```
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:<tag>
```

For example, you can pull the image with latest version by:

```
docker pull public.ecr.aws/aws-observability/aws-for-fluent-bit:latest
```

If you see errors for image pull limits, try log into public ECR with your AWS credentials:

```
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
```

You can check the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html) for more details

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use our SSM Public Parameters to find the Amazon ECR image URI in your region:

```
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit github repo](https://github.com/aws/aws-for-fluent-bit#public-images).
