# Graylog Extended Log Format (GELF

The _[Graylog](https://www.graylog.org) Extended Log Format (GELF)_ output plugin lets you send logs in GELF format directly to a Graylog input using TLS, TCP, or UDP protocols.

The following instructions assume that you have a fully operational Graylog server running in your environment.

## Configuration parameters

According to the [GELF Payload Specification](https://go2docs.graylog.org/5-0/getting_in_log_data/gelf.html?Highlight=Payload#GELFPayloadSpecification), there are mandatory and optional fields used by Graylog in GELF format. These fields are determined by the `Gelf\_*_Key` key in this plugin.

| Key | Description | Default |
| --- | ----------- | ------- |
| `Match` | Pattern to match which tags of logs to be outputted by this plugin. | _none_ |
| `Host` | IP address or hostname of the target Graylog server. | `127.0.0.1` |
| `Port` | The port that your Graylog GELF input is listening on. | `12201` |
| `Mode` | The protocol to use. Allowed values:`tls`, `tcp`, `udp`.| `udp` |
| `Gelf_Tag_Key` | Key to be used for tag. (Optional in GELF.) | _none_ |
| `Gelf_Short_Message_Key` | A short descriptive message. Must be set in GELF. | `short_message` |
| `Gelf_Timestamp_Key` | Your log timestamp. Should be set in GELF. | `timestamp` |
| `Gelf_Host_Key` | Key which its value is used as the name of the host, source or application that sent this message. Must be set in GELF. | `host` |
| `Gelf_Full_Message_Key` | Key to use as the long message that can, for example, contain a backtrace. Optional in GELF. | `full_message`  |
| `Gelf_Level_Key` | Key to be used as the log level. Its value must be in [standard syslog levels](https://en.wikipedia.org/wiki/Syslog#Severity_level) (between `0` and `7`). Optional in GELF. | `level` |
| `Packet_Size` | If transport protocol is `udp`, you can set the size of packets to be sent. | `1420` |
| `Compress` | If transport protocol is `udp`, you can set this if you want your UDP packets to be compressed. | `true` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The GELF output plugin supports TLS/SSL. For iformation about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Notes

Be aware that the following items can require changes to your configuration.

### Docker logs

If you're using Fluent Bit to collect Docker logs, Docker places your log in JSON under key `log`. Set `log` as your `Gelf_Short_Message_Key` to send everything in Docker logs to Graylog. In this case, your `log` value must be a string, so don't parse it using JSON parser.

### Timestamps

The order of looking up the timestamp in this plugin is as follows:

1. Value of `Gelf_Timestamp_Key` provided in configuration.
1. Value of `timestamp` key,
1. If you're using [Docker JSON parser](../parsers/json.md), this parser can parse time and use it as timestamp of message. If these steps fail, Fluent Bit tries to get timestamp extracted by your parser.
1. Timestamp isn't set by Fluent Bit. In this case, your Graylog server will set it to the current timestamp (now).

Your log timestamp has to be in [Unix Epoch Timestamp](https://en.wikipedia.org/wiki/Unix_time) format. If the `Gelf_Timestamp_Key` value of your log isn't in this format, your Graylog server will ignore it.

### Kubernetes

If you're using Fluent Bit in Kubernetes and you're using [Kubernetes Filter Plugin](../filters/kubernetes.md), this plugin adds `host` value to your log by default, and you don't need to add it by your own.

### Version

The `version` of GELF message is also mandatory and Fluent Bit sets it to 1.1 which is the current latest version of GELF.

### Compression

If you use `udp` as transport protocol and set `Compress` to `true`, Fluent Bit compresses your packets in GZIP format, which is the default compression that Graylog offers. This can be used to trade more CPU load for saving network bandwidth.

## Configuration file example

If you're using Fluent Bit for shipping Kubernetes logs, you can use something like this as your configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
  - name: docker
    format: json
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: off

pipeline:
  inputs:
    - name: tail
      tag: kube.*
      path: /var/log/containers/*.log
      parser: docker
      db: /var/log/flb_kube.db
      mem_buf_limit: 5MB
      refresh_interval: 10

  filters:
    - name: kubernetes
      match: 'kube.*'
      merge_log_key: log
      merge_log: on
      keep_log: off
      annotations: off
      labels: off

    - name: nest
      match: '*'
      operation: lift
      nested_under: log

  outputs:
    - name: gelf
      match: 'kube.*'
      host: <your-graylog-server>
      port: 12201
      mode: tcp
      gelf_short_message_key: data
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name                    tail
    Tag                     kube.*
    Path                    /var/log/containers/*.log
    Parser                  docker
    DB                      /var/log/flb_kube.db
    Mem_Buf_Limit           5MB
    Refresh_Interval        10

[FILTER]
    Name                    kubernetes
    Match                   kube.*
    Merge_Log_Key           log
    Merge_Log               On
    Keep_Log                Off
    Annotations             Off
    Labels                  Off

[FILTER]
    Name                    nest
    Match                   *
    Operation               lift
    Nested_under            log

[OUTPUT]
    Name                    gelf
    Match                   kube.*
    Host                    <your-graylog-server>
    Port                    12201
    Mode                    tcp
    Gelf_Short_Message_Key  data

[PARSER]
    Name                    docker
    Format                  json
    Time_Key                time
    Time_Format             %Y-%m-%dT%H:%M:%S.%L
    Time_Keep               Off
```

{% endtab %}
{% endtabs %}

By default, GELF TCP uses port `12201` and Docker places your logs in `/var/log/containers` directory. The logs are placed in value of the `log` key. For example, this is a log saved by Docker:

```text
...
{"log":"{\"data\": \"This is an example.\"}","stream":"stderr","time":"2019-07-21T12:45:11.273315023Z"}
...
```

If you use [Tail Input](../inputs/tail.md) and use a Parser like the `docker` parser shown previously, it decodes your message and extracts `data` (and any other present) field. This is how this log in [stdout](standard-output.md) looks like after decoding:

```text
...
[0] kube.log: [1565770310.000198491, {"log"=>{"data"=>"This is an example."}, "stream"=>"stderr", "time"=>"2019-07-21T12:45:11.273315023Z"}]
...
```

This is what happens to the log:

1. Fluent Bit GELF plugin adds `"version": "1.1"` to it.
1. The [Nest Filter](../filters/nest.md), unnests fields inside `log` key. In the example, it puts `data` alongside `stream` and `time`.
1. The `data` key was `Gelf_Short_Message_Key`, so GELF plugin changes it to `short_message`.
1. [Kubernetes Filter](../filters/kubernetes.md) adds `host` name.
1. Timestamp is generated.
1. Any custom field (not present in [GELF Payload Specification](https://go2docs.graylog.org/5-0/getting_in_log_data/gelf.html?Highlight=Payload#GELFPayloadSpecification).) is prefixed by an underline.

Finally, this is what the Graylog server input sees:

```text
...
{"version":"1.1", "short_message":"This is an example.", "host": "<Your Node Name>", "_stream":"stderr", "timestamp":1565770310.000199}
...
```
