# Filters as processors

Any Fluent Bit [filter](../filters/README.md) can be used as a processor.

## Grep example

In this example, the [Grep](../filters/grep.md) filter is used as an output processor that sends log records only if they match a specified regular expression.

{% code title="fluent-bit.yaml" %}
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
{% endcode %}
