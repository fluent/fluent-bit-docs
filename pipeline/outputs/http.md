# HTTP

The **http** output plugin allows to flush your records into a HTTP endpoint. For now the functionality is pretty basic and it issues a POST request with the data records in [MessagePack](http://msgpack.org) (or JSON) format.

## Configuration Parameters

| Key                        | Description                                                                                                                                                                                                                                                                                                                        | default   |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| host                       | IP address or hostname of the target HTTP Server                                                                                                                                                                                                                                                                                   | 127.0.0.1 |
| http\_User                 | Basic Auth Username                                                                                                                                                                                                                                                                                                                |           |
| http\_Passwd               | Basic Auth Password. Requires HTTP\_User to be set                                                                                                                                                                                                                                                                                 |           |
| AWS\_Auth                  | Enable AWS SigV4 authentication                                                                                                                                                                                                                                                                                                    | false     |
| AWS\_Service               | Specify the AWS service code, i.e. es, xray, etc., of your service, used by SigV4 authentication. Usually can be found in the service endpoint's subdomains, `protocol://service-code.region-code.amazonaws.com`                                                                                                                   |           |
| AWS\_Region                | Specify the AWS region of your service, used by SigV4 authentication                                                                                                                                                                                                                                                               |           |
| AWS\_STS\_Endpoint         | Specify the custom sts endpoint to be used with STS API, used with the AWS_Role_ARN option, used by SigV4 authentication                                                                                                                                                                                                           |           |
| AWS\_Role\_ARN             | AWS IAM Role to assume, used by SigV4 authentication                                                                                                                                                                                                                                                                               |           |
| AWS\_External\_ID          | External ID for the AWS IAM Role specified with `aws_role_arn`, used by SigV4 authentication                                                                                                                                                                                                                                       |           |
| port                       | TCP port of the target HTTP Server                                                                                                                                                                                                                                                                                                 | 80        |
| Proxy                      | Specify an HTTP Proxy. The expected format of this value is `http://HOST:PORT`. Note that HTTPS is **not** currently supported. It is recommended not to set this and to configure the [HTTP proxy environment variables](https://docs.fluentbit.io/manual/administration/http-proxy) instead as they support both HTTP and HTTPS. |           |
| uri                        | Specify an optional HTTP URI for the target web server, e.g: /something                                                                                                                                                                                                                                                            | /         |
| compress                   | Set payload compression mechanism. Option available is 'gzip'                                                                                                                                                                                                                                                                      |           |
| format                     | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_. Other supported formats are _json_, _json\_stream_ and _json\_lines_ and _gelf_.                                                                                                                                                        | msgpack   |
| allow\_duplicated\_headers | Specify if duplicated headers are allowed. If a duplicated header is found, the latest key/value set is preserved.                                                                                                                                                                                                                 | true      |
| log\_response\_payload     | Specify if the response paylod should be logged or not.                                                                                                                                                                                                                                                                            | true      |
| header\_tag                | Specify an optional HTTP header field for the original message tag.                                                                                                                                                                                                                                                                |           |
| header                     | Add a HTTP header key/value pair. Multiple headers can be set.                                                                                                                                                                                                                                                                     |           |
| json\_date\_key            | Specify the name of the time key in the output record. To disable the time key just set the value to `false`.                                                                                                                                                                                                                      | date      |
| json\_date\_format         | Specify the format of the date. Supported formats are _double_, _epoch_, _iso8601_ (eg: _2018-05-30T09:39:52.000681Z_) and _java_sql_timestamp_ (eg: _2018-05-30 09:39:52.000681_)                                                                                                                                                 | double    |
| gelf\_timestamp\_key       | Specify the key to use for `timestamp` in _gelf_ format                                                                                                                                                                                                                                                                            |           |
| gelf\_host\_key            | Specify the key to use for the `host` in _gelf_ format                                                                                                                                                                                                                                                                             |           |
| gelf\_short\_message\_key  | Specify the key to use as the `short` message in _gelf_ format                                                                                                                                                                                                                                                                     |           |
| gelf\_full\_message\_key   | Specify the key to use for the `full` message in _gelf_ format                                                                                                                                                                                                                                                                     |           |
| gelf\_level\_key           | Specify the key to use for the `level` in _gelf_ format                                                                                                                                                                                                                                                                            |           |
| body\_key                  | Specify the key to use as the body of the request (must prefix with "$"). The key must contain either a binary or raw string, and the content type can be specified using headers\_key (which must be passed whenever body\_key is present). When this option is present, each msgpack record will create a separate request.      |           |
| headers\_key               | Specify the key to use as the headers of the request (must prefix with "$"). The key must contain a map, which will have the contents merged on the request headers. This can be used for many purposes, such as specifying the content-type of the data contained in body\_key.                                                   |           |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

### TLS / SSL

The HTTP output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Getting Started

In order to insert records into a HTTP server, you can run the plugin from the command line or through the configuration file:

### Command Line

The **http** plugin, can read the parameters from the command line in two ways, through the **-p** argument (property) or setting them directly through the service URI. The URI format is the following:

```
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```
fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something -m '*'
```

### Configuration File

In your main configuration file, append the following _Input_ & _Output_ sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name  http
    Match *
    Host  192.168.2.3
    Port  80
    URI   /something
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: cpu
          tag:  cpu
    outputs:
        - name: http
          match: '*'
          host: 192.168.2.3
          port: 80
          URI: /something
```
{% endtab %}
{% endtabs %}

By default, the URI becomes tag of the message, the original tag is ignored. To retain the tag, multiple configuration sections have to be made based and flush to different URIs.

Another approach we also support is the sending the original message tag in a configurable header. It's up to the receiver to do what it wants with that header field: parse it and use it as the tag for example.

To configure this behaviour, add this config:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```
[OUTPUT]
    Name  http
    Match *
    Host  192.168.2.3
    Port  80
    URI   /something
    Format json
    header_tag  FLUENT-TAG
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
    outputs:
        - name: http
          match: '*'
          host: 192.168.2.3
          port: 80
          URI: /something
          format: json
          header_tag: FLUENT-TAG
```
{% endtab %}
{% endtabs %}


Provided you are using Fluentd as data receiver, you can combine `in_http` and `out_rewrite_tag_filter` to make use of this HTTP header.

```
<source>
  @type http
  add_http_headers true
</source>

<match something>
  @type rewrite_tag_filter
  <rule>
    key HTTP_FLUENT_TAG
    pattern /^(.*)$/
    tag $1
  </rule>
</match>
```

Notice how we override the tag, which is from URI path, with our custom header

#### Example : Add a header

{% tabs %}
{% tab title="fluent-bit.conf" %}
```
[OUTPUT]
    Name           http
    Match          *
    Host           127.0.0.1
    Port           9000
    Header         X-Key-A Value_A
    Header         X-Key-B Value_B
    URI            /something
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
    outputs:
        - name: http
          match: '*'
          host: 127.0.0.1
          port: 9000
          header:
            - X-Key-A Value_A
            - X-Key-B Value_B
          URI: /something
```
{% endtab %}
{% endtabs %}

#### Example : Sumo Logic HTTP Collector

Suggested configuration for Sumo Logic using `json_lines` with `iso8601` timestamps. The `PrivateKey` is specific to a configured HTTP collector.

{% tabs %}
{% tab title="fluent-bit.conf" %}
```
[OUTPUT]
    Name             http
    Match            *
    Host             collectors.au.sumologic.com
    Port             443
    URI              /receiver/v1/http/[PrivateKey]
    Format           json_lines
    Json_date_key    timestamp
    Json_date_format iso8601
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
    outputs:
        - name: http
          match: '*'
          host: collectors.au.sumologic.com
          port: 443
          URI: /receiver/v1/http/[PrivateKey]
          format: json_lines
          json_date_key: timestamp
          json_date_format: iso8601
```
{% endtab %}
{% endtabs %}

A sample Sumo Logic query for the [CPU](../inputs/cpu-metrics.md) input. \(Requires `json_lines` format with `iso8601` date format for the `timestamp` field\).

```
_sourcecategory="my_fluent_bit"
| json "cpu_p" as cpu
| timeslice 1m
| max(cpu) as cpu group by _timeslice
```
