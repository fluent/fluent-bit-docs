# UDP

The **udp** input plugin allows to retrieve structured JSON or raw messages over a UDP network interface (UDP port).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description                                                                                                                                                                                                                                                    | Default |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Listen       | Listener network interface.                                                                                                                                                                                                                                    | 0.0.0.0 |
| Port         | UDP port where listening for connections                                                                                                                                                                                                                       | 5170    |
| Buffer\_Size | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default size will be the value of _Chunk\_Size_.                                                                                                                              |         |
| Chunk\_Size  | By default the buffer to store the incoming JSON messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Chunk\_Size_ in KB. If not set, _Chunk\_Size_ is equal to 32 (32KB). | 32      |
| Format       | Specify the expected payload format. It support the options _json_ and _none_. When using _json_, it expects JSON maps, when is set to _none_, it will split every record using the defined _Separator_ (option below).                                        | json    |
| Separator    | When the expected _Format_ is set to _none_, Fluent Bit needs a separator string to split the records. By default it uses the breakline character  (LF or 0x10).                                                                                               |         |
| Source\_Address\_Key| Specify the key where the source address will be injected.                                                                                                                                                                                              |         |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Getting Started

In order to receive JSON messages over UDP, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit listen for _JSON_ messages with the following options:

```bash
$ fluent-bit -i udp -o stdout
```

By default the service will listen an all interfaces (0.0.0.0) through UDP port 5170, optionally you can change this directly, e.g:

```bash
$ fluent-bit -i udp -pport=9090 -o stdout
```

In the example the JSON messages will only arrive through network interface under 192.168.3.2 address and UDP Port 9090.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name        udp
    Listen      0.0.0.0
    Port        5170
    Chunk_Size  32
    Buffer_Size 64
    Format      json

[OUTPUT]
    Name        stdout
    Match       *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: udp
          listen: 0.0.0.0
          port: 5170
          chunk_size: 32
          buffer_size: 64
          format: json
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you can send some messages using the _netcat_:

```bash
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc -u 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -i udp -o stdout -f 1
Fluent Bit v2.x.x
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2023/07/21 13:01:03] [ info] [fluent bit] version=2.1.7, commit=2474ccc759, pid=9677
[2023/07/21 13:01:03] [ info] [storage] ver=1.2.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/07/21 13:01:03] [ info] [cmetrics] version=0.6.3
[2023/07/21 13:01:03] [ info] [ctraces ] version=0.3.1
[2023/07/21 13:01:03] [ info] [input:udp:udp.0] initializing
[2023/07/21 13:01:03] [ info] [input:udp:udp.0] storage_strategy='memory' (memory only)
[2023/07/21 13:01:03] [ info] [output:stdout:stdout.0] worker #0 started
[2023/07/21 13:01:03] [ info] [sp] stream processor started
[0] udp.0: [[1689912069.078189000, {}], {"key 1"=>123456789, "key 2"=>"abcdefg"}]
```

## Performance Considerations

When receiving payloads in JSON format, there are high performance penalties. Parsing JSON is a very expensive task so you could expect your CPU usage increase under high load environments.

To get faster data ingestion, consider to use the option `Format none` to avoid JSON parsing if not needed.
