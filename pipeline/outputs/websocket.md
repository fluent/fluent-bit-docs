# WebSocket

The **websocket** output plugin allows to flush your records into a WebSocket endpoint. For now the functionality is pretty basic and it issues a HTTP GET request to do the handshake, and then use TCP connections to send the data records in either JSON or [MessagePack](http://msgpack.org) \(or JSON\) format.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target WebSocket Server | 127.0.0.1 |
| Port | TCP port of the target WebSocket Server | 80 |
| URI | Specify an optional HTTP URI for the target websocket server, e.g: /something | / |
| Header | Add a HTTP header key/value pair. Multiple headers can be set. | |
| Format | Specify the data format to be used in the HTTP request body, by default it uses _msgpack_. Other supported formats are _json_, _json\_stream_ and _json\_lines_ and _gelf_. | msgpack |
| json\_date\_key | Specify the name of the date field in output | date |
| json\_date\_format | Specify the format of the date. Supported formats are _double_, _epoch_, _iso8601_ (eg: _2018-05-30T09:39:52.000681Z_) and _java_sql_timestamp_ (eg: _2018-05-30 09:39:52.000681_) | double |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

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
```

Websocket plugin is working with tcp keepalive mode, please refer to [networking](https://docs.fluentbit.io/manual/v/master/administration/networking#configuration-options) section for details. Since websocket is a stateful plugin, it will decide when to send out handshake to server side, for example when plugin just begins to work or after connection with server has been dropped. In general, the interval to init a new websocket handshake would be less than the keepalive interval. With that strategy, it could detect and resume websocket connections.


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
    Port           8080
    URI            /
    Format         json
    workers	   4
    net.keepalive               on
    net.keepalive_idle_timeout  30
```

Once Fluent Bit is running, you can send some messages using the _netcat_:

```bash
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170; sleep 35; echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
bin/fluent-bit   -c ../conf/out_ws.conf
Fluent Bit v1.7.0
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2021/02/05 22:17:09] [ info] [engine] started (pid=6056)
[2021/02/05 22:17:09] [ info] [storage] version=1.1.0, initializing...
[2021/02/05 22:17:09] [ info] [storage] in-memory
[2021/02/05 22:17:09] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/02/05 22:17:09] [ info] [input:tcp:tcp.0] listening on 0.0.0.0:5170
[2021/02/05 22:17:09] [ info] [out_ws] we have following parameter /, 127.0.0.1, 8080, 25
[2021/02/05 22:17:09] [ info] [output:websocket:websocket.0] worker #1 started
[2021/02/05 22:17:09] [ info] [output:websocket:websocket.0] worker #0 started
[2021/02/05 22:17:09] [ info] [sp] stream processor started
[2021/02/05 22:17:09] [ info] [output:websocket:websocket.0] worker #3 started
[2021/02/05 22:17:09] [ info] [output:websocket:websocket.0] worker #2 started
[2021/02/05 22:17:33] [ info] [out_ws] handshake for ws
[2021/02/05 22:18:08] [ warn] [engine] failed to flush chunk '6056-1612534687.673438119.flb', retry in 7 seconds: task_id=0, input=tcp.0 > output=websocket.0 (out_id=0)
[2021/02/05 22:18:15] [ info] [out_ws] handshake for ws
^C[2021/02/05 22:18:23] [engine] caught signal (SIGINT)
[2021/02/05 22:18:23] [ warn] [engine] service will stop in 5 seconds
[2021/02/05 22:18:27] [ info] [engine] service stopped
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #0 stopping...
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #0 stopped
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #1 stopping...
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #1 stopped
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #2 stopping...
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #2 stopped
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #3 stopping...
[2021/02/05 22:18:27] [ info] [output:websocket:websocket.0] thread worker #3 stopped
[2021/02/05 22:18:27] [ info] [out_ws] flb_ws_conf_destroy
```

### Scenario Description

From the output of fluent-bit log, we see that once data has been ingested into fluent bit, plugin would perform handshake. After a while, no data or traffic is undergoing, tcp connection would been abort. And then another piece of data arrived, a retry for websocket plugin has been triggered, with another handshake and data flush.

There is another scenario, once websocket server flaps in a short time, which means it goes down and up in a short time, fluent-bit would resume tcp connection immediately. But in that case, websocket output plugin is a malfunction state, it needs to restart fluent-bit to get back to work.
