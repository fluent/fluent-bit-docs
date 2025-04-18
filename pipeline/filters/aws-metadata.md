# AWS Metadata

The _AWS Filter_ Enriches logs with AWS Metadata. Currently the plugin adds the EC2 instance ID and availability zone to log records. To use this plugin, you must be running in EC2 and have the [instance metadata service enabled](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| imds\_version | Specify which version of the instance metadata service to use. Valid values are 'v1' or 'v2'. | v2 |
| az | The [availability zone](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html); for example, "us-east-1a". | true |
| ec2\_instance\_id | The EC2 instance ID. | true |
| ec2\_instance\_type | The EC2 instance type. | false |
| private\_ip | The EC2 instance private ip. | false |
| ami\_id | The EC2 instance image id. | false |
| account\_id | The account ID for current EC2 instance. | false |
| hostname | The hostname for current EC2 instance. | false |
| vpc\_id | The VPC ID for current EC2 instance. | false |
| tags\_enabled | Specifies if should attach EC2 instance tags. EC2 instance must have the [instance-metadata-tags](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option enabled (which is disabled by default). | false |
| tags\_include | Defines list of specific EC2 tag keys to inject into the logs. Tag keys must be separated by "," character. Tags which are not present in this list will be ignored. Example: `Name,tag1,tag2`. | |
| tags\_exclude | Defines list of specific EC2 tag keys not to inject into the logs. Tag keys must be separated by "," character. Tags which are not present in this list will be injected into the logs. If both `tags_include` and `tags_exclude` are specified, configuration is invalid and plugin fails. Example: `Name,tag1,tag2` | |
| retry\_interval\_s |Defines minimum duration between retries for fetching EC2 instance tags. | 300 |

Note: _If you run Fluent Bit in a container, you may have to use instance metadata v1._ The plugin behaves the same regardless of which version is used.

### Command Line

```text
$ bin/fluent-bit -c /PATH_TO_CONF_FILE/fluent-bit.conf

[2020/01/17 07:57:17] [ info] [engine] started (pid=32744)
[0] dummy: [1579247838.000171227, {"message"=>"dummy", "az"=>"us-west-2c", "ec2_instance_id"=>"i-0c862eca9038f5aae", "ec2_instance_type"=>"t2.medium", "private_ip"=>"172.31.6.59", "vpc_id"=>"vpc-7ea11c06", "ami_id"=>"ami-0841edc20334f9287", "account_id"=>"YOUR_ACCOUNT_ID", "hostname"=>"ip-172-31-6-59.us-west-2.compute.internal"}]
[0] dummy: [1601274509.970235760, {"message"=>"dummy", "az"=>"us-west-2c", "ec2_instance_id"=>"i-0c862eca9038f5aae", "ec2_instance_type"=>"t2.medium", "private_ip"=>"172.31.6.59", "vpc_id"=>"vpc-7ea11c06", "ami_id"=>"ami-0841edc20334f9287", "account_id"=>"YOUR_ACCOUNT_ID", "hostname"=>"ip-172-31-6-59.us-west-2.compute.internal"}]
```

### Configuration File

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

## EC2 Tags

EC2 Tags are a useful feature that enables you to label and organize your EC2 instances by creating custom-defined key-value pairs. These tags are commonly utilized for resource management, cost allocation, and automation. Consequently, including them in the Fluent Bit generated logs is almost essential.

To achieve this, AWS Filter can be configured with `tags_enabled true` to enable the _tagging_ of logs with the relevant EC2 instance tags. This setup ensures that logs are appropriately tagged, making it easier to manage and analyze them based on specific criteria.

### Requirements

To use the `tags_enabled true` functionality in Fluent Bit, the [instance-metadata-tags](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option must be enabled on the EC2 instance where Fluent Bit is running. Without this option enabled, Fluent Bit will not be able to retrieve the tags associated with the EC2 instance. However, this does not mean that Fluent Bit will fail or stop working altogether. Instead, if [instance-metadata-tags](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/modify-instance-metadata-options.html) option is not enabled, Fluent Bit will continue to operate normally and capture other values, such as the EC2 instance ID or availability zone, based on its configuration.

### Example

#### tags_include

Assume that our EC2 instance has many tags, some of which have lengthy values that are irrelevant to the logs we want to collect. Only two tags, `department` and `project`, seem to be valuable for our purpose. Here is a configuration which reflects this requirement:

```
[FILTER]
    Name aws
    Match *
    tags_enabled true
    tags_include department,project
```

If we run Fluent Bit, what will the logs look like? Here is an example of what the logs might contain:
```
{"log"=>"fluentbit is awesome", "az"=>"us-east-1a", "ec2_instance_id"=>"i-0e66fc7f9809d7168", "department"=>"it", "project"=>"fluentbit"}
```

#### tags_exclude

Suppose our EC2 instance has three tags: `Name:fluent-bit-docs-example`, `project:fluentbit`, and `department:it`. In this example, we want to exclude the `department` tag since we consider it redundant. This is because all of our projects belong to the `it` department, and we do not need to waste storage space on redundant labels.

Here is an example configuration that achieves this:

```
[FILTER]
    Name aws
    Match *
    tags_enabled true
    tags_exclude department
```

The resulting logs might look like this:

```
{"log"=>"aws is awesome", "az"=>"us-east-1a", "ec2_instance_id"=>"i-0e66fc7f9809d7168", "Name"=>"fluent-bit-docs-example", "project"=>"fluentbit"}
```
