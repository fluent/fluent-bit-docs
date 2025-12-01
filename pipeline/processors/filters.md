# Filters as processors

You can use any [filter](../filters.md) as a processor in Fluent Bit.

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml.md) support processors.

{% endhint %}

## Examples

The following examples show how to configure filters as processors.

### Grep

In this example, the [Grep](../filters/grep.md) filter is used as an input processor to filter log events based on a regular expression pattern:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
    - name: json
      format: json

pipeline:
    inputs:
        - name: tail
          path: /var/log/example.log
          parser: json

          processors:
              logs:
                  - name: grep
                    regex: log aa
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% endtabs %}

### Lua

In this example configuration, an input plugin uses the [Lua](../filters/lua.md) filter as a processor to add a new key `hostname` with the value `monox`. Then, an output plugin adds a new key named `output` with the value `new data`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
  service:
    log_level: info
    http_server: on
    http_listen: 0.0.0.0
    http_port: 2021
  pipeline:
    inputs:
      - name: random
        tag: test-tag
        interval_sec: 1
        processors:
          logs:
            - name: modify
              add: hostname monox
            - name: lua
              call: append_tag
              code: |
                  function append_tag(tag, timestamp, record)
                     new_record = record
                     new_record["tag"] = tag
                     return 1, timestamp, new_record
                  end
    outputs:
      - name: stdout
        match: '*'
        processors:
          logs:
            - name: lua
              call: add_field
              code: |
                  function add_field(tag, timestamp, record)
                     new_record = record
                     new_record["output"] = "new data"
                     return 1, timestamp, new_record
                  end
```

{% endtab %}
{% endtabs %}
