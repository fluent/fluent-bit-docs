# Syslog

The Syslog output plugin allows you to deliver messages to Syslog servers. It supports RFC3164 and RFC5424 formats through different transports such as UDP, TCP or TLS.

As of Fluent Bit v1.5.3 the configuration is very strict. You must be aware of the structure of your original record so you can configure the plugin to use specific keys to compose your outgoing Syslog message.

> Future versions of Fluent Bit are expanding this plugin feature set to support better handling of keys and message composing.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| host | Domain or IP address of the remote Syslog server. | 127.0.0.1 |
| port | TCP or UDP port of the remote Syslog server. | 514 |
| mode | Desired transport type. Available options are `tcp`, `tls` and `udp`. | udp |
| syslog\_format | The Syslog protocol format to use. Available options are `rfc3164` and `rfc5424`. | rfc5424 |
| syslog\_maxsize | The maximum size allowed per message. The value must be an integer representing the number of bytes allowed. If no value is provided, the default size is set depending of the protocol version specified by `syslog_format`.<br><br>`rfc3164` sets max size to 1024 bytes.<br><br>`rfc5424` sets the size to 2048 bytes. |  |
| syslog\_severity\_key | The key name from the original record that contains the Syslog severity number. This configuration is optional. |  |
| syslog\_severity\_preset | The preset severity number. It will be overwritten if `syslog_severity_key` is set and a key of a record is matched. This configuration is optional. | 6 |
| syslog\_facility\_key | The key name from the original record that contains the Syslog facility number. This configuration is optional. |  |
| syslog\_facility\_preset | The preset facility number. It will be overwritten if `syslog_facility_key` is set and a key of a record is matched. This configuration is optional. | 1 |
| syslog\_hostname\_key | The key name from the original record that contains the hostname that generated the message. This configuration is optional. |  |
| syslog\_hostname\_preset | The preset hostname. It will be overwritten if `syslog_hostname_key` is set and a key of a record is matched. This configuration is optional. | |
| syslog\_appname\_key | The key name from the original record that contains the application name that generated the message. This configuration is optional. |  |
| syslog\_appname\_preset | The preset application name. It will be overwritten if `syslog_appname_key` is set and a key of a record is matched. This configuration is optional. | |
| syslog\_procid\_key | The key name from the original record that contains the Process ID that generated the message. This configuration is optional. |  |
| syslog\_procid\_preset | The preset process ID. It will be overwritten if `syslog_procid_key` is set and a key of a record is matched. This configuration is optional. | |
| syslog\_msgid\_key | The key name from the original record that contains the Message ID associated to the message. This configuration is optional. |  |
| syslog\_msgid\_preset | The preset message ID. It will be overwritten if `syslog_msgid_key` is set and a key of a record is matched. This configuration is optional. | |
| syslog\_sd\_key | The key name from the original record that contains the Structured Data \(SD\)  content. This configuration is optional. |  |
| syslog\_message\_key | The key name from the original record that contains the message to deliver. Note that this property is **mandatory**, otherwise the message will be empty. |  |
| allow\_longer\_sd\_id| If true, Fluent-bit allows SD-ID that is longer than 32 characters. Such long SD-ID violates RFC 5424.| false |

## Examples

### Configuration File

Get started quickly with this configuration file:

```text
[OUTPUT]
    name                 syslog
    match                *
    host                 syslog.yourserver.com
    port                 514
    mode                 udp
    syslog_format        rfc5424
    syslog_maxsize       2048
    syslog_severity_key  severity
    syslog_facility_key  facility
    syslog_hostname_key  hostname
    syslog_appname_key   appname
    syslog_procid_key    procid
    syslog_msgid_key     msgid
    syslog_sd_key        sd
    syslog_message_key   message
```

### Structured Data

The following is an example of how to configure the `syslog_sd_key` to send Structured Data to the remote Syslog server.

Example log:

```json
{
    "hostname": "myhost",
    "appname": "myapp",
    "procid": "1234",
    "msgid": "ID98",
    "uls@0": {
        "logtype": "access",
        "clustername": "mycluster",
        "namespace": "mynamespace"
    },
    "log": "Sample app log message."
}
```

Example configuration file:

```text
[OUTPUT]
    name                 syslog
    match                *
    host                 syslog.yourserver.com
    port                 514
    mode                 udp
    syslog_format        rfc5424
    syslog_maxsize       2048
    syslog_hostname_key  hostname
    syslog_appname_key   appname
    syslog_procid_key    procid
    syslog_msgid_key     msgid    
    syslog_sd_key        uls@0
    syslog_message_key   log
```

Example output:

```bash
<14>1 2021-07-12T14:37:35.569848Z myhost myapp 1234 ID98 [uls@0 logtype="access" clustername="mycluster" namespace="mynamespace"] Sample app log message.
```