# NATS

The _NATS_ output plugin lets you flush your records into a [NATS Server](https://docs.nats.io/) server endpoint.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `host` | The IP address or hostname of the NATS server. | `127.0.0.1` |
| `invalid_subject_action` | Action for tags that aren't valid NATS subjects: `reject` or `encode`. See [Subjects](#subjects). Supported in v5.2 or later. | `reject` |
| `port` | The TCP port of the target NATS server. | `4222` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

{% hint style="info" %}

On the command line, you can set the host and port with the Fluent Bit network address format, for example `-o nats://127.0.0.1:4222`.

{% endhint %}

## Subjects

Fluent Bit publishes each chunk of records to the NATS subject that matches the record tag. In v5.2 or later, Fluent Bit checks that the tag is a valid NATS publish subject before it connects to the server. A tag isn't a valid subject if it:

- Is empty.
- Contains a space, a tab, another ASCII control character, `*`, or `>`.
- Starts or ends with `.`, or contains two consecutive `.` characters.

Bytes outside the ASCII range, such as UTF-8 characters, don't make a tag invalid on their own. When a tag is encoded, every byte is encoded, including UTF-8 bytes.

The `invalid_subject_action` value is case-sensitive. Any value other than `reject` or `encode` causes startup to fail.

With `invalid_subject_action: reject`, the default, Fluent Bit logs `invalid NATS publish subject in tag` and drops the chunk without retrying.

With `invalid_subject_action: encode`, Fluent Bit encodes only tags that aren't valid subjects and tags that start with `_flb_encoded.`. Valid tags, such as `app.logs`, are still published unchanged. An encoded tag is published to `_flb_encoded.` followed by each byte of the tag as two uppercase hexadecimal digits. For example, records with the tag `app logs` are published to `_flb_encoded.617070206C6F6773`. Tags that already start with `_flb_encoded.`, including the final `.`, are encoded the same way, even when they're valid, so they can't collide with encoded subjects. An empty tag encodes to `_flb_encoded.` with nothing after the prefix. Subscribers and NATS publish permissions must cover both the unchanged valid subjects and the encoded subjects. For example, subscribe to `_flb_encoded.>` to receive every encoded subject, in addition to the subjects of your valid tags. The `tag` field in each record still contains the original tag, unless the record already has its own `tag` key. See [Data format](#data-format). If Fluent Bit can't allocate memory for the encoded subject, the chunk is retried according to `retry_limit`.

With either setting, Fluent Bit logs `NATS publish control line exceeds 4096 bytes` and drops the chunk without retrying if the NATS publish command line, `PUB <subject> <size>` plus the trailing carriage return and line feed, is longer than 4,096 bytes. This limit matches the default NATS `max_control_line` value and is fixed in Fluent Bit, so raising `max_control_line` on the server doesn't change it. Encoding more than doubles the length of a tag, so long tags are more likely to exceed this limit.

### Upgrade to v5.2

Earlier versions send the tag as the subject without checking it. A tag that whitespace splits into two parts, such as `app logs`, was read by the NATS server as a subject and a reply subject, so those records were published to the subject `app`. A tag with three or more parts, such as `app logs extra`, produced a `PUB` command with too many fields, which the server rejects. Fluent Bit doesn't read replies from the NATS server, so it doesn't log a rejected command and counts the chunk as delivered. In v5.2 or later, with the default `invalid_subject_action: reject`, chunks with such tags, or tags that contain `*` or `>`, are dropped instead. Before you upgrade, rename those tags, for example with the [Rewrite Tag](../filters/rewrite-tag.md) filter, or set `invalid_subject_action: encode` and update your subscribers.

## Get started

To flush records to a NATS server, you can run the plugin from the command line or through the configuration file.

### Command line

If you use the following command without specifying parameter values, Fluent Bit uses the default values defined in the previous section.

```shell
fluent-bit -i cpu -o nats -f 5
```

### Configuration file

In your main configuration file, append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: nats
      match: '*'
      host: 127.0.0.1
      port: 4222
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu

[OUTPUT]
  Name   nats
  Match  *
  Host   127.0.0.1
  Port   4222
```

{% endtab %}
{% endtabs %}

## Data format

For every set of records flushed to a NATS server, Fluent Bit uses the following format:

```text
[
  [UNIX_TIMESTAMP, JSON_MAP_1],
  [UNIX_TIMESTAMP, JSON_MAP_2],
  [UNIX_TIMESTAMP, JSON_MAP_N],
]
```

Each record is an individual entity represented in a JSON array that contains a Unix timestamp, as a floating-point number of seconds, and a JSON map with a set of key/value pairs. Fluent Bit adds a `tag` key with the record tag at the start of each map. If a record already has its own `tag` key, Fluent Bit keeps the record's value and doesn't include the record tag. To include it, rename the record's key before the NATS output with the `rename` operation of the [Modify](../filters/modify.md) filter, for example to `source_tag`. The rename only applies when the new key doesn't already exist in the record. After the rename, consumers that read `tag` receive the Fluent Bit record tag instead of the record's own value. A summarized output of the CPU input plugin will resemble the following:

```json
[
  [1457108504.123456,{"tag":"cpu.0","cpu_p":1.500000,"user_p":1,"system_p":0.500000}],
  [1457108505.123789,{"tag":"cpu.0","cpu_p":4.500000,"user_p":3,"system_p":1.500000}],
  [1457108506.124012,{"tag":"cpu.0","cpu_p":6.500000,"user_p":4.500000,"system_p":2}]
]
```
