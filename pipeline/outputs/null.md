# Null

The _Null_ output plugin discards events.

## Configuration parameters

This plugin doesn't have any configuration parameters.

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
