# Logfmt format

Use the _logfmt_ parser format to create custom parsers compatible with [logfmt](https://pkg.go.dev/github.com/kr/logfmt?utm_source=godoc) data.

For available configuration parameters, see [Configuring custom parsers](configuring-parser.md).

## Configuration parameters

The `logfmt` parser supports the following format-specific configuration parameter:

| Key | Description | Default |
| --- | ----------- | ------- |
| `logfmt_no_bare_keys` | If enabled, the parser rejects log entries where keys don't have associated values (bare keys). | `false` |

The following example shows a custom parser that uses the `logfmt` format:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: logfmt
    format: logfmt
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name        logfmt
  Format      logfmt
```

{% endtab %}
{% endtabs %}

The following log entry is valid for the previously defined parser:

```text
key1=val1 key2=val2 key3
```

After processing, its internal representation will be:

```text
[1540936693, {"key1"=>"val1",
              "key2"=>"val2"
              "key3"=>true}]
```

If you want to be more strict than the logfmt standard and not parse lines where certain keys lack values (such as `key3` in the previous example), you can configure the parser as follows:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: logfmt
    format: logfmt
    logfmt_no_bare_keys: true
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name        logfmt
  Format      logfmt
  Logfmt_No_Bare_Keys true
```

{% endtab %}
{% endtabs %}
