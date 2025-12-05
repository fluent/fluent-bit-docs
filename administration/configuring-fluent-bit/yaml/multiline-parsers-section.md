# Multiline parsers

You can define custom [multiline parsers](../../pipeline/parsers/multiline-parsing.md) in the `multiline_parsers` section of YAML configuration files.

{% hint style="info" %}

To define standard custom parsers, use [the `parsers` section](./parsers-section.md) of YAML configuration files.

{% endhint %}

## Syntax

To define custom parsers in the `multiline_parsers` section of a YAML configuration file, use the following syntax:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
multiline_parsers:
  - name: multiline-regex-test
    type: regex
    flush_timeout: 1000
    rules:
      - state: start_state
        regex: '/([a-zA-Z]+ \d+ \d+:\d+:\d+)(.*)/'
        next_state: cont
      - state: cont
        regex: '/^\s+at.*/'
        next_state: cont
```

{% endtab %}
{% endtabs %}

This example defines a multiline parser named `multiline-regex-test` that uses regular expressions to handle multi-event logs. The parser contains two rules: the first rule transitions from `start_state` to cont when a matching log entry is detected, and the second rule continues to match subsequent lines.

For information about supported configuration options for custom multiline parsers, see [configuring multiline parsers](../../pipeline/parsers/multiline-parsing.md#configuring-multiline-parsers).
