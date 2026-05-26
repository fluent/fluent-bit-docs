# OpenTelemetry

{% hint style="info" %}
**Supported event types:** `logs` `metrics` `traces` `profiles`
{% endhint %}

The OpenTelemetry plugin lets you take logs, metrics, traces, and profiles from Fluent Bit and submit them to an OpenTelemetry receiver over OTLP/HTTP or OTLP/gRPC.

OTLP/HTTP supports both HTTP/1.1 and HTTP/2. OTLP/gRPC requires HTTP/2 and is enabled with the `grpc` option.


| Key     | Description  | Default |
|---------|--------------|---------|
| `add_label`                               | Adds a custom label to the metrics use format: `add_label name value`.         | _none_ |
| `alias`                                   | Sets an alias, use for multiple instances of the same output plugin.        | _none_ |
| `aws_auth`                                | Enable AWS SigV4 authentication.                                               | `false`|
| `aws_external_id`                         | Specify an external ID for the STS API, can be used with the `aws_role_arn` parameter.                                                                  | _none_ |
| `aws_profile`                             | AWS Profile name. AWS Profiles can be configured with AWS CLI.                 | _none_ |
| `aws_region`                              | AWS region of your service.                                                    | _none_ |
| `aws_role_arn`                            | ARN of an IAM role to assume (ex. for cross account access).                   | _none_ |
| `aws_service`                             | AWS destination service code, used by SigV4 authentication.                    | `logs` |
| `aws_sts_endpoint`                        | Custom endpoint for the AWS STS API, used with the `aws_role_arn` option.      | _none_ |
| `batch_size`                              | Set the maximum number of log records to be flushed at a time.                 | `1000` |
| `compress`                                | Set payload compression mechanism. Options available are `gzip` and `zstd`.    | _none_ |
| `encoding`                                | Set the encoding used to send logs, metrics, and traces over OTLP/HTTP. Accepted values: `protobuf` (default, `Content-Type: application/x-protobuf`) or `json` (`Content-Type: application/json`). Profiles always use `protobuf`. | `protobuf` |
| `grpc`                                    | Enable gRPC transport (OTLP/gRPC). When enabled, HTTP/2 is automatically activated. Accepted values: `on`, `off`. | `off`  |
| `grpc_logs_uri`                           | gRPC endpoint URI for log exports.                                             | `/opentelemetry.proto.collector.logs.v1.LogsService/Export`                     |
| `grpc_metrics_uri`                        | gRPC endpoint URI for metric exports.                                          | `/opentelemetry.proto.collector.metrics.v1.MetricsService/Export`               |
| `grpc_profiles_uri`                       | gRPC endpoint URI for profile exports.                                         | `/opentelemetry.proto.collector.profiles.v1experimental.ProfilesService/Export` |
| `grpc_traces_uri`                         | gRPC endpoint URI for trace exports.                                           | `/opentelemetry.proto.collector.trace.v1.TraceService/Export`                   |
| `header`                                  | Add a HTTP header key/value pair. Multiple headers can be set.                 | _none_ |
| `host`                                    | IP address or hostname of the target HTTP server.                              | `127.0.0.1`                                                                     |
| `http2`                                   | Enable, disable or force HTTP/2 usage. Accepted values: `on`, `off`, or `force`.                                                                        | `off`  |
| `http_passwd`                             | Set HTTP auth password.                                                        | _none_ |
| `http_user`                               | Set HTTP auth user.                                                            | _none_ |
| `log_level`                               | Specifies the log level for output plugin. If not set here, plugin uses global log level in `service` section.                                          | `info` |
| `log_response_payload`                    | Specify if the response payload should be logged or not.                       | `true` |
| `log_suppress_interval`                   | Suppresses log messages from output plugin that appear similar within a specified time interval. `0` disables suppression.                                    | `0`    |
| `logs_attributes_metadata_key`            | Metadata key used to read log record attributes.                               | `$Attributes`                                                                   |
| `logs_body_key`                           | Record accessor pattern(s) used to populate the OTLP log body. The first matching key wins. May be specified multiple times. Defaults to `$log` then `$message`. | _none_ |
| `logs_body_key_attributes`                | When `true`, record fields not matched by `logs_body_key` are added to the log record's attributes instead of being dropped.                            | `false`|
| `logs_instrumentation_scope_metadata_key` | Metadata key used to read the instrumentation scope.                           | `InstrumentationScope`                                                          |
| `logs_max_resources`                      | Set the maximum number of OTLP log resources per export request (`0` disables the limit).                                                               | `0`    |
| `logs_max_scopes`                         | Set the maximum number of OTLP log scopes per resource (`0` disables the limit).                                                                        | `0`    |
| `logs_metadata_key`                       | Top-level metadata key used to look up OTLP metadata added by `in_opentelemetry`. | `otlp` |
| `logs_observed_timestamp_metadata_key`    | Metadata key used to read the observed timestamp.                              | `$ObservedTimestamp`                                                            |
| `logs_resource_metadata_key`              | Metadata key used to read the OTLP resource.                                   | `Resource`                                                                      |
| `logs_severity_number_message_key`        | Record body key used to read the severity number.                              | `$SeverityNumber`                                                               |
| `logs_severity_number_metadata_key`       | Metadata key used to read the severity number.                                 | `$SeverityNumber`                                                               |
| `logs_severity_text_message_key`          | Record body key used to read the severity text.                                | `$SeverityText`                                                                 |
| `logs_severity_text_metadata_key`         | Metadata key used to read the severity text.                                   | `$SeverityText`                                                                 |
| `logs_span_id_message_key`                | Record body key used to read the span ID.                                      | `$SpanId`                                                                       |
| `logs_span_id_metadata_key`               | Metadata key used to read the span ID.                                         | `$SpanId`                                                                       |
| `logs_timestamp_metadata_key`             | Metadata key used to read the log timestamp.                                   | `$Timestamp`                                                                    |
| `logs_trace_flags_metadata_key`           | Metadata key used to read the trace flags.                                     | `$TraceFlags`                                                                   |
| `logs_trace_id_message_key`               | Record body key used to read the trace ID.                                     | `$TraceId`                                                                      |
| `logs_trace_id_metadata_key`              | Metadata key used to read the trace ID.                                        | `$TraceId`                                                                      |
| `logs_uri`                                | HTTP URI for the logs OTLP endpoint.                                           | `/v1/logs`                                                                      |
| `match`                                   | Set a tag pattern to match records that output should process. Exact matches or wildcards (for example `*`).                                            | _none_ |
| `match_regex`                             | Set a regular expression to match tags for output routing. This allows more flexible matching compared to wildcards.                             | _none_ |
| `metrics_uri`                             | HTTP URI for the metrics OTLP endpoint.                                        | `/v1/metrics`                                                                   |
| `net.connect_timeout`                     | Set maximum time allowed to establish a connection, this time includes the TLS handshake.                                                               | `10s`  |
| `net.connect_timeout_log_error`           | On connection timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message.                                      | `true` |
| `net.dns.mode`                            | Select the primary DNS connection type (TCP or UDP).                           | _none_ |
| `net.dns.prefer_ipv4`                     | Select the primary DNS resolver type (LEGACY or ASYNC).                        | _none_ |
| `net.dns.prefer_ipv6`                     | Prioritize IPv6 DNS results when trying to establish a connection.             | _none_ |
| `net.io_timeout`                          | Set maximum time a connection can stay idle while assigned.                    | `0s`   |
| `net.keepalive_max_recycle`               | Set maximum number of times a keepalive connection can be used before it retries.  | `2000` |
| `net.max_worker_connections`              | Set the maximum number of active TCP connections that can be used per worker thread.                                                                    | `0`    |
| `net.proxy_env_ignore`                    | Ignore the environment variables `HTTP_PROXY`, `HTTPS_PROXY` and `NO_PROXY` when set.                                                                   | `false`|
| `net.source_address`                      | Specify network address to bind for data traffic.                              | _none_ |
| `net.tcp_keepalive`                       | Enable or disable Keepalive support.                                           | `off`  |
| `net.tcp_keepalive_interval`              | Interval between TCP keepalive probes when no response is received on a `keepidle` probe. | `-1`   |
| `net.tcp_keepalive_probes`                | Number of unacknowledged probes to consider a connection dead.                 | `-1`   |
| `net.tcp_keepalive_time`                  | Interval between the last data packet sent and the first TCP keepalive probe.  | `-1`   |
| `oauth2.audience`                         | Optional `OAuth 2.0` audience parameter.                                       | _none_ |
| `oauth2.auth_method`                      | `OAuth 2.0` client authentication method. Supported values: `basic`, `post`, `private_key_jwt`. | `basic` |
| `oauth2.client_id`                        | `OAuth 2.0` client ID.                                                         | _none_ |
| `oauth2.client_secret`                    | `OAuth 2.0` client secret.                                                     | _none_ |
| `oauth2.connect_timeout`                  | Connect timeout for `OAuth 2.0` token requests.                                | `0s`   |
| `oauth2.enable`                           | Enable `OAuth 2.0` client credentials for outgoing requests.                   | `false`|
| `oauth2.jwt_aud`                          | Audience for `private_key_jwt` JSON Web Token (JWT) assertion. Defaults to the value of `oauth2.token_url` when not set. | _none_ |
| `oauth2.jwt_cert_file`                    | Path to certificate file used by `private_key_jwt`.                            | _none_ |
| `oauth2.jwt_header`                       | JWT header claim name for `private_key_jwt` thumbprint. Accepted values: `kid`, `x5t`. | `kid` |
| `oauth2.jwt_key_file`                     | Path to PEM private key file used by `private_key_jwt`.                        | _none_ |
| `oauth2.jwt_ttl_seconds`                  | Lifetime in seconds for `private_key_jwt` JWT client assertions.               | `300`  |
| `oauth2.refresh_skew_seconds`             | Seconds before expiry at which to refresh the access token.                    | `60`   |
| `oauth2.resource`                         | Optional `OAuth 2.0` resource parameter.                                       | _none_ |
| `oauth2.scope`                            | Optional `OAuth 2.0` scope.                                                    | _none_ |
| `oauth2.timeout`                          | Timeout for `OAuth 2.0` token requests.                                        | `0s`   |
| `oauth2.token_url`                        | `OAuth 2.0` token endpoint URL.                                                | _none_ |
| `port`                                    | TCP port of the target HTTP server.                                            | `80`   |
| `profiles_uri`                            | HTTP URI for the profiles OTLP endpoint.                                       | `/v1development/profiles`                                                       |
| `proxy`                                   | Specify an HTTP Proxy. The expected format of this value is `http://host:port`.| _none_ |
| `retry_limit`                             | Set retry limit for output plugin when delivery fails. Integer, `no_limits`, `false`, or `off` to disable, or `no_retries` to disable retries entirely. | `1`    |
| `tls`                                     | Enable or disable TLS/SSL support.                                             | `off`  |
| `tls.ca_file`                             | Absolute path to CA certificate file.                                          | _none_ |
| `tls.ca_path`                             | Absolute path to scan for certificate files.                                   | _none_ |
| `tls.ciphers`                             | Specify TLS ciphers up to TLSv1.2.                                             | _none_ |
| `tls.crt_file`                            | Absolute path to Certificate file.                                             | _none_ |
| `tls.debug`                               | Set TLS debug level. Accepts `0` (No debug), `1`(Error), `2` (State change), `3` (Informational) and `4` (Verbose).                                     | `1`    |
| `tls.key_file`                            | Absolute path to private Key file.                                             | _none_ |
| `tls.key_passwd`                          | Optional password for tls.key_file.                                             | _none_ |
| `tls.max_version`                         | Specify the maximum version of TLS.                                            | _none_ |
| `tls.min_version`                         | Specify the minimum version of TLS.                                            | _none_ |
| `tls.verify`                              | Force certificate validation.                                                  | `on`   |
| `tls.verify_hostname`                     | Enable or disable to verify hostname.                                          | `off`  |
| `tls.vhost`                               | Hostname to be used for TLS SNI extension.                                     | _none_ |
| `tls.windows.certstore_name`              | Sets the `certstore` name on an output (Windows).                                | _none_ |
| `tls.windows.use_enterprise_store`        | Sets whether using enterprise `certstore` or not on an output (Windows).         | _none_ |
| `traces_uri`                              | HTTP URI for the traces OTLP endpoint.                                         | `/v1/traces`                                                                    |
| `workers`                                 | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Get started

The OpenTelemetry plugin supports all four OTLP signal types: logs, metrics, traces, and profiles. In the following example, log records generated by the dummy plugin and host metrics from the node exporter metrics plugin are exported together over OTLP/HTTP.

### Encoding

By default the plugin sends all signals as binary protobuf (`Content-Type: application/x-protobuf`). Set `encoding json` to send logs, metrics, and traces as OTLP JSON (`Content-Type: application/json`) instead. This is useful when sending to receivers that only accept JSON, such as HTTP webhook endpoints.

{% hint style="info" %}
The `encoding` option applies to **OTLP/HTTP** exports only. When `grpc` is `on`, logs, metrics, and traces are sent over OTLP/gRPC using protobuf framing.

Profiles are always sent as protobuf regardless of the `encoding` setting — no OTLP JSON encoder exists for the profiles signal yet.
{% endhint %}

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: opentelemetry
      match: "*"
      host: localhost
      port: 4318
      encoding: json
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name     opentelemetry
  Match    *
  Host     localhost
  Port     4318
  Encoding json
```

{% endtab %}
{% endtabs %}

### Full example

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
# Collect host metrics and dummy logs, export via OpenTelemetry output
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: node_exporter_metrics
      tag: node_metrics
      scrape_interval: 2

    - name: dummy
      tag: dummy.log
      rate: 3

    - name: event_type
      type: traces

  outputs:
    - name: opentelemetry
      match: "*"
      host: localhost
      port: 443
      metrics_uri: /v1/metrics
      logs_uri: /v1/logs
      traces_uri: /v1/traces
      log_response_payload: true
      tls: on
      tls.verify: off
      logs_body_key: $message
      logs_span_id_message_key: span_id
      logs_trace_id_message_key: trace_id
      logs_severity_text_message_key: loglevel
      logs_severity_number_message_key: lognum
      add_label:
        - app fluent-bit
        - color blue
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
# Collect host metrics and dummy logs, export via OpenTelemetry output
[SERVICE]
  Flush                1
  Log_Level            info

[INPUT]
  Name                 node_exporter_metrics
  Tag                  node_metrics
  Scrape_Interval      2

[INPUT]
  Name                 dummy
  Tag                  dummy.log
  Rate                 3

[INPUT]
  Name                 event_type
  Type                 traces

[OUTPUT]
  Name                 opentelemetry
  Match                *
  Host                 localhost
  Port                 443
  Metrics_uri          /v1/metrics
  Logs_uri             /v1/logs
  Traces_uri           /v1/traces
  Log_response_payload True
  Tls                  On
  Tls.verify           Off
  Logs_Body_Key        $message
  Logs_Span_Id_Message_Key     span_id
  Logs_Trace_Id_Message_Key    trace_id
  Logs_Severity_Text_Message_Key   loglevel
  Logs_Severity_Number_Message_Key lognum
  Add_Label            app fluent-bit
  Add_Label            color blue
```

{% endtab %}
{% endtabs %}
