# Syslog

The Syslog output plugin allows you to deliver messages to Syslog servers, it supports RFC3164 and RFC5424 formats through different transports such as UDP, TCP or TLS.

As of Fluent Bit v1.5.3, the configuration is very strict in terms that you must be aware about the structure of your original record, so you can configure the plugin to use specific keys to compose your outgoing Syslog message.

> Future versions of Fluent Bit are expanding this plugin feature set to support better handling of keys and message composing.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| host | Domain or IP address of the remote Syslog server. | 127.0.0.1 |
| port | TCP or UDP port of the remote Syslog server. | 514 |
| mode | Set the desired transport type, the available options are `tcp`, `tls` and `udp`. | udp |
| syslog\_format | Specify the Syslog protocol format to use, the available options are `rfc3164` and `rfc5424`. | rfc5424 |
| syslog\_maxsize | Set the maximum size allowed per message. The value must be only integers representing the number of bytes allowed. If no value is provided, the default size is set depending of the protocol version specified by `syslog_format` , `rfc3164` sets max size to 1024 bytes, while `rfc5424` sets the size to 2048 bytes. |  |
| syslog\_severity\_key | Specify the name of the key from the original record that contains the Syslog severity number. This configuration is optional. |  |
| syslog\_facility\_key | Specify the name of the key from the original record that contains the Syslog facility number. This configuration is optional. |  |
| syslog\_hostname\_key | Specify the key name from the original record that contains the hostname that generated the message. This configuration is optional. |  |
| syslog\_appname\_key | Specify the key name from the original record that contains the application name that generated the message. This configuration is optional. |  |
| syslog\_procid\_key | Specify the key name from the original record that contains the Process ID that generated the message. This configuration is optional. |  |
| syslog\_msgid\_key | Specify the key name from the original record that contains the Message ID associated to the message. This configuration is optional. |  |
| syslog\_sd\_key | Specify the key name from the original record that contains the Structured Data \(SD\)  content. This configuration is optional. |  |
| syslog\_message\_key | Specify the key name that contains the message to deliver. Note that if this property is **mandatory**, otherwise the message will be empty |  |

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

