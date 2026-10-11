# Null

{% hint style="info" %}
**Supported event types:** `logs` `metrics`
{% endhint %}

The _Null_ output plugin discards events.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `format` | Specify the data format. Supported formats: `msgpack`, `json`, `json_lines`, `json_stream`. | `msgpack` |
| `json_date_format` | Specify the format of the date. Supported formats: `double`, `epoch`, `epoch_ms`, `iso8601` (for example, `2018-05-30T09:39:52.000681Z`), and `java_sql_timestamp` (for example, `2018-05-30 09:39:52.000681`). | `double` |
| `json_date_key` | Specify the name of the time key in the output record. To disable the time key, set the value to `false`. | `date` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can let Fluent Bit discard events with the following options:

```shell
fluent-bit -i cpu -o null
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
    - name: null
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name null
  Match *
```

{% endtab %}
{% endtabs %}
