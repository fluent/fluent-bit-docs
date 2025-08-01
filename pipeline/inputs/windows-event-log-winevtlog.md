# Windows Event logs (winevtlog)

The _Windows Event logs_ (`winevtlog`) input plugin lets you read Windows Event logs with the API from `winevt.h`.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                       | Description                                                                                                                                                                                | Default  |
|:--------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------|
| `Channels`                | A comma-separated list of channels to read from.                                                                                                                                           | _none_   |
| `Interval_Sec`            | Optional. Set the polling interval for each channel.                                                                                                                                       | `1`      |
| `Interval_NSec`           | Optional. Set the polling interval for each channel. (nanoseconds)                                                                                                                         | `0 `     |
| `Read_Existing_Events`    | Optional. Whether to read existing events from head or tailing events at last on subscribing.                                                                                              | `False`  |
| `DB`                      | Optional. Set the path to save the read offsets.                                                                                                                                           | _none_   |
| `String_Inserts`          | Optional. Whether to include string inserts in output records.                                                                                                                             | `True`   |
| `Render_Event_As_XML`     | Optional. Whether to render the system part of an event as an XML string or not.                                                                                                           | `False`  |
| `Ignore_Missing_Channels` | Optional. Whether to ignore event channels not present in the event log, and continue running with subscribed channels.                                                                    | `False`  |
| `Use_ANSI`                | Optional. Use ANSI encoding on `eventlog` messages. If you have issues receiving blank strings with old Windows versions (Server 2012 R2), setting this to `True` might solve the problem. | `False`  |
| `Event_Query`             | Specify XML query for filtering events.                                                                                                                                                    | `*`      |
| `Read_Limit_Per_Cycle`    | Specify read limit per cycle.                                                                                                                                                              | `512KiB` |
| Threaded                  | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                    | `false`  |
| `Remote.Server`           | Specify server name of remote access for Windows EventLog.                                                                                                                                 | _none_   |
| `Remote.Domain`           | Specify domain name of remote access for Windows EventLog.                                                                                                                                 | _none_   |
| `Remote.Username`         | Specify user name of remote access for Windows EventLog.                                                                                                                                   | _none_   |
| `Remote.Password`         | Specify password of remote access for Windows EventLog.                                                                                                                                    | _none_   |

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

The default value of `Read_Limit_Per_Cycle` is `512KiB`.

512&nbsp;KiB(= 0x7ffff = 512 * 1024 * 1024) isn't equal to 512&nbsp;KB (= 512 * 1000 * 1000). To increase events per second on this plugin, specify larger value than 512&nbsp;KiB.

#### Query languages for `Event_Query` parameter

The `Event_Query` parameter can be used to specify the XML query for filtering Windows EventLog during collection.
The supported query types are [`XPath`](https://developer.mozilla.org/en-US/docs/Web/XPath) and XML Query.
For further details, refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/win32/wes/consuming-events).

### Command line

If you want to do a test, you can run this plugin from the command line:

```shell
fluent-bit -i winevtlog -p 'channels=Setup' -p 'Read_Existing_Events=true' -o stdout
```

The `winevtlog` plugin will tail channels on each startup.
If you want to confirm whether this plugin is working or not, specify the `-p 'Read_Existing_Events=true'` parameter.
