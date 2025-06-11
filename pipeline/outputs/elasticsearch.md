---
description: Send logs to Elasticsearch (including Amazon OpenSearch Service)
---

# Elasticsearch

The **es** output plugin lets you ingest your records into an
[Elasticsearch](http://www.elastic.co) database. To use this plugin, you must have an
operational Elasticsearch service running in your environment.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `Host` | IP address or hostname of the target Elasticsearch instance | `127.0.0.1` |
| `Port` | TCP port of the target Elasticsearch instance | `9200` |
| `Path` | Elasticsearch accepts new data on HTTP query path `/_bulk`. You can also serve Elasticsearch behind a reverse proxy on a sub-path. Define the path by adding a path prefix in the indexing HTTP POST URI. | Empty string |
| `compress` | Set payload compression mechanism. Option available is `gzip`. | _none_ |
| `Buffer_Size` | Specify the buffer size used to read the response from the Elasticsearch HTTP service. Use for debugging purposes where required to read full responses. Response size grows depending of the number of records inserted. To use an unlimited amount of memory, set this value to `False`. Otherwise set the value according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md). | `512KB` |
| `Pipeline` | Define which pipeline the database should use. For performance reasons, it's strongly suggested to do parsing and filtering on Fluent Bit side, and avoid pipelines. | _none_ |
| `AWS_Auth` | Enable AWS Sigv4 Authentication for Amazon OpenSearch Service. | `Off` |
| `AWS_Region` | Specify the AWS region for Amazon OpenSearch Service. | _none_ |
| `AWS_STS_Endpoint` | Specify the custom STS endpoint to be used with STS API for Amazon OpenSearch Service | _none_ |
| `AWS_Role_ARN` | AWS IAM Role to assume to put records to your Amazon cluster | _none_ |
| `AWS_External_ID` | External ID for the AWS IAM Role specified with `aws_role_arn` | _none_ |
| `AWS_Service_Name` | Service name to use in AWS Sigv4 signature. For integration with Amazon OpenSearch Serverless, set to `aoss`. See [Amazon OpenSearch Serverless](opensearch.md) for more information. | `es` |
| `AWS_Profile` | AWS profile name | `default` |
| `Cloud_ID` | If using Elastic's Elasticsearch Service you can specify the `cloud_id` of the cluster running. The string has the format `<deployment_name>:<base64_info>`. Once decoded, the `base64_info` string has the format `<deployment_region>$<elasticsearch_hostname>$<kibana_hostname>`. | _none_ |
| `Cloud_Auth` | Specify the credentials to use to connect to Elastic's Elasticsearch Service running on Elastic Cloud | _none_ |
| `HTTP_User` | Optional username credential for Elastic X-Pack access | _none_ |
| `HTTP_Passwd` | Password for user defined in `HTTP_User` | _none_ |
| `HTTP_API_Key` | API key for Elastic. If `HTTP_User` or `Cloud_Auth` are defined, this will be ignored  | _none_ |
| `Index` | Index name | `fluent-bit` |
| `Type` | Type name | `_doc` |
| `Logstash_Format` | Enable Logstash format compatibility. This option takes a Boolean value: `True/False`, `On/Off` | `Off` |
| `Logstash_Prefix` | When `Logstash_Format` is enabled, the Index name is composed using a prefix and the date, e.g: If `Logstash_Prefix` is equal to `mydata` your index will become `mydata-YYYY.MM.DD`. The last string appended belongs to the date when the data is being generated. | `logstash` |
| `Logstash_Prefix_Key` | When included: the value of the key in the record will be evaluated as key reference and overrides `Logstash_Prefix` for index generation. If the key/value isn't found in the record then the `Logstash_Prefix` option will act as a fallback. The parameter is expected to be a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md). | _none_ |
| `Logstash_Prefix_Separator` | Set a separator between `Logstash_Prefix` and date.| `-` |
| `Logstash_DateFormat` | Time format based on [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html) to generate the second part of the Index name. | `%Y.%m.%d` |
| `Time_Key` | When `Logstash_Format` is enabled, each record will get a new timestamp field. The `Time_Key` property defines the name of that field. | `@timestamp` |
| `Time_Key_Format` | When `Logstash_Format` is enabled, this property defines the format of the timestamp. | `%Y-%m-%dT%H:%M:%S` |
| `Time_Key_Nanos` | When `Logstash_Format` is enabled, enabling this property sends nanosecond precision timestamps. | `Off` |
| `Include_Tag_Key` | When enabled, it append the Tag name to the record. | `Off` |
| `Tag_Key` | When `Include_Tag_Key` is enabled, this property defines the key name for the tag. | `_flb-key` |
| `Generate_ID` | When enabled, generate `_id` for outgoing records. This prevents duplicate records when retrying ES. | `Off` |
| `Id_Key` | If set, `_id` will be the value of the key from incoming record and `Generate_ID` option is ignored. | _none_ |
| `Write_Operation` | `Write_operation` can be any of: `create`, `index`, `update`, `upsert`. | `create` |
| `Replace_Dots` | When enabled, replace field name dots with underscore. Required by Elasticsearch 2.0-2.3. | `Off` |
| `Trace_Output` | Print all ElasticSearch API request payloads to `stdout` for diagnostics. | `Off` |
| `Trace_Error` | If ElasticSearch returns an error, print the ElasticSearch API request and response for diagnostics. | `Off` |
| `Current_Time_Index` | Use current time for index generation instead of message record. | `Off` |
| `Suppress_Type_Name` | When enabled, mapping types is removed and `Type` option is ignored. Elasticsearch 8.0.0 or higher [no longer supports mapping types](https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html), and is set to `On`. | `Off` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

If you have used a common relational database, the parameters `index` and `type` can
be compared to the `database` and `table` concepts.

### TLS / SSL

The Elasticsearch output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

### `write_operation`

The `write_operation` can be any of:

| Operation   | Description |
| ----------- | ----------- |
| `create`    | Adds new data. If the data already exists (based on its id), the op is skipped.|
| `index`     | New data is added while existing data (based on its id) is replaced (reindexed).|
| `update`    | Updates existing data (based on its id). If no data is found, the op is skipped. |
| `upsert`    | Merge or insert if the data doesn't exist, updates if the data exists (based on its id).|

{% hint style="info" %}

`Id_Key` or `Generate_ID` is required for `update` and `upsert`.

{% endhint %}

## Get started

To insert records into an Elasticsearch service, you run the plugin from the
command line or through the configuration file:

### Command Line

The **es** plugin can read the parameters from the command line in two ways:

- Through the `-p` argument (property).
- Setting them directly through the service URI.

The URI format is the following:

```text
es://host:port/index/type
```

Using the format specified, you could start Fluent Bit through:

```shell copy
fluent-bit -i cpu -t cpu -o es://192.168.2.3:9200/my_index/my_type \
    -o stdout -m '*'
```

Which is similar to the following command:

```shell copy
fluent-bit -i cpu -t cpu -o es -p Host=192.168.2.3 -p Port=9200 \
    -p Index=my_index -p Type=my_type -o stdout -m '*'
```

### Configuration File

In your main configuration file append the following `Input` and `Output` sections.

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

![example configuration visualization from Calyptia](../../.gitbook/assets/image%20%282%29.png)

## About Elasticsearch field names

Some input plugins can generate messages where the field names contains dots. For
Elasticsearch 2.0, this isn't allowed. The current **es** plugin replaces
them with an underscore:

```text
{"cpu0.p_cpu"=>17.000000}
```

becomes

```text
{"cpu0_p_cpu"=>17.000000}
```

## Use Fluent Bit ElasticSearch plugin with other services

Connect to Amazon OpenSearch or Elastic Cloud with the ElasticSearch plugin.

### Amazon OpenSearch Service

The Amazon OpenSearch Service adds an extra security layer where HTTP requests must
be signed with AWS Sigv4. Fluent Bit v1.5 introduced full support for Amazon
OpenSearch Service with IAM Authentication.

See [details](https://github.com/fluent/fluent-bit-docs/tree/43c4fe134611da471e706b0edb2f9acd7cdfdbc3/administration/aws-credentials.md) on how AWS credentials are fetched.

Example configuration:

```text copy
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

Be aware that the `Port` is set to `443`, `tls` is enabled, and `AWS_Region` is set.

### Use Fluent Bit with Elastic Cloud

Fluent Bit supports connecting to
[Elastic Cloud](https://www.elastic.co/guide/en/cloud/current/ec-getting-started.html)
by providing the `cloud_id` and the `cloud_auth` settings. `cloud_auth` uses the
`elastic` user and password provided when the cluster was created. For details refer
to the
[Cloud ID usage page](https://www.elastic.co/guide/en/cloud/current/ec-cloud-id.html).

Example configuration:

```text copy
[OUTPUT]
    Name es
    Include_Tag_Key true
    Tag_Key tags
    tls On
    tls.verify Off
    Suppress_Type_Name On
    cloud_id elastic-obs-deployment:ZXVybxxxxxxxxxxxg==
    cloud_auth elastic:2vxxxxxxxxYV
```

In Elastic Cloud version 8 and great, the type option must be removed by setting
`Suppress_Type_Name On`.

Without this you will see errors like:

```text
{"error":{"root_cause":[{"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"}],"type":"illegal_argument_exception","reason":"Action/metadata line [1] contains an unknown parameter [_type]"},"status":400}
```

## Troubleshooting

Use the following information to help resolve errors using the ElasticSearch plugin.

### Using multiple types in a single index

Elasticsearch 6.0 can't create multiple types in a single index. An error message
like the following indicates you need to update your configuration to use a single
type on each index.

```text
Rejecting mapping update to [products] as the final mapping would have more than 1 type:
```

This means that you can't set up your configuration like the following:.

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

For details, read [the official blog post on that issue](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/removal-of-types.html).

### Mapping type names can't start with underscores (`_`)

Fluent Bit v1.5 changed the default mapping type from `flb_type` to `_doc`, matching
the recommendation from Elasticsearch for version 6.2 and greater
([see commit with
rationale](https://github.com/fluent/fluent-bit/commit/04ed3d8104ca8a2f491453777ae6e38e5377817e#diff-c9ae115d3acaceac5efb949edbb21196)).

This doesn't work in Elasticsearch versions 5.6 through 6.1
([discussion and fix](https://discuss.elastic.co/t/cant-use-doc-as-type-despite-it-being-declared-the-preferred-method/113837/9)).

Ensure you set an explicit map such as `doc` or `flb_type` in the configuration,
as seen on the last line:

```text copy
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

### Validation failures

In Fluent Bit v1.8.2 and greater, Fluent Bit started using `create` method (instead
of `index`) for data submission. This makes Fluent Bit compatible with Datastream,
introduced in Elasticsearch 7.9. You might see errors like:

```text
Validation Failed: 1: an id must be provided if version type or value are set
```

If you see `action_request_validation_exception` errors on your pipeline with
Fluent Bit versions greater than v1.8.2, correct them  by turning on `Generate_ID`
as follows:

```text copy
[OUTPUT]
    Name es
    Match *
    Host  192.168.12.1
    Generate_ID on
```

### `Logstash_Prefix_Key`

The following snippet demonstrates using the namespace name as extracted by the
`kubernetes` filter as `logstash` prefix:

```text
[OUTPUT]
    Name es
    Match *
    # ...
    Logstash_Prefix logstash
    Logstash_Prefix_Key $kubernetes['namespace_name']
    # ...
```

For records that don't have the field `kubernetes.namespace_name`, the default prefix
`logstash` will be used.
