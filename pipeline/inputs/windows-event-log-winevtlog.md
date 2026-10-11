# Windows Event logs (winevtlog)

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Windows Event logs_ (`winevtlog`) input plugin lets you read Windows Event logs with the API from `winevt.h`.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                         | Description                                                                                                                                                                                | Default  |
|:----------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------|
| `channels`                  | A comma-separated list of channels to read from.                                                                                                                                           | _none_   |
| `db`                        | Optional. Set the path to save the read offsets.                                                                                                                                           | _none_   |
| `event_data_as_map`         | Optional. Emit `EventData` as a named map built from provider metadata instead of string inserts. Requires `event_template_cache_size` greater than zero.                                  | `false`  |
| `event_query`               | Specify XML query for filtering events.                                                                                                                                                    | `*`      |
| `event_template_cache_size` | Optional. Maximum number of provider event templates cached when `event_data_as_map` is enabled.                                                                                           | `256`    |
| `ignore_missing_channels`   | Optional. Whether to ignore event channels not present in the event log, and continue running with subscribed channels.                                                                    | `false`  |
| `interval_nsec`             | Optional. Set the polling interval for each channel. (nanoseconds)                                                                                                                         | `0`      |
| `interval_sec`              | Optional. Set the polling interval for each channel.                                                                                                                                       | `1`      |
| `read_existing_events`      | Optional. Whether to read existing events from head or tailing events at last on subscribing.                                                                                              | `false`  |
| `read_limit_per_cycle`      | Specify read limit per cycle.                                                                                                                                                              | `512KiB` |
| `remote.domain`             | Specify domain name of remote access for Windows EventLog.                                                                                                                                 | _none_   |
| `remote.password`           | Specify password of remote access for Windows EventLog.                                                                                                                                    | _none_   |
| `remote.server`             | Specify server name of remote access for Windows EventLog.                                                                                                                                 | _none_   |
| `remote.username`           | Specify user name of remote access for Windows EventLog.                                                                                                                                   | _none_   |
| `reconnect.base_ms`         | Base reconnect delay in milliseconds after a subscription failure.                                                                                                                         | `500`    |
| `reconnect.max_ms`          | Maximum reconnect delay in milliseconds.                                                                                                                                                   | `30000`  |
| `reconnect.multiplier`      | Backoff multiplier applied between reconnect attempts.                                                                                                                                     | `2.0`    |
| `reconnect.jitter_pct`      | Jitter percentage applied to the reconnect delay to avoid synchronized retries.                                                                                                            | `20`     |
| `reconnect.max_retries`     | Maximum number of reconnect attempts before the channel stops retrying.                                                                                                                    | `8`      |
| `render_event_as_text`      | Optional. Render the Windows EventLog event as newline-separated `key=value` text. Mutually exclusive with `render_event_as_xml`.                                                          | `false`  |
| `render_event_as_xml`       | Optional. Render the Windows EventLog event as XML, including the System and Message fields. Mutually exclusive with `render_event_as_text`.                                               | `false`  |
| `render_event_text_key`     | Optional. Record key name used to store the rendered text when `render_event_as_text` is enabled.                                                                                          | `log`    |
| `string_inserts`            | Optional. Whether to include string inserts in output records.                                                                                                                             | `true`   |
| `threaded`                  | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                    | `false`  |
| `use_ansi`                  | Optional. Use ANSI encoding on `eventlog` messages. If you have issues receiving blank strings with old Windows versions (Server 2012 R2), setting this to `true` might solve the problem. | `false`  |

If `db` isn't set, the plugin will tail channels on each startup.

## Configuration examples

### Configuration file

Here is a minimum configuration example.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: winevtlog
      channels: Setup,Windows PowerShell
      interval_sec: 1
      db: winevtlog.sqlite

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name         winevtlog
  Channels     Setup,Windows PowerShell
  Interval_Sec 1
  DB           winevtlog.sqlite

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

Some Windows Event Log channels, like `Security`, require administrative privilege for reading. In this case, you must run Fluent Bit as an administrator.

The default value of `read_limit_per_cycle` is `512KiB`.

512&nbsp;KiB(= 0x7ffff = 512 * 1024 * 1024) isn't equal to 512&nbsp;KB (= 512 * 1000 * 1000). To increase events per second on this plugin, specify larger value than 512&nbsp;KiB.

#### Query languages for `event_query` parameter

The `event_query` parameter can be used to specify the XML query for filtering Windows EventLog during collection.
The supported query types are [`XPath`](https://developer.mozilla.org/en-US/docs/Web/XML/XPath) and XML Query.
For further details, refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/win32/wes/consuming-events).

### Render events as text

When `render_event_as_text` is set to `true`, each event is rendered as a newline-separated `key=value` string and stored under the key specified by `render_event_text_key`. This mode is mutually exclusive with `render_event_as_xml`—enabling both causes the plugin to exit with an error.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: winevtlog
      channels: Setup,Windows PowerShell
      db: winevtlog.sqlite
      render_event_as_text: true
      render_event_text_key: log

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name                   winevtlog
  Channels               Setup,Windows PowerShell
  DB                     winevtlog.sqlite
  Render_Event_As_Text   true
  Render_Event_Text_Key  log

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

### Emit EventData as a map

By default, the `EventData` values of an event are emitted as string inserts. When `event_data_as_map` is set to `true`, the plugin uses the event provider's metadata to emit `EventData` as a named map, so each value is keyed by its field name instead of appearing as a positional string insert.

This mode caches provider event templates. Use `event_template_cache_size` to set the maximum number of cached templates. The value must be greater than zero when `event_data_as_map` is enabled, otherwise the plugin exits with an error.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: winevtlog
      channels: Setup,Windows PowerShell
      db: winevtlog.sqlite
      event_data_as_map: true
      event_template_cache_size: 256

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name                       winevtlog
  Channels                   Setup,Windows PowerShell
  DB                         winevtlog.sqlite
  Event_Data_As_Map          true
  Event_Template_Cache_Size  256

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

### Command line

If you want to do a test, you can run this plugin from the command line:

```shell
fluent-bit -i winevtlog -p 'channels=Setup' -p 'read_existing_events=true' -o stdout
```

The `winevtlog` plugin will tail channels on each startup.
If you want to confirm whether this plugin is working or not, specify the `-p 'read_existing_events=true'` parameter.
