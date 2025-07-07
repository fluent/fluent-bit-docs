# AWS Metadata

The _AWS Filter_ enriches logs with AWS Metadata. The plugin adds the EC2 instance ID and availability zone to log records. To use this plugin, you must be running in EC2 and have the [instance metadata service enabled](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html).

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `imds_version` | Specify which version of the instance metadata service to use. Valid values are `v1` and `v2`. | `v2` |
| `az` | The [availability zone](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), such as `us-east-1a`. | `true` |
| `ec2_instance_id` | The EC2 instance ID. | `true` |
| `ec2_instance_type` | The EC2 instance type. | `false` |
| `private_ip` | The EC2 instance private IP. | `false` |
| `ami_id` | The EC2 instance image ID. | `false` |
| `account_id` | The account ID for the current EC2 instance. | `false` |
| `hostname` | The hostname for the current EC2 instance. | `false` |
| `vpc_id` | The VPC ID for the current EC2 instance. | `false` |
| `tags_enabled` | Specifies whether to attach EC2 instance tags. The EC2 instance must have the [`instance-metadata-tags`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option enabled, which is disabled by default. | `false` |
| `tags_include` | Defines a list of specific EC2 tag keys to inject into the logs. Tag keys must be comma-separated (`,`). Tags not included in this list will be ignored. Example: `Name,tag1,tag2`. | _none_ |
| `tags_exclude` | Defines a list of specific EC2 tag keys not to inject into the logs. Tag keys must be comma-separated (`,`). Tags not included in this list will be injected into the logs. If both `tags_include` and `tags_exclude` are specified, the configuration is invalid and the plugin fails. Example: `Name,tag1,tag2` | _none_ |
| `retry_interval_s` |Defines minimum duration between retries for fetching EC2 instance tags. | `300` |

If you run Fluent Bit in a container, you might need to use instance metadata v1. The plugin behaves the same regardless of which version is used.

### Command line

Run Fluent Bit from the command line:

```shell
$ ./fluent-bit -c /PATH_TO_CONF_FILE/fluent-bit.conf
```

You should see results like this:

```text
[2020/01/17 07:57:17] [ info] [engine] started (pid=32744)
[0] dummy: [1579247838.000171227, {"message"=>"dummy", "az"=>"us-west-2c", "ec2_instance_id"=>"i-0c862eca9038f5aae", "ec2_instance_type"=>"t2.medium", "private_ip"=>"172.31.6.59", "vpc_id"=>"vpc-7ea11c06", "ami_id"=>"ami-0841edc20334f9287", "account_id"=>"YOUR_ACCOUNT_ID", "hostname"=>"ip-172-31-6-59.us-west-2.compute.internal"}]
[0] dummy: [1601274509.970235760, {"message"=>"dummy", "az"=>"us-west-2c", "ec2_instance_id"=>"i-0c862eca9038f5aae", "ec2_instance_type"=>"t2.medium", "private_ip"=>"172.31.6.59", "vpc_id"=>"vpc-7ea11c06", "ami_id"=>"ami-0841edc20334f9287", "account_id"=>"YOUR_ACCOUNT_ID", "hostname"=>"ip-172-31-6-59.us-west-2.compute.internal"}]
```

### Configuration file

The following is an example of a configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          tag: dummy

    filters:
        - name: aws
          match: '*'
          imds_version: v1
          az: true
          ec2_instance_id: true
          ec2_instance_type: true
          private_ip: true
          ami_id: true
          account_id: true
          hostname: true
          vpc_id: true
          tags_enabled: true
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name dummy
    Tag dummy

[FILTER]
    Name aws
    Match *
    imds_version v1
    az true
    ec2_instance_id true
    ec2_instance_type true
    private_ip true
    ami_id true
    account_id true
    hostname true
    vpc_id true
    tags_enabled true

[OUTPUT]
    Name stdout
    Match *
```

{% endtab %}
{% endtabs %}

## EC2 tags

EC2 Tags let you label and organize your EC2 instances by creating custom-defined key-value pairs. These tags are commonly used for resource management, cost allocation, and automation. Including them in the Fluent Bit-generated logs is almost essential.

To achieve this, AWS Filter can be configured with `tags_enabled true` to enable the tagging of logs with the relevant EC2 instance tags. This setup ensures that logs are appropriately tagged, making it easier to manage and analyze them based on specific criteria.

### Requirements

To use the `tags_enabled true` feature in Fluent Bit, the [instance-metadata-tags](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option must be enabled on the EC2 instance where Fluent Bit is running. Without this option enabled, Fluent Bit won't be able to retrieve the tags associated with the EC2 instance. However, this doesn't mean that Fluent Bit will fail or stop working altogether. Instead, if [instance-metadata-tags](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option isn't enabled, Fluent Bit will continue to operate normally and capture other values, such as the EC2 instance ID or availability zone, based on its configuration.

### Example

#### `tags_include`

Assume the EC2 instance has many tags, some of which have lengthy values that are irrelevant to the logs you want to collect. Only two tags, `department` and `project`, are valuable for your purpose. The following configuration reflects this requirement:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

    filters:
        - name: aws
          match: '*'
          tags_enabled: true
          tags_include: department,project
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[FILTER]
    Name aws
    Match *
    tags_enabled true
    tags_include department,project
```

{% endtab %}
{% endtabs %}

If you run Fluent Bit logs might look like the following:

```text
{"log"=>"fluentbit is awesome", "az"=>"us-east-1a", "ec2_instance_id"=>"i-0e66fc7f9809d7168", "department"=>"it", "project"=>"fluentbit"}
```

#### `tags_exclude`

Suppose the EC2 instance has three tags: `Name:fluent-bit-docs-example`, `project:fluentbit`, and `department:it`. In this example, the `department` tag is redundant and will be excluded. All of the projects belong to the `it` department, and you don't want to waste storage space on redundant labels.

Here is an example configuration that achieves this:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

    filters:
        - name: aws
          match: '*'
          tags_enabled: true
          tags_exclude: department
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[FILTER]
    Name aws
    Match *
    tags_enabled true
    tags_exclude department
```

{% endtab %}
{% endtabs %}

The resulting logs might look like this:

```text
{"log"=>"aws is awesome", "az"=>"us-east-1a", "ec2_instance_id"=>"i-0e66fc7f9809d7168", "Name"=>"fluent-bit-docs-example", "project"=>"fluentbit"}
```