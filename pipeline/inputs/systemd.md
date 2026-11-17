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
| `db.sync`             | Set a default synchronization (I/O) method. Possible values: `extra`, `full`, `normal`, and `off`. This flag affects how the internal SQLite engine synchronizes to disk. For more details, see the [SQLite documentation](https://www.sqlite.org/pragma.html#pragma_synchronous). Available in Fluent Bit v1.4.6 and later.                                  | `full`  |
| `lowercase`           | Lowercase the `journald` field (key).                                                                                                                                                                                                                                                                                                                         | `false` |
| `max_entries`         | When Fluent Bit starts, the Journal might have a high number of logs in the queue. To avoid delays and reduce memory usage, use this option to specify the maximum number of log entries that can be processed per round. Once the limit is reached, Fluent Bit will continue processing the remaining log entries once `journald` performs the notification. | `5000`  |
| `max_fields`          | Set a maximum number of fields (keys) allowed per record.                                                                                                                                                                                                                                                                                                     | `8000`  |
| `namespace`           | Read from a specific `journald` namespace instead of the default journal. See [Journal namespaces](#journal-namespaces). Can't be used with `path`. Setting both causes a startup error.                                                                                                                                                                      | _none_  |
| `path`                | Optional path to the Systemd journal directory. If not set, the plugin uses default paths to read local-only logs.                                                                                                                                                                                                                                            | _none_  |
| `read_from_tail`      | Start reading new entries. Skip entries already stored in `journald`.                                                                                                                                                                                                                                                                                         | `false` |
| `read_since`          | Start reading entries written within this period before Fluent Bit starts, for example `30m`, `1h`, or `2d`. `0` disables this option. See [Start position](#start-position).                                                                                                                                                                                 | `0`     |
| `strip_underscores`   | Remove the leading underscore of the `journald` field (key). For example, the `journald` field `_PID` becomes the key `PID`.                                                                                                                                                                                                                                  | `false` |
| `systemd_filter`      | Perform a query over logs that contain specific `journald` key/value pairs. For example, `_SYSTEMD_UNIT=UNIT`. The `systemd_filter` option can be specified multiple times in the input section to apply multiple filters.                                                                                                                                    | _none_  |
| `systemd_filter_type` | Define the filter type when `systemd_filter` is specified multiple times. Allowed values: `and`, `or`. With `and` a record is matched only when all `systemd_filter` have a match. With `or` a record is matched when any `systemd_filter` has a match.                                                                                                       | `or`    |
| `tag`                 | Fluent Bit uses tags to route messages. For the Systemd input plugin, tags have an additional capability: if the tag includes a wildcard (`*`), it will be expanded with the Systemd Unit file (`_SYSTEMD_UNIT`, like `host.* => host.UNIT_NAME`) or `unknown` (`host.unknown`) if `_SYSTEMD_UNIT` is missing.                                                | _none_  |
| `threaded`            | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                                                                                                       | `false` |

## Journal namespaces

Systemd can partition the journal into [namespaces](https://www.freedesktop.org/software/systemd/man/latest/systemd-journald.service.html#Journal%20Namespaces), where a separate `systemd-journald` instance keeps its own log storage for a set of units. Set `namespace` to collect from one of these namespaces instead of the default journal.

Keep the following in mind when using `namespace`:

- The plugin reads only the named namespace. Entries in the default journal aren't collected. To collect both, define a separate `systemd` input for each.
- `namespace` and `path` are mutually exclusive. If you set both, Fluent Bit logs `path and namespace are mutually exclusive` and fails to start.
- This option requires a Fluent Bit binary built against `libsystemd` 245 or later, which is when `sd_journal_open_namespace` was introduced. If the binary was built against an older version, Fluent Bit logs `namespace requires libsystemd >= 245` and fails to start. Use `path` instead on those builds.
- When you use `db` to track the journal cursor, give each namespace its own database file. Reusing one database file across namespaces produces a cursor that the other namespace can't seek to, and the plugin logs a `seek_cursor failed` warning and starts over.

The following example collects logs from a namespace named `logging`, and writes the cursor to a database file dedicated to that namespace:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: systemd
      tag: host.*
      namespace: logging
      db: /var/lib/fluent-bit/systemd-logging.db
  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name       systemd
  Tag        host.*
  Namespace  logging
  DB         /var/lib/fluent-bit/systemd-logging.db

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Start position

When there's no saved cursor, the plugin starts reading from the oldest entry in the journal. On hosts with a large journal, this can mean processing a large backlog at startup. Use one of the following parameters to start somewhere else:

- `read_from_tail` skips all existing entries and reads only entries written after Fluent Bit starts.
- `read_since` reads entries written within the given period before Fluent Bit starts. Use a whole number followed by a single unit: `m` for minutes, `h` for hours, or `d` for days. A number without a unit is in seconds. Combined values such as `1h30m` aren't supported, so use `90m` instead. Fluent Bit doesn't reject other formats. It reads the leading whole number and checks only the last character for a unit, so `1h30m` is read as 1 minute, `1.5h` as 1 hour, and `1hour` as 1 second. The plugin then skips entries you expected it to read.

Keep the following in mind when using these parameters:

- If `db` has a saved cursor, the plugin resumes from that cursor and ignores `read_from_tail` and `read_since`. The plugin doesn't check that the cursor's entry still exists. If that entry was removed, for example by journal rotation, the seek moves to the closest remaining entry in time. The plugin treats that entry as already read and skips it, so collection starts with the entry after it. `read_from_tail` and `read_since` apply only when there's no saved cursor, or when seeking to the saved cursor returns an error.
- If you set both `read_since` and `read_from_tail`, `read_since` takes precedence.
- `read_since` relies on the timestamps stored in the journal. If the system clock changed during that period, the start position is approximate.

## Map journal fields to OpenTelemetry

To convert journal entries to the OpenTelemetry logs data model, attach the [journald OpenTelemetry processor](../processors/journald-otel.md) to this input. The processor matches journal field names exactly, so it doesn't recognize renamed fields when `lowercase` or `strip_underscores` is enabled.

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