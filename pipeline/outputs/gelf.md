# GELF

**GELF** is [Graylog](https://www.graylog.org) Extended Log Format. The GELF output plugin allows to send logs in GELF format directly to a Graylog input using TLS, TCP or UDP protocols.

The following instructions assumes that you have a fully operational Graylog server running in your environment.

## Configuration Parameters

According to [GELF Payload Specification](https://go2docs.graylog.org/5-0/getting_in_log_data/gelf.html?Highlight=Payload#GELFPayloadSpecification), there are some mandatory and optional fields which are used by Graylog in GELF format. These fields are determined with _Gelf\\_\*\_Key\_ key in this plugin.

| Key                    | Description                                                                                                                                                                 | default       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| Match                  | Pattern to match which tags of logs to be outputted by this plugin                                                                                                          |               |
| Host                   | IP address or hostname of the target Graylog server                                                                                                                         | 127.0.0.1     |
| Port                   | The port that your Graylog GELF input is listening on                                                                                                                       | 12201         |
| Mode                   | The protocol to use (`tls`, `tcp` or `udp`)                                                                                                                                 | udp           |
| Gelf\_Tag\_Key         | Key to be used for tag. (_Optional in GELF_)  |               |
| Gelf_Short_Message_Key | A short descriptive message (**MUST be set in GELF**)                                                                                                                       | short_message |
| Gelf_Timestamp_Key     | Your log timestamp (_SHOULD be set in GELF_)                                                                                                                                | timestamp     |
| Gelf_Host_Key          | Key which its value is used as the name of the host, source or application that sent this message. (**MUST be set in GELF**)                                                | host          |
| Gelf_Full_Message_Key  | Key to use as the long message that can i.e. contain a backtrace. (_Optional in GELF_)                                                                                      | full_message  |
| Gelf_Level_Key         | Key to be used as the log level. Its value must be in [standard syslog levels](https://en.wikipedia.org/wiki/Syslog#Severity_level) (between 0 and 7). (_Optional in GELF_) | level         |
| Packet_Size            | If transport protocol is `udp`, you can set the size of packets to be sent.                                                                                                 | 1420          |
| Compress               | If transport protocol is `udp`, you can set this if you want your UDP packets to be compressed.                                                                             | true          |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The GELF output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Notes

* If you're using Fluent Bit to collect Docker logs, note that Docker places your log in JSON under key `log`. So you can set `log` as your `Gelf_Short_Message_Key` to send everything in Docker logs to Graylog. In this case, you need your `log` value to be a string; so don't parse it using JSON parser.
* The order of looking up the timestamp in this plugin is as follows:
  1. Value of `Gelf_Timestamp_Key` provided in configuration
  2. Value of `timestamp` key
  3. If you're using [Docker JSON parser](../parsers/json.md), this parser can parse time and use it as timestamp of message. If all above fail, Fluent Bit tries to get timestamp extracted by your parser.
  4. Timestamp does not set by Fluent Bit. In this case, your Graylog server will set it to the current timestamp (now).
* Your log timestamp has to be in [UNIX Epoch Timestamp](https://en.wikipedia.org/wiki/Unix_time) format. If the `Gelf_Timestamp_Key` value of your log is not in this format, your Graylog server will ignore it.
* If you're using Fluent Bit in Kubernetes and you're using [Kubernetes Filter Plugin](../filters/kubernetes.md), this plugin adds `host` value to your log by default, and you don't need to add it by your own.
* The `version` of GELF message is also mandatory and Fluent Bit sets it to 1.1 which is the current latest version of GELF.
* If you use `udp` as transport protocol and set `Compress` to `true`, Fluent Bit compresses your packets in GZIP format, which is the default compression that Graylog offers. This can be used to trade more CPU load for saving network bandwidth.

## Configuration File Example

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

By default, GELF tcp uses port 12201 and Docker places your logs in `/var/log/containers` directory. The logs are placed in value of the `log` key. For example, this is a log saved by Docker:

```text
...
{"log":"{\"data\": \"This is an example.\"}","stream":"stderr","time":"2019-07-21T12:45:11.273315023Z"}
...
```

If you use [Tail Input](../inputs/tail.md) and use a Parser like the `docker` parser shown above, it decodes your message and extracts `data` (and any other present) field. This is how this log in [stdout](standard-output.md) looks like after decoding:

```text
...
[0] kube.log: [1565770310.000198491, {"log"=>{"data"=>"This is an example."}, "stream"=>"stderr", "time"=>"2019-07-21T12:45:11.273315023Z"}]
...
```

Now, this is what happens to this log:

1. Fluent Bit GELF plugin adds `"version": "1.1"` to it.
2. The [Nest Filter](../filters/nest.md), unnests fields inside `log` key. In our example, it puts `data` alongside `stream` and `time`.
3. We used this `data` key as `Gelf_Short_Message_Key`; so GELF plugin changes it to `short_message`.
4. [Kubernetes Filter](../filters/kubernetes.md) adds `host` name.
5. Timestamp is generated.
6. Any custom field (not present in [GELF Payload Specification](https://go2docs.graylog.org/5-0/getting_in_log_data/gelf.html?Highlight=Payload#GELFPayloadSpecification).) is prefixed by an underline.

Finally, this is what our Graylog server input sees:

```text
...
{"version":"1.1", "short_message":"This is an example.", "host": "<Your Node Name>", "_stream":"stderr", "timestamp":1565770310.000199}
...
```