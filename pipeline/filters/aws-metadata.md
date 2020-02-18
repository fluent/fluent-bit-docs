# AWS Metadata

The _AWS Filter_ Enriches logs with AWS Metadata. Currently the plugin adds the EC2 instance ID and availability zone to log records. To use this plugin, you must be running in EC2 and have the [instance metadata service enabled](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| imds\_version | Specify which version of the instance metadata service to use. Valid values are 'v1' or 'v2'. | v2 |

Note: _If you run Fluent Bit in a container, you may have to use instance metadata v1._ The plugin behaves the same regardless of which version is used.

## Usage

### Metadata Fields

Currently, the plugin only adds the instance ID and availability zone. AWS plans to [expand this plugin in the future](https://github.com/fluent/fluent-bit/issues/1780).

| Key | Value |
| :--- | :--- |
| az | The [availability zone](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html); for example, "us-east-1a". |
| ec2\_instance\_id | The EC2 instance ID. |

### Command Line

```text
$ bin/fluent-bit -i dummy -F aws -m '*' -o stdout

[2020/01/17 07:57:17] [ info] [engine] started (pid=32744)
[0] dummy.0: [1579247838.000171227, {"message"=>"dummy", "az"=>"us-west-2b", "ec2_instance_id"=>"i-06bc83dbc2ac2fdf8"}]
[1] dummy.0: [1579247839.000125097, {"message"=>"dummy", "az"=>"us-west-2b", "ec2_instance_id"=>"i-06bc87dbc2ac3fdf8"}]
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

[OUTPUT]
    Name stdout
    Match *
```

