---
description: Send logs to Splunk HTTP Event Collector
---

# Splunk

{% hint style="info" %}
**Supported event types:** `logs` `metrics`
{% endhint %}

The _Splunk_ output plugin lets you ingest your records into a [Splunk Enterprise](https://www.splunk.com/en_us/products/splunk-enterprise.html) service through the HTTP Event Collector (HEC) interface.

To learn how to set up the HEC in Splunk, refer to [Splunk / Use the HTTP Event Collector](https://docs.splunk.com/Documentation/SplunkCloud/latest/Data/UsetheHTTPEventCollector).

## Configuration parameters

Connectivity, transport, and authentication configuration properties:

| Key | Description | Default |
|:----|:------------|:--------|
| `channel` | Specify `X-Splunk-Request-Channel` header for the HTTP Event Collector interface. | _none_ |
| `compress` | Set payload compression mechanism. Allowed value: `gzip`. | _none_ |
| `host` | IP address or hostname of the target Splunk service. | `127.0.0.1` |
| `http_buffer_size` | Buffer size used to receive Splunk HTTP responses. | _none_ |
| `http_debug_bad_request` | If the HTTP server response code is `400` (bad request) and this flag is enabled, it will print the full HTTP request and response to the stdout interface. This feature is available for debugging purposes. | `false` |
| `http_passwd` | Password for user defined in `http_user`. | _none_ |
| `http_user` | Optional username for basic authentication on HEC. | _none_ |
| `port` | TCP port of the target Splunk service. | `8088` |
| `splunk_token` | Specify the authentication token for the HTTP Event Collector interface. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

Content and Splunk metadata (fields) handling configuration properties:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `auto_extract_timestamp` | Let Splunk extract the timestamp from the event data instead of sending the Fluent Bit event timestamp. See [Automatic timestamp extraction](#automatic-timestamp-extraction). Supported in v5.1.1 or later. | `off` |
| `event_field` | Set event fields for the record. This option can be set multiple times and the format is `key_name record_accessor_pattern`. | _none_ |
| `event_host` | Specify the key name that contains the host value. This option allows a record accessors pattern. | _none_ |
| `event_index` | The name of the index by which the event data is to be indexed. | _none_ |
| `event_index_key` | Set a record key that will populate the `index` field. If the key is found, it will have precedence over the value set in `event_index`. | _none_ |
| `event_key` | Specify the key name that will be used to send a single value as part of the record. | _none_ |
| `event_source` | Set the source value to assign to the event data. | _none_ |
| `event_sourcetype` | Set the `sourcetype` value to assign to the event data. | _none_ |
| `event_sourcetype_key` | Set a record key that will populate `sourcetype`. If the key is found, it will have precedence over the value set in `event_sourcetype`. | _none_ |
| `splunk_send_raw` | When enabled, the record keys and values are set in the top level of the map instead of under the event key. See [Sending Raw Events](#sending-raw-events) to configure this option. | `off` |
| `time_key` | Set a record key whose value populates the top level `time` field of the HTTP Event Collector payload instead of the Fluent Bit event timestamp. Accepts a plain key name or a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) pattern. See [Record-derived event time](#record-derived-event-time). Supported in v5.1.2 or later. | _none_ |
| `time_key_format` | Set the `strptime(3)` compatible format used to parse the value of `time_key` when that value is a string, for example `%Y-%m-%dT%H:%M:%S.%LZ`. The `%L` field descriptor is supported for fractional seconds. Requires `time_key`. Supported in v5.1.2 or later. | _none_ |

### TLS / SSL

The Splunk output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To insert records into a Splunk service, you can run the plugin from the command line or through the configuration file.

### Command line

The Splunk plugin can read the parameters from the command line through the `-p` argument (property):

```shell
fluent-bit -i cpu -t cpu -o splunk -p host=127.0.0.1 -p port=8088 \
  -p tls=on -p tls.verify=off -m '*'
```

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: splunk
      match: '*'
      host: 127.0.0.1
      port: 8088
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu
  Tag   cpu

[OUTPUT]
  Name        splunk
  Match       *
  Host        127.0.0.1
  Port        8088
  Tls         On
  Tls.verify  Off
```

{% endtab %}
{% endtabs %}

### Data format

By default, the Splunk output plugin nests the record under the `event` key in the payload sent to the HEC. It will also append the time of the record to a top level `time` key.

To customize any of the Splunk event metadata, such as the host or target index, you can set `Splunk_Send_Raw On` in the plugin configuration, and add the metadata as keys/values in the record. With `Splunk_Send_Raw` enabled, you are responsible for creating and populating the `event` section of the payload.

For example, to add a custom index and hostname:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  filters:
    # nest the record under the 'event' key
    - name: nest
      match: '*'
      operation: nest
      wildcard: '*'
      nest_under: event

    - name: modify
      match: '*'
      add:
        - index my-splunk-index
        - host my-host

  outputs:
    - name: splunk
      match: '*'
      host: 127.0.0.1
      splunk_token: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx'
      splunk_send_raw: On
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name  cpu
    Tag   cpu

# nest the record under the 'event' key
[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard *
    Nest_Under event

# add event metadata
[FILTER]
    Name      modify
    Match     *
    Add index my-splunk-index
    Add host  my-host

[OUTPUT]
    Name        splunk
    Match       *
    Host        127.0.0.1
    Splunk_Token xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    Splunk_Send_Raw On
```

{% endtab %}
{% endtabs %}

This will create a payload that looks like:

```json
{
  "time": "1535995058.003385189",
  "index": "my-splunk-index",
  "host": "my-host",
  "event": {
    "cpu_p":0.000000,
    "user_p":0.000000,
    "system_p":0.000000
  }
}
```

### Sending raw events

If the option `splunk_send_raw` has been enabled, the user must add all log details in the event field, and only specify fields known to Splunk in the top level event. If there is a mismatch, Splunk returns an HTTP `400 Bad Request` status code.

Consider the following examples:

- `splunk_send_raw` off

  ```json
  {"time": "SOMETIME", "event": {"k1": "foo", "k2": "bar", "index": "applogs"}}
  ```

- `splunk_send_raw` on

  ```json
  {"time": "SOMETIME", "k1": "foo", "k2": "bar", "index": "applogs"}
  ```

For up-to-date information about the valid keys, see [Getting Data In](https://docs.splunk.com/Documentation/Splunk/7.1.10/Data/AboutHEC).

### Automatic timestamp extraction

Automatic timestamp extraction is available in Fluent Bit version 5.1.1 and greater.

By default, Fluent Bit sends the event timestamp to Splunk in the `time` field of the event envelope. Set `auto_extract_timestamp` to `on` when the timestamp inside your event data is more accurate than the timestamp Fluent Bit assigned, for example when reading logs that were buffered elsewhere before collection.

When this option is enabled, Fluent Bit sends events to `/services/collector/event?auto_extract_timestamp=true` instead of `/services/collector/event`, which tells the HTTP Event Collector to parse the timestamp out of the event data. Fluent Bit also omits the `time` field from the event envelope, so Splunk has no timestamp to prefer over the one it extracts:

- `auto_extract_timestamp` off

  ```json
  {"time": "SOMETIME", "event": {"k1": "foo", "timestamp": "2026-08-17T10:00:00Z"}}
  ```

- `auto_extract_timestamp` on

  ```json
  {"event": {"k1": "foo", "timestamp": "2026-08-17T10:00:00Z"}}
  ```

If `splunk_send_raw` is also enabled, Fluent Bit doesn't generate a `time` field, but it does forward a top-level `time` key when your record contains one. Splunk prefers that value over the timestamp it would extract, so omit the top-level `time` key from your records when you want `auto_extract_timestamp` to take effect.

Splunk must be able to find a timestamp in the event data. If it can't, it assigns the time at which the event was indexed. For the timestamp formats and the extraction rules Splunk applies, see [Configure timestamp recognition](https://docs.splunk.com/Documentation/Splunk/latest/Data/HowSplunkextractstimestamps).

### Record-derived event time

Record-derived event time is available in Fluent Bit version 5.1.2 and greater.

Set `time_key` to the name of a record key that holds the event time when you want Splunk to receive that value in the `time` field of the event envelope instead of the timestamp Fluent Bit assigned. Unlike [automatic timestamp extraction](#automatic-timestamp-extraction), which delegates parsing to the HTTP Event Collector, Fluent Bit parses the value itself and sends the result in the envelope.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: splunk
      match: '*'
      host: 127.0.0.1
      port: 8088
      splunk_token: 00000000-0000-0000-0000-000000000000
      time_key: aggregator_time
      time_key_format: '%Y-%m-%dT%H:%M:%S.%LZ'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name             splunk
  Match            *
  Host             127.0.0.1
  Port             8088
  Splunk_Token     00000000-0000-0000-0000-000000000000
  Time_Key         aggregator_time
  Time_Key_Format  %Y-%m-%dT%H:%M:%S.%LZ
```

{% endtab %}
{% endtabs %}

`time_key` accepts a plain key name or a [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) pattern. A plain key name is treated as a top level key, so `aggregator_time` and `$aggregator_time` are equivalent. Use the record accessor form to reach a nested key, for example `$meta['ts']`.

The following value types are parsed without setting `time_key_format`:

- An integer or float holding a Unix timestamp, with an optional fractional part.
- A string holding a numeric Unix timestamp.
- An event time value produced by an earlier stage of the pipeline.

Set `time_key_format` for any other string format. When `time_key` is populating the event envelope, Fluent Bit prepares the format once at startup, so an invalid format prevents the output from starting. When `time_key` isn't in use, the format is never prepared and Fluent Bit logs a warning that the option has no effect.

If the key isn't present in the record, or its value can't be parsed as a timestamp, Fluent Bit uses the event timestamp instead and continues. A missing key is reported at the `debug` log level, and a value that can't be parsed is reported as a warning. Raise the log level to confirm which records fell back.

These options apply only to the event envelope:

- When `splunk_send_raw` is enabled there is no envelope to populate, so both options are ignored and neither is validated. Fluent Bit logs warnings at startup rather than failing, which means neither an unrelated `time_key` pattern nor an invalid `time_key_format` can stop a raw mode output from starting.
- When `auto_extract_timestamp` is enabled the `time` field is omitted from the envelope entirely, so `time_key` has no effect. Use one option or the other.

## Splunk metric index

With Splunk version 8.0 and later, you can use the Fluent Bit Splunk output plugin to send data to metric indices. This lets you perform visualizations, metric queries, and analysis with other metrics you might be collecting. This is based off of Splunk 8.0 support of multi metric support using single JSON payload, more details can be found in [Splunk metrics documentation](https://docs.splunk.com/Documentation/Splunk/9.4.2/Metrics/GetMetricsInOther#The_multiple-metric_JSON_format)

Sending to a Splunk metric index requires the use of `Splunk_send_raw` option being enabled and formatting the message properly. This includes these specific operations:

- Nest metric events under a `fields` property
- Add `metric_name:` to all metrics
- Add `index`, `source`, `sourcetype` as fields in the message

### Example configuration

The following configuration gathers CPU metrics, nests the appropriate field, adds the required identifiers and then sends to Splunk.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  filters:
    # Move CPU metrics to be nested under "fields" and
    # add the prefix "metric_name:" to all metrics
    # NOTE: you can change Wildcard field to only select metric fields
    - name: nest
      match: cpu
      wildcard: '*'
      operation: nest
      nest_under: fields
      add_prefix: 'metric_name:'

    # Add index, source, sourcetype
    - name: modify
      match: cpu
      set:
        - index cpu-metrics
        - source fluent-bit
        - sourcetype custom

  outputs:
    - name: splunk
      match: '*'
      host: <HOST>
      port: 8088
      splunk_token: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx'
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu
  Tag  cpu

# Move CPU metrics to be nested under "fields" and
# add the prefix "metric_name:" to all metrics
# NOTE: you can change Wildcard field to only select metric fields
[FILTER]
  Name       nest
  Match      cpu
  Wildcard   *
  Operation  nest
  Nest_Under fields
  Add_Prefix metric_name:

# Add index, source, sourcetype
[FILTER]
  Name    modify
  Match   cpu
  Set     index cpu-metrics
  Set     source fluent-bit
  Set     sourcetype custom

# ensure splunk_send_raw is on
[OUTPUT]
  Name            splunk
  Match           *
  Host            <HOST>
  Port            8088
  Splunk_Send_Raw on
  Splunk_Token    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
  Tls             on
  Tls.verify      off
```

{% endtab %}
{% endtabs %}

## Send metrics events of Fluent Bit

In Fluent Bit 2.0 or later, you can send Fluent Bit metrics the `events` type into Splunk using Splunk HEC. This lets you perform visualizations, metric queries, and analysis with directly sent using Fluent Bit metrics. This is based off Splunk 8.0 support of multi metric support using a single concatenated JSON payload.

Sending Fluent Bit metrics into Splunk requires the use of collecting Fluent Bit metrics plugins, whether events type of logs or metrics can be distinguished automatically. You don't need to pay attentions about the type of events.

This example includes two specific operations

- Collect node or Fluent Bit internal metrics
- Send metrics as single concatenated JSON payload

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: node_exporter_metrics
      tag: node_exporter_metrics

  outputs:
    - name: splunk
      match: '*'
      host: <HOST>
      port: 8088
      splunk_token: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx'
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name node_exporter_metrics
    Tag  node_exporter_metrics

[OUTPUT]
    Name         splunk
    Match        *
    Host         <HOST>
    Port         8088
    Splunk_Token xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    Tls          on
    Tls.verify   off
```

{% endtab %}
{% endtabs %}
