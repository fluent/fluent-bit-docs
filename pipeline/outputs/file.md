# File

The **file** output plugin allows to write the data received through the _input_ plugin to file.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Path | Directory path to store files. If not set, Fluent Bit will write the files on it's own positioned directory. note: this option was added on Fluent Bit v1.4.6 |
| File | Set file name to store the records. If not set, the file name will be the _tag_ associated with the records. |
| Format | The format of the file content. See also Format section. Default: out\_file. |
| Mkdir | Recursively create output directory if it does not exist. Permissions set to 0755. |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

## Format

### out\_file format

Output time, tag and json records. There is no configuration parameters for out\_file.

```text
tag: [time, {"key1":"value1", "key2":"value2", "key3":"value3"}]
```

### plain format

Output the records as JSON \(without additional `tag` and `timestamp` attributes\). There is no configuration parameters for plain format.

```json
{"key1":"value1", "key2":"value2", "key3":"value3"}
```

### csv format

Output the records as csv. Csv supports an additional configuration parameter.

| Key | Description |
| :--- | :--- |
| Delimiter | The character to separate each data. Accepted values are "\t" (or "tab"), "space" or "comma". Other values are ignored and will use default silently. Default: ',' |

```text
time[delimiter]"value1"[delimiter]"value2"[delimiter]"value3"
```

### ltsv format

Output the records as LTSV. LTSV supports an additional configuration parameter.

| Key | Description |
| :--- | :--- |
| Delimiter | The character to separate each pair. Default: '\t'\(TAB\) |
| Label\_Delimiter | The character to separate label and the value. Default: ':' |

```text
field1[label_delimiter]value1[delimiter]field2[label_delimiter]value2\n
```

### template format

Output the records using a custom format template.

| Key | Description |
| :--- | :--- |
| Template | The format string. Default: '{time} {message}' |

This accepts a formatting template and fills placeholders using corresponding values in a record.

For example, if you set up the configuration as below:

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

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```shell
fluent-bit -i cpu -o file -p path=output.txt
```

### Configuration File

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