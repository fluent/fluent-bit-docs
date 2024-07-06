---
description: Send logs to Amazon OpenSearch Service
---

# OpenSearch

The **opensearch** output plugin, allows to ingest your records into an [OpenSearch](https://opensearch.org/) database.
The following instructions assumes that you have a fully operational OpenSearch service running in your environment.

## Configuration Parameters

| Key | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  | default |
| :--- |:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| :--- |
| Host | IP address or hostname of the target OpenSearch instance                                                                                                                                                                                                                                                                                                                                                                                                     | 127.0.0.1 |
| Port | TCP port of the target OpenSearch instance                                                                                                                                                                                                                                                                                                                                                                                                                   | 9200 |
| Path | OpenSearch accepts new data on HTTP query path "/\_bulk". But it is also possible to serve OpenSearch behind a reverse proxy on a subpath. This option defines such path on the fluent-bit side. It simply adds a path prefix in the indexing HTTP POST URI.                                                                                                                                                                                                 | Empty string |
| Buffer\_Size | Specify the buffer size used to read the response from the OpenSearch HTTP service. This option is useful for debugging purposes where is required to read full responses, note that response size grows depending of the number of records inserted. To set an _unlimited_ amount of memory set this value to **False**, otherwise the value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | 4KB |
| Pipeline | OpenSearch allows to setup filters called pipelines. This option allows to define which pipeline the database should use. For performance reasons is strongly suggested to do parsing and filtering on Fluent Bit side, avoid pipelines.                                                                                                                                                                                                                     |  |
| AWS\_Auth | Enable AWS Sigv4 Authentication for Amazon OpenSearch Service                                                                                                                                                                                                                                                                                                                                                                                                | Off |
| AWS\_Region | Specify the AWS region for Amazon OpenSearch Service                                                                                                                                                                                                                                                                                                                                                                                                         |  |
| AWS\_STS\_Endpoint | Specify the custom sts endpoint to be used with STS API for Amazon OpenSearch Service                                                                                                                                                                                                                                                                                                                                                                        |  |
| AWS\_Role\_ARN | AWS IAM Role to assume to put records to your Amazon cluster                                                                                                                                                                                                                                                                                                                                                                                                 |  |
| AWS\_External\_ID | External ID for the AWS IAM Role specified with `aws_role_arn`                                                                                                                                                                                                                                                                                                                                                                                               |  |
| AWS\_Service\_Name | Service name to be used in AWS Sigv4 signature. For integration with Amazon OpenSearch Serverless, set to `aoss`. See the [FAQ](opensearch.md#faq) section on Amazon OpenSearch Serverless for more information.                                                                                                                                                                                                                                                                                                                                                                                              | es |
| AWS\_Profile | AWS profile name | default |
| HTTP\_User | Optional username credential for access                                                                                                                                                                                                                                                                                                                                                                                                                      |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User                                                                                                                                                                                                                                                                                                                                                                                                                      |  |
| Index | Index name, supports [Record Accessor syntax](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) from 2.0.5 onwards.                                             | fluent-bit |
| Type | Type name. This option is ignored if `Suppress_Type_Name` is enabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                    | \_doc |
| Logstash\_Format | Enable Logstash format compatibility. This option takes a boolean value: True/False, On/Off                                                                                                                                                                                                                                                                                                                                                                  | Off |
| Logstash\_Prefix | When Logstash\_Format is enabled, the Index name is composed using a prefix and the date, e.g: If Logstash\_Prefix is equals to 'mydata' your index will become 'mydata-YYYY.MM.DD'. The last string appended belongs to the date when the data is being generated.                                                                                                                                                                                          | logstash |
| Logstash\_Prefix\_Key | When included: the value of the key in the record will be evaluated as key reference and overrides Logstash\_Prefix for index generation. If the key/value is not found in the record then the Logstash\_Prefix option will act as a fallback. The parameter is expected to be a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md). |  |
| Logstash\_Prefix\_Separator | Set a separator between logstash_prefix and date.                                                                                                           | - |
| Logstash\_DateFormat | Time format \(based on [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html)\) to generate the second part of the Index name.                                                                                                                                                                                                                                                                                                                     | %Y.%m.%d |
| Time\_Key | When Logstash\_Format is enabled, each record will get a new timestamp field. The Time\_Key property defines the name of that field.                                                                                                                                                                                                                                                                                                                         | @timestamp |
| Time\_Key\_Format | When Logstash\_Format is enabled, this property defines the format of the timestamp.                                                                                                                                                                                                                                                                                                                                                                         | %Y-%m-%dT%H:%M:%S |
| Time\_Key\_Nanos | When Logstash\_Format is enabled, enabling this property sends nanosecond precision timestamps.                                                                                                                                                                                                                                                                                                                                                              | Off |
| Include\_Tag\_Key | When enabled, it append the Tag name to the record.                                                                                                                                                                                                                                                                                                                                                                                                          | Off |
| Tag\_Key | When Include\_Tag\_Key is enabled, this property defines the key name for the tag.                                                                                                                                                                                                                                                                                                                                                                           | \_flb-key |
| Generate\_ID | When enabled, generate `_id` for outgoing records. This prevents duplicate records when retrying.                                                                                                                                                                                                                                                                                                                                                            | Off |
| Id\_Key | If set, `_id` will be the value of the key from incoming record and `Generate_ID` option is ignored.                                                                                                                                                                                                                                                                                                                                                         |  |
| Write\_Operation | Operation to use to write in bulk requests.                                                                                                                                                                                                                                                                                                                                                                                                                  | create |
| Replace\_Dots | When enabled, replace field name dots with underscore.                                                                                                                                                                                                                                                                                                                                                                                                       | Off |
| Trace\_Output | When enabled print the OpenSearch API calls to stdout \(for diag only\)                                                                                                                                                                                                                                                                                                                                                                                      | Off |
| Trace\_Error | When enabled print the OpenSearch API calls to stdout when OpenSearch returns an error \(for diag only\)                                                                                                                                                                                                                                                                                                                                                     | Off |
| Current\_Time\_Index | Use current time for index generation instead of message record                                                                                                                                                                                                                                                                                                                                                                                              | Off |
| Suppress\_Type\_Name | When enabled, mapping types is removed and `Type` option is ignored.                                                                                                                                                                                                                        | Off |
| Workers | Enables dedicated thread(s) for this output. Default value is set since version 1.8.13. For previous versions is 0.                                                                                                                                                                                                                                                                                                                                          | 2 |
| Compress | Set payload compression mechanism. The only available option is `gzip`. Default = "", which means no compression. |  |

> The parameters _index_ and _type_ can be confusing if you are new to OpenSearch, if you have used a common relational database before, they can be compared to the _database_ and _table_ concepts. Also see [the FAQ below](opensearch.md#faq)

### TLS / SSL

OpenSearch output plugin supports TLS/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../../administration/transport-security.md) section.

### write\_operation

The write\_operation can be any of:

| Operation | Description          |
| ------------- | ----------- |
| create (default) | adds new data - if the data already exists (based on its id), the op is skipped.|
| index            | new data is added while existing data (based on its id) is replaced (reindexed).|
| update           | updates existing data (based on its id). If no data is found, the op is skipped.|
| upsert           | known as merge or insert if the data does not exist, updates if the data exists (based on its id).|

**Please note, `Id_Key` or `Generate_ID` is required in update, and upsert scenario.**

## Getting Started

In order to insert records into an OpenSearch service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **opensearch** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

```text
es://host:port/index/type
```

Using the format specified, you could start Fluent Bit through:

```text
$ fluent-bit -i cpu -t cpu -o es://192.168.2.3:9200/my_index/my_type \
    -o stdout -m '*'
```

which is similar to do:

```text
$ fluent-bit -i cpu -t cpu -o opensearch -p Host=192.168.2.3 -p Port=9200 \
    -p Index=my_index -p Type=my_type -o stdout -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections. You can visualize this configuration [here](https://link.calyptia.com/qhq)

```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name  opensearch
    Match *
    Host  192.168.2.3
    Port  9200
    Index my_index
    Type  my_type
```

![example configuration visualization from calyptia](../../.gitbook/assets/image%20%282%29.png)

## About OpenSearch field names

Some input plugins may generate messages where the field names contains dots. This **opensearch** plugin replaces them with an underscore, e.g:

```text
{"cpu0.p_cpu"=>17.000000}
```

becomes

```text
{"cpu0_p_cpu"=>17.000000}
```

## FAQ

### Logstash_Prefix_Key

The following snippet demonstrates using the namespace name as extracted by the
`kubernetes` filter as logstash preifix:

```text
[OUTPUT]
    Name opensearch
    Match *
    # ...
    Logstash_Prefix logstash
    Logstash_Prefix_Key $kubernetes['namespace_name']
    # ...
```

For records that do nor have the field `kubernetes.namespace_name`, the default prefix, `logstash` will be used.

### Fluent Bit + Amazon OpenSearch Service <a id="#aws-es"></a>

The Amazon OpenSearch Service adds an extra security layer where HTTP requests must be signed with AWS Sigv4. This plugin supports Amazon OpenSearch Service with IAM Authentication.

See [here](../../administration/aws-credentials.md) for details on how AWS credentials are fetched.

Example configuration:

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

Notice that the `Port` is set to `443`, `tls` is enabled, and `AWS_Region` is set.

### Action/metadata contains an unknown parameter type

Similarly to Elastic Cloud, OpenSearch in version 2.0 and above needs to have type option being removed by setting `Suppress_Type_Name On`.

Without this you will see errors like:

```text
{"error":{"root_cause":[{"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"}],"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"},"status":400}
```

### Fluent-Bit + Amazon OpenSearch Serverless <a id="#aws-opensearch-serverless"></a>
Amazon OpenSearch Serverless is an offering that eliminates your need to manage OpenSearch clusters. All existing Fluent Bit OpenSearch output plugin options work with OpenSearch Serverless. For Fluent Bit, the only difference is that you must specify the service name as `aoss` (Amazon OpenSearch Serverless) when you enable `AWS_Auth`:
```
AWS_Auth On
AWS_Region <aws-region>
AWS_Service_Name aoss
```

**Data Access Permissions**

When sending logs to OpenSearch Serverless, your AWS IAM entity needs [OpenSearch Serverless Data Access permisions](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-data-access.html). Give your IAM entity the following data access permissions to your serverless collection:
```
aoss:CreateIndex
aoss:UpdateIndex
aoss:WriteDocument
```
With data access permissions, IAM policies are not needed to access the collection.

### Issues with the OpenSearch cluster

Occasionally the Fluent Bit service may generate errors without any additional detail in the logs to explain the source of the issue, even with the service's log_level attribute set to [Debug](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file). 

For example, in this scenario the logs show that a connection was successfully established with the OpenSearch domain, and yet an error is still returned:
```
[2023/07/10 19:26:00] [debug] [http_client] not using http_proxy for header
[2023/07/10 19:26:00] [debug] [output:opensearch:opensearch.5] Signing request with AWS Sigv4
[2023/07/10 19:26:00] [debug] [aws_credentials] Requesting credentials from the EC2 provider..
[2023/07/10 19:26:00] [debug] [output:opensearch:opensearch.5] HTTP Status=200 URI=/_bulk
[2023/07/10 19:26:00] [debug] [upstream] KA connection #137 to [MY_OPENSEARCH_DOMAIN]:443 is now available
[2023/07/10 19:26:00] [debug] [out flush] cb_destroy coro_id=1746
[2023/07/10 19:26:00] [debug] [task] task_id=2 reached retry-attempts limit 5/5
[2023/07/10 19:26:00] [error] [engine] chunk '7578-1689017013.184552017.flb' cannot be retried: task_id=2, input=tail.6 > output=opensearch.5
[2023/07/10 19:26:00] [debug] [task] destroy task=0x7fd1cc4d5ad0 (task_id=2)
```

This behavior could be indicative of a hard-to-detect issue with index shard usage in the OpenSearch domain.

While OpenSearch index shards and disk space are related, they are not directly tied to one another.

OpenSearch domains are limited to 1000 index shards per data node, regardless of the size of the nodes. And, importantly, shard usage is not proportional to disk usage: an individual index shard can hold anywhere from a few kilobytes to dozens of gigabytes of data. 

In other words, depending on the way index creation and shard allocation are configured in the OpenSearch domain, all of the available index shards could be used long before the data nodes run out of disk space and begin exhibiting disk-related performance issues (e.g. nodes crashing, data corruption, or the dashboard going offline). 

The primary issue that arises when a domain is out of available index shards is that new indexes can no longer be created (though logs can still be added to existing indexes).

When that happens, the Fluent Bit OpenSearch output may begin showing confusing behavior. For example:
- Errors suddenly appear (outputs were previously working and there were no changes to the Fluent Bit configuration when the errors began)
- Errors are not consistently occurring (some logs are still reaching the OpenSearch domain)
- The Fluent Bit service logs show errors, but without any detail as to the root cause

If any of those symptoms are present, consider using the OpenSearch domain's API endpoints to troubleshoot possible shard issues.

Running this command will show both the shard count and disk usage on all of the nodes in the domain. 
```
GET _cat/allocation?v
```

Index creation issues will begin to appear if any hot data nodes have around 1000 shards OR if the total number of shards spread across hot and ultrawarm data nodes in the cluster is greater than 1000 times the total number of nodes (e.g., in a cluster with 6 nodes, the maximum shard count would be 6000).

Alternatively, running this command to manually create a new index will return an explicit error related to shard count if the maximum has been exceeded.
```
PUT <index-name>
```

There are multiple ways to resolve excessive shard usage in an OpenSearch domain such as deleting or combining indexes, adding more data nodes to the cluster, or updating the domain's index creation and sharding strategy. Consult the OpenSearch documentation for more information on how to use these strategies.
