# ECS Metadata

The _ECS Filter_ Enriches logs with AWS Elastic Container Service Metadata. The plugin can enrich logs with task, cluster and container metadata. The plugin uses the [ECS Agent introspection API](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-introspection.html) to obtain metadata. This filter only works with the ECS EC2 launch type. The filter only works when Fluent Bit is running on an ECS EC2 Container Instance and has access to the ECS Agent introspection API. The filter is not supported on ECS Fargate. To obtain metadata on ECS Fargate, use the [built-in FireLens metadata](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html) or the [AWS for Fluent Bit init](https://github.com/aws/aws-for-fluent-bit/blob/mainline/use_cases/init-process-for-fluent-bit/README.md) project.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Add | This parameter is similar to the ADD option in the [modify filter](https://docs.fluentbit.io/manual/pipeline/filters/modify).  You can specify it any number of times and it takes two arguments, a KEY name and VALUE. The value uses Fluent Bit [record_accessor](https://docs.fluentbit.io/manual/v/1.5/administration/configuring-fluent-bit/record-accessor) syntax to create a template that uses ECS Metadata values. See the list below for supported metadata templating keys. This option is designed to give you full power to control both the key names for metadata as well as the format for metadata values. See the examples below for more.  | No default |
| ECS\_Tag\_Prefix | This parameter is similar to the Kube_Tag_Prefix option in the [Kubernetes filter](https://docs.fluentbit.io/manual/pipeline/filters/kubernetes) and performs the same function. The full log tag should be prefixed with this string and after the prefix the filter must find the next characters in the tag to be the Docker Container Short ID (the first 12 characters of the full container ID). The filter uses this to identify which container the log came from so it can find which task it is a part of. See the design section below for more information. If not specified, it defaults to empty string, meaning that the tag must be prefixed with the 12 character container short ID. If you just want to attach cluster metadata to system/OS logs from processes that do not run as part of containers or ECS Tasks, then do not set this parameter and enable the Cluster\_Metadata\_Only option | emptry string |
| Cluster\_Metadata\_Only | When enabled, the plugin will only attempt to attach cluster metadata values. This is useful if you want to attach cluster metadata to system/OS logs from processes that do not run as part of containers or ECS Tasks. | Off |
| ECS\_Meta\_Cache\_TTL | The filter builds a hash table in memory mapping each unique container short ID to its metadata. This option sets a max TTL for objects in the hash table. You should set this if you have frequent container/task restarts. For example, your cluster runs short running batch jobs that complete in less than 10 minutes, there is no reason to keep any stored metadata longer than 10 minutes. So you would set this parameter to "10m". | 1h (1 hour) |

### Supported Templating Variables for the ADD option

The following template variables can be used for values with the `Add` option. See the tutorial below for examples.

| Variable | Description | Supported with Cluster\_Metadata\_Only On |
| :--- | :--- | :--- |
| `$ClusterName` | The ECS cluster name. Fluent Bit is running on EC2 instance(s) that are part of this cluster. | Yes |
| `$ContainerInstanceARN` | The full ARN of the ECS EC2 Container Instance. This is the instance that Fluent Bit is running on. | Yes |
| `$ContainerInstanceID` | The ID of the ECS EC2 Container Instance. | Yes |
| `$ECSAgentVersion` | The Version string of the ECS Agent that is running on the container instance. | Yes |
| `$ECSContainerName` | The name of the container from which the log originated. This is the name in your ECS Task Definition. | No |
| `$DockerContainerName` | The name of the container from which the log originated. This is the name obtained from Docker and is the name shown if you run `docker ps` on the instance.  | No |
| `$ContainerID` | The ID of the container from which the log originated. This is the full 64 character long container ID. | No |
| `$TaskDefinitionFamily` | The family name of the task definition for the task from which the log originated. | No |
| `$TaskDefinitionVersion` | The version/revision of the task definition for the task from which the log originated. | No |
| `$TaskID` | The ID of the ECS Task from which the log originated. | No |
| `$TaskARN` | The full ARN of the ECS Task from which the log originated. | No |


### Configuration File

#### Example 1: Attach Task ID and cluster name to container logs

```text
[INPUT]
    Name                tail
    Tag                 ecs.*
    Path                /var/lib/docker/containers/*/*.log
    Docker_Mode         On
    Docker_Mode_Flush   5
    Docker_Mode_Parser  container_firstline
    Parser              docker
    DB                  /var/fluent-bit/state/flb_container.db
    Mem_Buf_Limit       50MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type        filesystem
    Read_From_Head      Off

[FILTER]
    Name ecs
    Match *
    ECS_Tag_Prefix ecs.var.lib.docker.containers.
    ADD ecs_task_id $TaskID
    ADD cluster $ClusterName

[OUTPUT]
    Name stdout
    Match *
    Format json_lines
```

The output log should be similar to:
```text
{
    "date":1665003546.0,
    "log":"some message from your container",
    "ecs_task_id" "1234567890abcdefghijklmnop",
    "cluster": "your_cluster_name",
}
```

#### Example 2: Attach customized resource name to container logs

```text
[INPUT]
    Name                tail
    Tag                 ecs.*
    Path                /var/lib/docker/containers/*/*.log
    Docker_Mode         On
    Docker_Mode_Flush   5
    Docker_Mode_Parser  container_firstline
    Parser              docker
    DB                  /var/fluent-bit/state/flb_container.db
    Mem_Buf_Limit       50MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type        filesystem
    Read_From_Head      Off

[FILTER]
    Name ecs
    Match *
    ECS_Tag_Prefix ecs.var.lib.docker.containers.
    ADD resource $ClusterName.$TaskDefinitionFamily.$TaskID.$ECSContainerName

[OUTPUT]
    Name stdout
    Match *
    Format json_lines
```

The output log would be similar to:
```text
{
    "date":1665003546.0,
    "log":"some message from your container",
    "resource" "cluster.family.1234567890abcdefghijklmnop.app",
}
```

Notice that the template variables in the value for the `resource` key are separated by dot characters, only dots and commas
 (`.` and `,`) can come after a template variable. For more information, please check the [Record accessor limitation's section](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md#limitations-of-record_accessor-templating).

#### Example 3: Attach cluster metadata to non-container logs

This examples shows a use case for the `Cluster_Metadata_Only` option- attaching cluster metadata to ECS Agent logs. 

```text
[INPUT]
    Name                tail
    Tag                 ecsagent.*
    Path                /var/log/ecs/*
    DB                  /var/fluent-bit/state/flb_ecs.db
    Mem_Buf_Limit       50MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type        filesystem
    # Collect all logs on instance
    Read_From_Head      On

[FILTER]
    Name ecs
    Match *
    Cluster_Metadata_Only On
    ADD cluster $ClusterName

[OUTPUT]
    Name stdout
    Match *
    Format json_lines
```

