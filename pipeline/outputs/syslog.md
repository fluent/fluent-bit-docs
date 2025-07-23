# Syslog

The _Syslog_ output plugin lets you deliver messages to Syslog servers. It supports RFC3164 and RFC5424 formats through different transports such as UDP, TCP or TLS.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `host` | Domain or IP address of the remote Syslog server. | `127.0.0.1` |
| `port` | TCP or UDP port of the remote Syslog server. | `514` |
| `mode` | Desired transport type. Available options are `tcp` and `udp`. | `udp` |
| `syslog_format` | The Syslog protocol format to use. Available options are `rfc3164` and `rfc5424`. | `rfc5424` |
| `syslog_maxsize` | The maximum size allowed per message. The value must be an integer representing the number of bytes allowed. If no value is provided, the default size is set depending of the protocol version specified by `syslog_format`. The value `rfc3164` sets max size to 1024 bytes, and `rfc5424` sets the size to 2048 bytes. | _none_ |
| `syslog_severity_key` | The key name from the original record that contains the Syslog severity number. This configuration is optional. | _none_ |
| `syslog_severity_preset` | The preset severity number. It will be overwritten if `syslog_severity_key` is set and a key of a record is matched. This configuration is optional. | `6` |
| `syslog_facility_key` | The key name from the original record that contains the Syslog facility number. This configuration is optional. | _none_ |
| `syslog_facility_preset` | The preset facility number. It will be overwritten if `syslog_facility_key` is set and a key of a record is matched. This configuration is optional. | `1` |
| `syslog_hostname_key` | The key name from the original record that contains the hostname that generated the message. This configuration is optional. | _none_ |
| `syslog_hostname_preset` | The preset hostname. It will be overwritten if `syslog_hostname_key` is set and a key of a record is matched. This configuration is optional. | _none_ |
| `syslog_appname_key` | The key name from the original record that contains the application name that generated the message. This configuration is optional. | _none_ |
| `syslog_appname_preset` | The preset application name. It will be overwritten if `syslog_appname_key` is set and a key of a record is matched. This configuration is optional. | _none_ |
| `syslog_procid_key` | The key name from the original record that contains the Process ID that generated the message. This configuration is optional. | _none_ |
| `syslog_procid_preset` | The preset process ID. It will be overwritten if `syslog_procid_key` is set and a key of a record is matched. This configuration is optional. | _none_ |
| `syslog_msgid_key` | The key name from the original record that contains the Message ID associated to the message. This configuration is optional. | _none_ |
| `syslog_msgid_preset` | The preset message ID. It will be overwritten if `syslog_msgid_key` is set and a key of a record is matched. This configuration is optional. | _none_ |
| `syslog_sd_key` | The key name from the original record that contains a map of key/value pairs to use as Structured Data \(SD\) content. The key name is included in the resulting SD field as shown in the examples in this doc. This configuration is optional. | _none_ |
| `syslog_message_key` | The key name from the original record that contains the message to deliver. Be aware that this property is required, otherwise the message will be empty. | _none_ |
| `allow_longer_sd_id` | If `true`, Fluent-bit allows SD-ID values that are longer than 32 characters. SD-ID values that exceed 32 characters violate RFC5424 standards. | `false` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The Syslog output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Examples

### Configuration file

Get started quickly with this configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: syslog
      match: "*"
      host: syslog.yourserver.com
      port: 514
      mode: udp
      syslog_format: rfc5424
      syslog_maxsize: 2048
      syslog_severity_key: severity
      syslog_facility_key: facility
      syslog_hostname_key: hostname
      syslog_appname_key: appname
      syslog_procid_key: procid
      syslog_msgid_key: msgid
      syslog_sd_key: sd
      syslog_message_key: message
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

### Structured data

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

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: syslog
      match: "*"
      host: syslog.yourserver.com
      port: 514
      mode: udp
      syslog_format: rfc5424
      syslog_maxsize: 2048
      syslog_hostname_key: hostname
      syslog_appname_key: appname
      syslog_procid_key: procid
      syslog_msgid_key: msgid
      syslog_sd_key: uls@0
      syslog_message_key: log
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

Example output:

```text
...
<14>1 2021-07-12T14:37:35.569848Z myhost myapp 1234 ID98 [uls@0 logtype="access" clustername="mycluster" namespace="mynamespace"] Sample app log message.
...
```

### Add structured data authentication token

Some services use the structured data field to pass authentication tokens (for example, `[<token>@41018]`), which would need to be added to each log message dynamically. However, this requires setting the token as a key rather than as a value.

Here's an example of how that might be achieved, using `AUTH_TOKEN` as a [variable](../../administration/configuring-fluent-bit/classic-mode/variables.md):

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  filters:
    - name:  lua
      match: "*"
      call:  append_token
      code:  |
        function append_token(tag, timestamp, record)
            record["${AUTH_TOKEN}"] = {}
            return 2, timestamp, record
        end

  outputs:
    - name: syslog
      match: "*"
      host: syslog.yourserver.com
      port: 514
      mode: tcp
      syslog_format: rfc5424
      syslog_hostname_preset: myhost
      syslog_appname_preset: myapp
      syslog_message_key: log
      allow_longer_sd_id: true
      syslog_sd_key: ${AUTH_TOKEN}
      tls: on
      tls.crt_file: /path/to/my.crt
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[FILTER]
  name  lua
  match *
  call  append_token
  code  function append_token(tag, timestamp, record) record["${AUTH_TOKEN}"] = {} return 2, timestamp, record end

[OUTPUT]
  name                    syslog
  match                   *
  host                    syslog.yourserver.com
  port                    514
  mode                    tcp
  syslog_format           rfc5424
  syslog_hostname_preset  my-hostname
  syslog_appname_preset   my-appname
  syslog_message_key      log
  allow_longer_sd_id      true
  syslog_sd_key           ${AUTH_TOKEN}
  tls                     on
  tls.crt_file            /path/to/my.crt
```

{% endtab %}
{% endtabs %}
