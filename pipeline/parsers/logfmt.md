# Logfmt

The _logfmt_ parser lets you parse data in the [logfmt](https://pkg.go.dev/github.com/kr/logfmt?utm_source=godoc) format.

Here is an example parsers configuration:

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

If you want to be more strict than the logfmt standard and not parse lines where certain attributes lack values (such as `key3` in the previoue example), you can configure the parser as follows:

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
