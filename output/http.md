# HTTP

The **http** output plugin, allows to flush your records into an HTTP end point. For now the functionality is pretty basic and it issue a POST request with the data records in [MessagePack](http://msgpack.org) format.

> In future versions the target URI and data format will be configurable.

## Configuration Parameters

| Key         | Description          | default           |
|-------------|----------------------|-------------------|
| Host        | IP address or hostname of the target HTTP Server | 127.0.0.1 |
| HTTP_User   | Basic Auth Username |         |
| HTTP_Passwd | Basic Auth Password. Requires HTTP_User to be set |         |
| Port        | TCP port of the target HTTP Server | 80 |
| Proxy       | Specify an HTTP Proxy. The expected format of this value is _http://host:port_. Note that _https_ is __not__ supported yet. ||
| URI         | Specify an optional HTTP URI for the target web server, e.g: /something  | / |
| Format      | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_. Other supported formats are _json_, _json_stream_ and _json_lines_. | msgpack |
| header_tag | Specify an optional HTTP header field for the original message tag. |         |
| json_date_key | Specify the name of the date field in output | date |
| json_date_format | Specify the format of the date. Supported formats are _double_ and _iso8601_ (eg: _2018-05-30T09:39:52.000681Z_)| double |

### TLS / SSL

HTTP output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../configuration/tls_ssl.md) section.

## Getting Started

In order to insert records into a HTTP server, you can run the plugin from the command line or through the configuration file:

### Command Line

The **http** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

```text
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```text
$ fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something -o stdout -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

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

By default, the URI becomes tag of the message, the original tag is ignore. To retain the tag, multiple configuration sections has to be made based and flush to different URIs.

Another approach we also support is the sending the original message tag in a configurabled header. It's up to the receiver to do what it want with that header field: parse it and use it as the tag for example. With fluend http plugin, it's straightforward.

To configure this behaviour, add this config:

```text
[OUTPUT]
    Name  http
    Match *
    Host  192.168.2.3
    Port  80
    URI   /something
    header_tag  FLUENT-TAG
```

Given the default http input fluentd plugin: [https://github.com/fluent/fluentd/blob/1afbfb17c833b05757122a53ea14b17af659fd75/lib/fluent/plugin/in\_http.rb\#L212-L215](https://github.com/fluent/fluentd/blob/1afbfb17c833b05757122a53ea14b17af659fd75/lib/fluent/plugin/in_http.rb#L212-L215)

We can easily parse the tag like this:

```ruby
@@ -153,6 +153,7 @@ module Fluent::Plugin
       begin
         path = path_info[1..-1]  # remove /
         tag = path.split('/').join('.')
+        tag = params["HTTP_FLUENT_TAG"] if params["HTTP_FLUENT_TAG"]
         record_time, record = parse_params(params)
```

Notice how we override the tag, which is from URI path, with our custom header

