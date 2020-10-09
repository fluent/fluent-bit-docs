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

[OUTPUT]
    Name stdout
    Match *
```

