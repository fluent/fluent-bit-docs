---
description: Send logs to Amazon OpenSearch Service
---

# OpenSearch

The _OpenSearch_ output plugin lets you ingest your records into an [OpenSearch](https://opensearch.org/) database. The following instructions assume you have an operational OpenSearch service running in your environment.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `Host` | IP address or hostname of the target OpenSearch instance. | `127.0.0.1` |
| `Port` | TCP port of the target OpenSearch instance. | `9200` |
| `Path` | OpenSearch accepts new data on HTTP query path `/_bulk`. It's possible to serve OpenSearch behind a reverse proxy on a sub-path. This option defines such path on the Fluent Bit side. It adds a path prefix in the indexing HTTP POST URI. | Empty string |
| `Buffer_Size` | Specify the buffer size used to read the response from the OpenSearch HTTP service. Use for debugging purposes where it's required to read full responses. The response size grows depending of the number of records inserted. Set this value to `False` to set an unlimited amount of memory. Otherwise set the value according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | `4KB` |
| `Pipeline` | OpenSearch lets you set up filters called pipelines. This option defines which pipeline the database should use. For performance reasons is strongly suggested to do parsing and filtering on Fluent Bit side, avoid pipelines. | _none_ |
| `AWS_Auth` | Enable AWS Sigv4 Authentication for Amazon OpenSearch Service. | `Off` |
| `AWS_Region` | Specify the AWS region for Amazon OpenSearch Service. | _none_ |
| `AWS_STS_Endpoint` | Specify the custom STS endpoint to be used with STS API for Amazon OpenSearch Service. | _none_ |
| `AWS_Role_ARN` | AWS IAM Role to assume to put records to your Amazon cluster. | _none_ |
| `AWS_External_ID` | External ID for the AWS IAM Role specified with `aws_role_arn`. | _none_ |
| `AWS_Service_Name` | Service name to be used in AWS Sigv4 signature. For integration with Amazon OpenSearch Serverless, set to `aoss`. See the [FAQ](opensearch.md#faq) section on Amazon OpenSearch Serverless for more information. | `es` |
| `AWS_Profile` | AWS profile name. | `default` |
| `HTTP_User` | Optional. Username credential for access. | _none_ |
| `HTTP_Passwd` | Password for user defined in `HTTP_User`. | _none_ |
| `Index` | Index name, supports [Record Accessor syntax](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) from 2.0.5 or later. | `fluent-bit` |
| `Type` | Type name. This option is ignored if `Suppress_Type_Name` is enabled. | `_doc` |
| `Logstash_Format` | Enable Logstash format compatibility. This option takes a boolean value: `True`/`False`, `On`/`Off` | `Off` |
| `Logstash_Prefix` | When `Logstash_Format` is enabled, the Index name is composed using a prefix and the date. For example, if `Logstash_Prefix` is equal to `mydata` your index will become `mydata-YYYY.MM.DD`. The last string appended belongs to the date when the data is being generated. | `logstash` |
| `Logstash_Prefix_Key` | When included, the value of the key in the record will be evaluated as key reference and overrides `Logstash_Prefix` for index generation. If the key/value isn't found in the record then the `Logstash_Prefix` option will act as a fallback. The parameter is expected to be a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md). | _none_ |
| `Logstash_Prefix_Separator` | Set a separator between `Logstash_Prefix` and `Date`. | `-` |
| `Logstash_DateFormat` | Time format, based on [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html), to generate the second part of the `Index` name. | `%Y.%m.%d` |
| `Time_Key` | When `Logstash_Format` is enabled, each record will get a new timestamp field. The `Time_Key` property defines the name of that field. | `@timestamp` |
| `Time_Key_Format` | When `Logstash_Format` is enabled, this property defines the format of the timestamp. | `%Y-%m-%dT%H:%M:%S` |
| `Time_Key_Nanos` | When `Logstash_Format` is enabled, enabling this property sends nanosecond precision timestamps. | `Off` |
| `Include_Tag_Key` | When enabled, append the `Tag` name to the record. | `Off` |
| `Tag_Key | When `Include_Tag_Key` is enabled, this property defines the key name for the tag. | `_flb-key` |
| `Generate_ID` | When enabled, generate `_id` for outgoing records. This prevents duplicate records when retrying. | `Off` |
| `Id_Key` | If set, `_id` will be the value of the key from incoming record and `Generate_ID` option is ignored. | _none_ |
| `Write_Operation` | Operation to use to write in bulk requests. | `create` |
| `Replace_Dots` | When enabled, replace field name dots (`.`) with underscores (`_`). | `Off` |
| `Trace_Output` | When enabled, print the OpenSearch API calls to stdout (for diagnostics only). | `Off` |
| `Trace_Error` | When enabled, print the OpenSearch API calls to stdout when OpenSearch returns an error (for diagnostics only). | `Off` |
| `Current_Time_Index` | Use current time for index generation instead of message record. | `Off` |
| `Suppress_Type_Name` | When enabled, mapping types is removed and the `Type` option is ignored. | `Off` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| `Compress` | Set payload compression mechanism. Allowed value: `gzip`. | _none_ (no compression) |

The parameters `index` and `type` can be confusing if you are new to OpenSearch. If you have used a common relational database before, they can be compared to the `database` and `table` concepts. Also see [the FAQ](opensearch.md#faq).

### TLS / SSL

The OpenSearch output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

### `write_operation`

The `write_operation` can be any of:

| Operation        | Description                                                                                        |
|------------------|----------------------------------------------------------------------------------------------------|
| `create` (default) | Adds new data - if the data already exists (based on its id), the op is skipped.                   |
| `index`            | New data is added while existing data (based on its id) is replaced (reindexed).                   |
| `update`           | Updates existing data (based on its id). If no data is found, the op is skipped.                   |
| `upsert`           | Known as `merge` or `insert` if the data doesn't exist. Updates if the data exists (based on its id). |

`Id_Key` or `Generate_ID` is required for `update` and `upsert`.

## Get started

To insert records into an OpenSearch service, you can run the plugin from the command line or through the configuration file.

### Command line

The OpenSearch plugin can read the parameters from the command line in two ways, through the `-p` argument (property) or by setting them directly through the service URI. The URI format is the following:

```text
es://host:port/index/type
```

Using the format specified, start Fluent Bit through:

```shell
fluent-bit -i cpu -t cpu -o es://192.168.2.3:9200/my_index/my_type \
  -o stdout -m '*'
```

which is similar to do:

```shell
fluent-bit -i cpu -t cpu -o opensearch -p Host=192.168.2.3 -p Port=9200 \
  -p Index=my_index -p Type=my_type -o stdout -m '*'
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: opensearch
      match: '*'
      host: 192.168.2.3
      port: 9200
      index: my_index
      type: my_type
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  opensearch
  Match *
  Host  192.168.2.3
  Port  9200
  Index my_index
  Type  my_type
```

{% endtab %}
{% endtabs %}

## About OpenSearch field names

Some input plugins can generate messages where the field names contain dots (`.`). The OpenSearch plugin replaces them with an underscore (`_`):

```text
{"cpu0.p_cpu"=>17.000000}
```

becomes

```text
{"cpu0_p_cpu"=>17.000000}
```

## Frequently asked questions

### `Logstash_Prefix_Key`

The following snippet demonstrates using the namespace name as extracted by the
`kubernetes` filter as `logstash` prefix:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: opensearch
      match: '*'
      # ...
      logstash_prefix: logstash
      logstash_prefix_key: $kubernetes['namespace_name']
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name opensearch
  Match *
  # ...
  Logstash_Prefix logstash
  Logstash_Prefix_Key $kubernetes['namespace_name']
  # ...
```

{% endtab %}
{% endtabs %}

For records that do nor have the field `kubernetes.namespace_name`, the default prefix, `logstash` will be used.

### Fluent Bit and Amazon OpenSearch Service

The Amazon OpenSearch Service adds an extra security layer where HTTP requests must be signed with AWS Sigv4. This plugin supports Amazon OpenSearch Service with IAM Authentication.

For details about how AWS credentials are fetched, see [AWS credentials](../../administration/aws-credentials.md).

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: opensearch
      match: '*'
      host: vpc-test-domain-ke7thhzoo7jawsrhmm6mb7ite7y.us-west-2.es.amazonaws.com
      port: 443
      index: my_index
      type: my_type
      aws_auth: on
      aws_region: us-west-2
      tls: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name  opensearch
  Match *
  Host  vpc-test-domain-ke7thhzoo7jawsrhmm6mb7ite7y.us-west-2.es.amazonaws.com
  Port  443
  Index my_index
  Type  my_type
  AWS_Auth On
  AWS_Region us-west-2
  tls     On
```

{% endtab %}
{% endtabs %}

Notice that the `Port` is set to `443`, `tls` is enabled, and `AWS_Region` is set.

### Action/metadata contains an unknown parameter type

Similar to Elastic Cloud, OpenSearch in version 2.0 and later needs to have the type option removed by setting `Suppress_Type_Name On`.

Without this you will see errors like:

```text
{"error":{"root_cause":[{"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"}],"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"},"status":400}
```

### Fluent-Bit and Amazon OpenSearch serverless

Amazon OpenSearch Serverless is an offering that eliminates your need to manage OpenSearch clusters. All existing Fluent Bit OpenSearch output plugin options work with OpenSearch Serverless. For Fluent Bit, you must specify the service name as `aoss` (Amazon OpenSearch Serverless) when you enable `AWS_Auth`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: opensearch
      match: '*'
      host: vpc-test-domain-ke7thhzoo7jawsrhmm6mb7ite7y.us-west-2.es.amazonaws.com
      port: 443
      index: my_index
      type: my_type
      aws_auth: on
      aws_region: <aws-region>
      aws_service_name: aoss
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name  opensearch
  Match *
  Host  vpc-test-domain-ke7thhzoo7jawsrhmm6mb7ite7y.us-west-2.es.amazonaws.com
  Port  443
  Index my_index
  Type  my_type
  AWS_Auth On
  AWS_Region <aws-region>
  AWS_Service_Name aoss
```

{% endtab %}
{% endtabs %}

#### Data access permissions

When sending logs to OpenSearch Serverless, your AWS IAM entity needs [OpenSearch Serverless Data Access permissions](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-data-access.html). Give your IAM entity the following data access permissions to your serverless collection:

```text
aoss:CreateIndex
aoss:UpdateIndex
aoss:WriteDocument
```

With data access permissions, IAM policies aren't needed to access the collection.

### Issues with the OpenSearch cluster

The Fluent Bit service might generate errors without any additional detail in the logs to explain the source of the issue, even with the service's `log_level` attribute set to [Debug](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file).

For example, in this scenario the logs show that a connection was successfully established with the OpenSearch domain, and yet an error is still returned:

```text
...
[2023/07/10 19:26:00] [debug] [http_client] not using http_proxy for header
[2023/07/10 19:26:00] [debug] [output:opensearch:opensearch.5] Signing request with AWS Sigv4
[2023/07/10 19:26:00] [debug] [aws_credentials] Requesting credentials from the EC2 provider..
[2023/07/10 19:26:00] [debug] [output:opensearch:opensearch.5] HTTP Status=200 URI=/_bulk
[2023/07/10 19:26:00] [debug] [upstream] KA connection #137 to [MY_OPENSEARCH_DOMAIN]:443 is now available
[2023/07/10 19:26:00] [debug] [out flush] cb_destroy coro_id=1746
[2023/07/10 19:26:00] [debug] [task] task_id=2 reached retry-attempts limit 5/5
[2023/07/10 19:26:00] [error] [engine] chunk '7578-1689017013.184552017.flb' cannot be retried: task_id=2, input=tail.6 > output=opensearch.5
[2023/07/10 19:26:00] [debug] [task] destroy task=0x7fd1cc4d5ad0 (task_id=2)
...
```

This behavior could be indicative of a hard-to-detect issue with index shard usage in the OpenSearch domain. Although OpenSearch index shards and disk space are related, they're not directly tied to one another. OpenSearch domains are limited to 1,000 index shards per data node, regardless of the size of the nodes. Shard usage isn't proportional to disk usage. An individual index shard can hold anywhere from a few kilobytes to dozens of gigabytes of data.

Depending index creation and shard allocation configuration in the OpenSearch domain, all the available index shards could be used before the data nodes run out of disk space. This can result in exhibition disk-related performance issues (nodes crashing, data corruption, or the dashboard going offline). The primary issue that arises when a domain is out of available index shards is that new indexes can no longer be created (although logs can still be added to existing indexes).

When that happens, the Fluent Bit OpenSearch output can show confusing behavior. For example:

- Errors suddenly appear (outputs were previously working and there were no changes to the Fluent Bit configuration when the errors began)
- Errors aren't consistently occurring (some logs are still reaching the OpenSearch domain)
- The Fluent Bit service logs show errors, but without any detail as to the root cause

If any of those symptoms are present, consider using the OpenSearch domain's API endpoints to troubleshoot possible shard issues.

Running this command will show both the shard count and disk usage on all the nodes in the domain.

```text
GET _cat/allocation?v
```

Index creation issues can appear if any hot data nodes have around 1,000 shards. Creation issues can also occur if the total number of shards spread across hot and ultra warm data nodes in the cluster is greater than 1,000 times the total number of nodes. For example, in a cluster with six nodes, the maximum shard count would be `6000`.

Alternately, running this command to manually create a new index will return an explicit error related to shard count if the maximum has been exceeded:

```text
PUT <index-name>
```

There are multiple ways to resolve excessive shard usage in an OpenSearch domain. Deleting or combining indexes, adding more data nodes to the cluster, or updating the domain's index creation and sharding strategy can resolve this issue. Consult the OpenSearch documentation for more information about how to use these strategies.
