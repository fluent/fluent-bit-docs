---
description: An input plugin to ingest OTLP Logs, Metrics, and Traces
---

# OpenTelemetry

The OpenTelemetry plugin allows you to ingest telemetry data as per the OTLP specification, from various OpenTelemetry exporters, the OpenTelemetry Collector, or Fluent Bit's OpenTelemetry output plugin.

## Configuration <a href="#configuration" id="configuration"></a>

| Key           | Description                                                                                                                                    | default |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| listen            | The address to listen on                                                                                                                       | 0.0.0.0 |
| port              | The port for Fluent Bit to listen on                                                                                                           | 4318    |
| tag_key           | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                            |         |
| raw_traces        | Route trace data as a log message                                                                                                              | false   |
| buffer_max_size   | Specify the maximum buffer size in KB to receive a JSON message.                                                                               | 4M      |
| buffer_chunk_size | This sets the chunk size for incoming incoming JSON messages. These chunks are then stored/managed in the space available by buffer_max_size.  | 512K    |
|successful_response_code | It allows to set successful response code. `200`, `201` and `204` are supported.| 201 |
| tag_from_uri      | If true, tag will be created from uri. e.g. v1_metrics from /v1/metrics .                                                                      | true    |

Important note: Raw traces means that any data forwarded to the traces endpoint (`/v1/traces`) will be packed and forwarded as a log message, and will NOT be processed by Fluent Bit. The traces endpoint by default expects a valid protobuf encoded payload, but you can set the `raw_traces` option in case you want to get trace telemetry data to any of Fluent Bit's supported outputs.

## Getting started

The OpenTelemetry plugin currently supports the following telemetry data types:

|     Type    |    HTTP/JSON  |   HTTP/Protobuf |
| ----------- | ------------- | --------------- |
|    Logs     |     Stable    |      Stable     |
|    Metrics  | Unimplemented |      Stable     |
|    Traces   | Unimplemented |      Stable     |

A sample config file to get started will look something like the following:


{% tabs %}
{% tab title="fluent-bit.conf" %}
```
[INPUT]
	name opentelemetry
	listen 127.0.0.1
	port 4318

[OUTPUT]
	name stdout
	match *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: opentelemetry
          listen: 127.0.0.1
          port: 4318
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

With the above configuration, Fluent Bit will listen on port `4318` for data. You can now send telemetry data to the endpoints `/v1/metrics`, `/v1/traces`, and `/v1/logs` for metrics, traces, and logs respectively.

A sample curl request to POST json encoded log data would be:
```
curl --header "Content-Type: application/json" --request POST --data '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"timeUnixNano":"1660296023390371588","body":{"stringValue":"{\"message\":\"dummy\"}"},"traceId":"","spanId":""}]}]}]}'   http://0.0.0.0:4318/v1/logs
```
