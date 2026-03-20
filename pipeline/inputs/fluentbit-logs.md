# Fluent Bit logs

The _Fluent Bit logs_ input plugin routes Fluent Bit internal log output into the pipeline as structured log records. Each record contains a `level` field and a `message` field, which lets you ship, filter, or store Fluent Bit internal diagnostic output using the same pipeline you use for all other data.

This plugin is event-driven: records are delivered immediately as the internal logger emits them, not on a polling interval. Fluent Bit enables internal log mirroring automatically when this input is configured.

{% hint style="info" %}

Internal log records are buffered in a bounded in-memory queue of up to 1024 entries. Records produced before the pipeline is ready, or while the queue is full, aren't delivered through this plugin.

{% endhint %}

## Record format

Each record contains the following fields:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `level` | String | Severity of the log entry. Possible values: `error`, `warn`, `info`, `debug`, `trace`, `help`. |
| `message` | String | The log message text. |

## Configuration parameters

This plugin has no configuration parameters.

## Get started

### Command line

```shell
fluent-bit -i fluentbit_logs -o stdout
```

### Configuration file

The following example captures Fluent Bit internal logs and writes them to standard output:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: fluentbit_logs
      tag: internal.logs

  outputs:
    - name: stdout
      match: 'internal.logs'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Flush     1
    Log_Level info

[INPUT]
    Name  fluentbit_logs
    Tag   internal.logs

[OUTPUT]
    Name  stdout
    Match internal.logs
```

{% endtab %}
{% endtabs %}

To forward internal logs to an external destination, replace the output with any supported output plugin. For example, to forward to an OpenTelemetry collector:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: fluentbit_logs
      tag: internal.logs

  outputs:
    - name: opentelemetry
      match: 'internal.logs'
      host: otel-collector
      port: 4318
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Flush     1
    Log_Level info

[INPUT]
    Name  fluentbit_logs
    Tag   internal.logs

[OUTPUT]
    Name  opentelemetry
    Match internal.logs
    Host  otel-collector
    Port  4318
```

{% endtab %}
{% endtabs %}
