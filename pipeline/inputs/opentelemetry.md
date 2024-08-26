---
description: An input plugin to ingest OTLP Logs, Metrics, and Traces
---

# OpenTelemetry

The OpenTelemetry input plugin allows you to receive data as per the OTLP specification, from various OpenTelemetry exporters, the OpenTelemetry Collector, or Fluent Bit's OpenTelemetry output plugin.

Our compliant implementation fully supports OTLP/HTTP and OTLP/GRPC. Note that the single `port` configured which defaults to 4318 supports both transports.

## Configuration <a href="#configuration" id="configuration"></a>

| Key               | Description                                                                        | default |
| ----------------- | -----------------------------------------------------------------------------------| ------- |
| listen            | The network address to listen.                                                     | 0.0.0.0 |
| port              | The port for Fluent Bit to listen for incoming connections. Note that as of Fluent Bit v3.0.2 this port is used for both transport OTLP/HTTP and OTLP/GRPC.                                                                                      | 4318    |
| tag_key           | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the  |         |
| raw_traces        | Route trace data as a log                                                          | false   |
| buffer_max_size   | Specify the maximum buffer size in KB/MB/GB to the HTTP payload.                   | 4M      |
| buffer_chunk_size | Initial size and allocation strategy to store the payload (advanced users only)    | 512K    |
|successful_response_code | It allows to set successful response code. `200`, `201` and `204` are supported.| 201 |
| tag_from_uri      | If true, tag will be created from uri. e.g. v1_metrics from /v1/metrics .                                                                      | true    |
| threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | false |

Important note: Raw traces means that any data forwarded to the traces endpoint (`/v1/traces`) will be packed and forwarded as a log message, and will NOT be processed by Fluent Bit. The traces endpoint by default expects a valid protobuf encoded payload, but you can set the `raw_traces` option in case you want to get trace telemetry data to any of Fluent Bit's supported outputs.

### OTLP Transport Protocol Endpoints

Fluent Bit based on the OTLP desired protocol exposes the following endpoints for data ingestion:

__OTLP/HTTP__
- Logs
  - `/v1/logs`
- Metrics
  - `/v1/metrics`
- Traces
  - `/v1/traces`

__OTLP/GRPC__

- Logs
  - `/opentelemetry.proto.collector.log.v1.LogService/Export`
  - `/opentelemetry.proto.collector.log.v1.LogService/Export`
- Metrics
  - `/opentelemetry.proto.collector.metric.v1.MetricService/Export`
  - `/opentelemetry.proto.collector.metrics.v1.MetricsService/Export`
- Traces
  - `/opentelemetry.proto.collector.trace.v1.TraceService/Export`
  - `/opentelemetry.proto.collector.traces.v1.TracesService/Export`


## Getting started

The OpenTelemetry input plugin supports the following telemetry data types:

| Type    | HTTP1/JSON | HTTP1/Protobuf | HTTP2/GRPC |
| ------- | ---------- | -------------- | ---------- |
| Logs    | Stable | Stable | Stable |
| Metrics | Unimplemented | Stable | Stable |
| Traces  | Unimplemented | Stable | Stable |

A sample config file to get started will look something like the following:


{% tabs %}

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

{% endtabs %}

With the above configuration, Fluent Bit will listen on port `4318` for data. You can now send telemetry data to the endpoints `/v1/metrics`, `/v1/traces`, and `/v1/logs` for metrics, traces, and logs respectively.

A sample curl request to POST json encoded log data would be:
```
curl --header "Content-Type: application/json" --request POST --data '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"timeUnixNano":"1660296023390371588","body":{"stringValue":"{\"message\":\"dummy\"}"},"traceId":"","spanId":""}]}]}]}'   http://0.0.0.0:4318/v1/logs
```
