# Systemd

The _Systemd_ input plugin allows to collect log messages from the Journald daemon on Linux environments.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Path | Optional path to the Systemd journal directory, if not set, the plugin will use default paths to read local-only logs. |  |
| Max\_Fields | Set a maximum number of fields \(keys\) allowed per record. | 8000 |
| Max\_Entries | When Fluent Bit starts, the Journal might have a high number of logs in the queue. In order to avoid delays and reduce memory usage, this option allows to specify the maximum number of log entries that can be processed per round. Once the limit is reached, Fluent Bit will continue processing the remaining log entries once Journald performs the notification. | 5000 |
| Systemd\_Filter | Allows to perform a query over logs that contains a specific Journald key/value pairs, e.g: \_SYSTEMD\_UNIT=UNIT. The Systemd\_Filter option can be specified multiple times in the input section to apply multiple filters as required. |  |
| Systemd\_Filter\_Type | Define the filter type when _Systemd\_Filter_ is specified multiple times. Allowed values are _And_ and _Or_. With _And_ a record is matched only when all of the _Systemd\_Filter_ have a match. With _Or_ a record is matched when any of the _Systemd\_Filter_ has a match. | Or |
| Tag | The tag is used to route messages but on Systemd plugin there is an extra functionality: if the tag includes a star/wildcard, it will be expanded with the Systemd Unit file \(`_SYSTEMD_UNIT`, e.g. host.\* =&gt; host.UNIT\_NAME\) or `unknown` \(e.g. host.unknown\) if `_SYSTEMD_UNIT` is missing. |  |
| DB | Specify the absolute path of a database file to keep track of Journald cursor. |  |
| DB.Sync | Set a default synchronization \(I/O\) method. values: Extra, Full, Normal, Off. This flag affects how the internal SQLite engine do synchronization to disk, for more details about each option please refer to [this section](https://www.sqlite.org/pragma.html#pragma_synchronous). note: this option was introduced on Fluent Bit v1.4.6. | Full |
| Read\_From\_Tail | Start reading new entries. Skip entries already stored in Journald. | Off |
| Lowercase | Lowercase the Journald field \(key\). | Off |
| Strip\_Underscores | Remove the leading underscore of the Journald field \(key\). For example the Journald field _\_PID_ becomes the key _PID_. | Off |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Getting Started

In order to receive Systemd messages, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit listen for _Systemd_ messages with the following options:

```shell
$ fluent-bit -i systemd \
             -p systemd_filter=_SYSTEMD_UNIT=docker.service \
             -p tag='host.*' -o stdout
```

> In the example above we are collecting all messages coming from the Docker service.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

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
    Parsers_File parsers.conf

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