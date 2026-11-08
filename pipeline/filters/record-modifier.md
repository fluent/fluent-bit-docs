# Record modifier

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Record Modifier_ [filter](record-modifier.md) lets you append fields to a record, or exclude specific fields.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `allowlist_key` | If the key isn't matched, that field is removed. You can use this or `remove_key`. |
| `record` | Append fields. This parameter needs a key/value pair. |
| `remove_key` | If the key is matched, that field is removed. You can use this or `allowlist_key`.|
| `uuid_key` | If set, the plugin appends UUID to each record. The value assigned becomes the key in the map. |
| `whitelist_key` | An alias of `allowlist_key` for backwards compatibility. |

## Records left without fields

If `remove_key` or `allowlist_key` removes every field from a record, and the filter doesn't add any field to that record with `record` or `uuid_key`, Fluent Bit drops the record. For example, with `allowlist_key`, a record that contains none of the listed keys is dropped. Fluent Bit counts dropped records in the filter's `fluentbit_filter_drop_records_total` metric. See [Monitoring](../../administration/monitoring.md).

If records are missing from the output, check that your `allowlist_key` values match the keys in your records, and watch `fluentbit_filter_drop_records_total`.

To keep records that would otherwise be left without fields, add at least one field with `record`. A `record` entry must contain exactly one key and one value. If the key or value is empty, for example because an environment variable in it resolves to an empty string, Fluent Bit fails to start. If the value contains spaces, enclose it in double quotes. For an unquoted value that contains spaces, Fluent Bit logs `invalid record parameters, expects 'KEY VALUE'` and skips the entry, so it doesn't add a field.

## Get started

To start filtering records, run the filter from the command line or through a configuration file.

This is a sample `in_mem` record to filter.

```text
{"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>299352, "Swap.total"=>2064380, "Swap.used"=>32656, "Swap.free"=>2031724}
```

### Append fields

The following configuration file appends a product name and hostname to a record using an environment variable:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: mem
      tag: mem.local

  filters:
    - name: record_modifier
      match: '*'
      record:
       - hostname ${HOSTNAME}
       - product Awesome_Tool

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name mem
  Tag  mem.local

[OUTPUT]
  Name  stdout
  Match *

[FILTER]
  Name record_modifier
  Match *
  Record hostname ${HOSTNAME}
  Record product Awesome_Tool
```

{% endtab %}
{% endtabs %}

You can run the filter from command line:

```shell
fluent-bit -i mem -o stdout -F record_modifier -p 'Record=hostname ${HOSTNAME}' -p 'Record=product Awesome_Tool' -m '*'
```

The output looks something like:

```text
[0] mem.local: [1492436882.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>299352, "Swap.total"=>2064380, "Swap.used"=>32656, "Swap.free"=>2031724, "hostname"=>"localhost.localdomain", "product"=>"Awesome_Tool"}]
```

### Remove fields with `Remove_key`

The following configuration file removes `Swap.*` fields:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: mem
      tag: mem.local

  filters:
    - name: record_modifier
      match: '*'
      remove_key:
       - Swap.total
       - Swap.used
       - Swap.free

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name mem
  Tag  mem.local

[OUTPUT]
  Name  stdout
  Match *

[FILTER]
  Name record_modifier
  Match *
  Remove_key Swap.total
  Remove_key Swap.used
  Remove_key Swap.free
```

{% endtab %}
{% endtabs %}

You can also run the filter from command line.

```shell
fluent-bit -i mem -o stdout -F  record_modifier -p 'Remove_key=Swap.total' -p 'Remove_key=Swap.free' -p 'Remove_key=Swap.used' -m '*'
```

The output looks something like:

```text
[0] mem.local: [1492436998.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>295332}]
```

### Retain fields with `Allowlist_key`

The following configuration file retains `Mem.*` fields.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: mem
      tag: mem.local

  filters:
    - name: record_modifier
      match: '*'
      allowlist_key:
       - Mem.total
       - Mem.used
       - Mem.free

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name mem
  Tag  mem.local

[FILTER]
  Name record_modifier
  Match *
  Allowlist_key Mem.total
  Allowlist_key Mem.used
  Allowlist_key Mem.free

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

You can also run the filter from command line:

```shell
fluent-bit -i mem -o stdout -F record_modifier -p 'Allowlist_key=Mem.total' -p 'Allowlist_key=Mem.free' -p 'Allowlist_key=Mem.used' -m '*'
```

The output looks something like:

```text
[0] mem.local: [1492436998.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>295332}]
```
