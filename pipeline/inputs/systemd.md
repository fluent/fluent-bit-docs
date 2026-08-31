# Systemd

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Systemd_ input plugin lets you collect log messages from the `journald` daemon in Linux environments.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                   | Description                                                                                                                                                                                                                                                                                                                                                   | Default |
|:----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| `db`                  | Specify the absolute path of a database file to keep track of the `journald` cursor.                                                                                                                                                                                                                                                                          | _none_  |
| `db.sync`             | Set a default synchronization (I/O) method. Possible values: `extra`, `full`, `normal`, and `off`. This flag affects how the internal SQLite engine synchronizes to disk. For more details, see the [SQLite documentation](https://www.sqlite.org/pragma.html#pragma_synchronous). Available in Fluent Bit v1.4.6 and later.                                          | `full`  |
| `lowercase`           | Lowercase the `journald` field (key).                                                                                                                                                                                                                                                                                                                         | `false` |
| `max_entries`         | When Fluent Bit starts, the Journal might have a high number of logs in the queue. To avoid delays and reduce memory usage, use this option to specify the maximum number of log entries that can be processed per round. Once the limit is reached, Fluent Bit will continue processing the remaining log entries once `journald` performs the notification. | `5000`  |
| `max_fields`          | Set a maximum number of fields (keys) allowed per record.                                                                                                                                                                                                                                                                                                     | `8000`  |
| `path`                | Optional path to the Systemd journal directory. If not set, the plugin uses default paths to read local-only logs.                                                                                                                                                                                                                                            | _none_  |
| `read_from_tail`      | Start reading new entries. Skip entries already stored in `journald`.                                                                                                                                                                                                                                                                                         | `false` |
| `strip_underscores`   | Remove the leading underscore of the `journald` field (key). For example, the `journald` field `_PID` becomes the key `PID`.                                                                                                                                                                                                                                  | `false` |
| `systemd_filter`      | Perform a query over logs that contain specific `journald` key/value pairs. For example, `_SYSTEMD_UNIT=UNIT`. The `systemd_filter` option can be specified multiple times in the input section to apply multiple filters.                                                                                                                                    | _none_  |
| `systemd_filter_type` | Define the filter type when `systemd_filter` is specified multiple times. Allowed values: `and`, `or`. With `and` a record is matched only when all `systemd_filter` have a match. With `or` a record is matched when any `systemd_filter` has a match.                                                                                                | `or`    |
| `tag`                 | Fluent Bit uses tags to route messages. For the Systemd input plugin, tags have an additional capability: if the tag includes a wildcard (`*`), it will be expanded with the Systemd Unit file (`_SYSTEMD_UNIT`, like `host.* => host.UNIT_NAME`) or `unknown` (`host.unknown`) if `_SYSTEMD_UNIT` is missing.                                                              | _none_  |
| `threaded`            | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                                                                                                       | `false` |

## Get started

To receive Systemd messages, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for Systemd messages with the following options:

```shell
fluent-bit -i systemd \
           -p systemd_filter=_SYSTEMD_UNIT=docker.service \
           -p tag='host.*' \
           -o stdout
```

This example collects all messages coming from the Docker service.

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: systemd
      tag: host.*
      systemd_filter: _SYSTEMD_UNIT=docker.service
  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush        1
  Log_Level    info

[INPUT]
  Name            systemd
  Tag             host.*
  Systemd_Filter  _SYSTEMD_UNIT=docker.service

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Parse messages with a per-unit parser

The Systemd input plugin can select a [parser](../parsers.md) at runtime, on a per-entry basis, based on the value of the `FLUENT_BIT_PARSER` journal field. When this field is present, the plugin applies the named parser to the entry's `MESSAGE` field and emits the parsed key/value pairs as structured fields instead of the raw message.

Use this when the application that emits the logs knows how its messages are formatted (for example `logfmt` or `json`). You can advertise the parser directly from the systemd unit file using `LogExtraFields`, without adding any plugin configuration:

```ini
[Service]
LogExtraFields=FLUENT_BIT_PARSER=logfmt
```

Every journal entry produced by that unit then carries `FLUENT_BIT_PARSER=logfmt`, and Fluent Bit parses the `MESSAGE` field with the `logfmt` parser (which must be defined in your parsers configuration).

Behavior notes:

- The `FLUENT_BIT_PARSER` field is treated as metadata: it's removed from the emitted record and doesn't count toward `max_fields`.
- Only the `MESSAGE` field is parsed. The parsed fields replace the raw `MESSAGE` in the resulting record.
- If the named parser doesn't exist, or if parsing fails, Fluent Bit falls back to emitting the original, unmodified `MESSAGE` (an error is logged when the parser can't be found).
- The parser is resolved per entry, so different units can request different parsers on the same journal.

### Configuration example

Define the parser you want to reference. This example uses a `logfmt` parser:

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
  Name   logfmt
  Format logfmt
```

{% endtab %}
{% endtabs %}

Load the parsers file and run the Systemd input as usual:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
  parsers_file: parsers.yaml

pipeline:
  inputs:
    - name: systemd
      tag: host.*
  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush        1
  Log_Level    info
  Parsers_File parsers.conf

[INPUT]
  Name  systemd
  Tag   host.*

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

With `LogExtraFields=FLUENT_BIT_PARSER=logfmt` set on the emitting unit, a message such as `level=info msg="request handled" status=200` is emitted as structured fields (`level`, `msg`, `status`) instead of a single `MESSAGE` string.