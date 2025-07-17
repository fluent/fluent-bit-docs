# HTTP

The _HTTP_ output plugin lets you flush your records into an HTTP endpoint. It issues a POST request with the data records in [MessagePack](http://msgpack.org) (or JSON) format.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | -------- |
| `host` | IP address or hostname of the target HTTP Server | `127.0.0.1` |
| `http_User` | Basic Auth username | _none_ |
| `http_Passwd` | Basic Auth password. Requires `HTTP_User` to be set. | _none_ |
| `AWS_Auth` | Enable AWS SigV4 authentication. | `false` |
| `AWS_Service` | Specify the AWS service code of your service, used by SigV4 authentication (for example, `es`, `xray`.) Usually found in the service endpoint's subdomains, `protocol://service-code.region-code.amazonaws.com`. | _none_ |
| `AWS_Region` | Specify the AWS region of your service, used by SigV4 authentication. | _none_ |
| `AWS_STS_Endpoint` | Specify the custom STS endpoint to be used by STS API. Used with the `AWS_Role_ARN option` and by SigV4 authentication. | _none_ |
| `AWS_Role_ARN` | AWS IAM Role to assume, used by SigV4 authentication. | _none_ |
| `AWS_External_ID` | External ID for the AWS IAM Role specified with `aws_role_arn`, used by SigV4 authentication. | _none_ |
| `port` | TCP port of the target HTTP Server. | `80` |
| `Proxy` | Specify an HTTP Proxy. The expected format of this value is `http://HOST:PORT`. HTTPS isn't supported. It's recommended to configure the [HTTP proxy environment variables](https://docs.fluentbit.io/manual/administration/http-proxy) instead as they support both HTTP and HTTPS. | _none_ |
| `uri` | Specify an optional HTTP URI for the target web server. For example, `/somepath`. | `/` |
| `compress` | Set payload compression mechanism. Allowed value: `gzip`. | _none_ |
| `format` | Specify the data format to be used in the HTTP request body. Supported formats: `gelf`, `json`, `json_stream`, `json_lines`, `msgpack`. | `msgpack` |
| `allow_duplicated_headers` | Specify if duplicated headers are allowed. If a duplicated header is found, the latest key/value set is preserved. | `true` |
| `log_response_payload` | Specify if the response payload should be logged or not. | `true` |
| `header_tag` | Specify an optional HTTP header field for the original message tag. | _none_ |
| `header` | Add a HTTP header key/value pair. Multiple headers can be set. | _none_ |
| `json_date_key` | Specify the name of the time key in the output record. To disable the time key, set the value to `false`. | `date` |
| `json_date_format` | Specify the format of the date. Supported formats: `double`, `epoch`, `iso8601`, `java_sql_timestamp`. | `double` |
| `gelf_timestamp_key` | Specify the key to use for `timestamp` in `gelf` format. | _none_ |
| `gelf_host_key` | Specify the key to use for the `host` in `gelf` format. | _none_ |
| `gelf_short_message_key` | Specify the key to use as the `short` message in `gelf` format. | _none_ |
| `gelf_full_message_key` | Specify the key to use for the `full` message in `gelf` format. | _none_ |
| `gelf_level_key` | Specify the key to use for the `level` in `gelf` format. | _none_ |
| `body_key` | Specify the key to use as the body of the request (must prefix with `$`). The key must contain either a binary or raw string, and the content type can be specified using `headers_key`, which must be passed whenever `body_key` is present. When this option is present, each `msgpack` record will create a separate request. | _none_ |
| `headers_key` | Specify the key to use as the headers of the request (must prefix with `$`). The key must contain a map, which will have the contents merged on the request headers. This can be used for many purposes, such as specifying the content type of the data contained in `body_key`.| _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

### TLS / SSL

The HTTP output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To insert records into an HTTP server, you can run the plugin from the command line or through the configuration file.

### Command line

The HTTP plugin can read the parameters from the command line through the `-p` argument (property) or setting them directly through the service URI. The URI format is the following:

```text
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```shell
fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something -m '*'
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
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
      uri: /something
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

By default, the URI becomes tag of the message, the original tag is ignored. To retain the tag, multiple configuration sections have to be made based and flush to more than one URI.

Another supported approach is the sending the original message tag in a configurable header. It's up to the receiver to do what it wants with that header field. For example, parse it and use it as the tag for example.

To configure this behaviour, add this configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: http
      match: '*'
      host: 192.168.2.3
      port: 80
      uri: /something
      format: json
      header_tag: FLUENT-TAG
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}


Provided you are using Fluentd as data receiver, you can combine `in_http` and `out_rewrite_tag_filter` to make use of this HTTP header.

```text
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

Fluent Bit overrides the tag, which is from URI path, with a custom header.

#### Add a header

This example adds a header.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: http
      match: '*'
      host: 127.0.0.1
      port: 9000
      header:
        - X-Key-A Value_A
        - X-Key-B Value_B
      uri: /something
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

#### Sumo Logic HTTP collector

The following is a suggested configuration for Sumo Logic using `json_lines` with `iso8601` timestamps. The `PrivateKey` is specific to a configured HTTP collector.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: http
      match: '*'
      host: collectors.au.sumologic.com
      port: 443
      uri: /receiver/v1/http/[PrivateKey]
      format: json_lines
      json_date_key: timestamp
      json_date_format: iso8601
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

A sample Sumo Logic query for the [CPU](../inputs/cpu-metrics.md) input. \(Requires `json_lines` format with `iso8601` date format for the `timestamp` field\).

```text
_sourcecategory="my_fluent_bit"
| json "cpu_p" as cpu
| timeslice 1m
| max(cpu) as cpu group by _timeslice
```
