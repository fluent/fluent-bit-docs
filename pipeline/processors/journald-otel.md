# Journald OpenTelemetry

The _journald OpenTelemetry_ (`journald_otel`) processor maps `systemd` journal fields to the OpenTelemetry logs data model. It moves the journal message into the log body, converts the journal priority to an OpenTelemetry severity, and moves well-known journal fields into OpenTelemetry resource and log attributes. Use it with the [Systemd input plugin](../inputs/systemd.md) before sending logs to a destination that expects OpenTelemetry-formatted data, such as the [OpenTelemetry output plugin](../outputs/opentelemetry.md).

{% hint style="info" %}

Only [YAML configuration files](../../administration/configuring-fluent-bit/yaml.md) support processors.

{% endhint %}

## Configuration parameters

The journald OpenTelemetry processor doesn't use configuration parameters. It supports [conditional processing](./conditional-processing.md) and processes logs only.

## Field mapping

The processor reads the fields of each log record and builds the OpenTelemetry representation as follows.

| Journal field | OpenTelemetry destination | Notes |
| ------------- | ------------------------- | ----- |
| `MESSAGE` | Log body `message` | The new log body contains only `message`. |
| `PRIORITY` | Severity number and severity text | Values `0` to `7` map as shown in the severity table. |
| `__REALTIME_TIMESTAMP` | Log record timestamp | Microseconds since the Unix epoch. Replaces the record timestamp. |
| `_HOSTNAME` | Resource attribute `host.name` | String value. |
| `_PID` | Resource attribute `process.pid` | Converted to an integer. |
| `_EXE` | Resource attribute `process.executable.path` | String value. |
| `_CMDLINE` | Resource attribute `process.command_line` | String value. |
| `CODE_FILE` | Log attribute `code.file.path` | String value. |
| `CODE_FUNC` | Log attribute `code.function.name` | String value. |
| `CODE_LINE` | Log attribute `code.line.number` | Converted to an integer. |
| `SYSLOG_FACILITY` | Log attribute `syslog.facility.code` | Converted to an integer. |
| `SYSLOG_IDENTIFIER` | Log attribute `syslog.identifier` | String value. |
| `SYSLOG_PID` | Log attribute `syslog.pid` | Converted to an integer. |
| `SYSLOG_TIMESTAMP` | Log attribute `syslog.timestamp` | String value. |
| Any other field | Log attribute `journald.<FIELD>` | Original value is kept. For example, `_SYSTEMD_UNIT` becomes `journald._SYSTEMD_UNIT`. |

`PRIORITY` values map to OpenTelemetry severities as follows:

| `PRIORITY` | Severity text | Severity number |
| ---------- | ------------- | --------------- |
| `0` | `emerg` | `21` |
| `1` | `alert` | `19` |
| `2` | `crit` | `18` |
| `3` | `err` | `17` |
| `4` | `warning` | `13` |
| `5` | `notice` | `10` |
| `6` | `info` | `9` |
| `7` | `debug` | `5` |

Fields that can't be converted keep their original value as a `journald.<FIELD>` log attribute instead. This applies to a `PRIORITY` outside the range `0` to `7`, a numeric field that isn't a non-negative integer, or a string field with a non-string value.

Journal field names are matched exactly and are case-sensitive. If you enable the `lowercase` or `strip_underscores` options of the Systemd input plugin, the field names no longer match and the fields are stored as `journald.<FIELD>` log attributes.

## Grouping behavior

The processor wraps each mapped record in its own OpenTelemetry group, with the resource attributes listed in the field mapping table and an empty instrumentation scope. Each journal entry can come from a different process, so one group per record keeps each record's resource attributes accurate. Existing record metadata is preserved.

The processor leaves the following records unchanged:

- Records that already contain OpenTelemetry (`otlp`) metadata.
- Records that already belong to a group, such as records from the [OpenTelemetry input plugin](../inputs/opentelemetry.md).
- Records that don't match the processor's `condition`, when one is set.

## Example

The following example reads entries from the `systemd` journal, maps them to the OpenTelemetry logs data model, and sends them to an OpenTelemetry endpoint.

```yaml
pipeline:
  inputs:
    - name: systemd
      tag: host.*
      systemd_filter: _SYSTEMD_UNIT=docker.service

      processors:
        logs:
          - name: journald_otel

  outputs:
    - name: opentelemetry
      match: '*'
      host: 127.0.0.1
      port: 4318
```

For example, a journal entry with the fields `MESSAGE=Started container`, `PRIORITY=6`, `_HOSTNAME=node-1`, `_PID=1234`, and `_SYSTEMD_UNIT=docker.service` produces a log record with:

- Body `{"message": "Started container"}`.
- Severity text `info` and severity number `9`.
- Resource attributes `host.name=node-1` and `process.pid=1234`.
- Log attribute `journald._SYSTEMD_UNIT=docker.service`.
