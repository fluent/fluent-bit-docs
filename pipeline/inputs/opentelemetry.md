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
| `buffer_max_size`                   | Specify the maximum buffer size in `KB`, `MB`, or `GB` to the HTTP payload.                                                                                                                   | `4M`        |
| `buffer_chunk_size`                 | Initial size and allocation strategy to store the payload (advanced users only).                                                                                                              | `512K`      |
| `encode_profiles_as_log`            | Encode profiles received as text and ingest them in the logging pipeline.                                                                                                                     | `true`      |
| `host`                              | The hostname.                                                                                                                                                                                 | `localhost` |
| `http2`                             |                                                                                                                                                                                               | `true`      |
| `listen`                            | The network address to listen on.                                                                                                                                                             | `0.0.0.0`   |
| `log_level`                         | Specifies the log level for this plugin. If not set here, the plugin uses the global log level specified in the `service` section of your configuration file.                                                                                | `info`      |
| `log_supress_interval`              | Suppresses log messages from this plugin that appear similar within a specified time interval. `0` no suppression.                                                                          | `0`         |
| `logs_body_key`                     | Specify a body key.                                                                                                                                                                           | _none_      |
| `logs_metadata_key`                 | Specify a metadata key.                                                                                                                                                                       | `otlp`      |
| `mem_buf_limit`                     | Set a memory buffer limit for the input plugin. If the limit is reached, the plugin will pause until the buffer is drained. The value is in bytes. If set to 0, the buffer limit is disabled. | `0`         |
| `net.accept_timeout`                | Set maximum time allowed to establish an incoming connection. This time includes the TLS handshake.                                                                                           | `10s`       |
| `net.accept_timeout_log_error`      | On client accept timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message.                                                                         | `true`      |
| `net.backlog`                       | Set the backlog size for listening sockets.                                                                                                                                                   | `128`       |
| `net.io_timeout`                    | Set maximum time a connection can stay idle.                                                                                                                                                  | `0s`        |
| `net.keepalive`                     | Enable or disable Keepalive support.                                                                                                                                                          | `true`      |
| `net.share_port`                    | Allow multiple plugins to bind to the same port.                                                                                                                                              | `false`     |
| `port`                              | The port for Fluent Bit to listen for incoming connections.                                                                                                                                   | `0`         |
| `profiles_support`                  | This is an experimental feature, feel free to test it but don't enable this in production environments.                                                                                       | `false`     |
| `raw_traces`                        | Forward traces without processing.                                                                                                                                                            | `false`     |
| `routable`                          | If set to `true`, the data generated by the plugin will be routable, meaning that it can be forwarded to other plugins or outputs. If set to `false`, the data will be  discarded.            | `true`      |
| `storage.pause_on_chunks_overlimit` | Enable pausing on an input when they reach their chunks limit.                                                                                                                                | _none_      |
| `storage.type`                      | Sets the storage type for this input, one of: `filesystem`, `memory` or `memrb`.                                                                                                              | `memory`    |
| `successful_response_code`          | Allows for setting a successful response code. Supported values: `200`, `201`, or `204`.                                                                                                      | `201`       |
| `tag`                               | Set a tag for the events generated by this input plugin.                                                                                                                                      | _none_      |
| `tag_from_uri`                      | By default, the tag will be created from the URI. For example, `v1_metrics` from `/v1/metrics`. This must be set to false if using `tag`.                                                     | `true`      |
| `tag_key`                           | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                                                                           | _none_      |
| `threaded`                          | Enable threading on an input.                                                                                                                                                                 | `false`     |
| `thread.ring_buffer.capacity`       | Set custom ring buffer capacity when the input runs in threaded mode.                                                                                                                         | `1024`      |
| `thread.ring_buffer.window`         | Set custom ring buffer window percentage for threaded inputs.                                                                                                                                 | `5`         |
| `tls`                               | Enable or disable TLS/SSL support.                                                                                                                                                            | `off`       |
| `tls.ca_file`                       | Absolute path to CA certificate file.                                                                                                                                                         | _none_      |
| `tls.ca_path`                       | Absolute path to scan for certificate files.                                                                                                                                                  | _none_      |
| `tls.cert_file`                     | Absolute path to Certificate file.                                                                                                                                                            | _none_      |
| `tls.ciphers`                       | Specify TLS ciphers up to TLSv1.2.                                                                                                                                                            | _none_      |
| `tls.debug`                         | Set TLS debug level. Accepts `0` (No debug), `1`(Error), `2` (State change), `3` (Informational) and `4` (Verbose).                                                                           | `1`         |
| `tls.key_file`                      | Absolute path to private Key file.                                                                                                                                                            | _none_      |
| `tls.key_passwd`                    | Optional password for tls.key_file file.                                                                                                                                                      | _none_      |
| `tls.max_version`                   | Specify the maximum version of TLS.                                                                                                                                                           | _none_      |
| `tls.min_version`                   | Specify the minimum version of TLS.                                                                                                                                                           | _none_      |
| `tls.verify`                        | Force certificate validation.                                                                                                                                                                 | `on`        |
| `tls.verify_hostname`               | Enable or disable to verify hostname.                                                                                                                                                         | `off`       |
| `tls.vhost`                         | Hostname to be used for TLS SNI extension.                                                                                                                                                    | _none_      |

Raw traces means that any data forwarded to the traces endpoint (`/v1/traces`) will be packed and forwarded as a log message, and won't be processed by Fluent Bit. The traces endpoint by default expects a valid `protobuf` encoded payload, but you can set the `raw_traces` option in case you want to get trace telemetry data to any of the Fluent Bit supported outputs.

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
| Traces  | Unimplemented | Stable         | Stable     |

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
