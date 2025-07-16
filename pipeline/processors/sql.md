# SQL

The _SQL_ processor lets you use conditional expressions to select content from logs. This processor doesn't depend on a database or table. Instead, your queries run on the stream.

This processor differs from the stream processor interface that runs after filters.

{% hint style="info" %}

Only [YAML configuration files](../administration/configuring-fluent-bit/yaml/README.md) support processors.

{% endhint %}

## Configuration parameters

| Key | Description |
| --- | ----------- |
| `query` | The SQL statement to query your logs stream. This statement must end with `;`. |

## Basic selection example

The following example generates a sample message with two keys: `key` and `http.url`, then uses a SQL statement to select only the key `http.url`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4", "http.url": "https://fluentbit.io/search?q=docs"}'

          processors:
              logs:
                  - name: sql
                    query: "SELECT http.url FROM STREAM;"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

## Extract and select example

The following example is similar to the previous example, but additionally extracts part of `http.url` to select the domain from the value. To accomplish this, use the `content-modifier` and `sql` processors in tandem:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4", "http.url": "https://fluentbit.io/search?q=docs"}'

          processors:
              logs:
                  - name: content_modifier
                    action: extract
                    key: "http.url"
                    pattern: ^(?<http_protocol>https?):\/\/(?<http_domain>[^\/\?]+)(?<http_path>\/[^?]*)?(?:\?(?<http_query_params>.*))?

        - name: sql
          query: "SELECT http_domain FROM STREAM;"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

The resulting output resembles the following:

```json
{
  "date": 1711059261.630668,
  "http_domain": "fluentbit.io"
}
```
