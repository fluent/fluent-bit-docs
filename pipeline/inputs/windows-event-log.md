# Windows Event Log

The **winlog** input plugin allows you to read Windows Event Log.

## Configuration Parameters <a href="config" id="config"></a>

The plugin supports the following configuration parameters:

| Key          | Description                                           | Default |
| ------------ | ----------------------------------------------------- | ------- |
| Channels     | A comma-separated list of channels to read from.      |         |
| Interval_Sec | Set the polling interval for each channel. (optional) | 1       |
| DB           | Set the path to save the read offsets. (optional)     |         |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

Note that if you do not set _db_, the plugin will read channels from the beginning on each startup.

## Configuration Examples <a href="config_example" id="config_example"></a>

### Configuration File

Here is a minimum configuration example.

```python
[INPUT]
    Name         winlog
    Channels     Setup,Windows PowerShell
    Interval_Sec 1
    DB           winlog.sqlite

[OUTPUT]
    Name   stdout
    Match  *
```

Note that some Windows Event Log channels (like `Security`) requires an admin privilege for reading. In this case, you need to run fluent-bit as an administrator.

### Command Line

If you want to do a quick test, you can run this plugin from the command line.

```bash
$ fluent-bit -i winlog -p 'channels=Setup' -o stdout
```
