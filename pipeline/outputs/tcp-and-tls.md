# TCP and TLS

The _TCP and TLS_ output plugin lets you send records to a remote TCP server. The payload can be formatted in different ways as required.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `Host` | Target host where Fluent Bit or Fluentd are listening for Forward messages. | `127.0.0.1` |
| `Port` | TCP Port of the target service. | `5170` |
| `Format` | Specify the data format to be printed. Supported formats: `msgpack`, `json`, `json_lines`, `json_stream`. | `msgpack` |
| `json_date_key`| Specify the name of the time key in the output record. To disable the time key, set the value to `false`. | `date` |
| `json_date_format` | Specify the format of the date. Supported formats: `double`, `epoch`, `epoch_ms`, `iso8601`, `java_sql_timestamp`. | `double` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

## TLS configuration parameters

The following parameters are available to configure a secure channel connection through TLS:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `tls` | Enable or disable TLS support. | `Off` |
| `tls.verify` | Force certificate validation. | `On` |
| `tls.debug` | Set TLS debug verbosity level. Allowed values: `0` (No debug), `1` (Error), `2` (State change), `3` (Informational), `4` (Verbose) | `1` |
| `tls.ca_file` | Absolute path to CA certificate file. | _none_ |
| `tls.crt_file`   | Absolute path to Certificate file. | _none_ |
| `tls.key_file`   | Absolute path to private Key file. | _none_ |
| `tls.key_passwd` | Optional password for `tls.key_file` file. | _none_ |

### Command line

#### JSON format

This example specifies gathering [CPU](https://docs.fluentbit.io/manual/pipeline/inputs/cpu-metrics) usage metrics and send them in JSON lines mode to a remote endpoint using netcat service.

```shell
fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=json_lines -v
```


Run the following in a separate terminal, `netcat` will start listening for messages on TCP port `5170`. After it connects to Fluent Bit you should see the output in JSON format:

```shell
nc -l 5170
```

Which returns results similar to:

```text
...
{"date":1644834856.905985,"cpu_p":1.1875,"user_p":0.5625,"system_p":0.625,"cpu0.p_cpu":0.0,"cpu0.p_user":0.0,"cpu0.p_system":0.0,"cpu1.p_cpu":1.0,"cpu1.p_user":1.0,"cpu1.p_system":0.0,"cpu2.p_cpu":4.0,"cpu2.p_user":2.0,"cpu2.p_system":2.0,"cpu3.p_cpu":1.0,"cpu3.p_user":0.0,"cpu3.p_system":1.0,"cpu4.p_cpu":1.0,"cpu4.p_user":0.0,"cpu4.p_system":1.0,"cpu5.p_cpu":1.0,"cpu5.p_user":1.0,"cpu5.p_system":0.0,"cpu6.p_cpu":0.0,"cpu6.p_user":0.0,"cpu6.p_system":0.0,"cpu7.p_cpu":3.0,"cpu7.p_user":1.0,"cpu7.p_system":2.0,"cpu8.p_cpu":0.0,"cpu8.p_user":0.0,"cpu8.p_system":0.0,"cpu9.p_cpu":1.0,"cpu9.p_user":0.0,"cpu9.p_system":1.0,"cpu10.p_cpu":1.0,"cpu10.p_user":0.0,"cpu10.p_system":1.0,"cpu11.p_cpu":0.0,"cpu11.p_user":0.0,"cpu11.p_system":0.0,"cpu12.p_cpu":0.0,"cpu12.p_user":0.0,"cpu12.p_system":0.0,"cpu13.p_cpu":3.0,"cpu13.p_user":2.0,"cpu13.p_system":1.0,"cpu14.p_cpu":1.0,"cpu14.p_user":1.0,"cpu14.p_system":0.0,"cpu15.p_cpu":0.0,"cpu15.p_user":0.0,"cpu15.p_system":0.0}
...
```

#### `msgpack` format

Repeat the JSON approach but using the `msgpack` output format.

```shell
fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=msgpack -v
```

You could send this to stdout but as it's a serialized format you would end up with strange output.

This should be handled by a [`msgpack`](../../development/msgpack-format.md) receiver to unpack. The following example uses the [Python `msgpack` library](https://msgpack.org/#languages) handle it:

```python
#Python3
import socket
import msgpack

unpacker = msgpack.Unpacker(use_list=False, raw=False)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 5170))
s.listen(1)
connection, address = s.accept()

while True:
    data = connection.recv(1024)
    if not data:
        break
    unpacker.feed(data)
    for unpacked in unpacker:
        print(unpacked)
```

Run the following commands:

```shell
 pip install msgpack
 python3 test.py
```

Which return results like:

```text
...
(ExtType(code=0, data=b'b\n5\xc65\x05\x14\xac'), {'cpu_p': 0.1875, 'user_p': 0.125, 'system_p': 0.0625, 'cpu0.p_cpu': 0.0, 'cpu0.p_user': 0.0, 'cpu0.p_system': 0.0, 'cpu1.p_cpu': 0.0, 'cpu1.p_user': 0.0, 'cpu1.p_system': 0.0, 'cpu2.p_cpu': 1.0, 'cpu2.p_user': 0.0, 'cpu2.p_system': 1.0, 'cpu3.p_cpu': 0.0, 'cpu3.p_user': 0.0, 'cpu3.p_system': 0.0, 'cpu4.p_cpu': 0.0, 'cpu4.p_user': 0.0, 'cpu4.p_system': 0.0, 'cpu5.p_cpu': 0.0, 'cpu5.p_user': 0.0, 'cpu5.p_system': 0.0, 'cpu6.p_cpu': 0.0, 'cpu6.p_user': 0.0, 'cpu6.p_system': 0.0, 'cpu7.p_cpu': 0.0, 'cpu7.p_user': 0.0, 'cpu7.p_system': 0.0, 'cpu8.p_cpu': 0.0, 'cpu8.p_user': 0.0, 'cpu8.p_system': 0.0, 'cpu9.p_cpu': 1.0, 'cpu9.p_user': 1.0, 'cpu9.p_system': 0.0, 'cpu10.p_cpu': 0.0, 'cpu10.p_user': 0.0, 'cpu10.p_system': 0.0, 'cpu11.p_cpu': 0.0, 'cpu11.p_user': 0.0, 'cpu11.p_system': 0.0, 'cpu12.p_cpu': 0.0, 'cpu12.p_user': 0.0, 'cpu12.p_system': 0.0, 'cpu13.p_cpu': 0.0, 'cpu13.p_user': 0.0, 'cpu13.p_system': 0.0, 'cpu14.p_cpu': 0.0, 'cpu14.p_user': 0.0, 'cpu14.p_system': 0.0, 'cpu15.p_cpu': 0.0, 'cpu15.p_user': 0.0, 'cpu15.p_system': 0.0})
...
```
