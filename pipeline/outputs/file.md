# File

The _File_ output plugin lets you write the data received through the input plugin to file.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Path` | Directory path to store files. If not set, Fluent Bit will write the files on it's own positioned directory. Available in Fluent Bit 1.4.6 and later. | _none_ |
| `File` | Set filename to store the records. If not set, the filename will be the `tag` associated with the records. | _none_ |
| `Format` | The [format](#format) of the file content. | `out_file` |
| `Mkdir` | Recursively create output directory if it doesn't exist. Permissions set to `0755`. | _none_ |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |
| `line_append` | Append new data to the end of log in same line. | `false` |                                                                                       | false   |


## Format

This plugin uses the following formats:

### `out_file`

Output `time`, `tag`, and `json` records. There are no configuration parameters for `out_file`.

```text
tag: [time, {"key1":"value1", "key2":"value2", "key3":"value3"}]
```

### Plain

Output the records as JSON (without additional `tag` and `timestamp` attributes). There are no configuration parameters for plain format.

```json
{"key1":"value1", "key2":"value2", "key3":"value3"}
```

### CSV

Output the records in CSV format. CSV mode supports an additional configuration parameter.

| Key | Description |
| :--- | :--- |
| `Delimiter` | The character to separate each data. Accepted values: `\t` (or `tab`), ` ` (`space`), or `,` (`comma`). Other values are ignored and will use default silently. Default: `,` |

```text
time[delimiter]"value1"[delimiter]"value2"[delimiter]"value3"
```

### LTSV

Output the records in LTSV format. LTSV mode supports an additional configuration parameter.

| Key | Description |
| :--- | :--- |
| `Delimiter` | The character to separate each pair. Default: `t` (`TAB`) |
| `Label_Delimiter` | The character to separate label and the value. Default: `:` |

```text
field1[label_delimiter]value1[delimiter]field2[label_delimiter]value2\n
```

### Template

Output the records using a custom format template.

| Key | Description |
| :--- | :--- |
| Template | The format string. Default: `{time} {message}` |

This accepts a formatting template and fills placeholders using corresponding values in a record.

For example, if you set up the configuration like the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: mem

  outputs:
    - name: file
      match: '*'
      format: template
      template: '{time} used={Mem.used} free={Mem.free} total={Mem.total}'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name mem

[OUTPUT]
  Name file
  Match *
  Format template
  Template {time} used={Mem.used} free={Mem.free} total={Mem.total}
```

{% endtab %}
{% endtabs %}

You will get the following output:

```text
1564462620.000254 used=1045448 free=31760160 total=32805608
```

## Get started

You can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit count up a data with the following options:

```shell
fluent-bit -i cpu -o file -p path=output.txt
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: file
      match: '*'
      path: output_dir
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name  file
  Match *
  Path  output_dir
```

{% endtab %}
{% endtabs %}
