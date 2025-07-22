# Filters as processors

You can use any [filter](../filters/README.md) as a processor in Fluent Bit.

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml/README.md) support processors.

{% endhint %}

## Grep example

In this example, the [Grep](../filters/grep.md) filter is an output processor that sends log records only if they match a specified regular expression.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      path: lines.txt
      parser: json

  outputs:
    - name: stdout
      match: '*'

      processors:
        logs:
          - name: grep
            regex: log aa
```

{% endtab %}
{% endtabs %}