# UDP

The _UDP_ input plugin lets you retrieve structured JSON or raw messages over a UDP network interface (UDP port).

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                  | Description                                                                                                                                                                                          | Default                     |
|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `Listen`             | Listener network interface.                                                                                                                                                                          | `0.0.0.0`                   |
| `Port`               | UDP port used to listen for connections.                                                                                                                                                             | `5170`                      |
| `Buffer_Size `       | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default size will be the value of `Chunk_Size`.                                                                     | `Chunk_Size` (value)        |
| `Chunk_Size`         | The default buffer to store incoming JSON messages. Doesn't allocate the maximum memory allowed; instead it allocates memory when required. The rounds of allocations are set by `Chunk_Size` in KB. | `32`                        |
| `Format`             | Specify the expected payload format. Supported values: `json` and `none`. `json` expects JSON maps. `none` splits every record using the defined `Separator`.                                        | `json`                      |
| `Separator`          | When `Format` is set to `none`, Fluent Bit needs a separator string to split the records.                                                                                                            | `LF` or `0x10` (break line) |
| `Source_Address_Key` | Specify the key where the source address will be injected.                                                                                                                                           | _none_                      |
| `Threaded`           | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                              | `false`                     |

## Get started

To receive JSON messages over UDP, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for JSON messages with the following options:

```shell
fluent-bit -i udp -o stdout
```

By default, the service listens on all interfaces (`0.0.0.0`) using UDP port `5170`. Optionally. you can change this directly.

In this example the JSON messages will only arrive through network interface at `192.168.3.2` address and UDP Port `9090`.

```shell
fluent-bit -i udp -pport=9090 -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
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
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

## Testing

When Fluent Bit is running, you can send some messages using `netcat`:

```shell
echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc -u 127.0.0.1 5170
```

Run Fluent Bit:

```shell
fluent-bit -i udp -o stdout -f 1
```

You should see the following output:

```text
...
[0] udp.0: [[1689912069.078189000, {}], {"key 1"=>123456789, "key 2"=>"abcdefg"}]
...
```

## Performance considerations

When receiving payloads in JSON format, there are high performance penalties. Parsing JSON is a very expensive task so you could expect your CPU usage increase under high load environments.

To get faster data ingestion, consider using the option `Format none` to avoid JSON parsing if not needed.