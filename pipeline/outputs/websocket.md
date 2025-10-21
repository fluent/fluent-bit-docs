# WebSocket

The _WebSocket_ output plugin lets you flush your records into a WebSocket endpoint. It issues an HTTP `GET` request to do the handshake, and then uses TCP connections to send the data records in either JSON or [MessagePack](http://msgpack.org) format.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:--- |:------------|:----------|
| `Host` | IP address or hostname of the target WebSocket Server. | `127.0.0.1` |
| `Port` | TCP port of the target WebSocket Server. | `80` |
| `URI` | Specify an optional HTTP URI for the target WebSocket server. For example, `/someuri`. | `/` |
| `Header` | Add a HTTP header key/value pair. Multiple headers can be set.  | _none_ |
| `Format` | Specify the data format to be used in the HTTP request body. Supported formats: `json`, `json_stream`, `json_lines`, `gelf`. | `msgpack` |
| `json_date_key` | Specify the name of the date field in output. | `date` |
| `json_date_format` | Specify the format of the date. Supported formats: `double`, `epoch`, `iso8601`, `java_sql_timestamp`. | `double` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

To insert records into an HTTP server, you can run the plugin from the command line or through the configuration file.

### Command line

The WebSocket plugin can read the parameters from the command line through the `-p` argument (property) or by setting them directly through the service URI. The URI format is the following:

```text
http://host:port/something
```

Using the format specified, you could start Fluent Bit through:

```shell
fluent-bit -i cpu -t cpu -o websocket://192.168.2.3:80/something -m '*'
```

### Configuration file

In your main configuration file, append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: websocket
      match: '*'
      host: 192.168.2.3
      port: 80
      uri: /something
      format: json
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu
  Tag   cpu

[OUTPUT]
  Name   websocket
  Match  *
  Host   192.168.2.3
  Port   80
  URI    /something
  Format json
```

{% endtab %}
{% endtabs %}

For details about how the WebSocket plugin works with TCP keepalive mode, see [networking](https://docs.fluentbit.io/manual/v/master/administration/networking#configuration-options). Because WebSocket is a stateful plugin, it will decide when to send out handshake to server side. For example, when the plugin begins to work or after connection with server has been dropped. In general, the interval to init a new WebSocket handshake would be less than the keepalive interval. With that strategy, it could detect and resume WebSocket connections.

## Tests

### Configuration file example

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tcp
      listen: 0.0.0.0
      port: 5170
      format: json

  outputs:
    - name: websocket
      match: '*'
      host: 127.0.0.1
      port: 8080
      uri: /
      format: json
      workers: 4
      net.keepalive: on
      net.keepalive_idle_timeout: 30
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

When Fluent Bit is running, you can send some messages using `netcat`:

```shell
echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170; sleep 35; echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) you should see the following output:

```shell
fluent-bit   -c ../conf/out_ws.conf

...
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
...
```

### Scenario description

From the output of the Fluent Bit log, you can see that when data has been ingested into Fluent Bit, the plugin performs a handshake. If no data or traffic is ongoing, the TCP connection would be aborted. When additional data arrives, a retry for WebSocket plugin triggers, with another handshake and data flush.

In another scenario, if the WebSocket server goes down and up in a short time, Fluent Bit would resume the TCP connection immediately. But in that case, the WebSocket output plugin is a malfunction state, and needs to restart Fluent Bit to resume working.
