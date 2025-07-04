# TCP

The _TCP_ input plugin lets you retrieve structured JSON or raw messages over a TCP network interface (TCP port).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description | Default |
| ------------ | ----------- | ------- |
| `Listen`     | Listener network interface. | `0.0.0.0` |
| `Port`       | TCP port to listen for connections. | `5170` |
| `Buffer_Size` | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default is the value of `Chunk_Size`. | `Chunk_Size` |
| `Chunk_Size` | The default buffer to store the incoming JSON messages. It doesn't allocate the maximum memory allowed; instead it allocates memory when required. The rounds of allocations are set by `Chunk_Size`. If not set, `Chunk_Size` is equal to 32 (32KB). | `32` |
| `Format`     | Specify the expected payload format. Supported values: `json` and `none`. When set to `json` it expects JSON maps. When set to `none`, every record splits using the defined `Separator`. | `json` |
| `Separator`  | When `Format` is set to `none`, Fluent Bit needs a separator string to split the records. | `LF` or `0x10` (break line) |
| `Source_Address_Key`| Specify the key to inject the source address. | _none_ |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To receive JSON messages over TCP, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for JSON messages with the following options:

```bash
fluent-bit -i tcp -o stdout
```

By default the service will listen an all interfaces (`0.0.0.0`) through TCP port `5170`. Optionally you can change this directly:

```bash
fluent-bit -i tcp://192.168.3.2:9090 -o stdout
```

In the example the JSON messages will only arrive through the network interface at `192.168.3.2` address and TCP Port `9090`.

### Configuration file

In your main configuration file append the following sections:

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

## Test the configuration

When Fluent Bit is running, you can send some messages using `netcat`:

```bash
echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

Run Fluent Bit:

```shell
bin/fluent-bit -i tcp -o stdout -f 1
```

You should see the following output:

```bash
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
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

## Performance considerations

When receiving payloads in JSON format, there are high performance penalties. Parsing JSON is a very expensive task so you could expect your CPU usage increase under high load environments.

To get faster data ingestion, consider to use the option `Format none` to avoid JSON parsing if not needed.
