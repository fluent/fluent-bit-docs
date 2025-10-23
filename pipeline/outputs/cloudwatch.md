---
description: Send logs and metrics to Amazon CloudWatch
---

# Amazon CloudWatch

![Amazon CloudWatch](<../../.gitbook/assets/image (3) (2) (2) (4) (4) (3) (1).png>)

The _Amazon CloudWatch_ output plugin lets you ingest your records into the [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html) service. Support for CloudWatch Metrics is also provided using [Embedded Metric Format (EMF)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html).

This is the documentation for the core Fluent Bit CloudWatch plugin written in C. It can replace the [aws/amazon-cloudwatch-logs-for-fluent-bit](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit) Golang Fluent Bit plugin (`cloudwatch`). This CloudWatch plugin is called `cloudwatch_logs` to prevent conflicts or confusion. Check the Amazon repository for the Golang plugin for details about the deprecation and migration plan for the original plugin.

See [AWS credentials](https://docs.fluentbit.io/manual/administration/aws-credentials) for details about how AWS credentials are fetched.

## Configuration parameters

| Key  | Description       |
|----- |------------------ |
| `region`         | The AWS region.   |
| `log_group_name` | The name of the CloudWatch log group that you want log records sent to.               |
| `log_group_template`  | Optional. Template for the log group name using Fluent Bit [`record_accessor`](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax. If configured, this field overrides the `log_group_name`. If the template translation fails, an error is logged and the `log_group_name` is used instead. See the tutorial for an example. |
| `log_stream_name`     | The name of the CloudWatch log stream that you want log records sent to.              |
| `log_stream_prefix`   | Prefix for the log stream name. The tag is appended to the prefix to construct the full log stream name. Not compatible with the `log_stream_name` option. |
| `log_stream_template` | Optional. Template for log stream name using Fluent Bit [`record_accessor`](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax. If configured, it overrides other log stream options. If the template translation fails, an error is logged and `log_stream_name` or `log_stream_prefix` are used instead (one of those fields must be configured). See the tutorial for an example.           |
| `log_key`              | By default, the whole log record will be sent to CloudWatch. If you specify a key name with this option, then only the value of that key will be sent to CloudWatch. For example, if you are using the Fluentd Docker log driver, you can specify `log_key log` and only the log message will be sent to CloudWatch.                |
| `log_format`           | Optional. A parameter that can be used to tell CloudWatch the format of the data. A value of `json/emf` enables CloudWatch to extract custom metrics embedded in a JSON payload. See the [Embedded Metric Format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html) specification.            |
| `role_arn`             | ARN of an IAM role to assume for  cross account access.             |
| `auto_create_group`   | Automatically create the log group. Allowed values: `true`, `false` (case insensitive). Defaults to `false`.           |
| `log_group_class`     | Optional. Specifies the log storage class for new log groups when `auto_create_group` is set to `true`. You can't modify the storage class of existing log groups. Allowed values: `STANDARD`, `INFREQUENT_ACCESS`. Default: `STANDARD`.       |
| `log_retention_days`  | If set to a number greater than zero, and newly create log group's retention policy is set to this many days. Allowed values: [`1`, `3`, `5`, `7`, `14`, `30`, `60`, `90`, `120`, `150`, `180`, `365`, `400`, `545`, `731`, `1827`, `3653`] |
| `endpoint`              | Specify a custom endpoint for the CloudWatch Logs API.               |
| `metric_namespace`     | An optional string representing the CloudWatch namespace for the metrics. See the [Metrics tutorial](#metrics-tutorial) section for a full configuration. |
| `metric_dimensions`    | A list of lists containing the dimension keys that will be applied to all metrics. The values within a dimension set must be members on the root-node. For more information about dimensions, see [Dimension](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_Dimension.html) and [Dimensions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Dimension). In the Fluent Bit configurations, `metric_dimensions` is a comma and semicolon separated string. If you have only one list of dimensions, put the values as a comma separated string. If you want to put list of lists, use the list as semicolon separated strings. For example, if you set the value as `dimension_1,dimension_2;dimension_3`, Fluent Bit converts it as `[[dimension_1, dimension_2],[dimension_3]]`. |
| `sts_endpoint`         | Specify a custom STS endpoint for the AWS STS API.  |
| `profile`               | Option to specify an AWS Profile for credentials. Defaults to `default`.              |
| `auto_retry_requests` | Immediately retry failed requests to AWS services once. This option doesn't affect the normal Fluent Bit retry mechanism with backoff. Instead, it enables an immediate retry with no delay for networking errors, which can help improve throughput when there are transient/random networking issues. Defaults to `true`.             |
| `external_id`          | Specify an external ID for the STS API, can be used with the `role_arn` parameter if your role requires an external ID.  |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. Default: `1`. |

## Get started

To send records into Amazon CloudWatch, you can run the plugin from the command line or through the configuration file.

### Command line

The CloudWatch plugin can read the parameters from the command line using the `-p` argument (property):

```shell
fluent-bit -i cpu -o cloudwatch_logs -p log_group_name=group -p log_stream_name=stream -p region=us-west-2 -m '*' -f 1
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: cloudwatch_logs
      match: '*'
      region: us-east-1
      log_group_name: fluent-bit-cloudwatch
      log_stream_prefix: from-fluent-bit-
      auto_create_group: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name cloudwatch_logs
  Match   *
  region us-east-1
  log_group_name fluent-bit-cloudwatch
  log_stream_prefix from-fluent-bit-
  auto_create_group On
```

{% endtab %}
{% endtabs %}

#### Integration with LocalStack (CloudWatch logs)

For an instance of `Localstack` running at `http://localhost:4566`, use the following configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: cloudwatch_logs
      match: '*'
      region: us-east-1
      log_group_name: fluent-bit-cloudwatch
      log_stream_prefix: from-fluent-bit-
      auto_create_group: on
      endpoint: localhost
      port: 4566
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name cloudwatch_logs
  Match   *
  region us-east-1
  log_group_name fluent-bit-cloudwatch
  log_stream_prefix from-fluent-bit-
  auto_create_group On
  endpoint localhost
  port 4566
```

{% endtab %}
{% endtabs %}

Any testing credentials can be exported as local variables, such as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### Permissions

The following AWS IAM permissions are required to use this plugin:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy"
    ],
    "Resource": "*"
  }]
}
```

### Log stream and group name templating using `record_accessor` syntax

You might want the log group or stream name to be based on the contents of the log record itself. This plugin supports templating log group and stream names using Fluent Bit [`record_accessor`](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) syntax.

The following example outlines a common use case-templating log group and stream names based on Kubernetes metadata.

The Kubernetes filter can add metadata which will look like the following:

```text
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

Using `record_accessor`, you can build a template based on this object.

Here is the configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: cloudwatch_logs
      match: '*'
      region: us-east-1
      log_group_name: fallback-group
      log_stream_prefix: fallback-stream
      auto_create_group: on
      log_group_template: application-logs-$kubernetes['host'].$kubernetes['namespace_name']
      log_stream_template: $kubernetes['pod_name'].$kubernetes['container_name']
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

With the Kubernetes metadata, the log group name will be `application-logs-ip-10-1-128-166.us-east-2.compute.internal.my-namespace`, and the log stream name will be `myapp-5468c5d4d7-n2swr.myapp`.

If the Kubernetes structure isn't found in the log record, then the `log_group_name` and `log_stream_prefix` are used, and Fluent Bit will log an error like:

```text
[2022/06/30 06:09:29] [ warn] [record accessor] translation failed, root key=kubernetes
```

#### Limitations of `record_accessor` syntax

In the previous example, the template values are separated by dot (`.`) characters. The Fluent Bit `record_accessor` library has a limitation in the characters that can separate template variables. Only dots and commas (`.` and `,`) can come after a template variable. This is because the templating library must parse the template and determine the end of a variable.

Assume that your log records contain the metadata keys `container_name` and `task`. The following would be invalid templates because the two template variables aren't separated by commas or dots:

- `$task-$container_name`
- `$task/$container_name`
- `$task_$container_name`
- `$taskfooo$container_name`

However, the following are valid:

- `$task.$container_name`
- `$task.resource.$container_name`
- `$task.fooo.$container_name`

And the following are valid since they only contain one template variable with nothing after it:

- `fooo$task`
- `fooo____$task`
- `fooo/bar$container_name`

### Metrics tutorial

Fluent Bit has input plugins (`cpu`, `mem`, `disk`, `netif`) to collect host resource usage metrics. The `cloudwatch_logs` output plugin can be used to send these host metrics to CloudWatch in Embedded Metric Format (EMF). If data comes from any of the mentioned input plugins, the `cloudwatch_logs` output plugin will convert them to EMF format and send to CloudWatch as JSON log. Additionally, if `json/emf` is set as the value of the `log_format` configuration option, CloudWatch will extract custom metrics from embedded JSON payload.

Only `cpu` and `mem` metrics can be sent to CloudWatch.

For using the `mem` input plugin and sending memory usage metrics to CloudWatch, consider the following example configuration file. This example uses the `aws` filter which adds `ec2_instance_id` and `az` (availability zone) to the log records. Later, the output configuration section sets `ec2_instance_id` as the metric dimension.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  log_level: info

pipeline:
  inputs:
    - name: mem
      tag: mem

  filters:
    - name: aws
      match: '*'

  outputs:
    - name: cloudwatch_logs
      match: '*'
      region: us-west-2
      log_stream_name: fluent-bit-cloudwatch
      log_group_name: fluent-bit-cloudwatch
      log_format: json/emf
      metric_namespace: fluent-bit-metrics
      metric_dimensions: ec2_instance_id
      auto_create_group: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  region us-west-2
  log_stream_name fluent-bit-cloudwatch
  log_group_name fluent-bit-cloudwatch
  log_format json/emf
  metric_namespace fluent-bit-metrics
  metric_dimensions ec2_instance_id
  auto_create_group true
```

{% endtab %}
{% endtabs %}

The following configuration will set two dimensions to all of the metrics: `ec2_instance_id` and `az`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  log_level: info

pipeline:
  inputs:
    - name: mem
      tag: mem

  filters:
    - name: aws
      match: '*'

  outputs:
    - name: cloudwatch_logs
      match: '*'
      region: us-west-2
      log_stream_name: fluent-bit-cloudwatch
      log_group_name: fluent-bit-cloudwatch
      log_format: json/emf
      metric_namespace: fluent-bit-metrics
      metric_dimensions: ec2_instance_id,az
      auto_create_group: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  region us-west-2
  log_stream_name fluent-bit-cloudwatch
  log_group_name fluent-bit-cloudwatch
  log_format json/emf
  metric_namespace fluent-bit-metrics
  metric_dimensions ec2_instance_id,az
  auto_create_group true
```

{% endtab %}
{% endtabs %}

### AWS for Fluent Bit

Amazon distributes a container image with Fluent Bit and these plugins.

#### GitHub

[github.com/aws/aws-for-fluent-bit](https://github.com/aws/aws-for-fluent-bit)

#### Amazon ECR Public Gallery

[aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit)

Images are available in Amazon ECR Public Gallery. You can download images with different tags by following command:

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

You can check the [Amazon ECR Public official doc](https://docs.aws.amazon.com/AmazonECR/latest/public/get-set-up-for-amazon-ecr.html) for more details

#### Docker Hub

[amazon/aws-for-fluent-bit](https://hub.docker.com/r/amazon/aws-for-fluent-bit/tags)

#### Amazon ECR

You can use SSM public parameters to find the Amazon ECR image URI in your region:

```shell
aws ssm get-parameters-by-path --path /aws/service/aws-for-fluent-bit/
```

For more see [the AWS for Fluent Bit GitHub repository](https://github.com/aws/aws-for-fluent-bit#public-images).
