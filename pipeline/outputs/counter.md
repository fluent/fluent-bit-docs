# Counter

_Counter_ is a plugin that counts how many records it's getting upon flush time. Plugin output is as follows:

```text
[TIMESTAMP, NUMBER_OF_RECORDS_NOW] (total = RECORDS_SINCE_IT_STARTED)
```

## Get started

You can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit count data with the following options:

```shell
fluent-bit -i cpu -o counter
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
    - name: counter
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  counter
  Match *
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see the reports similar to this in the output interface:

```text
...
1500484743,1 (total = 1)
1500484744,1 (total = 2)
1500484745,1 (total = 3)
1500484746,1 (total = 4)
1500484747,1 (total = 5)
```
