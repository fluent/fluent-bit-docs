# Windows Event Log (winevtlog)

The **winevtlog** input plugin allows you to read Windows Event Log with new API from `winevt.h`.

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Channels | A comma-separated list of channels to read from. |  |
| Interval\_Sec | Set the polling interval for each channel. \(optional\) | 1 |
| Interval\_NSec | Set the polling interval for each channel (sub seconds. \(optional\) | 0 |
| Read\_Existing\_Events | Whether to read existing events from head or tailing events at last on subscribing. \(optional\) | False |
| DB | Set the path to save the read offsets. \(optional\) |  |
| String\_Inserts | Whether to include StringInserts in output records. \(optional\) | True  |
| Render\_Event\_As\_XML | Whether to render system part of event as XML string or not. \(optional\) | False  |
| Ignore\_Missing\_Channels | Whether to ignore event channels not present in the event log, and continue running with subscribed channels. \(optional\) | False  |
| Use\_ANSI | Use ANSI encoding on eventlog messages. If you have issues receiving blank strings with old Windows versions (Server 2012 R2), setting this to True may solve the problem. \(optional\) | False  |
| Event\_Query | Specify XML query for filtering events. | `*` |
| Read\_Limit\_Per\_Cycle | Specify read limit per cycle.  | 512KiB |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |
| Remote.Server | Specify server name of remote access for Windows EventLog. | |
| Remote.Domain | Specify domain name of remote access for Windows EventLog. | |
| Remote.Username | Specify user name of remote access for Windows EventLog. | |
| Remote.Password | Specify password of remote access for Windows EventLog.  | |

Note that if you do not set _db_, the plugin will tail channels on each startup.

## Configuration Examples <a id="config_example"></a>

### Configuration File

Here is a minimum configuration example.

```python
[INPUT]
    Name         winevtlog
    Channels     Setup,Windows PowerShell
    Interval_Sec 1
    DB           winevtlog.sqlite

[OUTPUT]
    Name   stdout
    Match  *
```

Note that some Windows Event Log channels \(like `Security`\) requires an admin privilege for reading. In this case, you need to run fluent-bit as an administrator.

The default value of Read\_Limit\_Per\_Cycle is set up as 512KiB.
Note that 512KiB(= 0x7ffff = 512 * 1024 * 1024) does not equals to 512KB (= 512 * 1000 * 1000).
To increase events per second on this plugin, specify larger value than 512KiB.

#### Query Languages for Event_Query Parameter

The `Event_Query` parameter can be used to specify the XML query for filtering Windows EventLog during collection.
The supported query types are [XPath](https://developer.mozilla.org/en-US/docs/Web/XPath) and XML Query.
For further details, please refer to [the MSDN doc](https://learn.microsoft.com/en-us/windows/win32/wes/consuming-events).

### Command Line

If you want to do a quick test, you can run this plugin from the command line.

```bash
$ fluent-bit -i winevtlog -p 'channels=Setup' -p 'Read_Existing_Events=true' -o stdout
```

Note that `winevtlog` plugin will tail channels on each startup.
If you want to confirm whether this plugin is working or not, you should specify `-p 'Read_Existing_Events=true'` parameter.
