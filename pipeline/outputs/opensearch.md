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
| HTTP\_User | Optional username credential for access                                                                                                                                                                                                                                                                                                                                                                                                                      |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User                                                                                                                                                                                                                                                                                                                                                                                                                      |  |
| Index | Index name, supports record accessor syntax from 2.0.5 onwards.                                                                                                                                                                                                                                                                                                                                                                                                                                                   | fluent-bit |
| Type | Type name                                                                                                                                                                                                                                                                                                                                                                                                                                                    | \_doc |
| Logstash\_Format | Enable Logstash format compatibility. This option takes a boolean value: True/False, On/Off                                                                                                                                                                                                                                                                                                                                                                  | Off |
| Logstash\_Prefix | When Logstash\_Format is enabled, the Index name is composed using a prefix and the date, e.g: If Logstash\_Prefix is equals to 'mydata' your index will become 'mydata-YYYY.MM.DD'. The last string appended belongs to the date when the data is being generated.                                                                                                                                                                                          | logstash |
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
| Logstash\_Prefix\_Key | When included: the value in the record that belongs to the key will be looked up and over-write the Logstash\_Prefix for index generation. If the key/value is not found in the record then the Logstash\_Prefix option will act as a fallback. Nested keys are not supported \(if desired, you can use the nest filter plugin to remove nesting\)                                                                                                           |  |
| Suppress\_Type\_Name | When enabled, mapping types is removed and `Type` option is ignored.                                                                                                                                                                                                                        | Off |
| Workers | Enables dedicated thread(s) for this output. Default value is set since version 1.8.13. For previous versions is 0.                                                                                                                                                                                                                                                                                                                                          | 2 |

> The parameters _index_ and _type_ can be confusing if you are new to OpenSearch, if you have used a common relational database before, they can be compared to the _database_ and _table_ concepts. Also see [the FAQ below](opensearch.md#faq)

### TLS / SSL

OpenSearch output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](tcp-and-tls.md) section.

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

![example configuration visualization from config.calyptia.com](../../.gitbook/assets/image%20%282%29.png)

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
