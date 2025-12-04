# Parsers

You can define customer [parsers](../pipeline/parsers.md) in the `parsers` section of YAML configuration files.

{% hint style="info" %}

To define custom multiline parsers, use [the `multiline_parsers` section](../administration/configuring-fluent-bit/yaml/multiline-parsers-section.md) of YAML configuration files.

{% endhint %}

## Syntax

To define customers parsers in the `parsers` section of a YAML configuration file, use the following syntax.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
  - name: custom_parser1
    format: json
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on

  - name: custom_parser2
    format: regex
    regex: '^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) (?<ident>[^ ]+) (?<pid>[-0-9]+) (?<msgid>[^ ]+) (?<extradata>(\[(.*)\]|-)) (?<message>.+)$'
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on
    types: pid:integer
```

{% endtab %}
{% endtabs %}

For information about supported configuration options for custom parsers, see [configuring parsers](../pipeline/parsers/configuring-parser.md).

## Standalone parsers files

In addition to defining parsers in the `parsers` section of YAML configuration files, you can store parser definitions in standalone files. These standalone files require the same syntax as parsers defined in a standard YAML configuration file.

To add a standalone parsers file to Fluent Bit, use the `parsers_file` parameter in the `service` section of your YAML configuration file.

### Add a standalone parsers file to Fluent Bit

To add a standalone parsers file to Fluent Bit, follow these steps.

1. Define custom parsers in a standalone YAML file. For example, `my-parsers.yaml` defines two custom parsers:

{% tabs %}
{% tab title="my-parsers.yaml" %}

```yaml
parsers:
  - name: custom_parser1
    format: json
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on

  - name: custom_parser2
    format: regex
    regex: '^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) (?<ident>[^ ]+) (?<pid>[-0-9]+) (?<msgid>[^ ]+) (?<extradata>(\[(.*)\]|-)) (?<message>.+)$'
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on
    types: pid:integer
```

{% endtab %}
{% endtabs %}

1. Update the `parsers_file` parameter in the `service` section of your YAML configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  parsers_file: my-parsers.yaml
```

{% endtab %}
{% endtabs %}
