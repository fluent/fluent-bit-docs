# NULL

The **null** output plugin just throws away events.

## Configuration Parameters

The plugin doesn't support configuration parameters.

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit throws away events with the following options:

```shell
fluent-bit -i cpu -o null
```

### Configuration File

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