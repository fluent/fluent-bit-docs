---
description: Send logs to a remote UDP server
---

# UDP

The _UDP_ output plugin lets you send records to a remote UDP server. The payload can be formatted in different ways as required.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `Host` | Target host where the UDP server is listening. | `127.0.0.1` |
| `Port` | `UDP` Port of the target service. | `5170` |
| `Format` | Specify the data format to be printed. Supported formats: `msgpack`, `json`, `json_lines`, `json_stream`. | `json_lines` |
| `json_date_key` | Specify the name of the time key in the output record. To disable the time key, set the value to `false`. | `date` |
| `json_date_format` | Specify the format of the date. Supported formats: `double`, `epoch`, `epoch_ms`, `iso8601`, `java_sql_timestamp`. | `double` |
| `raw_message_key` | Use a raw message key for the message. When set, the plugin sends the value of this key as the raw message instead of formatting it as JSON. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

## Get started

To send records to a `UDP` server, you can run the plugin from the command line or through the configuration file.

### Command line

The `UDP` plugin can read the parameters from the command line through the `-p` argument (property) or by setting them directly through the service URI. The URI format is the following:

```text
udp://host:port
```

Using the format specified, start Fluent Bit through:

```shell
fluent-bit -i cpu -t cpu -o udp://192.168.2.3:5170 -p format=json_lines -v
```

which is similar to:

```shell
fluent-bit -i cpu -t cpu -o udp -p Host=192.168.2.3 -p Port=5170 \
  -p Format=json_lines -o stdout -m '*'
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: udp
      match: '*'
      host: 192.168.2.3
      port: 5170
      format: json_lines
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  udp
  Match *
  Host  192.168.2.3
  Port  5170
  Format json_lines
```

{% endtab %}
{% endtabs %}

## JSON format examples

### JSON lines format

This example sends CPU metrics in JSON lines format to a `UDP` server:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: udp
      match: '*'
      host: 127.0.0.1
      port: 5170
      format: json_lines
      json_date_key: timestamp
      json_date_format: iso8601
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name            udp
  Match           *
  Host            127.0.0.1
  Port            5170
  Format          json_lines
  Json_date_key   timestamp
  Json_date_format iso8601
```

{% endtab %}
{% endtabs %}

Run the following in a separate terminal, `netcat` will start listening for messages on `UDP` port `5170`:

```shell
nc -u -l 5170
```

After Fluent Bit connects, you should see output in JSON format:

```text
{"timestamp":"2024-01-15T10:30:45.123456Z","cpu_p":1.1875,"user_p":0.5625,"system_p":0.625}
{"timestamp":"2024-01-15T10:30:46.123456Z","cpu_p":2.25,"user_p":2.0,"system_p":0.25}
```

### Raw message format

When `raw_message_key` is set, the plugin sends the value of the specified key as a raw message instead of formatting it as JSON. This is for when you want to send pre-formatted messages:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      path: /var/log/app.log
      tag: app

  outputs:
    - name: udp
      match: '*'
      host: 127.0.0.1
      port: 5170
      raw_message_key: message
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name tail
  Path /var/log/app.log
  Tag  app

[OUTPUT]
  Name           udp
  Match          *
  Host           127.0.0.1
  Port           5170
  Raw_message_key message
```

{% endtab %}
{% endtabs %}

## Message size limitations

`UDP` has a maximum datagram size of `65535` bytes. If a record exceeds this size, the plugin will send it but log a debug message. For large messages, consider using `TCP` or `HTTP` output plugins instead.

## Testing

To test the `UDP` output plugin, you can use `netcat` to listen for incoming `UDP` messages:

```shell
nc -u -l 5170
```

Or use `socat` for more advanced testing:

```shell
socat UDP-RECV:5170 STDOUT
```
