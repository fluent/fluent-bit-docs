# TCP

The _TCP_ input plugin lets you retrieve structured JSON or raw messages over a TCP network interface (TCP port).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key                  | Description                                                                                                                                                                                                                                           | Default                     |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `Listen`             | Listener network interface.                                                                                                                                                                                                                           | `0.0.0.0`                   |
| `Port`               | TCP port to listen for connections.                                                                                                                                                                                                                   | `5170`                      |
| `Buffer_Size`        | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default is the value of `Chunk_Size`.                                                                                                                                | `Chunk_Size`                |
| `Chunk_Size`         | The default buffer to store the incoming JSON messages. It doesn't allocate the maximum memory allowed; instead it allocates memory when required. The rounds of allocations are set by `Chunk_Size`. If not set, `Chunk_Size` is equal to 32 (32KB). | `32`                        |
| `Format`             | Specify the expected payload format. Supported values: `json` and `none`. When set to `json` it expects JSON maps. When set to `none`, every record splits using the defined `Separator`.                                                             | `json`                      |
| `Separator`          | When `Format` is set to `none`, Fluent Bit needs a separator string to split the records.                                                                                                                                                             | `LF` or `0x10` (break line) |
| `Source_Address_Key` | Specify the key to inject the source address.                                                                                                                                                                                                         | _none_                      |
| `Threaded`           | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                               | `false`                     |

## Get started

To receive JSON messages over TCP, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for JSON messages with the following options:

```shell
fluent-bit -i tcp -o stdout
```

By default, the service will listen an all interfaces (`0.0.0.0`) through TCP port `5170`. Optionally you can change this directly:

```shell
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

```shell
echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

Run Fluent Bit:

```shell
fluent-bit -i tcp -o stdout -f 1
```

You should see the following output:

```text
...
[0] tcp.0: [1570115975.581246030, {"key 1"=>123456789, "key 2"=>"abcdefg"}]
...
```

## Performance considerations

When receiving payloads in JSON format, there are high performance penalties. Parsing JSON is a very expensive task so you could expect your CPU usage increase under high load environments.

To get faster data ingestion, consider to use the option `Format none` to avoid JSON parsing if not needed.