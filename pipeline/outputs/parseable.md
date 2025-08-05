---
description: Send logs, metrics, and traces to Parseable
---

# Parseable

Stream logs, metrics, and traces to [Parseable](https://www.parseable.com) by utilizing the [OpenTelemetry plugin](opentelemetry.md) to send telemetry data to Parseable's OpenTelemetry-compatible Ingestor endpoints.

## Configuration parameters

| Key                        | Description | Default |
| -------------------------- | ----------- | ------- |
| `host`                     | Your Parseable Ingestor hostname or IP address. | `parseable` |
| `port`                     | TCP port of your Parseable Ingestor. | `8000` |
| `http_user`                | Username for HTTP basic authentication. | `admin` |
| `http_passwd`              | Password for HTTP basic authentication. | `admin` |
| `header`                   | **Required headers for Parseable integration.** Must include `X-P-Stream` (stream name) and `X-P-Log-Source` (telemetry type: `otel-logs`, `otel-metrics`, or `otel-traces`). | **Required** |
| `add_label`                | Add custom labels to the telemetry data. | None |
| `log_response_payload`     | Log the response payload from the server for debugging. | `False` |
| `metrics_uri`              | Specify the HTTP URI for the target web server listening for metrics | `/v1/metrics` |
| `logs_uri`                 | Specify the HTTP URI for the target web server listening for logs | `/v1/logs` |
| `traces_uri`               | Specify the HTTP URI for the target web server listening for traces | `/v1/traces` |
| `tls`                      | Enable or disable TLS/SSL encryption. | `Off` |

### TLS / SSL

The OpenTelemetry output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To get started with sending telemetry data to Parseable:

1. Ensure your Parseable Ingestor is running and accessible.
2. Configure authentication credentials (username/password).
3. In your main Fluent Bit configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    # Send logs to Parseable
    - name: opentelemetry
      match: v1_logs
      host: parseable
      port: 8000
      logs_uri: /v1/logs
      log_response_payload: true
      tls: off
      http_user: admin
      http_passwd: admin
      header: X-P-Stream otellogs
      header: X-P-Log-Source otel-logs
      add_label: app fluent-bit

    # Send metrics to Parseable
    - name: opentelemetry
      match: v1_metrics
      host: parseable
      port: 8000
      metrics_uri: /v1/metrics
      log_response_payload: true
      tls: off
      http_user: admin
      http_passwd: admin
      header: X-P-Stream otelmetrics
      header: X-P-Log-Source otel-metrics
      add_label: app fluent-bit

    # Send traces to Parseable
    - name: opentelemetry
      match: v1_traces
      host: parseable
      port: 8000
      traces_uri: /v1/traces
      log_response_payload: true
      tls: off
      http_user: admin
      http_passwd: admin
      header: X-P-Stream oteltraces
      header: X-P-Log-Source otel-traces
      add_label: app fluent-bit
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
# Send logs to Parseable
[OUTPUT]
    Name          opentelemetry
    Match         v1_logs
    Host          parseable
    Port          8000
    Logs_uri      /v1/logs
    Log_response_payload True
    Tls           Off
    Http_User     admin
    Http_Passwd   admin
    Header        X-P-Stream otellogs
    Header        X-P-Log-Source otel-logs
    Add_label     app fluent-bit

# Send metrics to Parseable
[OUTPUT]
    Name          opentelemetry
    Match         v1_metrics
    Host          parseable
    Port          8000
    Metrics_uri   /v1/metrics
    Log_response_payload True
    Tls           Off
    Http_User     admin
    Http_Passwd   admin
    Header        X-P-Stream otelmetrics
    Header        X-P-Log-Source otel-metrics
    Add_label     app fluent-bit

# Send traces to Parseable
[OUTPUT]
    Name          opentelemetry
    Match         v1_traces
    Host          parseable
    Port          8000
    Traces_uri    /v1/traces
    Log_response_payload True
    Tls           Off
    Http_User     admin
    Http_Passwd   admin
    Header        X-P-Stream oteltraces
    Header        X-P-Log-Source otel-traces
    Add_label     app fluent-bit
```

{% endtab %}
{% endtabs %}

## Stream Configuration

Parseable uses streams to organize your telemetry data. The `X-P-Stream` header specifies which stream the data should be sent to:

- **otellogs**: Stream for log data
- **otelmetrics**: Stream for metrics data  
- **oteltraces**: Stream for trace data

The `X-P-Log-Source` header helps identify the source of the telemetry data for better organization and filtering. And this has to be set to `otel-logs`, `otel-metrics`, or `otel-traces` based on the telemetry type.

## Authentication

Parseable supports HTTP basic authentication. Configure the `http_user` and `http_passwd` parameters with your Parseable server credentials.

## References

- [Parseable documentation](https://www.parseable.com/docs)
- [Parseable Fluent-bit integration](https://www.parseable.com/docs/datasource/log-agents/fluent-bit)
