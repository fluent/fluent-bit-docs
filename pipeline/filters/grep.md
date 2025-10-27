---
description: Select or exclude records using regular expressions.
---

# Grep

The _Grep_ filter plugin lets you match or exclude specific records based on regular expression patterns for values or nested values.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Record Type | Description |
| :--- | :--- | :--- | :--- |
| `Regex` | `KEY REGEX` | String | Keep records in which the content of `KEY` matches the regular expression. |
| `Exclude` | `KEY REGEX` | String | Exclude records in which the content of `KEY` matches the regular expression. |
| `number_equal` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is equal to `NUMBER`. |
| `number_not_equal` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is not equal to `NUMBER`. |
| `number_less_than` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is less than the `NUMBER`. |
| `number_less_than_or_equal` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is less than or equal to `NUMBER`. |
| `number_greater_than` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is greater than the `NUMBER`. |
| `number_greater_than_or_equal` | `KEY NUMBER` | number | Keep records in which the content of `KEY` is greater than or equal to `NUMBER`. |


If you use the number compare parameters with a `KEY` that doesn't have a `NUMBER` as a value, it will be excluded.

If you use `REGEX` or `EXCLUDE` with a number, it will never match it.

### Record accessor enabled

Enable the [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) feature to specify the `KEY`. Use the record accessor to match values against nested values.

## Filter records

To start filtering records, run the filter from the command line or through the configuration file. The following example assumes that you have a file named `lines.txt` with the following content:

```text
{"log": "aaa"}
{"log": "aab"}
{"log": "bbb"}
{"log": "ccc"}
{"log": "ddd"}
{"log": "eee"}
{"log": "fff"}
{"log": "ggg"}
```

### Command line

When using the command line, pay close attention to quote the regular expressions. Using a configuration file might be easier.

The following command loads the [tail](../../pipeline/inputs/tail.md) plugin and reads the content of `lines.txt`. Then the `grep` filter applies a regular expression rule over the `log` field created by the `tail` plugin and only passes records with a field value starting with `aa`:

```shell
fluent-bit -i tail -p 'path=lines.txt' -F grep -p 'regex=log aa' -m '*' -o stdout
```

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  parsers_file: /path/to/parsers.conf

pipeline:
  inputs:
    - name: tail
      path: lines.txt
      parser: json

  filters:
    - name: grep
      match: '*'
      regex: log aa

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  parsers_file /path/to/parsers.conf

[INPUT]
  name   tail
  path   lines.txt
  parser json

[FILTER]
  name   grep
  match  *
  regex  log aa

[OUTPUT]
  name   stdout
  match  *
```

{% endtab %}
{% endtabs %}

The filter lets you use multiple rules which are applied in order, you can have many `Regex` and `Exclude` entries as required ([more information](#multiple-conditions)).

### Nested fields example

To match or exclude records based on nested values, you can use [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) format as the `KEY` name.

Consider the following record example:

```json
{
  "log": "something",
  "kubernetes": {
    "pod_name": "myapp-0",
    "namespace_name": "default",
    "pod_id": "216cd7ae-1c7e-11e8-bb40-000c298df552",
    "labels": {
      "app": "myapp"
    },
    "host": "minikube",
    "container_name": "myapp",
    "docker_id": "370face382c7603fdd309d8c6aaaf434fd98b92421ce"
  }
}
```

For example, to exclude records that match the nested field `kubernetes.labels.app`, use the following rule:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  filters:
    - name: grep
      match: '*'
      exclude: $kubernetes['labels']['app'] myapp
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[FILTER]
  Name    grep
  Match   *
  Exclude $kubernetes['labels']['app'] myapp
```

{% endtab %}
{% endtabs %}

### Excluding records with missing or invalid fields

You might want to drop records that are missing certain keys.

One way to do this is to `exclude` with a regular expression that matches anything. A missing
key fails this check.

The following example checks for a specific valid value for the key:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  filters:
    # Use Grep to verify the contents of the iot_timestamp value.
    # If the iot_timestamp key does not exist, this will fail
    # and exclude the row.
    - name: grep
      alias: filter-iots-grep
      match: iots_thread.*
      regex: iot_timestamp ^\d{4}-\d{2}-\d{2}
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
# Use Grep to verify the contents of the iot_timestamp value.
# If the iot_timestamp key does not exist, this will fail
# and exclude the row.
[FILTER]
  Name                     grep
  Alias                    filter-iots-grep
  Match                    iots_thread.*
  Regex                    iot_timestamp ^\d{4}-\d{2}-\d{2}
```

{% endtab %}
{% endtabs %}

The specified key `iot_timestamp` must match the expected expression. If it doesn't,
or is missing or empty, then it will be excluded.

### Multiple conditions

If you want to set multiple `Regex` or `Exclude`, you must use the `legacy` mode. In this case, the `Exclude` must be first and you can have only one `Regex`.
If `Exclude` match, the string is blocked. You can have multiple `Exclude` entry.
After, if there is no `Regex`, the line is sent to the output.

If there is a `Regex` and it matches, the line is sent to the output, else, it's blocked.

If you want to set multiple `Regex` or `Exclude`, you can use `Logical_Op` property to use logical conjunction or disjunction.

If `Logical_Op` is set, setting both `Regex` and `Exclude` results in an error.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"endpoint":"localhost", "value":"something"}'
      tag: dummy

  filters:
    - name: grep
      match: '*'
      logical_op: or
      regex:
        - value something
        - value error

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Dummy {"endpoint":"localhost", "value":"something"}
  Tag dummy

[FILTER]
  Name grep
  Match *
  Logical_Op or
  Regex value something
  Regex value error

[OUTPUT]
  Name stdout
  Match *
```

{% endtab %}
{% endtabs %}

The output looks similar to:

```text
[0] dummy: [1674348410.558341857, {"endpoint"=>"localhost", "value"=>"something"}]
[0] dummy: [1674348411.546425499, {"endpoint"=>"localhost", "value"=>"something"}]
```
