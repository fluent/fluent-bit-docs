# What's new in Fluent Bit v5.0

Fluent Bit `v5.0` adds new inputs and processors, expands authentication and TLS options, and standardizes configuration for HTTP-based plugins. It also delivers an important round of performance and scalability work, especially for pipelines that ingest logs, metrics, and traces through HTTP-based protocols. This page gives a quick user-focused overview of the main changes since Fluent Bit `v4.2`.

For migration-impacting changes, see [Upgrade notes](upgrade-notes.md).

## Performance and scalability

### Unified processing and delivery model

Fluent Bit `v5.0` continues the move toward a more unified runtime for logs, metrics, and traces. In practice, this means the same core engine improvements benefit more of the pipeline, instead of individual signal paths evolving separately.

For end users, the result is a more consistent behavior across telemetry types and a better base for high-throughput pipelines that mix logs, metrics, and traces in the same deployment.

### Refactored HTTP stack

One of the most important `v5.0` changes is the refactoring of the HTTP listener stack used by several input plugins. Fluent Bit now uses a shared HTTP server implementation across the major HTTP-based receivers instead of maintaining separate code paths.

This work improves:

- concurrency through shared listener worker support
- consistency of request handling across HTTP-based inputs
- buffer enforcement and connection handling
- maintainability, which reduces drift between plugin implementations

The biggest user-facing beneficiaries are:

- [HTTP input](../pipeline/inputs/http.md)
- [Splunk input](../pipeline/inputs/splunk.md)
- [Elasticsearch input](../pipeline/inputs/elasticsearch.md)
- [OpenTelemetry input](../pipeline/inputs/opentelemetry.md)
- [Prometheus remote write input](../pipeline/inputs/prometheus-remote-write.md)

If you run large HTTP or OTLP ingestion workloads, `v5.0` is not only a feature release. It is also a meaningful runtime improvement.

## Configuration and operations

### Shared HTTP listener settings

HTTP-based inputs now use a shared listener configuration model. The preferred setting names are:

- `http_server.http2`
- `http_server.buffer_chunk_size`
- `http_server.buffer_max_size`
- `http_server.max_connections`
- `http_server.workers`

Legacy aliases such as `http2`, `buffer_chunk_size`, and `buffer_max_size` still work, but new configurations should use the `http_server.*` names.

Affected plugin families include:

- [HTTP input](../pipeline/inputs/http.md)
- [Splunk input](../pipeline/inputs/splunk.md)
- [Elasticsearch input](../pipeline/inputs/elasticsearch.md)
- [OpenTelemetry input](../pipeline/inputs/opentelemetry.md)
- [Prometheus remote write input](../pipeline/inputs/prometheus-remote-write.md)

### Mutual TLS for inputs

Input plugins that support TLS can now require client certificate verification with `tls.verify_client_cert`. This makes it easier to run mutual TLS (`mTLS`) directly on Fluent Bit listeners.

See [TLS](../administration/transport-security.md).

### JSON health endpoint in API v2

The built-in HTTP server exposes `/api/v2/health`, which returns health status as JSON and uses the HTTP status code to indicate healthy (`200`) or unhealthy (`500`) state.

See [Monitoring](../administration/monitoring.md).

## Inputs

### New `fluentbit_logs` input

The [Fluent Bit logs input](../pipeline/inputs/fluentbit-logs.md) routes Fluent Bit internal logs back into the pipeline as structured records. This lets you forward agent diagnostics to any supported destination.

### HTTP input remote address capture

The [HTTP input](../pipeline/inputs/http.md) adds:

- `add_remote_addr`
- `remote_addr_key`

These settings let you attach the client address from `X-Forwarded-For` to each ingested record.

### `OAuth 2.0` bearer token validation on HTTP-based inputs

HTTP-based receivers can validate incoming bearer tokens with:

- `oauth2.validate`
- `oauth2.issuer`
- `oauth2.jwks_url`
- `oauth2.allowed_audience`
- `oauth2.allowed_clients`
- `oauth2.jwks_refresh_interval`

This is available on the relevant input plugins, including [HTTP](../pipeline/inputs/http.md) and [OpenTelemetry](../pipeline/inputs/opentelemetry.md).

### OpenTelemetry input improvements

The [OpenTelemetry input](../pipeline/inputs/opentelemetry.md) in `v5.0` expands user-visible behavior with:

- shared HTTP listener worker support
- `OAuth 2.0` bearer token validation
- stable JSON metrics ingestion over `OTLP/HTTP`
- improved JSON trace validation and error reporting

### Kubernetes events state database controls

The [Kubernetes events input](../pipeline/inputs/kubernetes-events.md) documents additional SQLite controls:

- `db.journal_mode`
- `db.locking`

These settings help tune event cursor persistence and database access behavior.

## Processors

### New cumulative-to-delta processor

The [cumulative to delta processor](../pipeline/processors/cumulative-to-delta.md) converts cumulative monotonic metrics to delta values, which is useful when scraping Prometheus-style metrics but exporting to backends that expect deltas.

### New topological data analysis processor

The [topological data analysis processor](../pipeline/processors/tda.md) adds a metrics processor for topology-based analysis workflows.

### Sampling processor updates

The [sampling processor](../pipeline/processors/sampling.md) adds `legacy_reconcile` for tail sampling, which helps compare the optimized reconciler with the previous behavior when validating upgrades.

## Outputs

### HTTP output `OAuth 2.0` client credentials

The [HTTP output](../pipeline/outputs/http.md) now supports built-in `OAuth 2.0` client credentials with:

- `basic`
- `post`
- `private_key_jwt`

You can configure token acquisition directly in Fluent Bit with the `oauth2.*` settings.

### More compression options for cloud outputs

Several outputs gained additional compression support in the `v4.2` to `v5.0` range:

- [Amazon Kinesis Data Streams](../pipeline/outputs/kinesis.md): `gzip`, `zstd`, `snappy`
- [Amazon Kinesis Data Firehose](../pipeline/outputs/firehose.md): `snappy` added alongside existing codecs
- [Amazon S3](../pipeline/outputs/s3.md): `snappy` added alongside existing codecs
- [Azure Blob](../pipeline/outputs/azure_blob.md): `zstd` support for transfer compression

## Monitoring changes

### `fluentbit_hot_reloaded_times` is now a counter

The `fluentbit_hot_reloaded_times` metric changed from a gauge to a counter, which makes it safe to use with PromQL functions such as `rate()` and `increase()`.

### New output backpressure visibility

`v5.0` adds output backpressure duration metrics so you can observe time spent waiting because of downstream pressure.

See [Monitoring](../administration/monitoring.md).
