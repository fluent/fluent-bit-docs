# Pipeline

The `pipeline` section of YAML configuration files defines the flow of how data is collected, processed, and sent to its final destination. This section contains the following subsections:

- [`inputs`](#inputs): Configures input plugins.
- [`filters`](#filters): Configures filters.
- [`outputs`](#outputs): Configures output plugins.


{% hint style="info" %}

Unlike filters, processors and parsers aren't defined within a unified section of YAML configuration files and don't use tag matching. Instead, each input or output plugin defined in the configuration file can have a `parsers` key and a `processors` key to configure the parsers and processors for that specific plugin.

{% endhint %}

## Syntax

The `pipeline` section of a YAML configuration file uses the following syntax:

```yaml
pipeline:
    inputs:
        ...
    filters:
        ...
    outputs:
        ...
```

Each of the subsections for `inputs`, `filters`, and `outputs` constitutes an array of maps that has the parameters for each. Most properties are either strings or numbers and can be defined directly.

For example:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: tail
          path: /var/log/example.log
          parser: json

          processors:
              logs:
                  - name: record_modifier

    filters:
        - name: grep
          match: '*'
          regex: key pattern

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% endtabs %}


{% hint style="info" %}

It's possible to define multiple `pipeline` sections, but they won't operate independently. Instead, Fluent Bit merges all defined pipelines into a single pipeline internally.

{% endhint %}

## Inputs

The `inputs` section defines one or more [input plugins](../../../pipeline/inputs.md). In addition to the settings unique to each plugin, all input plugins support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the input plugin. Defined as subsection of the `inputs` section. |
| `tag` | Tag name associated to all records coming from this plugin. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `service` section's `log_level`. |

The `name` parameter is required and defines for Fluent Bit which input plugin should be loaded. The `tag` parameter is required for all plugins except for the `forward` plugin, which provides dynamic tags.

There is no hard-coded limit on the number of input plugins. The practical maximum depends on available system resources such as memory and file descriptors.

### Count log records by tag for inputs

Each input can override the service-wide [`telemetry.metrics.logs.tag_records.enabled`](service-section.md#count-log-records-by-tag) setting with a nested `telemetry` block of its own. An input that doesn't set this block inherits the `service` value.

Only the `enabled` key is valid at the input level. Setting `max_series` or `max_tag_length` on an input is a startup error, because those limits are service-wide.

The following example enables per-tag counting for the whole service and disables it for one noisy input:

```yaml
service:
  telemetry:
    metrics:
      logs:
        tag_records:
          enabled: true

pipeline:
  inputs:
    - name: tail
      tag: app.logs
      path: /var/log/app/*.log

    - name: tail
      alias: high_cardinality
      tag: dynamic.*
      path: /var/log/dynamic/*.log
      telemetry:
        metrics:
          logs:
            tag_records:
              enabled: false
```

### Rate metrics and rate limiting for inputs

Available in Fluent Bit version 5.1 and greater.

Every input plugin measures its own ingestion rate, and can optionally pause itself when that rate gets too high. All input plugins support the following settings:

| Key | Description | Default |
| --- | ----------- | ------- |
| `rate_window` | Time window used to measure the ingestion rate, such as `1s`, `1m`, or `1h`. Whatever window you choose, the resulting rate is always published in per-second units. | `1s` |
| `rate_gate` | Enable the rate gate, which pauses ingestion while the measured rate exceeds the configured limits. | `false` |
| `rate_gate.max_bytes` | Maximum ingestion rate in bytes per second. Set to `0` to leave the byte rate unlimited. This value must follow [unit size](../../configuring-fluent-bit.md#unit-sizes) specifications. | `0` |
| `rate_gate.max_records` | Maximum ingestion rate in records per second. Set to `0` to leave the record rate unlimited. | `0` |
| `rate_gate.backpressure` | Lower the effective limits while the input has busy chunks or pending delivery retries. | `true` |
| `rate_gate.resume_ratio` | Fraction of the effective limit that the measured rate must fall to before ingestion resumes. Accepts a value greater than `0` and less than or equal to `1`. | `0.80` |

Rate measurement is always active, and publishes the [`fluentbit_input_rate_bytes` and `fluentbit_input_rate_records`](../../monitoring.md#v2-metrics) metrics. The rate gate is opt-in and takes effect only when you enable `rate_gate` and set at least one of `rate_gate.max_bytes` or `rate_gate.max_records` to a non-zero value. A limit of `0` is unlimited.

When the gate is enabled and either the measured byte rate or record rate exceeds its limit, Fluent Bit pauses the input, logs a warning, and schedules a one-shot timer to reevaluate the rate. The input resumes only when both measured rates are no greater than their respective effective limits multiplied by `rate_gate.resume_ratio`. Limits set to `0` are unlimited and are excluded from both checks. This gap between the pause and resume thresholds keeps an input at the limit from repeatedly pausing and resuming.

While `rate_gate.backpressure` is enabled, the limits you configure aren't applied directly. Fluent Bit divides each limit by the number of busy chunks plus pending retry attempts, plus one. An input with no pending work is held to the full limit, while an input whose destination is backed up is held to a progressively smaller share of it, which slows ingestion before chunks accumulate. Set `rate_gate.backpressure` to `false` to apply the configured limits as fixed values instead.

The following example limits an HTTP input to 5MB per second, measured over a five-second window:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: http
      listen: 0.0.0.0
      port: 8888
      rate_window: 5s
      rate_gate: true
      rate_gate.max_bytes: 5M
```

{% endtab %}
{% endtabs %}

### Shared HTTP listener settings for inputs

Some HTTP-based input plugins share the same listener implementation and support the following common settings in addition to their plugin-specific parameters:

These settings are shared by HTTP-based inputs such as `http`, `splunk`,
`elasticsearch`, `opentelemetry`, and `prometheus_remote_write`.
Use these keys the same way across those plugins.

If a plugin page shows one of the `http_server.*` keys in its configuration
table, it is documenting one of these shared listener settings, not a
plugin-specific behavior.

| Key | Description | Default |
| --- | ----------- | ------- |
| `http_server.http2` | Enable HTTP/2 support for the input listener. | `true` |
| `http_server.buffer_max_size` | Set the maximum size of the HTTP request buffer. In v5.2 or later, the `opentelemetry` input defaults to 64 MiB instead. | `4M` |
| `http_server.max_decoded_body_size` | Set the maximum size of a request body after automatic decompression, independently of `http_server.buffer_max_size`. `0` selects `100M`, for every input. Introduced in v5.2. When this key isn't set, the `opentelemetry` input uses a different default; see [Request body decompression](#request-body-decompression). | `100M` |
| `http_server.buffer_chunk_size` | Set the allocation chunk size used for the HTTP request buffer. | `512K` |
| `http_server.http1_max_header_size` | Set the maximum size of an HTTP/1 request line and headers, including the line-ending characters. Uses binary units: `K`, `KB`, and `KiB` all mean 1,024 bytes, and `M`/`G` scale the same way. `0` selects the default. The `http_server.buffer_max_size` limit still applies. Supported in v5.2 or later. See [HTTP/1 request header limits](#http1-request-header-limits). | `32KiB` |
| `http_server.max_connections` | Set the maximum number of concurrent active HTTP connections. `0` means unlimited. | `0` |
| `http_server.workers` | Set the number of HTTP listener worker threads. | `1` |
| `http_server.ingress_queue_event_limit` | Set the maximum number of deferred ingress queue entries. This setting applies only when `http_server.workers` is greater than `1`. | `8192` |
| `http_server.ingress_queue_byte_limit` | Set the maximum size of the deferred ingress queue. This setting applies only when `http_server.workers` is greater than `1`. | `256M` |
| `http_server.idle_timeout` | Maximum time an idle accepted HTTP connection is kept open. Connections that remain idle beyond this duration are closed. Set to `0` to disable. Accepts time values such as `10s` or `1m`. | `10s` |

When `http_server.workers` is `1`, Fluent Bit does not use the deferred
ingress queue, so the two `http_server.ingress_queue_*` settings have no
effect.

For backward compatibility, some plugins also accept the legacy aliases `http2`, `buffer_max_size`, `buffer_chunk_size`, `max_connections`, and `workers`. The other `http_server.*` keys, such as `http_server.http1_max_header_size`, have no alias and must use the full name.

All inputs that use the shared listener also pause and resume it in response to [backpressure](../../backpressure.md#pause-behavior-for-http-based-inputs). While an input is paused, Fluent Bit accepts and immediately closes incoming connections instead of buffering the requests, so clients must retry.

#### HTTP/1 request header limits

Fluent Bit reads the request line and headers of each HTTP/1 request before it processes the request. The `http_server.http1_max_header_size` limit counts the request line, the headers, and the blank line that ends them. Fluent Bit closes the connection without a response when:

- The request line and headers reach `http_server.http1_max_header_size` without the blank line that ends them. This limit is new in v5.2.
- The request method is longer than 11 bytes.
- The request target contains a carriage return or line feed.
- The protocol version doesn't start with `HTTP/1.`.

If the request reaches `http_server.buffer_max_size` first, Fluent Bit responds with `413 Request Entity Too Large` and closes the connection. Setting `http_server.http1_max_header_size` higher than `http_server.buffer_max_size` has no effect beyond the buffer limit.

Earlier versions don't enforce a separate header size limit; only `http_server.buffer_max_size`, `4M` by default, bounds the request line and headers. In v5.2 or later, requests whose headers reach the `32KiB` default, for example because of large cookies or tokens, are dropped without a response or a log message. If your clients send large headers, raise `http_server.http1_max_header_size` before you upgrade.

These checks apply to HTTP/1 requests, including HTTP/1.1 requests that ask to upgrade to HTTP/2. Connections that start directly with the HTTP/2 connection preface aren't affected.

Fluent Bit fails to start if `http_server.http1_max_header_size` isn't a number, is negative, or has a suffix other than `K`, `KB`, `KiB`, `M`, `MB`, `MiB`, `G`, `GB`, or `GiB`, and logs `[http_server] invalid http_server.http1_max_header_size`. The suffixes aren't case-sensitive and must follow the number without a space. Fractional values are truncated to whole bytes, and values that truncate to `0` select the default.

#### Request body decompression

In v5.0 or later, these inputs automatically decompress request bodies sent with the `Content-Encoding` header set to `gzip`, `zstd`, or `snappy`, whatever the `http2` setting. In earlier versions, the supported encodings depended on the input and, for some inputs, on the `http2` setting. Requests without a `Content-Encoding` header, or with `identity`, aren't decompressed. `http_server.buffer_max_size` limits the request as received, and `http_server.max_decoded_body_size` limits the body after decompression.

The `opentelemetry` input applies a different default. When `http_server.max_decoded_body_size` isn't set, the decompressed body is limited to the input's request size limit, which is its `buffer_max_size` value, or 64 MiB if that isn't set. Setting `http_server.max_decoded_body_size` to `0` selects `100M`. The `opentelemetry` input also checks the decompressed body against its `buffer_max_size` value, so it rejects a larger body even when `http_server.max_decoded_body_size` is higher.

In v5.2 or later, Fluent Bit rejects a request that it can't decompress, and responds with one of the following statuses:

- `413`: the decompressed body is larger than `http_server.max_decoded_body_size`.
- `503`: Fluent Bit couldn't allocate memory to decompress the body. Clients can retry the request.
- `400`: the body is invalid, or uses an unsupported or stacked encoding, such as `deflate` or `gzip, zstd`.

Earlier versions passed bodies with `deflate` or other unsupported encodings to the input without decompressing them. If your clients send `deflate`, switch them to `gzip`, `zstd`, or `snappy` before you upgrade.

When `oauth2.validate` is enabled on the `http` or `opentelemetry` input, Fluent Bit v5.2 or later validates the token before it decompresses the body, so a request without a valid token is rejected with `401` before decompression. In v5.0 and v5.1, Fluent Bit decompressed the body first and validated the token afterward, so unauthenticated requests could still use decompression resources. On the `http` input with `enable_health_endpoint` enabled, `GET /health` requests don't require a token, so a compressed body sent with one is still decompressed, up to the `http_server.max_decoded_body_size` limit. Decompression within that limit still uses CPU and memory.

### Incoming `OAuth 2.0` `JWT` validation settings

The HTTP-based input plugins that support bearer token validation share the following `oauth2.*` settings:

| Key | Description | Default |
| --- | ----------- | ------- |
| `oauth2.validate` | Enable `OAuth 2.0` `JWT` validation for incoming requests. | `false` |
| `oauth2.issuer` | Expected issuer (`iss`) claim. Required when `oauth2.validate` is `true`. | _none_ |
| `oauth2.jwks_url` | `JWKS` endpoint URL used to fetch public keys for token validation. Required when `oauth2.validate` is `true`. | _none_ |
| `oauth2.allowed_audience` | Audience claim to enforce when validating tokens. | _none_ |
| `oauth2.allowed_clients` | Authorized `client_id` or `azp` claim values. This key can be specified multiple times. | _none_ |
| `oauth2.jwks_refresh_interval` | Seconds after a fetch before the next request that needs validation refetches `JWKS` keys. Keys aren't refreshed in the background. | `300` |
| `oauth2.jwks_buffer_max_size` | Maximum size of the `JWKS` HTTP response, including headers and body. Must be between `4096` bytes and `16M`. Uses [unit sizes](../../configuring-fluent-bit.md#unit-sizes). Supported in v5.2 or later. | `1M` |
| `oauth2.jwks_response_timeout` | Maximum time to receive the `JWKS` HTTP response after the request is sent. Must be between `1s` and `300s`. Supported in v5.2 or later. See [`JWKS` fetch limits](#jwks-fetch-limits). | `30s` |

When validation is enabled, requests without a valid `Authorization: Bearer <token>` header are rejected. On the `http` input, `GET /health` requests are exempt when `enable_health_endpoint` is enabled.

#### `JWKS` fetch limits

The `oauth2.jwks_buffer_max_size` and `oauth2.jwks_response_timeout` limits are checked only when `oauth2.validate` is `true`. Size values use decimal units, so `1M` is 1,000,000 bytes. Time values are whole seconds: a plain number, or a number followed by `s`, `m`, `h`, or `d`. Fractions are truncated.

An out-of-range value stops Fluent Bit from starting. During a [hot reload](../../hot-reload.md), the previous pipeline has already stopped when the value is checked, so the reload is aborted and Fluent Bit exits. The `--dry-run` option doesn't detect out-of-range values.

`JWKS` keys are fetched on demand, so a misconfigured or oversized `JWKS` endpoint isn't detected at startup. Fluent Bit fetches keys when a request carries an RS256 token with a `kid` header and the cache is empty or older than `oauth2.jwks_refresh_interval`. Malformed tokens, tokens without `kid`, and tokens that use another algorithm are rejected without a fetch.

The fetch is synchronous. While it runs, other requests to the same input that need validation wait. The `oauth2.jwks_response_timeout` clock starts after the request is sent, so DNS resolution, connection setup, and the TLS handshake aren't included.

If a fetch fails, for example because the response exceeds `oauth2.jwks_buffer_max_size` or doesn't arrive within `oauth2.jwks_response_timeout`, Fluent Bit logs an error and rejects the request, even if previously cached keys could validate the token. Each following request that needs a fetch tries again and is rejected until a fetch succeeds. The [HTTP](../../../pipeline/inputs/http.md) input responds with `401`. The [OpenTelemetry](../../../pipeline/inputs/opentelemetry.md) input responds with `401`, or with gRPC status `16` (`UNAUTHENTICATED`) for gRPC requests.

### Example input configuration

The following is an example of an `inputs` section that contains a `cpu` plugin.

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
```

## Filters

The `filters` section defines one or more [filters](../../../pipeline/filters.md). In addition to the settings unique to each filter, all filters support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the filter plugin. Defined as a subsection of the `filters` section. |
| `match` | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `match_regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `service` section's `log_level`. |

The `name` parameter is required and lets Fluent Bit know which filter should be loaded. One of either the `match` or `match_regex` parameters is required. If both are specified, `match_regex` takes precedence.

There is no hard-coded limit on the number of filter plugins. The practical maximum depends on available system resources such as memory.

### Example filter configuration

The following is an example of a `filters` section that contains a `grep` plugin:

```yaml
pipeline:
    filters:
        - name: grep
          match: '*'
          regex: log aa
```


## Outputs

The `outputs` section defines one or more [output plugins](../../../pipeline/outputs.md). In addition to the settings unique to each plugin, all output plugins support the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `name` | Name of the output plugin. Defined as a subsection of the `outputs` section. |
| `match` | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `match_regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `log_level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. The output log level defaults to the `service` section's `log_level`. |

Fluent Bit has no hard-coded limit on the number of output plugins. The routing `bitmask` is dynamically sized at startup based on the number of configured output plugins. The practical maximum depends on available system resources such as memory and file descriptors.

### Outgoing `OAuth 2.0` client credentials settings

Output plugins that support outgoing `OAuth 2.0` authentication can expose the following shared `oauth2.*` settings:

| Key | Description | Default |
| --- | ----------- | ------- |
| `oauth2.enable` | Enable `OAuth 2.0` client credentials for outgoing requests. | `false` |
| `oauth2.token_url` | Token endpoint URL. | _none_ |
| `oauth2.client_id` | Client ID. | _none_ |
| `oauth2.client_secret` | Client secret. | _none_ |
| `oauth2.scope` | Optional scope parameter. | _none_ |
| `oauth2.audience` | Optional audience parameter. | _none_ |
| `oauth2.resource` | Optional resource parameter. | _none_ |
| `oauth2.auth_method` | Client authentication method. Supported values: `basic`, `post`, `private_key_jwt`. | `basic` |
| `oauth2.jwt_key_file` | PEM private key file used with `private_key_jwt`. | _none_ |
| `oauth2.jwt_cert_file` | Certificate file used to derive the `kid` or `x5t` header value for `private_key_jwt`. | _none_ |
| `oauth2.jwt_aud` | Audience to use in `private_key_jwt` assertions. Defaults to `oauth2.token_url` when unset. | _none_ |
| `oauth2.jwt_header` | JWT header claim name used for the thumbprint. Supported values: `kid`, `x5t`. | `kid` |
| `oauth2.jwt_ttl_seconds` | Lifetime in seconds for `private_key_jwt` client assertions. | `300` |
| `oauth2.refresh_skew_seconds` | Seconds before expiry at which to refresh the access token. | `60` |
| `oauth2.timeout` | Timeout for token requests. | `0s` |
| `oauth2.connect_timeout` | Connect timeout for token requests. | `0s` |
| `oauth2.user_agent` | Optional `User-Agent` header to include on `OAuth 2.0` token requests. | _none_ |

### Example output configuration

The following is an example of an `outputs` section that contains a `stdout` plugin:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
```
