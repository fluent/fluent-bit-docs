# File

{% hint style="info" %}
**Supported event types:** `logs` `metrics`
{% endhint %}

The _File_ output plugin lets you write the data received through the input plugin to file.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `file` | Set filename to store the records. If not set, the filename will be the `tag` associated with the records. | _none_ |
| `files_rotation` | Enable size-based [log rotation](#log-rotation). When enabled, files that exceed `max_size` are rotated and optionally compressed. | `false` |
| `format` | The [format](#format) of the file content. | _none_ |
| `gzip` | Compress rotated files using gzip. Only applies when `files_rotation` is enabled. | `true` |
| `max_files` | Maximum number of rotated files to retain per output file. Oldest files are deleted first. Must be `1` or greater. Only applies when `files_rotation` is enabled. | `7` |
| `max_size` | Maximum size of the active output file before rotation is triggered. Supports size suffixes: `k` (kilobytes), `m` (megabytes), `g` (gigabytes). Only applies when `files_rotation` is enabled. | `100m` |
| `mkdir` | Recursively create output directory if it doesn't exist. Permissions set to `0755`. | `false` |
| `path` | Directory path to store files. If not set, Fluent Bit will write the files in its own working directory. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

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

Output the records in CSV format. CSV mode supports additional configuration parameters.

| Key | Description | Default |
| :--- | :--- | :--- |
| `csv_column_names` | Add column names (keys) as the first line of the output file. | `false` |
| `delimiter` | The character to separate each field. Accepted values: `\t` (or `tab`), ` ` (`space`), or `,` (`comma`). Other values are ignored and fall back to the default. | `,` |

```text
time[delimiter]"value1"[delimiter]"value2"[delimiter]"value3"
```

### LTSV

Output the records in LTSV format. LTSV mode supports additional configuration parameters.

| Key | Description | Default |
| :--- | :--- | :--- |
| `delimiter` | The character to separate each pair. | `\t` |
| `label_delimiter` | The character to separate label and the value. | `:` |

```text
field1[label_delimiter]value1[delimiter]field2[label_delimiter]value2\n
```

### Template

Output the records using a custom format template.

| Key | Description | Default |
| :--- | :--- | :--- |
| `template` | The format string. | `{time} {message}` |

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

## Log rotation

The File output plugin supports size-based log rotation.

When `files_rotation` is enabled, the plugin monitors the size of each output file. Once a file exceeds `max_size`, the next flush rotates the file by renaming it with a timestamp suffix in the format `<filename>.<YYYYMMDD_HHMMSS_XXXXXXXX>`. The `YYYYMMDD_HHMMSS` is machine local timestamp of the time the rotation occurred, and `XXXXXXXX` is a random identifier to guarantee unique filenames if multiple rotations happen within the same second.

If `gzip` is enabled (the default), rotated files are compressed with gzip and stored with an additional `.gz` extension (for example, `cpu.log.20260512_134500_a1b2c3d4.gz`).

The plugin retains up to `max_files` rotated files per output file. When the limit is reached, the oldest rotated files are deleted automatically.

Log rotation works with all supported output [formats](#format): `plain`, `CSV`, `LTSV`, `template`, and `msgpack`. File operations are thread-safe, so rotation can be used alongside multiple [workers](../../administration/multithreading.md#outputs).

### Log rotation example

The following configuration writes CPU metrics to file with rotation enabled. Files are rotated at 50 MB and the five most recent rotated files are retained with gzip compression:

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
      path: /var/log/fluent-bit
      file: cpu.log
      files_rotation: true
      max_size: 50m
      max_files: 5
      gzip: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name           file
  Match          *
  Path           /var/log/fluent-bit
  File           cpu.log
  Files_Rotation true
  Max_Size       50m
  Max_Files      5
  Gzip           true
```

{% endtab %}
{% endtabs %}

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
