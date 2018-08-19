# HTTP

The **http** output plugin, allows to flush your records into an HTTP end point. For now the functionality is pretty basic and it issue a POST request with the data records in [MessagePack](http://msgpack.org) format.

> In future versions the target URI and data format will be configurable.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target HTTP Server | 127.0.0.1 |
| Port | TCP port of the target HTTP Server | 80 |
| Proxy | Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host:port). Note that _https_ is **not** supported yet. |  |
| URI | Specify an optional HTTP URI for the target web server, e.g: /something | / |
| Format | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_, optionally it can be set to _json_. | msgpack |

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

