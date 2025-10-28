# Windows Event logs (winlog)

The _Windows Event logs_ (`winlog`) input plugin lets you read Windows Event logs.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key            | Description                                                                                             | Default |
|----------------|---------------------------------------------------------------------------------------------------------|---------|
| `Channels`     | A comma-separated list of channels to read from.                                                        | _none_  |
| `Interval_Sec` | Set the polling interval for each channel. (optional)                                                   | `1`     |
| `DB`           | Set the path to save the read offsets. (optional)                                                       | _none_  |
| `Threaded`     | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

If `db` isn't set, the plugin will read channels from the beginning on each startup.

## Configuration examples

### Configuration file

Here is a minimum configuration example.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: winlog
      channels: setup,Windows Powershell
      interval_sec: 1
      db: winlog.sqlite

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name         winlog
  Channels     Setup,Windows PowerShell
  Interval_Sec 1
  DB           winlog.sqlite

[OUTPUT]
  Name   stdout
  Match  *
```

Some Windows Event Log channels, like `Security`, require administrative privileges for reading. In this case, you need to run Fluent Bit as an administrator.

### Command line

If you want to do a test, you can run this plugin from the command line:

```shell
fluent-bit -i winlog -p 'channels=Setup' -o stdout
```
