# File

{% hint style="info" %}
**Supported event types:** `logs` `metrics`
{% endhint %}

The _File_ output plugin lets you write the data received through the input plugin to file.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `enable_strftime` | Enable [`strftime`](#strftime-placeholders) placeholders in `path` and `file`. Disabled by default so that literal percent (`%`) characters in existing filenames are preserved. | `false` |
| `fallback_file` | Static filename used when a `fallback` action is applied. Required whenever `path` or `file` uses a record accessor or a `strftime` placeholder. See [Dynamic destinations](#dynamic-destinations). | _none_ |
| `fallback_path` | Static directory path used together with `fallback_file` when a `fallback` action is applied. | _none_ |
| `file` | Set filename to store the records. If not set, the filename will be the `tag` associated with the records. Supports [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) expressions. When `enable_strftime` is `true`, `strftime` placeholders are expanded using the UTC event timestamp. | _none_ |
| `format` | The [format](#format) of the file content. | _none_ |
| `max_dynamic_files` | Maximum number of distinct destinations that record accessor expressions and `strftime` placeholders can resolve to. Set to `0` for unlimited. | `1024` |
| `mkdir` | Recursively create output directory if it doesn't exist. Permissions set to `0755`. | `false` |
| `on_limit_reached` | Action to take for a record whose destination would exceed `max_dynamic_files`. Accepted values: `error`, `drop`, `fallback`. | `error` |
| `on_missing_field` | Action to take for a record whose record accessor field is missing, or resolves to an unsafe value. Accepted values: `error`, `drop`, `fallback`. | `error` |
| `path` | Directory path to store files. If not set, Fluent Bit will write the files in its own working directory. Supports [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) expressions, which must follow a static prefix. When `enable_strftime` is `true`, `strftime` placeholders are expanded using the UTC event timestamp. | _none_ |
| `rotate` | Enable size-based [log rotation](#log-rotation). When enabled, files that exceed `rotate_max_size` are rotated and optionally compressed. | `false` |
| `rotate_gzip` | Compress rotated files using gzip. Only applies when `rotate` is enabled. | `true` |
| `rotate_max_files` | Maximum number of rotated files to retain per output file. Oldest files are deleted first. Must be `1` or greater. Only applies when `rotate` is enabled. | `7` |
| `rotate_max_size` | Maximum size of the active output file before rotation is triggered. Supports size suffixes: `k` (kilobytes), `m` (megabytes), `g` (gigabytes). Only applies when `rotate` is enabled. | `100M` |
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

When `rotate` is enabled, the plugin monitors the size of each output file. Once a file exceeds `rotate_max_size`, the next flush rotates the file by renaming it with a timestamp suffix in the format `<filename>.<YYYYMMDD_HHMMSS_XXXXXXXX>`. The `YYYYMMDD_HHMMSS` is the machine-local timestamp of the rotation, and `XXXXXXXX` is a random hex identifier that guarantees unique filenames if multiple rotations happen within the same second.

If `rotate_gzip` is enabled (the default), rotated files are compressed with gzip and stored with an additional `.gz` extension (for example, `cpu.log.20260512_134500_a1b2c3d4.gz`).

The plugin retains up to `rotate_max_files` rotated files per output file. When the limit is reached, the oldest rotated files are deleted automatically.

Log rotation works with all supported output [formats](#format): default (`out_file`), `plain`, `csv`, `ltsv`, `template`, and `msgpack`. File operations are thread-safe, so rotation can be used alongside multiple [workers](../../administration/multithreading.md#outputs).

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
      rotate: true
      rotate_max_size: 50M
      rotate_max_files: 5
      rotate_gzip: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

[OUTPUT]
  Name             file
  Match            *
  Path             /var/log/fluent-bit
  File             cpu.log
  Rotate           true
  Rotate_Max_Size  50M
  Rotate_Max_Files 5
  Rotate_Gzip      true
```

{% endtab %}
{% endtabs %}

## Dynamic destinations

Dynamic destinations are available in Fluent Bit version 5.1 and greater.

The `path` and `file` parameters accept [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) expressions, which lets one output instance write records to different files based on the content of each record. They also accept [`strftime` placeholders](#strftime-placeholders), which route records by the time at which each event occurred. Fluent Bit treats a destination as dynamic when `path` or `file` contains a `$` character, or when `enable_strftime` is `true` and `path` or `file` contains a percent (`%`) character.

Two rules apply when you configure a dynamic destination:

- A `path` that uses a record accessor must begin with a static prefix. Fluent Bit rejects a `path` that starts with a record accessor, so that generated paths always stay under a directory you chose. This check doesn't apply to `strftime` placeholders. See [`strftime` placeholders](#strftime-placeholders).
- You must set `fallback_file`. Fluent Bit fails to start if a record accessor or a `strftime` placeholder is used without it, because there would be nowhere to write records whose destination can't be resolved.

Fluent Bit rejects a resolved destination as unsafe when the filename is empty, is `.` or `..`, or contains a path separator or one of the characters `:`, `*`, `?`, `"`, `<`, `>`, or `|`. Path components of `.` and `..` are also rejected. This keeps a record value from redirecting output outside of the configured directory.

Generated directories are only created if you also enable `mkdir`.

Dynamic destinations apply to log records only. Metrics records are always written to `fallback_path` and `fallback_file`.

### `strftime` placeholders

Support for `strftime` placeholders is available in Fluent Bit version 5.1.1 and greater.

Set `enable_strftime` to `true` to expand [`strftime`](https://man7.org/linux/man-pages/man3/strftime.3.html) placeholders such as `%Y`, `%m`, and `%d` in `path` and `file`. Fluent Bit formats each placeholder using the timestamp of the event being written, expressed in UTC. Because the value comes from the event itself and not from the clock at flush time, records that arrive late are still written to the file for the period in which they occurred.

This parameter is disabled by default. When `enable_strftime` is `false`, a percent character in `path` or `file` is written literally, which preserves existing filenames that contain one.

When `enable_strftime` is `true`, escape every literal percent character in `path` and `file` as `%%`. A `%` that isn't escaped is consumed as the start of a `strftime` conversion specifier and is replaced with a time value.

Fluent Bit treats any `path` or `file` containing a percent character as a dynamic destination when `enable_strftime` is `true`, so `fallback_file` is required even when the value contains only escaped `%%` sequences and always resolves to the same destination.

You can combine placeholders with record accessors in the same value. Fluent Bit expands the `strftime` placeholders first, then resolves the record accessors against the result:

```text
path: /var/log/fluent-bit/%Y/%m/%d/$namespace
```

Most rules described in [Dynamic destinations](#dynamic-destinations) apply to placeholders the same way they apply to record accessors. `fallback_file` is required, resolved destinations are rejected when unsafe, and each distinct destination counts toward `max_dynamic_files`. Because a new destination is created for every time period you include, choose the smallest unit your retention needs. An hourly layout such as `%Y%m%d%H` reaches the default `max_dynamic_files` limit of `1024` after about 42 days of continuous operation.

The static prefix requirement is the exception. Fluent Bit enforces it for record accessors only, so a `path` can begin with a placeholder. A `path` of `%Y/%m/%d` resolves to a relative directory such as `2026/08/17`, located inside the Fluent Bit working directory. Begin the value with a static prefix, as in `/var/log/fluent-bit/%Y/%m/%d`, to keep output under a directory you chose.

### Actions for unresolved destinations

Two settings control what happens to a record whose destination Fluent Bit can't use. `on_missing_field` applies when the record accessor field is missing or resolves to an unsafe value, and `on_limit_reached` applies when writing to a new destination would exceed `max_dynamic_files`. Both accept the same actions:

| Action | Behavior |
| --- | --- |
| `error` | Log an error and fail the flush, so the chunk is retried. |
| `drop` | Log a warning and discard the record. |
| `fallback` | Write the record to `fallback_path` and `fallback_file` instead. |

The `max_dynamic_files` limit counts distinct destinations that this output instance has written to, which bounds the number of files a high-cardinality record field can create. Records that resolve to a destination already in use aren't affected by the limit.

### Dynamic destination example

The following configuration writes each record to a file named after its `app` field, under a per-namespace directory. Records without both fields go to `/var/log/fluent-bit/unrouted.log`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: file
      match: '*'
      path: /var/log/fluent-bit/$namespace
      file: $app.log
      mkdir: true
      max_dynamic_files: 256
      on_missing_field: fallback
      on_limit_reached: fallback
      fallback_path: /var/log/fluent-bit
      fallback_file: unrouted.log
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name              file
  Match             *
  Path              /var/log/fluent-bit/$namespace
  File              $app.log
  Mkdir             true
  Max_Dynamic_Files 256
  On_Missing_Field  fallback
  On_Limit_Reached  fallback
  Fallback_Path     /var/log/fluent-bit
  Fallback_File     unrouted.log
```

{% endtab %}
{% endtabs %}

### Time-based destination example

The following configuration writes each record to a daily directory derived from the UTC event timestamp. Records whose destination can't be resolved go to `/var/log/fluent-bit/unrouted.log`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: file
      match: '*'
      path: /var/log/fluent-bit/%Y/%m/%d
      file: app.log
      enable_strftime: true
      mkdir: true
      on_missing_field: fallback
      on_limit_reached: fallback
      fallback_path: /var/log/fluent-bit
      fallback_file: unrouted.log
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name             file
  Match            *
  Path             /var/log/fluent-bit/%Y/%m/%d
  File             app.log
  Enable_Strftime  true
  Mkdir            true
  On_Missing_Field fallback
  On_Limit_Reached fallback
  Fallback_Path    /var/log/fluent-bit
  Fallback_File    unrouted.log
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
