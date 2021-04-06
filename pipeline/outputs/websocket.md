# WebSocket

The **websocket** output plugin allows to flush your records into a WebSocket endpoint. For now the functionality is pretty basic and it issues a HTTP GET request to do the handshake, and then use TCP connections to send the data records in either JSON or [MessagePack](http://msgpack.org) \(or JSON\) format.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target WebScoket Server | 127.0.0.1 |
| Port | TCP port of the target WebScoket Server | 80 |
| URI | Specify an optional HTTP URI for the target websocket server, e.g: /something | / |
| Format | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_. Other supported formats are _json_, _json\_stream_ and _json\_lines_ and _gelf_. | msgpack |
| json\_date\_key | Specify the name of the date field in output | date |
| json\_date\_format | Specify the format of the date. Supported formats are _double_ and _iso8601_ \(eg: _2018-05-30T09:39:52.000681Z_\) | double |
| idle\_interval | The interval that websocket output plugin would keep to decide if it is OK to reconnect to Websocket Server | 20 |

## Getting Started

In order to insert records into a HTTP server, you can run the plugin from the command line or through the configuration file:

### Command Line

The **websocket** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

```text
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```text
$ fluent-bit -i cpu -t cpu -o websocket://192.168.2.3:80/something -m '*'
```

### Configuration File

In your main configuration file, append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name  websocket
    Match *
    Host  192.168.2.3
    Port  80
    URI   /something
    Format json
    Idle_interval 21
```

Suggested configuration for Idle Interval is 20. Websocket plugin is working with tcp keepalive mode, please refer to [networking](https://docs.fluentbit.io/manual/v/master/administration/networking#configuration-options) section for details.

By default, if there is no traffic for about 30 seconds, fluent-bit would abort the tcp connection. As a result, if websocket would like to send data to the same server again, it has to reconnect. This parameter is to help to determine if websocket need to reconnect or not.

## Testing

### Configuration File

```text
[INPUT]
    Name        tcp
    Listen      0.0.0.0
    Port        5170
    Format      json
[OUTPUT]
    Name           websocket
    Match          *
    Host           127.0.0.1
    Port           9000
    URI            /
    Format         json
    Idle_interval  21
```

Once Fluent Bit is running, you can send some messages using the _netcat_:

```bash
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170; sleep 35; echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
bin/fluent-bit -c ../conf/out_ws.conf
Fluent Bit v1.5.0
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2020/07/07 03:39:31] [ info] [storage] version=1.0.4, initializing...
[2020/07/07 03:39:31] [ info] [storage] in-memory
[2020/07/07 03:39:31] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2020/07/07 03:39:31] [ info] [engine] started (pid=12734)
[2020/07/07 03:39:31] [ info] [input:tcp:tcp.0] listening on 0.0.0.0:5170
[2020/07/07 03:39:31] [ info] [out_ws] we have following parameter /, 127.0.0.1, 9000, 22
[2020/07/07 03:39:31] [ info] [sp] stream processor started
[2020/07/07 03:39:36] [ info] [out_ws] handshake for ws
[2020/07/07 03:40:11] [ warn] [engine] failed to flush chunk '12734-1594107609.72852130.flb', retry in 6 seconds: task_id=0, input=tcp.0 > output=websocket.0
[2020/07/07 03:40:17] [ info] [out_ws] handshake for ws
[2020/07/07 03:40:17] [ info] [engine] flush chunk '12734-1594107609.72852130.flb' succeeded at retry 1: task_id=1, input=tcp.0 > output=websocket.0
```

### Scenario Description

From the output of fluent-bit log, we see that once data has been ingested into fluent bit, plugin would perform handshake. After a while, no data or traffic is undergoing, tcp connection has been abort. And then another piece of data arrived, a try fro websocket plugin has been triggered, following with another handshake and data flush.

