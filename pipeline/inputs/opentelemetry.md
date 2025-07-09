---
description: An input plugin to ingest OpenTelemetry logs, metrics, and traces
---

# OpenTelemetry

The OpenTelemetry input plugin lets you receive data based on the OpenTelemetry specification from various OpenTelemetry exporters, the OpenTelemetry Collector, or the Fluent Bit OpenTelemetry output plugin.

Fluent Bit has a compliant implementation which fully supports `OTLP/HTTP` and `OTLP/GRPC`. The single `port` configured defaults to `4318` and supports both transport methods.

## Configuration

| Key      | Description | Default |
| -------- | ------------| ------- |
| `listen` | The network address to listen on. | `0.0.0.0` |
| `port`   | The port for Fluent Bit to listen for incoming connections. In Fluent Bit 3.0.2 or later, this port is used for both transport `OTLP/HTTP` and `OTLP/GRPC`. | `4318` |
| `tag` | Tag for all data ingested by this plugin. This will only be used if `tag_from_uri` is set to `false`. Otherwise, the tag will be created from the URI. | _none_ |
| `tag_key` | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key. | _none_ |
| `raw_traces`        | Route trace data as a log. | `false` |
| `buffer_max_size`   | Specify the maximum buffer size in `KB`, `MB`, or `GB` to the HTTP payload. | `4M` |
| `buffer_chunk_size` | Initial size and allocation strategy to store the payload (advanced users only)` | `512K` |
| `successful_response_code` | Allows for setting a successful response code. Supported values: `200`, `201`, or `204`. | `201` |
| `tag_from_uri` | By default, the tag will be created from the URI. For example, `v1_metrics` from `/v1/metrics`. This must be set to false if using `tag`. | `true` |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

Raw traces means that any data forwarded to the traces endpoint (`/v1/traces`) will be packed and forwarded as a log message, and won' be processed by Fluent Bit. The traces endpoint by default expects a valid `protobuf` encoded payload, but you can set the `raw_traces` option in case you want to get trace telemetry data to any of the Fluent Bit supported outputs.

### OpenTelemetry transport protocol endpoints

Fluent Bit exposes the following endpoints for data ingestion based on the OpenTelemetry protocol:

For `OTLP/HTTP`:

- Logs
  - `/v1/logs`
- Metrics
  - `/v1/metrics`
- Traces
  - `/v1/traces`

For `OTLP/GRPC`:

- Logs
  - `/opentelemetry.proto.collector.log.v1.LogService/Export`
  - `/opentelemetry.proto.collector.log.v1.LogService/Export`
- Metrics
  - `/opentelemetry.proto.collector.metric.v1.MetricService/Export`
  - `/opentelemetry.proto.collector.metrics.v1.MetricsService/Export`
- Traces
  - `/opentelemetry.proto.collector.trace.v1.TraceService/Export`
  - `/opentelemetry.proto.collector.traces.v1.TracesService/Export`

## Get started

The OpenTelemetry input plugin supports the following telemetry data types:

| Type    | HTTP1/JSON | HTTP1/Protobuf | HTTP2/GRPC |
| ------- | ---------- | -------------- | ---------- |
| Logs    | Stable | Stable | Stable |
| Metrics | Unimplemented | Stable | Stable |
| Traces  | Unimplemented | Stable | Stable |

A sample configuration file to get started will look something like the following:

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

```text
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

With this configuration, Fluent Bit listens on port `4318` for data. You can now send telemetry data to the endpoints `/v1/metrics` for metrics, `/v1/traces` for traces, and `/v1/logs` for logs.

A sample curl request to POST JSON encoded log data would be:

```shell
curl --header "Content-Type: application/json" --request POST --data '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"timeUnixNano":"1660296023390371588","body":{"stringValue":"{\"message\":\"dummy\"}"},"traceId":"","spanId":""}]}]}]}'   http://0.0.0.0:4318/v1/logs
```