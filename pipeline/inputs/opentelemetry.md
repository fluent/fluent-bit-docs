---
description: An input plugin to ingest OpenTelemetry logs, metrics, and traces
---

# OpenTelemetry

The OpenTelemetry input plugin lets you receive data based on the OpenTelemetry specification from various OpenTelemetry exporters, the OpenTelemetry Collector, or the Fluent Bit OpenTelemetry output plugin.

Fluent Bit has a compliant implementation which fully supports `OTLP/HTTP` and `OTLP/GRPC`. The single `port` configured defaults to `4318` and supports both transport methods.

## Configuration

| Key                                 | Description                                                                                                                                                                                   | Default     |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| `alias`                             | Sets an alias for multiple instances of the same input plugin. If no alias is specified, a default name will be assigned using the plugin name followed by a dot and a sequence number.       | _none_      |
| `buffer_chunk_size`                 | Size of each buffer chunk allocated for HTTP requests (advanced users only).                                                                                                                  | `512K`      |
| `buffer_max_size`                   | Maximum size of the HTTP request buffer in `KB`, `MB`, or `GB`.                                                                                                                               | `4M`        |
| `encode_profiles_as_log`            | Encode profiles received as text and ingest them in the logging pipeline.                                                                                                                     | `true`      |
| `host`                              | The hostname.                                                                                                                                                                                 | `localhost` |
| `http2`                             | Enable HTTP/2 protocol support for the OpenTelemetry receiver.                                                                                                                                | `true`      |
| `listen`                            | The network address to listen on.                                                                                                                                                             | `0.0.0.0`   |
| `log_level`                         | Specifies the log level for this plugin. If not set here, the plugin uses the global log level specified in the `service` section of your configuration file.                                 | `info`      |
| `log_suppress_interval`             | Suppresses log messages from this plugin that appear similar within a specified time interval. `0` no suppression.                                                                            | `0`         |
| `logs_body_key`                     | Specify a body key.                                                                                                                                                                           | _none_      |
| `logs_metadata_key`                 | Key name to store OpenTelemetry logs metadata in the record.                                                                                                                                  | `otlp`      |
| `mem_buf_limit`                     | Set a memory buffer limit for the input plugin. If the limit is reached, the plugin will pause until the buffer is drained. The value is in bytes. If set to 0, the buffer limit is disabled. | `0`         |
| `net.accept_timeout`                | Set maximum time allowed to establish an incoming connection. This time includes the TLS handshake.                                                                                           | `10s`       |
| `net.accept_timeout_log_error`      | On client accept timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message.                                                                         | `true`      |
| `net.backlog`                       | Set the backlog size for listening sockets.                                                                                                                                                   | `128`       |
| `net.io_timeout`                    | Set maximum time a connection can stay idle.                                                                                                                                                  | `0s`        |
| `net.keepalive`                     | Enable or disable keepalive support.                                                                                                                                                          | `true`      |
| `net.share_port`                    | Allow multiple plugins to bind to the same port.                                                                                                                                              | `false`     |
| `port`                              | The port for Fluent Bit to listen for incoming connections.                                                                                                                                   | `4318`      |
| `profiles_support`                  | This is an experimental feature, feel free to test it but don't enable this in production environments.                                                                                       | `false`     |
| `raw_traces`                        | Forward traces without processing. When set to `false` (default), traces are processed using the unified JSON parser with strict validation. When set to `true`, trace data is forwarded as raw log messages without validation or processing.                                                                                                                              | `false`     |
| `routable`                          | If set to `true`, the data generated by the plugin will be routable, meaning that it can be forwarded to other plugins or outputs. If set to `false`, the data will be discarded.             | `true`      |
| `storage.pause_on_chunks_overlimit` | Enable pausing on an input when they reach their chunks limit.                                                                                                                                | _none_      |
| `storage.type`                      | Sets the storage type for this input, one of: `filesystem`, `memory` or `memrb`.                                                                                                              | `memory`    |
| `successful_response_code`          | Allows for setting a successful response code. Supported values: `200`, `201`, or `204`.                                                                                                      | `201`       |
| `tag`                               | Set a tag for the events generated by this input plugin.                                                                                                                                      | _none_      |
| `tag_from_uri`                      | By default, the tag will be created from the URI. For example, `v1_metrics` from `/v1/metrics`. This must be set to false if using `tag`.                                                     | `true`      |
| `tag_key`                           | Record accessor key to use for generating tags from incoming records.                                                                                                                         | _none_      |
| `thread.ring_buffer.capacity`       | Number of slots in the ring buffer for data entries when running in [threaded](../../administration/multithreading.md) mode. Each slot can hold one data entry.                              | `1024`      |
| `thread.ring_buffer.window`         | Percentage threshold (1-100) of the ring buffer capacity at which a flush is triggered when running in [threaded](../../administration/multithreading.md) mode.                              | `5`         |
| `threaded`                          | Enable [multithreading](../../administration/multithreading.md) for this input to run in a separate dedicated thread.                                                                         | `false`     |
| `tls`                               | Enable or disable TLS/SSL support.                                                                                                                                                            | `off`       |
| `tls.ca_file`                       | Absolute path to CA certificate file.                                                                                                                                                         | _none_      |
| `tls.ca_path`                       | Absolute path to scan for certificate files.                                                                                                                                                  | _none_      |
| `tls.ciphers`                       | Specify TLS ciphers up to TLSv1.2.                                                                                                                                                            | _none_      |
| `tls.crt_file`                      | Absolute path to Certificate file.                                                                                                                                                            | _none_      |
| `tls.debug`                         | Set TLS debug level. Accepts `0` (No debug), `1`(Error), `2` (State change), `3` (Informational) and `4` (Verbose).                                                                           | `1`         |
| `tls.key_file`                      | Absolute path to private Key file.                                                                                                                                                            | _none_      |
| `tls.key_passwd`                    | Optional password for tls.key_file file.                                                                                                                                                      | _none_      |
| `tls.max_version`                   | Specify the maximum version of TLS.                                                                                                                                                           | _none_      |
| `tls.min_version`                   | Specify the minimum version of TLS.                                                                                                                                                           | _none_      |
| `tls.verify`                        | Force certificate validation.                                                                                                                                                                 | `on`        |
| `tls.verify_hostname`               | Enable or disable to verify hostname.                                                                                                                                                         | `off`       |
| `tls.vhost`                         | Hostname to be used for TLS SNI extension.                                                                                                                                                    | _none_      |

When `raw_traces` is set to `false` (default), the traces endpoint (`/v1/traces`) processes incoming trace data using the unified JSON parser with strict validation. The endpoint accepts both `protobuf` and `JSON` encoded payloads. When `raw_traces` is set to `true`, any data forwarded to the traces endpoint will be packed and forwarded as a log message without processing, validation, or conversion to the Fluent Bit internal trace format.

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

| Type    | HTTP1/JSON    | HTTP1/Protobuf | HTTP2/gRPC |
|---------|---------------|----------------|------------|
| Logs    | Stable        | Stable         | Stable     |
| Metrics | Unimplemented | Stable         | Stable     |
| Traces  | Stable        | Stable         | Stable     |

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

## OpenTelemetry trace improvements

Fluent Bit includes enhanced support for OpenTelemetry traces with improved JSON parsing, error handling, and validation capabilities.

### Unified trace JSON parser

Fluent Bit provides a unified interface for processing OpenTelemetry trace data in JSON format. The parser converts OpenTelemetry JSON trace payloads into the Fluent Bit internal trace representation, supporting the full OpenTelemetry trace specification including:

- Resource spans with attributes
- Instrumentation scope information
- Span data (names, IDs, timestamps, status)
- Span events and links
- Trace and span ID validation

The unified parser handles the OpenTelemetry JSON encoding format, which wraps attribute values in type-specific containers (for example, `stringValue`, `intValue`, `doubleValue`, `boolValue`).

### Error status propagation

The OpenTelemetry input plugin provides detailed error status information when processing trace data. If trace processing fails, the plugin returns specific error codes that help identify the issue:

- `FLB_OTEL_TRACES_ERR_INVALID_JSON` - Invalid JSON format
- `FLB_OTEL_TRACES_ERR_INVALID_TRACE_ID` - Invalid trace ID format or length
- `FLB_OTEL_TRACES_ERR_INVALID_SPAN_ID` - Invalid span ID format or length
- `FLB_OTEL_TRACES_ERR_INVALID_PARENT_SPAN_ID` - Invalid parent span ID
- `FLB_OTEL_TRACES_ERR_STATUS_FAILURE` - Invalid span status code
- `FLB_OTEL_TRACES_ERR_INVALID_ATTRIBUTES` - Invalid attribute format
- `FLB_OTEL_TRACES_ERR_INVALID_EVENT_ENTRY` - Invalid span event
- `FLB_OTEL_TRACES_ERR_INVALID_LINK_ENTRY` - Invalid span link

#### Valid span status codes

The OpenTelemetry specification defines three valid span status codes. When processing trace data, the plugin accepts the following status code values (case-insensitive):

- `OK` - The operation completed successfully
- `ERROR` - The operation has an error
- `UNSET` - The status isn't set (default)

Any other status code value triggers `FLB_OTEL_TRACES_ERR_STATUS_FAILURE` and causes the trace data to be rejected. The status code must be provided as a string in the `status.code` field of the span object.

#### Error handling behavior

When trace validation fails, the following behavior applies:

- **Trace data is dropped**: Invalid trace data isn't processed or forwarded. The trace payload is rejected immediately.
- **Error logging**: The plugin logs an error message with the specific error status code to help diagnose issues. Error messages include the error code number and description.
- **No retry mechanism**: Failed requests aren't automatically retried. The client must resend corrected trace data.
- **HTTP response codes**:
  - **HTTP/1.1**: Returns `400 Bad Request` with an error message when validation fails. Returns the configured `successful_response_code` (default `201 Created`) when processing succeeds.
  - **gRPC**: Returns gRPC status `2 (UNKNOWN)` with message "Serialization error." when validation fails. Returns gRPC status `0 (OK)` with an empty `ExportTraceServiceResponse` when processing succeeds.

### Strict ID decoding

Fluent Bit enforces strict validation for trace and span IDs to ensure data integrity:

- **Trace IDs**: Must be exactly 32 hexadecimal characters (16 bytes)
- **Span IDs**: Must be exactly 16 hexadecimal characters (8 bytes)
- **Parent Span IDs**: Must be exactly 16 hexadecimal characters (8 bytes) when present

The validation process:
1. Verifies the ID length matches the expected size
2. Validates that all characters are valid hexadecimal digits (0-9, a-f, A-F)
3. Decodes the hexadecimal string to binary format
4. Rejects invalid IDs with appropriate error codes

Invalid IDs result in error status codes (`FLB_OTEL_TRACES_ERR_INVALID_TRACE_ID`, `FLB_OTEL_TRACES_ERR_INVALID_SPAN_ID`, and so on) and the trace data is rejected to prevent processing of corrupted or malformed trace information.

### Example: JSON trace payload

The following example shows a valid OpenTelemetry JSON trace payload that can be sent to the `/v1/traces` endpoint:

```json
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {
            "key": "service.name",
            "value": {
              "stringValue": "my-service"
            }
          }
        ]
      },
      "scopeSpans": [
        {
          "scope": {
            "name": "my-instrumentation",
            "version": "1.0.0"
          },
          "spans": [
            {
              "traceId": "0123456789abcdef0123456789abcdef",
              "spanId": "0123456789abcdef",
              "name": "my-span",
              "kind": 1,
              "startTimeUnixNano": "1660296023390371588",
              "endTimeUnixNano": "1660296023391371588",
              "status": {
                "code": "OK"
              },
              "attributes": [
                {
                  "key": "http.method",
                  "value": {
                    "stringValue": "GET"
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

Trace IDs must be exactly 32 hex characters and span IDs must be exactly 16 hex characters. Invalid IDs will be rejected with appropriate error messages.

In the example, the `status.code` field uses `"OK"`. Valid status code values are `"OK"`, `"ERROR"`, and `"UNSET"` (case-insensitive). Any other value triggers `FLB_OTEL_TRACES_ERR_STATUS_FAILURE` and causes the trace to be rejected.
