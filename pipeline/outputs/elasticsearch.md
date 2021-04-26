---
description: Send logs to Elasticsearch (including Amazon Elasticsearch Service)
---

# Elasticsearch

The **es** output plugin, allows to ingest your records into an [Elasticsearch](http://www.elastic.co) database. The following instructions assumes that you have a fully operational Elasticsearch service running in your environment.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target Elasticsearch instance | 127.0.0.1 |
| Port | TCP port of the target Elasticsearch instance | 9200 |
| Path | Elasticsearch accepts new data on HTTP query path "/\_bulk". But it is also possible to serve Elasticsearch behind a reverse proxy on a subpath. This option defines such path on the fluent-bit side. It simply adds a path prefix in the indexing HTTP POST URI. | Empty string |
| Buffer\_Size | Specify the buffer size used to read the response from the Elasticsearch HTTP service. This option is useful for debugging purposes where is required to read full responses, note that response size grows depending of the number of records inserted. To set an _unlimited_ amount of memory set this value to **False**, otherwise the value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | 4KB |
| Pipeline | Newer versions of Elasticsearch allows to setup filters called pipelines. This option allows to define which pipeline the database should use. For performance reasons is strongly suggested to do parsing and filtering on Fluent Bit side, avoid pipelines. |  |
| AWS\_Auth | Enable AWS Sigv4 Authentication for Amazon ElasticSearch Service | Off |
| AWS\_Region | Specify the AWS region for Amazon ElasticSearch Service |  |
| AWS\_STS\_Endpoint | Specify the custom sts endpoint to be used with STS API for Amazon ElasticSearch Service |  |
| AWS\_Role\_ARN | AWS IAM Role to assume to put records to your Amazon ES cluster |  |
| AWS\_External\_ID | External ID for the AWS IAM Role specified with `aws_role_arn` |  |
| Cloud\_ID | If you are using Elastic's Elasticsearch Service you can specify the cloud\_id of the cluster running |  |
| Cloud\_Auth | Specify the credentials to use to connect to Elastic's Elasticsearch Service running on Elastic Cloud |  |
| HTTP\_User | Optional username credential for Elastic X-Pack access |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User |  |
| Index | Index name | fluent-bit |
| Type | Type name | \_doc |
| Logstash\_Format | Enable Logstash format compatibility. This option takes a boolean value: True/False, On/Off | Off |
| Logstash\_Prefix | When Logstash\_Format is enabled, the Index name is composed using a prefix and the date, e.g: If Logstash\_Prefix is equals to 'mydata' your index will become 'mydata-YYYY.MM.DD'. The last string appended belongs to the date when the data is being generated. | logstash |
| Logstash\_DateFormat | Time format \(based on [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html)\) to generate the second part of the Index name. | %Y.%m.%d |
| Time\_Key | When Logstash\_Format is enabled, each record will get a new timestamp field. The Time\_Key property defines the name of that field. | @timestamp |
| Time\_Key\_Format | When Logstash\_Format is enabled, this property defines the format of the timestamp. | %Y-%m-%dT%H:%M:%S |
| Time\_Key\_Nanos | When Logstash\_Format is enabled, enabling this property sends nanosecond precision timestamps. | Off |
| Include\_Tag\_Key | When enabled, it append the Tag name to the record. | Off |
| Tag\_Key | When Include\_Tag\_Key is enabled, this property defines the key name for the tag. | \_flb-key |
| Generate\_ID | When enabled, generate `_id` for outgoing records. This prevents duplicate records when retrying ES. | Off |
| Id\_Key | If set, `_id` will be the value of the key from incoming record and `Generate_ID` option is ignored. |  |
| Replace\_Dots | When enabled, replace field name dots with underscore, required by Elasticsearch 2.0-2.3. | Off |
| Trace\_Output | When enabled print the elasticsearch API calls to stdout \(for diag only\) | Off |
| Trace\_Error | When enabled print the elasticsearch API calls to stdout when elasticsearch returns an error \(for diag only\) | Off |
| Current\_Time\_Index | Use current time for index generation instead of message record | Off |
| Logstash\_Prefix\_Key | When included: the value in the record that belongs to the key will be looked up and over-write the Logstash\_Prefix for index generation. If the key/value is not found in the record then the Logstash\_Prefix option will act as a fallback. Nested keys are not supported \(if desired, you can use the nest filter plugin to remove nesting\) |  |
| Suppress\_Type\_Name | When enabled, mapping types is removed and `Type` option is ignored. Types are deprecated in APIs in [v7.0](https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html). This options is for v7.0 or later. | Off |

> The parameters _index_ and _type_ can be confusing if you are new to Elastic, if you have used a common relational database before, they can be compared to the _database_ and _table_ concepts. Also see [the FAQ below](elasticsearch.md#faq-multiple-types)

### TLS / SSL

Elasticsearch output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](tcp-and-tls.md) section.

## Getting Started

In order to insert records into a Elasticsearch service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **es** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

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
$ fluent-bit -i cpu -t cpu -o es -p Host=192.168.2.3 -p Port=9200 \
    -p Index=my_index -p Type=my_type -o stdout -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections. You can visualize this configuration [here](https://link.calyptia.com/qhq)

```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name  es
    Match *
    Host  192.168.2.3
    Port  9200
    Index my_index
    Type  my_type
```

![example configuration visualization from config.calyptia.com](../../.gitbook/assets/image%20%282%29.png)

## About Elasticsearch field names

Some input plugins may generate messages where the field names contains dots, since Elasticsearch 2.0 this is not longer allowed, so the current **es** plugin replaces them with an underscore, e.g:

```text
{"cpu0.p_cpu"=>17.000000}
```

becomes

```text
{"cpu0_p_cpu"=>17.000000}
```

## FAQ

### Elasticsearch rejects requests saying "the final mapping would have more than 1 type" <a id="faq-multiple-types"></a>

Since Elasticsearch 6.0, you cannot create multiple types in a single index. This means that you cannot set up your configuration as below anymore.

```text
[OUTPUT]
    Name  es
    Match foo.*
    Index search
    Type  type1

[OUTPUT]
    Name  es
    Match bar.*
    Index search
    Type  type2
```

If you see an error message like below, you'll need to fix your configuration to use a single type on each index.

> Rejecting mapping update to \[search\] as the final mapping would have more than 1 type

For details, please read [the official blog post on that issue](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/removal-of-types.html).

### Elasticsearch rejects requests saying "Document mapping type name can't start with '\_'" <a id="faq-underscore"></a>

Fluent Bit v1.5 changed the default mapping type from `flb_type` to `_doc`, which matches the recommendation from Elasticsearch from version 6.2 forwards \([see commit with rationale](https://github.com/fluent/fluent-bit/commit/04ed3d8104ca8a2f491453777ae6e38e5377817e#diff-c9ae115d3acaceac5efb949edbb21196)\). This doesn't work in Elasticsearch versions 5.6 through 6.1 \([see Elasticsearch discussion and fix](https://discuss.elastic.co/t/cant-use-doc-as-type-despite-it-being-declared-the-preferred-method/113837/9)\). Ensure you set an explicit map \(such as `doc` or `flb_type`\) in the configuration, as seen on the last line:

```text
[OUTPUT]
    Name  es
    Match *
    Host  vpc-test-domain-ke7thhzoo7jawsrhmm6mb7ite7y.us-west-2.es.amazonaws.com
    Port  443
    Index my_index
    AWS_Auth On
    AWS_Region us-west-2
    tls   On
    Type  doc
```

### Fluent Bit + Amazon Elasticsearch Service <a id="#aws-es"></a>

The Amazon ElasticSearch Service adds an extra security layer where HTTP requests must be signed with AWS Sigv4. Fluent Bit v1.5 introduced full support for Amazon ElasticSearch Service with IAM Authentication.

Fluent Bit supports sourcing AWS credentials from any of the standard sources \(for example, an [Amazon EKS IAM Role for a Service Account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)\).

Example configuration:

```text
[OUTPUT]
    Name  es
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

### Fluent Bit + Elastic Cloud

Fluent Bit supports connecting to [Elastic Cloud](https://www.elastic.co/guide/en/cloud/current/ec-getting-started.html) providing just the `cloud_id` and the `cloud_auth` settings.

Example configuration:

```text
[OUTPUT]
    Name es
    Include_Tag_Key true
    Tag_Key tags
    tls On
    tls.verify Off
    cloud_id elastic-obs-deployment:ZXVybxxxxxxxxxxxg==
    cloud_auth elastic:2vxxxxxxxxYV
```

