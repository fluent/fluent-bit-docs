# Syslog

The _Syslog_ output plugin lets you deliver messages to Syslog servers. It supports RFC3164 and RFC5424 formats over UDP, TCP, TLS, and Datagram Transport Layer Security (DTLS) transports.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `allow_longer_sd_id` | If `true`, Fluent Bit allows SD-ID values longer than 32 characters. SD-ID values that exceed 32 characters violate RFC5424 standards. | `false` |
| `host` | Domain or IP address of the remote Syslog server. | `127.0.0.1` |
| `mode` | Desired transport type. Available options are `udp`, `tcp`, `tls`, and `dtls`. See [Transport modes](#transport-modes). | `udp` |
| `port` | TCP or UDP port of the remote Syslog server. | `514` |
| `syslog_appname_key` | Optional. The key name from the original record that contains the application name that generated the message. | _none_ |
| `syslog_appname_preset` | Optional. The preset application name. It will be overwritten if `syslog_appname_key` is set and a key of a record is matched. | _none_ |
| `syslog_facility_key` | Optional. The key name from the original record that contains the Syslog facility number. | _none_ |
| `syslog_facility_preset` | Optional. The preset facility number. It will be overwritten if `syslog_facility_key` is set and a key of a record is matched. | `1` |
| `syslog_format` | The Syslog protocol format to use. Available options are `rfc3164` and `rfc5424`. | `rfc5424` |
| `syslog_framing` | The framing method used to delimit messages on stream transports. Available options are `newline` and `octet_counting`. Setting `octet_counting` requires `mode` set to `tcp` or `tls`. See [Message framing](#message-framing). | `newline` |
| `syslog_hostname_key` | Optional. The key name from the original record that contains the hostname that generated the message. | _none_ |
| `syslog_hostname_preset` | Optional. The preset hostname. It will be overwritten if `syslog_hostname_key` is set and a key of a record is matched. | _none_ |
| `syslog_maxsize` | The maximum size allowed per message. The value must be an integer representing the number of bytes allowed. If no value is provided, the default size is set depending on the protocol version specified by `syslog_format`. The value `rfc3164` sets max size to 1024 bytes, and `rfc5424` sets the size to 2048 bytes. | `0` |
| `syslog_message_key` | Required. The key name from the original record that contains the message to deliver. | _none_ |
| `syslog_msgid_key` | Optional. The key name from the original record that contains the Message ID associated to the message. | _none_ |
| `syslog_msgid_preset` | Optional. The preset message ID. It will be overwritten if `syslog_msgid_key` is set and a key of a record is matched. | _none_ |
| `syslog_procid_key` | Optional. The key name from the original record that contains the Process ID that generated the message. | _none_ |
| `syslog_procid_preset` | Optional. The preset process ID. It will be overwritten if `syslog_procid_key` is set and a key of a record is matched. | _none_ |
| `syslog_sd_key` | Optional. The key name from the original record that contains a map of key/value pairs to use as Structured Data \(SD\) content. The key name is included in the resulting SD field as shown in the examples in this doc. | _none_ |
| `syslog_sd_preset` | Optional. A literal RFC5424 structured data field used when no structured data is extracted from the record. Set it to `-`, or to one or more adjacent `[SD-ID PARAM-NAME="PARAM-VALUE"]` elements. Ignored when `syslog_format` is `rfc3164`. See [Structured data preset](#structured-data-preset). | _none_ |
| `syslog_severity_key` | Optional. The key name from the original record that contains the Syslog severity number. | _none_ |
| `syslog_severity_preset` | Optional. The preset severity number. It will be overwritten if `syslog_severity_key` is set and a key of a record is matched. | `6` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### Transport modes

The `mode` parameter selects the transport used to reach the Syslog server:

| Mode | Transport | `tls` setting |
| --- | --- | --- |
| `udp` | Datagrams. | Must remain `off`. |
| `tcp` | Stream. Set `tls` to `on` to secure the connection. | Optional. |
| `tls` | Stream secured with TLS. | Optional. Enabled automatically. |
| `dtls` | Datagrams secured with DTLS. | Optional. Enabled automatically. |

Setting `mode` to `tls` or `dtls` enables TLS automatically, so you don't need to set `tls` to `on` for those modes. Setting it explicitly is harmless. To secure a `tcp` connection, you must set `tls` to `on`.

Fluent Bit validates the configuration at startup and refuses to start in these cases:

- `mode` set to `udp` with `tls` set to `on` fails with `mode=udp with tls=on is unsupported`. Use `dtls` instead, which is the supported way to secure datagram transport.
- `mode` set to `tls` or `dtls` in a build compiled without TLS support fails with `TLS support is unavailable`.

DTLS support is available in Fluent Bit version 5.1 and greater. Earlier versions support only `udp`, `tcp`, and `tls`.

### Message framing

On a stream transport, the receiver needs a way to tell where one message ends and the next begins. The `syslog_framing` parameter selects that method:

| `syslog_framing` | Behavior | Supported modes |
| --- | --- | --- |
| `newline` | Appends a newline character to each message. This is the non-transparent framing described in RFC6587. | `tcp`, `tls`, `dtls`. On `udp`, each datagram is already a message boundary, so no newline is appended. |
| `octet_counting` | Prefixes each message with its byte length and a space, and appends no newline. This is the octet-counting framing described in RFC6587. | `tcp`, `tls` |

Setting `syslog_framing` to `octet_counting` with `mode` set to `udp` or `dtls` fails at startup with `invalid configuration: syslog_framing=octet_counting requires mode=tcp or mode=tls`.

Fluent Bit adds the length prefix after applying `syslog_maxsize`, so the prefix doesn't count toward that limit and a message can exceed `syslog_maxsize` by the length of its prefix.

With `octet_counting`, a message that reads `<14>1 2021-07-12T14:37:35.569848Z myhost myapp 1234 ID98 - Sample app log message.` is sent as:

```text
82 <14>1 2021-07-12T14:37:35.569848Z myhost myapp 1234 ID98 - Sample app log message.
```

### TLS / SSL

The Syslog output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

The same TLS properties apply to `dtls` mode, including `tls.verify`, `tls.ca_file`, `tls.crt_file`, and `tls.key_file`.

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
  Name                 syslog
  Match                *
  Host                 syslog.yourserver.com
  Port                 514
  Mode                 udp
  Syslog_Format        rfc5424
  Syslog_Maxsize       2048
  Syslog_Severity_Key  severity
  Syslog_Facility_Key  facility
  Syslog_Hostname_Key  hostname
  Syslog_Appname_Key   appname
  Syslog_Procid_Key    procid
  Syslog_Msgid_Key     msgid
  Syslog_Sd_Key        sd
  Syslog_Message_Key   message
```

{% endtab %}
{% endtabs %}

### Secure datagram transport with DTLS

To send messages over DTLS, set `mode` to `dtls`. The Syslog server must listen for DTLS on the configured port:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: syslog
      match: "*"
      host: syslog.yourserver.com
      port: 6514
      mode: dtls
      tls.verify: on
      tls.ca_file: /path/to/ca.crt
      syslog_format: rfc5424
      syslog_message_key: message
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name                 syslog
  Match                *
  Host                 syslog.yourserver.com
  Port                 6514
  Mode                 dtls
  Tls.verify           on
  Tls.ca_file          /path/to/ca.crt
  Syslog_Format        rfc5424
  Syslog_Message_Key   message
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
  Name                 syslog
  Match                *
  Host                 syslog.yourserver.com
  Port                 514
  Mode                 udp
  Syslog_Format        rfc5424
  Syslog_Maxsize       2048
  Syslog_Hostname_Key  hostname
  Syslog_Appname_Key   appname
  Syslog_Procid_Key    procid
  Syslog_Msgid_Key     msgid
  Syslog_Sd_Key        uls@0
  Syslog_Message_Key   log
```

{% endtab %}
{% endtabs %}

Example output:

```text
...
<14>1 2021-07-12T14:37:35.569848Z myhost myapp 1234 ID98 [uls@0 logtype="access" clustername="mycluster" namespace="mynamespace"] Sample app log message.
...
```

### Structured data preset

When the structured data is the same for every message, use `syslog_sd_preset` instead of deriving it from each record. Fluent Bit uses the preset only when no structured data is extracted from the record, so a record that carries its own structured data still takes precedence.

The value must be a literal RFC5424 structured data field: either `-` for the nil value, or one or more adjacent `[...]` elements. Each element starts with an SD-ID, optionally followed by one or more space-separated `PARAM-NAME="PARAM-VALUE"` pairs, as in `[uls@0 clustername="mycluster" namespace="mynamespace"]`. SD-IDs and parameter names are limited to 32 characters unless `allow_longer_sd_id` is `true`.

Validation depends on `syslog_format`:

- With `rfc5424`, Fluent Bit validates the preset at startup and fails with `invalid syslog_sd_preset` if it doesn't parse.
- With `rfc3164`, Fluent Bit ignores the preset and doesn't validate it, because that format has no structured data field. An invalid value starts without error and has no effect.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

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
      syslog_sd_preset: '[uls@0 clustername="mycluster" namespace="mynamespace"]'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name                    syslog
  Match                   *
  Host                    syslog.yourserver.com
  Port                    514
  Mode                    tcp
  Syslog_Format           rfc5424
  Syslog_Hostname_Preset  myhost
  Syslog_Appname_Preset   myapp
  Syslog_Message_Key      log
  Syslog_Sd_Preset        [uls@0 clustername="mycluster" namespace="mynamespace"]
```

{% endtab %}
{% endtabs %}

### Add structured data authentication token

Some services use the structured data field to pass authentication tokens (for example, `[<token>@41018]`), which would need to be added to each log message dynamically. However, this requires setting the token as a key rather than as a value.

If the token is the same for every message, `syslog_sd_preset` is a simpler alternative to the Lua filter shown here. See [Structured data preset](#structured-data-preset).

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
  Name  lua
  Match *
  Call  append_token
  Code  function append_token(tag, timestamp, record) record["${AUTH_TOKEN}"] = {} return 2, timestamp, record end

[OUTPUT]
  Name                    syslog
  Match                   *
  Host                    syslog.yourserver.com
  Port                    514
  Mode                    tcp
  Syslog_Format           rfc5424
  Syslog_Hostname_Preset  my-hostname
  Syslog_Appname_Preset   my-appname
  Syslog_Message_Key      log
  Allow_Longer_Sd_Id      true
  Syslog_Sd_Key           ${AUTH_TOKEN}
  Tls                     on
  Tls.crt_file            /path/to/my.crt
```

{% endtab %}
{% endtabs %}
