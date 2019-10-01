# Elasticsearch

The **es** output plugin, allows to flush your records into a [Elasticsearch](http://www.elastic.co) database. The following instructions assumes that you have a fully operational Elasticsearch service running in your environment.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target Elasticsearch instance | 127.0.0.1 |
| Port | TCP port of the target Elasticsearch instance | 9200 |
| Path | Elasticsearch accepts new data on HTTP query path "/\_bulk". But it is also possible to serve Elasticsearch behind a reverse proxy on a subpath. This option defines such path on the fluent-bit side. It simply adds a path prefix in the indexing HTTP POST URI. | Empty string |
| Buffer\_Size | Specify the buffer size used to read the response from the Elasticsearch HTTP service. This option is useful for debugging purposes where is required to read full responses, note that response size grows depending of the number of records inserted. To set an _unlimited_ amount of memory set this value to **False**, otherwise the value must be according to the [Unit Size](../configuration/unit_sizes.md) specification. | 4KB |
| Pipeline | Newer versions of Elasticsearch allows to setup filters called pipelines. This option allows to define which pipeline the database should use. For performance reasons is strongly suggested to do parsing and filtering on Fluent Bit side, avoid pipelines. |  |
| HTTP\_User | Optional username credential for Elastic X-Pack access |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User |  |
| Index | Index name | fluentbit |
| Type | Type name | flb\_type |
| Logstash\_Format | Enable Logstash format compatibility. This option takes a boolean value: True/False, On/Off | Off |
| Logstash\_Prefix | When Logstash\_Format is enabled, the Index name is composed using a prefix and the date, e.g: If Logstash\_Prefix is equals to 'mydata' your index will become 'mydata-YYYY.MM.DD'. The last string appended belongs to the date when the data is being generated. | logstash |
| Logstash\_DateFormat | Time format \(based on [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html)\) to generate the second part of the Index name. | %Y.%m.%d |
| Time\_Key | When Logstash\_Format is enabled, each record will get a new timestamp field. The Time\_Key property defines the name of that field. | @timestamp |
| Time\_Key\_Format | When Logstash\_Format is enabled, this property defines the format of the timestamp. | %Y-%m-%dT%H:%M:%S |
| Include\_Tag\_Key | When enabled, it append the Tag name to the record. | Off |
| Tag\_Key | When Include\_Tag\_Key is enabled, this property defines the key name for the tag. | \_flb-key |
| Generate\_ID | When enabled, generate `_id` for outgoing records. This prevents duplicate records when retrying ES. | Off |
| Replace\_Dots | When enabled, replace field name dots with underscore, required by Elasticsearch 2.0-2.3. | Off |
| Trace\_Output | When enabled print the elasticsearch API calls to stdout \(for diag only\) | Off |
| Current\_Time\_Index | Use current time for index generation instead of message record | Off |
| Logstash\_Prefix\_Key | Prefix keys with this string |  |

> The parameters _index_ and _type_ can be confusing if you are new to Elastic, if you have used a common relational database before, they can be compared to the _database_ and _table_ concepts. Also see [the FAQ below](elasticsearch.md#faq-multiple-types)

### TLS / SSL

Elasticsearch output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../configuration/tls_ssl.md) section.

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

In your main configuration file append the following _Input_ & _Output_ sections:

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

