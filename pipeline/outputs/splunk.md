---
description: Send logs to Splunk HTTP Event Collector
---

# Splunk

Splunk output plugin allows to ingest your records into a [Splunk Enterprise](https://www.splunk.com/en_us/products/splunk-enterprise.html) service through the HTTP Event Collector \(HEC\) interface.

To get more details about how to setup the HEC in Splunk please refer to the following documentation: [Splunk / Use the HTTP Event Collector](http://docs.splunk.com/Documentation/Splunk/7.0.3/Data/UsetheHTTPEventCollector)

## Configuration Parameters

Connectivity, transport and authentication configuration properties:

| Key | Description | default |
| :--- | :--- | :--- |
| host | IP address or hostname of the target Splunk service. | 127.0.0.1 |
| port | TCP port of the target Splunk service. | 8088 |
| splunk\_token | Specify the Authentication Token for the HTTP Event Collector interface. |  |
| http\_user | Optional username for Basic Authentication on HEC |  |
| http\_passwd | Password for user defined in HTTP\_User |  |
| http\_buffer\_size | Buffer size used to receive Splunk HTTP responses | 2M |
| compress | Set payload compression mechanism. The only available option is `gzip`. |  |
| channel | Specify X-Splunk-Request-Channel Header for the HTTP Event Collector interface. |  |
| http_debug_bad_request | If the HTTP server response code is 400 (bad request) and this flag is enabled, it will print the full HTTP request and response to the stdout interface. This feature is available for debugging purposes. | |
| Workers | Enables dedicated thread(s) for this output. Default value is set since version 1.8.13. For previous versions is 0. | 2 |

Content and Splunk metadata \(fields\) handling configuration properties:

| Key | Description | default |
| :--- | :--- | :--- |
| splunk\_send\_raw | When enabled, the record keys and values are set in the top level of the map instead of under the event key. Refer to the _Sending Raw Events_ section from the docs for more details to make this option work properly. | off |
| event\_key | Specify the key name that will be used to send a single value as part of the record. |  |
| event\_host | Specify the key name that contains the host value. This option allows a record accessors pattern. |  |
| event\_source | Set the source value to assign to the event data. |  |
| event\_sourcetype | Set the sourcetype value to assign to the event data. |  |
| event\_sourcetype\_key | Set a record key that will populate 'sourcetype'. If the key is found, it will have precedence over the value set in `event_sourcetype`. |  |
| event\_index | The name of the index by which the event data is to be indexed. |  |
| event\_index\_key | Set a record key that will populate the `index` field. If the key is found, it will have precedence over the value set in `event_index`. |  |
| event\_field | Set event fields for the record. This option can be set multiple times and the format is `key_name record_accessor_pattern`. |  |

### TLS / SSL

Splunk output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../../administration/transport-security.md) section.

## Getting Started

In order to insert records into a Splunk service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **splunk** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -t cpu -o splunk -p host=127.0.0.1 -p port=8088 \
  -p tls=on -p tls.verify=off -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

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

### Data format

By default, the Splunk output plugin nests the record under the `event` key in the payload sent to the HEC. It will also append the time of the record to a top level `time` key.

If you would like to customize any of the Splunk event metadata, such as the host or target index, you can set `Splunk_Send_Raw On` in the plugin configuration, and add the metadata as keys/values in the record. _Note_: with `Splunk_Send_Raw` enabled, you are responsible for creating and populating the `event` section of the payload.

For example, to add a custom index and hostname:

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

This will create a payload that looks like:

```javascript
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

For more information on the Splunk HEC payload format and all event meatadata Splunk accepts, see here: [http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC](http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC)

### Sending Raw Events

If the option `splunk_send_raw` has been enabled, the user must take care to put all log details in the event field, and only specify fields known to Splunk in the top level event, if there is a mismatch, Splunk will return a HTTP error 400.

Consider the following example:

**splunk\_send\_raw off**

```javascript
{"time": ..., "event": {"k1": "foo", "k2": "bar", "index": "applogs"}}
```

**splunk\_send\_raw on**

```text
{"time": .., "k1": "foo", "k2": "bar", "index": "applogs"}
```

For up to date information about the valid keys in the top level object, refer to the Splunk documentation:

[http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC](http://docs.splunk.com/Documentation/Splunk/latest/Data/AboutHEC)

## Splunk Metric Index

With Splunk version 8.0&gt; you can also use the Fluent Bit Splunk output plugin to send data to metric indices. This allows you to perform visualizations, metric queries, and analysis with other metrics you may be collecting. This is based off of Splunk 8.0 support of multi metric support via single JSON payload, more details can be found on [Splunk's documentation page](https://docs.splunk.com/Documentation/Splunk/8.1.2/Metrics/GetMetricsInOther#The_multiple-metric_JSON_format)

Sending to a Splunk Metric index requires the use of `Splunk_send_raw` option being enabled and formatting the message properly. This includes three specific operations

* Nest metric events under a "fields" property
* Add `metric_name:`  to all metrics
* Add index, source, sourcetype as fields in the message

### Example Configuration

The following configuration gathers CPU metrics, nests the appropriate field, adds the required identifiers and then sends to Splunk.

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
    splunk_token f9bd5bdb-c0b2-4a83-bcff-9625e5e908db 
    tls on
    tls.verify off
```

## Send Metrics Events of Fluent Bit

With Fluent Bit 2.0, you can also send Fluent Bit's metrics type of events into Splunk via Splunk HEC.
This allows you to perform visualizations, metric queries, and analysis with directly sent Fluent Bit's metrics type of events.
This is based off Splunk 8.0 support of multi metric support via single concatenated JSON payload.

Sending Fluent Bit's metrics into Splunk requires the use of collecting Fluent Bit's metrics plugins.
Note that whether events type of logs or metrics can be distinguished automatically.
You don't need to pay attentions about the type of events.
This example includes two specific operations

* Collect node or Fluent Bit's internal metrics
* Send metrics as single concatenated JSON payload

```text
[INPUT]
    name node_exporter_metrics
    tag node_exporter_metrics

[OUTPUT]
    name splunk
    match *
    host <HOST>
    port 8088
    splunk_token ee7edc62-19ad-4d1e-b957-448d3b326fb6
    tls on
    tls.verify off
```
