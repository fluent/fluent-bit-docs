# HTTP

The **http** output plugin allows to flush your records into a HTTP endpoint. For now the functionality is pretty basic and it issues a POST request with the data records in [MessagePack](http://msgpack.org) \(or JSON\) format.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| host | IP address or hostname of the target HTTP Server | 127.0.0.1 |
| http\_User | Basic Auth Username |  |
| http\_Passwd | Basic Auth Password. Requires HTTP\_User to be set |  |
| port | TCP port of the target HTTP Server | 80 |
| Proxy | Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host:port). Note that _https_ is **not** supported yet. Please consider not setting this and use `HTTP_PROXY` environment variable instead, which supports both http and https. |  |
| uri | Specify an optional HTTP URI for the target web server, e.g: /something | / |
| compress | Set payload compression mechanism. Option available is 'gzip' |  |
| format | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_. Other supported formats are _json_, _json\_stream_ and _json\_lines_ and _gelf_. | msgpack |
| allow\_duplicated\_headers | Specify if duplicated headers are allowed. If a duplicated header is found, the latest key/value set is preserved. | true |
| log\_response\_payload | Specify if the response paylod should be logged or not. | true |
| header\_tag | Specify an optional HTTP header field for the original message tag. |  |
| header | Add a HTTP header key/value pair. Multiple headers can be set. |  |
| json\_date\_key | Specify the name of the time key in the output record. To disable the time key just set the value to `false`. | date |
| json\_date\_format | Specify the format of the date. Supported formats are _double_, _epoch_ and _iso8601_ \(eg: _2018-05-30T09:39:52.000681Z_\) | double |
| gelf\_timestamp\_key | Specify the key to use for `timestamp` in _gelf_ format |  |
| gelf\_host\_key | Specify the key to use for the `host` in _gelf_ format |  |
| gelf\_short\_message\_key | Specify the key to use as the `short` message in _gelf_ format |  |
| gelf\_full\_message\_key | Specify the key to use for the `full` message in _gelf_ format |  |
| gelf\_level\_key | Specify the key to use for the `level` in _gelf_ format |  |

### TLS / SSL

HTTP output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](tcp-and-tls.md) section.

## Getting Started

In order to insert records into a HTTP server, you can run the plugin from the command line or through the configuration file:

### Command Line

The **http** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

```text
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```text
$ fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something -m '*'
```

### Configuration File

In your main configuration file, append the following _Input_ & _Output_ sections:

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

By default, the URI becomes tag of the message, the original tag is ignored. To retain the tag, multiple configuration sections have to be made based and flush to different URIs.

Another approach we also support is the sending the original message tag in a configurable header. It's up to the receiver to do what it wants with that header field: parse it and use it as the tag for example.

To configure this behaviour, add this config:

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

Notice how we override the tag, which is from URI path, with our custom header

#### Example : Add a header

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

#### Example : Sumo Logic HTTP Collector

Suggested configuration for Sumo Logic using `json_lines` with `iso8601` timestamps. The `PrivateKey` is specific to a configured HTTP collector.

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

A sample Sumo Logic query for the [CPU](https://github.com/fluent/fluent-bit-docs/tree/16f30161dc4c79d407cd9c586a0c6839d0969d97/pipeline/input/cpu.md) input. \(Requires `json_lines` format with `iso8601` date format for the `timestamp` field\).

```text
_sourcecategory="my_fluent_bit"
| json "cpu_p" as cpu
| timeslice 1m
| max(cpu) as cpu group by _timeslice
```

