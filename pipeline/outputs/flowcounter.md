# FlowCounter

_FlowCounter_ is the protocol to count records. The **flowcounter** output plugin allows to count up records and its size.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Unit | The unit of duration. \(second/minute/hour/day\) | minute |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```shell
fluent-bit -i cpu -o flowcounter
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
    - name: flowcounter
      match: '*'
      unit: second
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  flowcounter
  Match *
  Unit second
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see the reports in the output interface similar to this:

```text
...
[out_flowcounter] cpu.0:[1482458540, {"counts":60, "bytes":7560, "counts/minute":1, "bytes/minute":126 }]
...
```