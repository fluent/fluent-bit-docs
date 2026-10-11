# NATS

The _NATS_ output plugin lets you flush your records into a [NATS Server](https://docs.nats.io/) server endpoint.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `host` | The IP address or hostname of the NATS server. | `127.0.0.1` |
| `port` | The TCP port of the target NATS server. | `4222` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

{% hint style="info" %}

To override the default configuration values, this plugin uses the optional Fluent Bit network address format (for example, `nats://host:port`).

{% endhint %}

## Get started

To flush records to a NATS server, you can run the plugin from the command line or through the configuration file.

### Command line

If you use the following command without specifying parameter values, Fluent Bit uses the default values defined in the previous section.

```shell
fluent-bit -i cpu -o nats -f 5
```

### Configuration file

In your main configuration file, append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: nats
      match: '*'
      host: 127.0.0.1
      port: 4222
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name   nats
  Match  *
  Host   127.0.0.1
  Port   4222
```

{% endtab %}
{% endtabs %}

## Data format

For every set of records flushed to a NATS server, Fluent Bit uses the following format:

```text
[
  [UNIX_TIMESTAMP, JSON_MAP_1],
  [UNIX_TIMESTAMP, JSON_MAP_2],
  [UNIX_TIMESTAMP, JSON_MAP_N],
]
```

Each record is an individual entity represented in a JSON array that contains a Unix timestamp and a JSON map with a set of key/value pairs. A summarized output of the CPU input plugin will resemble the following:

```json
[
  [1457108504,{"tag":"fluentbit","cpu_p":1.500000,"user_p":1,"system_p":0.500000}],
  [1457108505,{"tag":"fluentbit","cpu_p":4.500000,"user_p":3,"system_p":1.500000}],
  [1457108506,{"tag":"fluentbit","cpu_p":6.500000,"user_p":4.500000,"system_p":2}]
]
```
