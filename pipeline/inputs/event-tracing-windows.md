# Event Tracing for Windows

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Event Tracing for Windows_ (`event_tracing_windows`) input plugin collects real-time [Event Tracing for Windows](https://learn.microsoft.com/en-us/windows/win32/etw/about-event-tracing) (ETW) events.

Use this plugin to define the Windows ETW provider you want to consume, similar to defining an arbitrary Windows Performance Counter. You can select a provider by name or GUID, tune the ETW level and keyword masks, and collect decoded event payload fields through Fluent Bit.

{% hint style="info" %}
This plugin is only available on Windows operating systems. Some ETW providers and system logger sessions require administrative privileges.
{% endhint %}

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                    | Description                                                                                                                                          | Default                              |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| `provider_guid`        | ETW provider GUID to enable. Required for `provider` sessions unless `provider_name` is set.                                                         | _none_                               |
| `provider_name`        | ETW provider name to resolve and enable. Required for `provider` sessions unless `provider_guid` is set.                                              | _none_                               |
| `session_name`         | ETW real-time session name. When `session_type` is `system` and this value is left as the default, the plugin uses `NT Kernel Logger`.                | `fluent-bit-event-tracing-windows`   |
| `session_type`         | ETW session type. Use `provider` for a real-time provider consumer, or `system` for a Windows kernel logger session that uses `kernel_flags`.         | `provider`                           |
| `stale_session_action` | Action when the ETW session already exists. Use `stop` to stop the existing session and retry, or `fail` to return an error without stopping it.      | `stop`                               |
| `level`                | ETW provider level. Valid values are `0` to `255`.                                                                                                   | `5`                                  |
| `match_any_keyword`    | ETW `MatchAnyKeyword` mask. Decimal and hexadecimal values are accepted.                                                                              | `0xffffffffffffffff`                 |
| `match_all_keyword`    | ETW `MatchAllKeyword` mask. Decimal and hexadecimal values are accepted.                                                                              | `0`                                  |
| `kernel_flags`         | Comma-separated kernel flags used with `session_type system`. Supported names are `process`, `thread`, `image_load`, `cswitch`, `tcpip`, `disk_io`. A numeric `EVENT_TRACE_FLAG_*` mask is also accepted. | `process,thread,image_load` |
| `buffer_size`          | ETW session buffer size in kilobytes. Zero uses the Windows default.                                                                                 | `64`                                 |
| `minimum_buffers`      | Minimum number of ETW session buffers. Zero uses the Windows default.                                                                                | `4`                                  |
| `maximum_buffers`      | Maximum number of ETW session buffers. Zero uses the Windows default.                                                                                | `32`                                 |
| `flush_timer`          | ETW session flush timer in seconds. Zero uses the Windows default.                                                                                   | `1`                                  |

For `provider` sessions, set `provider_guid`, `provider_name`, or both. If both are set, the resolved provider name must match the configured GUID.

For `system` sessions, don't set `provider_guid` or `provider_name`. Use `kernel_flags` to select Windows kernel events.

The session buffer memory upper bound is `buffer_size` KB multiplied by `maximum_buffers`. With the defaults, the upper bound is `64` KB multiplied by `32`, or `2048` KB.

## Event record fields

Each ETW event is emitted as a log record with the ETW timestamp and the following fields:

| Field                 | Description                                           |
|-----------------------|-------------------------------------------------------|
| `provider_guid`       | Provider GUID from the ETW event header.              |
| `provider_name`       | Configured provider name, or `null` if unset.         |
| `event_id`            | ETW event ID.                                         |
| `version`             | ETW event version.                                    |
| `channel`             | ETW event channel.                                    |
| `level`               | ETW event level.                                      |
| `task`                | ETW event task.                                       |
| `opcode`              | ETW event opcode.                                     |
| `keywords`            | ETW event keyword mask.                               |
| `process_id`          | Process ID from the ETW event header.                 |
| `thread_id`           | Thread ID from the ETW event header.                  |
| `activity_id`         | ETW activity ID.                                      |
| `related_activity_id` | Related activity ID when present, otherwise `null`.   |
| `payload`             | Decoded top-level ETW payload fields as key-value data. |

## Configuration examples

### Provider name

The following example collects events from the `Microsoft-Windows-Kernel-Process` provider by resolving the provider name:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: event_tracing_windows
      tag: etw.process
      provider_name: Microsoft-Windows-Kernel-Process
      level: 5
      match_any_keyword: 0xffffffffffffffff

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    name              event_tracing_windows
    tag               etw.process
    provider_name     Microsoft-Windows-Kernel-Process
    level             5
    match_any_keyword 0xffffffffffffffff

[OUTPUT]
    name  stdout
    match *
```

{% endtab %}
{% endtabs %}

### Provider GUID

The following example selects a provider by GUID:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: event_tracing_windows
      tag: etw.provider
      provider_guid: '{22fb2cd6-0e7b-422b-a0c7-2fad1fd0e716}'
      level: 5
      match_any_keyword: 0xffffffffffffffff
      match_all_keyword: 0

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    name              event_tracing_windows
    tag               etw.provider
    provider_guid     {22fb2cd6-0e7b-422b-a0c7-2fad1fd0e716}
    level             5
    match_any_keyword 0xffffffffffffffff
    match_all_keyword 0

[OUTPUT]
    name  stdout
    match *
```

{% endtab %}
{% endtabs %}

### Windows kernel events

Use `session_type system` to collect Windows kernel logger events. The system session uses `kernel_flags` instead of a provider name or GUID:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: event_tracing_windows
      tag: etw.kernel
      session_type: system
      kernel_flags: process,thread,image_load

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    name         event_tracing_windows
    tag          etw.kernel
    session_type system
    kernel_flags process,thread,image_load

[OUTPUT]
    name  stdout
    match *
```

{% endtab %}
{% endtabs %}

## Requirements and permissions

The Event Tracing for Windows input plugin uses Windows ETW real-time sessions and Trace Data Helper (TDH) APIs. The following requirements apply:

- **Operating system**: Windows only.
- **Provider availability**: The configured `provider_name` must exist in the registered ETW providers on the host. If you use `provider_guid`, the GUID must be a valid ETW provider GUID.
- **Permissions**: The Fluent Bit process must have permission to start the ETW session and enable the selected provider. System logger sessions and some providers require running Fluent Bit as an administrator.

If startup fails with an access error, run Fluent Bit with administrator privileges or use a service account that has permission to create and consume the selected ETW session.
