# TCP & TLS

The **tcp** output plugin allows to send records to a remote TCP server. The payload can be formatted in different ways as required.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | Target host where Fluent-Bit or Fluentd are listening for Forward messages. | 127.0.0.1 |
| Port | TCP Port of the target service. | 5170 |
| Format | Specify the data format to be printed. Supported formats are _msgpack_ _json_, _json\_lines_ and _json\_stream_. | msgpack |
| json\_date\_key | Specify the name of the time key in the output record. To disable the time key just set the value to `false`. | date |
| json\_date\_format | Specify the format of the date. Supported formats are _double_, _epoch_, _iso8601_ (eg: _2018-05-30T09:39:52.000681Z_) and _java_sql_timestamp_ (eg: _2018-05-30 09:39:52.000681_) | double |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

## TLS Configuration Parameters

The following parameters are available to configure a secure channel connection through TLS:

| Key | Description | Default |
| :--- | :--- | :--- |
| tls | Enable or disable TLS support | Off |
| tls.verify | Force certificate validation | On |
| tls.debug | Set TLS debug verbosity level. It accept the following values: 0 \(No debug\), 1 \(Error\), 2 \(State change\), 3 \(Informational\) and 4 Verbose | 1 |
| tls.ca\_file | Absolute path to CA certificate file |  |
| tls.crt\_file | Absolute path to Certificate file. |  |
| tls.key\_file | Absolute path to private Key file. |  |
| tls.key\_passwd | Optional password for tls.key\_file file. |  |

### Command Line

#### JSON format

```bash
$ bin/fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=json_lines -v
```

We have specified to gather [CPU](https://github.com/fluent/fluent-bit-docs/tree/16f30161dc4c79d407cd9c586a0c6839d0969d97/pipeline/input/cpu.md) usage metrics and send them in JSON lines mode to a remote end-point using netcat service.

Run the following in a separate terminal, `netcat` will start listening for messages on TCP port 5170.
Once it connects to Fluent Bit ou should see the output as above in JSON format:

```bash
$ nc -l 5170
{"date":1644834856.905985,"cpu_p":1.1875,"user_p":0.5625,"system_p":0.625,"cpu0.p_cpu":0.0,"cpu0.p_user":0.0,"cpu0.p_system":0.0,"cpu1.p_cpu":1.0,"cpu1.p_user":1.0,"cpu1.p_system":0.0,"cpu2.p_cpu":4.0,"cpu2.p_user":2.0,"cpu2.p_system":2.0,"cpu3.p_cpu":1.0,"cpu3.p_user":0.0,"cpu3.p_system":1.0,"cpu4.p_cpu":1.0,"cpu4.p_user":0.0,"cpu4.p_system":1.0,"cpu5.p_cpu":1.0,"cpu5.p_user":1.0,"cpu5.p_system":0.0,"cpu6.p_cpu":0.0,"cpu6.p_user":0.0,"cpu6.p_system":0.0,"cpu7.p_cpu":3.0,"cpu7.p_user":1.0,"cpu7.p_system":2.0,"cpu8.p_cpu":0.0,"cpu8.p_user":0.0,"cpu8.p_system":0.0,"cpu9.p_cpu":1.0,"cpu9.p_user":0.0,"cpu9.p_system":1.0,"cpu10.p_cpu":1.0,"cpu10.p_user":0.0,"cpu10.p_system":1.0,"cpu11.p_cpu":0.0,"cpu11.p_user":0.0,"cpu11.p_system":0.0,"cpu12.p_cpu":0.0,"cpu12.p_user":0.0,"cpu12.p_system":0.0,"cpu13.p_cpu":3.0,"cpu13.p_user":2.0,"cpu13.p_system":1.0,"cpu14.p_cpu":1.0,"cpu14.p_user":1.0,"cpu14.p_system":0.0,"cpu15.p_cpu":0.0,"cpu15.p_user":0.0,"cpu15.p_system":0.0}
```

#### Msgpack format

Repeat the JSON approach but using the `msgpack` output format.

```bash
$ bin/fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=msgpack -v

```

We could send this to stdout but as it is a serialized format you would end up with strange output.
This should really be handled by a msgpack receiver to unpack as per the details in the developer documentation [here](../../development/msgpack-format.md).
As an example we use the [Python msgpack library](https://msgpack.org/#languages) to deal with it:

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

```bash
$ pip install msgpack
$ python3 test.py
(ExtType(code=0, data=b'b\n5\xc65\x05\x14\xac'), {'cpu_p': 0.1875, 'user_p': 0.125, 'system_p': 0.0625, 'cpu0.p_cpu': 0.0, 'cpu0.p_user': 0.0, 'cpu0.p_system': 0.0, 'cpu1.p_cpu': 0.0, 'cpu1.p_user': 0.0, 'cpu1.p_system': 0.0, 'cpu2.p_cpu': 1.0, 'cpu2.p_user': 0.0, 'cpu2.p_system': 1.0, 'cpu3.p_cpu': 0.0, 'cpu3.p_user': 0.0, 'cpu3.p_system': 0.0, 'cpu4.p_cpu': 0.0, 'cpu4.p_user': 0.0, 'cpu4.p_system': 0.0, 'cpu5.p_cpu': 0.0, 'cpu5.p_user': 0.0, 'cpu5.p_system': 0.0, 'cpu6.p_cpu': 0.0, 'cpu6.p_user': 0.0, 'cpu6.p_system': 0.0, 'cpu7.p_cpu': 0.0, 'cpu7.p_user': 0.0, 'cpu7.p_system': 0.0, 'cpu8.p_cpu': 0.0, 'cpu8.p_user': 0.0, 'cpu8.p_system': 0.0, 'cpu9.p_cpu': 1.0, 'cpu9.p_user': 1.0, 'cpu9.p_system': 0.0, 'cpu10.p_cpu': 0.0, 'cpu10.p_user': 0.0, 'cpu10.p_system': 0.0, 'cpu11.p_cpu': 0.0, 'cpu11.p_user': 0.0, 'cpu11.p_system': 0.0, 'cpu12.p_cpu': 0.0, 'cpu12.p_user': 0.0, 'cpu12.p_system': 0.0, 'cpu13.p_cpu': 0.0, 'cpu13.p_user': 0.0, 'cpu13.p_system': 0.0, 'cpu14.p_cpu': 0.0, 'cpu14.p_user': 0.0, 'cpu14.p_system': 0.0, 'cpu15.p_cpu': 0.0, 'cpu15.p_user': 0.0, 'cpu15.p_system': 0.0})

```
