# ECS metadata

The _ECS Filter_ enriches logs with AWS Elastic Container Service metadata. The plugin can enrich logs with task, cluster, and container metadata. The plugin uses the [ECS Agent introspection API](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-introspection.html) to obtain metadata. This filter only works with the ECS EC2 launch type. The filter only works when Fluent Bit is running on an ECS EC2 Container Instance and has access to the ECS Agent introspection API.

The filter isn't supported on ECS Fargate. To obtain metadata on ECS Fargate, use the [built-in FireLens metadata](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html) or the [AWS for Fluent Bit init](https://github.com/aws/aws-for-fluent-bit/blob/mainline/use_cases/init-process-for-fluent-bit/README.md) project.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `add` | Similar to the `add` option in the [modify filter](../filters/modify.md). You can specify it multiple times. It takes two arguments: a `KEY` name and `VALUE`. The value uses Fluent Bit [`record_accessor`](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) syntax to create a template that uses ECS Metadata values. See the list of supported metadata templating keys. This option lets you control both the key names for metadata and the format for metadata values. | _none_ |
| `agent_endpoint_retries` | Number of retries for failed metadata requests to the ECS Agent Introspection endpoint. The most common cause of failed metadata requests is that the container the metadata request was made for isn't part of an ECS Task. | `2` |
| `cluster_metadata_only` | When enabled, the plugin only attempts to attach cluster metadata values. Use to attach cluster metadata to system or OS logs from processes that don't run as part of containers or ECS Tasks. | `false` |
| `ecs_meta_cache_ttl` | The filter builds a hash table in memory mapping each unique container short ID to its metadata. This option sets a max TTL for objects in the hash table. Set this if you have frequent container or task restarts. For example, if your cluster runs short-running batch jobs that complete in less than 10 minutes, set this parameter to `10m`. | `1h` |
| `ecs_meta_host` | The host name at which the ECS Agent Introspection endpoint is reachable. | `127.0.0.1` |
| `ecs_meta_port` | The port at which the ECS Agent Introspection endpoint is reachable. | `51678` |
| `ecs_tag_prefix` | Similar to the `kube_tag_prefix` option in the [Kubernetes filter](../filters/kubernetes.md) and performs the same function. The full log tag should be prefixed with this string and after the prefix the filter must find the next characters in the tag to be the Docker Container Short ID (the first 12 characters of the full container ID). The filter uses this to identify which container the log came from so it can find which task it's a part of. If not specified, defaults to empty string, meaning that the tag must be prefixed with the 12-character container short ID. If you want to attach cluster metadata to system or OS logs from processes that don't run as part of containers or ECS Tasks, don't set this parameter and enable `cluster_metadata_only`. | `""` |

### Supported templating variables for the `add` option

The following template variables can be used for values with the `add` option. See the tutorial in the sections following for examples.

| Variable | Description | Supported with `cluster_metadata_only` on |
| :--- | :--- | :--- |
| `$ClusterName` | The ECS cluster name. Fluent Bit is running on EC2 instances that are part of this cluster. | `Yes` |
| `$ContainerInstanceArn` | The full ARN of the ECS EC2 Container Instance. This is the instance that Fluent Bit is running on. | `Yes` |
| `$ContainerInstanceID` | The ID of the ECS EC2 Container Instance. | `Yes` |
| `$ECSAgentVersion` | The version string of the ECS Agent running on the container instance. | `Yes` |
| `$ECSContainerName` | The name of the container from which the log originated. This is the name in your ECS Task Definition. | `No` |
| `$DockerContainerName` | The name of the container from which the log originated. This is the name obtained from Docker and is the name shown if you run `docker ps` on the instance. | `No` |
| `$ContainerID` | The ID of the container from which the log originated. This is the full 64-character-long container ID. | `No` |
| `$TaskDefinitionFamily` | The family name of the task definition for the task from which the log originated. | `No` |
| `$TaskDefinitionVersion` | The version or revision of the task definition for the task from which the log originated. | `No` |
| `$TaskID` | The ID of the ECS Task from which the log originated. | `No` |
| `$TaskARN` | The full ARN of the ECS Task from which the log originated. | `No` |

### Configuration file

The following configurations assume a properly configured parsers file and `storage.path` variable defined in the services section of the Fluent Bit configuration (not shown).

#### Example 1: Attach Task ID and cluster name to container logs

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: ecs.*
      path: /var/lib/docker/containers/*/*.log
      docker_mode: on
      docker_mode_flush: 5
      docker_mode_parser: container_firstline
      parser: docker
      db: /var/fluent-bit/state/flb_container.db
      mem_buf_limit: 50MB
      skip_long_lines: on
      refresh_interval: 10
      rotate_wait: 30
      storage.type: filesystem
      read_from_head: off

  filters:
    - name: ecs
      match: '*'
      ecs_tag_prefix: ecs.var.lib.docker.containers.
      add:
        - ecs_task_id $TaskID
        - cluster $ClusterName

  outputs:
    - name: stdout
      match: '*'
      format: json_lines
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  ecs_tag_prefix ecs.var.lib.docker.containers.
  add ecs_task_id $TaskID
  add cluster $ClusterName

[OUTPUT]
  Name stdout
  Match *
  Format json_lines
```

{% endtab %}
{% endtabs %}

The output log should be similar to:

```text
{
  "date":1665003546.0,
  "log":"some message from your container",
  "ecs_task_id": "1234567890abcdefghijklmnop",
  "cluster": "your_cluster_name",
}
```

#### Example 2: Attach customized resource name to container logs

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: ecs.*
      path: /var/lib/docker/containers/*/*.log
      docker_mode: on
      docker_mode_flush: 5
      docker_mode_parser: container_firstline
      parser: docker
      db: /var/fluent-bit/state/flb_container.db
      mem_buf_limit: 50MB
      skip_long_lines: on
      refresh_interval: 10
      rotate_wait: 30
      storage.type: filesystem
      read_from_head: off

  filters:
    - name: ecs
      match: '*'
      ecs_tag_prefix: ecs.var.lib.docker.containers.
      add: resource $ClusterName.$TaskDefinitionFamily.$TaskID.$ECSContainerName

  outputs:
    - name: stdout
      match: '*'
      format: json_lines
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  ecs_tag_prefix ecs.var.lib.docker.containers.
  add resource $ClusterName.$TaskDefinitionFamily.$TaskID.$ECSContainerName

[OUTPUT]
  Name stdout
  Match *
  Format json_lines
```

{% endtab %}
{% endtabs %}

The output log would be similar to:

```text
{
  "date":1665003546.0,
  "log":"some message from your container",
  "resource": "cluster.family.1234567890abcdefghijklmnop.app",
}
```

The template variables in the value for the `resource` key are separated by dot characters. Only dots and commas (`.` and `,`) can come after a template variable. For more information, see the [Record accessor limitation's section](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md#limitations-of-record_accessor-templating).

#### Example 3: Attach cluster metadata to non-container logs

This example shows a use case for the `cluster_metadata_only` option attaching cluster metadata to ECS Agent logs.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: ecsagent.*
      path: /var/log/ecs/*
      db: /var/fluent-bit/state/flb_ecs.db
      mem_buf_limit: 50MB
      skip_long_lines: on
      refresh_interval: 10
      rotate_wait: 30
      storage.type: filesystem
      # Collect all logs on instance
      read_from_head: on

  filters:
    - name: ecs
      match: '*'
      cluster_metadata_only: on
      add: cluster $ClusterName

  outputs:
    - name: stdout
      match: '*'
      format: json_lines
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
  cluster_metadata_only on
  add cluster $ClusterName

[OUTPUT]
  Name stdout
  Match *
  Format json_lines
```

{% endtab %}
{% endtabs %}
