# CRI format

Use the _CRI_ parser format to create custom parsers for log lines written in the Container Runtime Interface (CRI) logging format, which container runtimes such as containerd and CRI-O use for container log files. The format doesn't use a regular expression. If you set `regex`, it's ignored.

For available configuration parameters, see [Configuring custom parsers](configuring-parser.md).

## Line format

Each line has four parts:

```text
<time> <stream> <flag> <content>
```

The parser looks for the first space that's followed by `stdout` or `stderr`, a space, `F` or `P`, and another space. Everything before that space is the time, which can't be empty and can contain spaces. The stream names and flags are case-sensitive, and tabs don't work as separators. A line with empty content still needs the space after the flag.

The content runs from after the space that follows the flag to the first line feed, or to the end of the line if there's no line feed. Any text after the first line feed is discarded. Carriage returns are kept in the content.

A line that doesn't follow this layout doesn't match the parser, the same as a line that doesn't match a `regex` parser.

## Output fields

The parser writes these four fields:

| Field | Value |
| --- | --- |
| `time` | The time text, as written by the container runtime. |
| `stream` | `stdout` or `stderr`. |
| `_p` | `F` for a full line, or `P` for a partial line. |
| `log` | The content of the line. |

All values are strings unless a decoder changes them. The `types` and `skip_empty_values` parameters don't apply to this format, so a line with empty content produces `"log":""`. Decoders set with `decode_field` or `decode_field_as` do apply.

## Time handling

The parser reads the record time only when `time_format` is set:

- `time_key` selects which of the four fields holds the time. The default is `time`. The name is case-sensitive and doesn't rename the field in the output. If `time_key` isn't one of the four field names, the parser doesn't read a time.
- `time_keep` defaults to `false`, so the field that holds the time is removed after the time is read. Set `time_keep` to `true` to keep it.
- When `time_strict` is `true` (the default) and the time doesn't match `time_format`, Fluent Bit logs an error such as `[parser] cannot parse '<value>'`, followed by a warning such as `[parser:cri_format] invalid time format %Y-%m-%dT%H:%M:%S.%L%z for '<value>'`. The field is removed even when `time_keep` is `true`. Strict matching checks only that the value starts with text that matches `time_format`. Extra characters after the matched part are ignored, without an error or warning.
- When `time_strict` is `false`, a time that doesn't fully match isn't reported, the field follows `time_keep`, and the record time can be wrong. Keep `time_strict` set to `true` unless your time values need a looser match.
- The other time parameters, such as `time_offset`, `time_zone`, and `time_system_timezone`, work as described in [Configuring custom parsers](configuring-parser.md). CRI timestamps include a UTC offset, so with `%z` in `time_format`, `time_offset` and `time_zone` have no effect. Don't turn on `time_system_timezone` for CRI timestamps: it converts the time using the system time zone and ignores the offset in the timestamp.

If the parser doesn't read a time, the record keeps the time it would have without a parsed time. For example, the [Tail](../inputs/tail.md) input uses the time it read the line, and the [Parser](../filters/parser.md) filter keeps the record's existing timestamp.

## Partial lines

The parser doesn't join partial lines. Each `P` line becomes its own record with `_p` set to `P`. To join partial lines into one record, use the built-in `cri` multiline parser described in [Multiline parsing](multiline-parsing.md#built-in-multiline-parsers). The built-in multiline parser uses this format internally, with `time_keep` turned on and `time_strict` turned off, and registers it under the reserved parser name `_ml_cri`.

## Example

The following example shows a custom parser that uses the `cri` format:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: cri_format
    format: cri
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L%z'
    time_keep: on
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name        cri_format
  Format      cri
  Time_Key    time
  Time_Format %Y-%m-%dT%H:%M:%S.%L%z
  Time_Keep   On
```

{% endtab %}
{% endtabs %}

The following log entry is valid for the previously defined parser:

```text
2019-05-07T18:57:50.904275087+00:00 stdout F hello world
```

After processing, its internal representation will be:

```text
[1557255470.904275087, {"time"=>"2019-05-07T18:57:50.904275087+00:00",
                        "stream"=>"stdout",
                        "_p"=>"F",
                        "log"=>"hello world"}]
```

## The `cri` parser in the bundled parsers file

The `parsers.conf` file that ships with Fluent Bit defines a parser named `cri` that uses the `regex` format. That parser writes the fields `time`, `stream`, `logtag`, and `message`, not the fields described on this page.

Parser names must be unique. If a parser with the same name already exists, Fluent Bit logs `[parser] parser named 'cri' already exists, skip.` and fails to load the configuration. If you load the bundled file, give your `cri` format parser a different name, such as `cri_format`. Use that name wherever you reference the parser, for example in the `parser` setting of the Tail input or the Parser filter. A reference to `cri` still selects the bundled `regex` parser. The `multiline.parser cri` setting of the Tail input refers to the built-in multiline parser and isn't affected by the name of your parser.
