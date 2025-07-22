---
description: Send logs to Splunk HTTP Event Collector
---

# Splunk

The _Splunk_ output plugin lets you ingest your records into a [Splunk Enterprise](https://www.splunk.com/en_us/products/splunk-enterprise.html) service through the HTTP Event Collector (HEC) interface.

To learn how to set up the HEC in Splunk, refer to [Splunk / Use the HTTP Event Collector](http://docs.splunk.com/Documentation/Splunk/7.0.3/Data/UsetheHTTPEventCollector)

## Configuration parameters

Connectivity, transport, and authentication configuration properties:

| Key | Description | Default |
|:----|:------------|:--------|
| `host` | IP address or hostname of the target Splunk service. | `127.0.0.1` |
| `port` | TCP port of the target Splunk service. | `8088` |
| `splunk_token` | Specify the authentication token for the HTTP Event Collector interface.| _none_ |
| `http_user` | Optional username for basic authentication on HEC. | _none_ |
| `http_passwd` | Password for user defined in `http_user` | _none_ |
| `http_buffer_size` | Buffer size used to receive Splunk HTTP responses. | `2M` |
| `compress` | Set payload compression mechanism. Allowed value: `gzip`. | _none_ |
| `channel` | Specify `X-Splunk-Request-Channel` header for the HTTP Event Collector interface. | _none_ |
| `http_debug_bad_request` | If the HTTP server response code is `400` (bad request) and this flag is enabled, it will print the full HTTP request and response to the stdout interface. This feature is available for debugging purposes. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

Content and Splunk metadata (fields) handling configuration properties:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `splunk_send_raw` | When enabled, the record keys and values are set in the top level of the map instead of under the event key. See [Sending Raw Events](sending-raw-events) to configure this option. | `off` |
| `event_key` | Specify the key name that will be used to send a single value as part of the record. | _none_ |
| `event_host` | Specify the key name that contains the host value. This option allows a record accessors pattern. | _none_ |
| `event_source` | Set the source value to assign to the event data. | _none_ |
| `event_sourcetype` | Set the `sourcetype` value to assign to the event data. | _none_ |
| `event_sourcetype_key` | Set a record key that will populate `sourcetype`. If the key is found, it will have precedence over the value set in `event_sourcetype`. | _none_ |
| `event_index` | The name of the index by which the event data is to be indexed. | _none_ |
| `event_index_key` | Set a record key that will populate the `index` field. If the key is found, it will have precedence over the value set in `event_index`. | _none_ |
| `event_field` | Set event fields for the record. This option can be set multiple times and the format is `key_name record_accessor_pattern`. | _none_ |

### TLS / SSL

The Splunk output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

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
  TLS         On
  TLS.Verify  Off
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
    Nest_under event

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
  name cpu
  tag cpu

# Move CPU metrics to be nested under "fields" and
# add the prefix "metric_name:" to all metrics
# NOTE: you can change Wildcard field to only select metric fields
[FILTER]
  Name nest
  Match cpu
  Wildcard *
  Operation nest
  Nest_under fields
  Add_Prefix metric_name:

# Add index, source, sourcetype
[FILTER]
  Name    modify
  Match   cpu
  Set index cpu-metrics
  Set source fluent-bit
  Set sourcetype custom

# ensure splunk_send_raw is on
[OUTPUT]
  name splunk
  match *
  host <HOST>
  port 8088
  splunk_send_raw on
  splunk_token xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
  tls on
  tls.verify off
```

{% endtab %}
{% endtabs %}

## Send metrics events of Fluent Bit

In Fluent Bit 2.0 or later, you can send Fluent Bit metrics the `events` type into Splunk using Splunk HEC. This lets you perform visualizations, metric queries, and analysis with directly sent using Fluent Bit metrics. This is based off Splunk 8.0 support of multi metric support using a single concatenated JSON payload.

Sending Fluent Bit metrics into Splunk requires the use of collecting Fluent Bit metrics plugins, whether events type of logs or metrics can be distinguished automatically.
You don't need to pay attentions about the type of events.

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
    name node_exporter_metrics
    tag node_exporter_metrics

[OUTPUT]
    name splunk
    match *
    host <HOST>
    port 8088
    splunk_token xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    tls on
    tls.verify off
```

{% endtab %}
{% endtabs %}
