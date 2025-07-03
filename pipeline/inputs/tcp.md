# TCP

The **tcp** input plugin allows to retrieve structured JSON or raw messages over a TCP network interface (TCP port).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description | Default |
| ------------ | ----------- | ------- |
| Listen       | Listener network interface.                                                                                                                                                                                                                                    | 0.0.0.0 |
| Port         | TCP port where listening for connections                                                                                                                                                                                                                       | 5170    |
| Buffer\_Size | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default size will be the value of _Chunk\_Size_.                                                                                                                              |         |
| Chunk\_Size  | By default the buffer to store the incoming JSON messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Chunk\_Size_ in KB. If not set, _Chunk\_Size_ is equal to 32 (32KB). | 32      |
| Format       | Specify the expected payload format. It support the options _json_ and _none_. When using _json_, it expects JSON maps, when is set to _none_, it will split every record using the defined _Separator_ (option below).                                        | json    |
| Separator    | When the expected _Format_ is set to _none_, Fluent Bit needs a separator string to split the records. By default it uses the breakline character  (LF or 0x10).                                                                                               |         |
| Source\_Address\_Key| Specify the key where the source address will be injected.                                                                                                                                                                                              |         |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Getting Started

In order to receive JSON messages over TCP, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit listen for _JSON_ messages with the following options:

```shell
$ fluent-bit -i tcp -o stdout
```

By default the service will listen an all interfaces (0.0.0.0) through TCP port 5170, optionally you can change this directly, e.g:

```shell
$ fluent-bit -i tcp://192.168.3.2:9090 -o stdout
```

In the example the JSON messages will only arrive through network interface under 192.168.3.2 address and TCP Port 9090.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: tcp
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
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name        tcp
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
{% endtabs %}

## Testing

Once Fluent Bit is running, you can send some messages using the _netcat_:

```shell
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```shell
$ bin/fluent-bit -i tcp -o stdout -f 1

Fluent Bit v4.0.3
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/07/01 14:44:47] [ info] [fluent bit] version=4.0.3, commit=f5f5f3c17d, pid=1
[2025/07/01 14:44:47] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/01 14:44:47] [ info] [simd    ] disabled
[2025/07/01 14:44:47] [ info] [cmetrics] version=1.0.3
[2025/07/01 14:44:47] [ info] [ctraces ] version=0.6.6
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] initializing
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] storage_strategy='memory' (memory only)
[2025/07/01 14:44:47] [ info] [sp] stream processor started
[2025/07/01 14:44:47] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
[2025/07/01 14:44:47] [ info] [output:stdout:stdout.0] worker #0 started
[0] tcp.0: [1570115975.581246030, {"key 1"=>123456789, "key 2"=>"abcdefg"}]
```

## Performance Considerations

When receiving payloads in JSON format, there are high performance penalties. Parsing JSON is a very expensive task so you could expect your CPU usage increase under high load environments.

To get faster data ingestion, consider to use the option `Format none` to avoid JSON parsing if not needed.