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
| String\_Inserts | Whether to include StringInserts in output records. \(optional\) | False  |
| Render\_Event\_As\_XML | Whether to render system part of event as XML string or not. \(optional\) | False  |
| Use\_ANSI | Use ANSI encoding on eventlog messages. \(optional\) | False  |

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

### Command Line

If you want to do a quick test, you can run this plugin from the command line.

```bash
$ fluent-bit -i winevtlog -p 'channels=Setup' -p 'Read_Existing_Events=true' -o stdout
```

Note that `winevtlog` plugin will tail channles on each startup.
If you want to confirm whether this plugin is working or not, you should specify `-p 'Read_Existing_Events=true'` parameter.
