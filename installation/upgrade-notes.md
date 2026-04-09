# Upgrade notes

The following article covers the relevant compatibility changes for users upgrading from previous Fluent Bit versions.

For more details about changes on each release, refer to the [Official Release Notes](https://fluentbit.io/announcements/).

Release notes will be prepared in advance of a Git tag for a release. An official release should provide both a tag and a release note together to allow users to verify and understand the release contents.

The tag drives the binary release process. Release binaries (containers and packages) will appear after a tag and its associated release note. This lets users to expect the new release binary to appear and allow/deny/update it as appropriate in their infrastructure.

## Fluent Bit v5.0

### `hot_reloaded_times` metric type change

The internal metric `fluentbit_hot_reloaded_times` has changed from a gauge to a counter. The previous gauge registration caused incorrect results when using PromQL functions like `rate()` and `increase()`, which expect counters.

If you have Prometheus dashboards or alerting rules that reference `fluentbit_hot_reloaded_times`, update them to use counter-appropriate PromQL functions (for example, `rate()` or `increase()` instead of gauge-specific functions like `delta()`).

### Shared HTTP listener settings for HTTP-based inputs

The HTTP-based input plugins now use a shared HTTP listener configuration model. In Fluent Bit `v5.0`, the canonical setting names are:

- `http_server.http2`
- `http_server.buffer_chunk_size`
- `http_server.buffer_max_size`
- `http_server.max_connections`
- `http_server.workers`

Legacy per-plugin names such as `http2`, `buffer_chunk_size`, and `buffer_max_size` are still accepted as compatibility aliases, but new configurations should use the `http_server.*` names.

If you tune `http`, `splunk`, `elasticsearch`, `opentelemetry`, or `prometheus_remote_write` inputs, review those sections and migrate to the shared naming so future upgrades are clearer.

### Mutual TLS for input plugins

Input plugins that support TLS now also support `tls.verify_client_cert`. Enable this option to require and validate the client certificate presented by the sender.

If you terminate TLS directly in Fluent Bit and need mutual TLS (`mTLS`), add `tls.verify_client_cert on` together with the usual `tls.crt_file` and `tls.key_file` settings.

### New internal logs input

Fluent Bit `v5.0` adds the `fluentbit_logs` input plugin, which mirrors Fluent Bit's own internal log stream back into the data pipeline as structured log records.

Use this input if you want to forward Fluent Bit diagnostics to another destination, filter them, or store them alongside the rest of your telemetry.

### Emitter backpressure with filesystem storage

The internal emitter plugin, used by filters such as `rewrite_tag`, now automatically enables `storage.pause_on_chunks_overlimit` when filesystem storage is in use and that option hasn't been explicitly configured.

Previously, the emitter could accumulate chunks beyond the `storage.max_chunks_up` limit. Pipelines that use `rewrite_tag` or other emitter-backed filters with filesystem storage will now pause when the configured storage limit is reached.

If you rely on the previous unlimited accumulation behavior, explicitly set `storage.pause_on_chunks_overlimit off` on the relevant input. Otherwise, review your `storage.max_chunks_up` value to ensure it's tuned for your expected throughput.

### More `OAuth 2.0` coverage

Fluent Bit `v5.0` expands `OAuth 2.0` support in both directions:

- HTTP-based inputs can validate incoming bearer tokens using `oauth2.validate`, `oauth2.issuer`, and `oauth2.jwks_url`.
- The HTTP output can acquire access tokens with `oauth2.enable` and supports `basic`, `post`, and `private_key_jwt` client authentication.

If you previously handled authentication outside Fluent Bit for these cases, review the plugin pages for the new built-in options.

For a broader overview of user-visible additions in this release, see [What's new in Fluent Bit v5.0](whats-new-in-fluent-bit-v5.0.md).

## Fluent Bit v4.2

### Vivo exporter output plugin

The HTTP endpoint paths exposed by the Vivo exporter output plugin have changed. All endpoints now follow an `/api/v1/` prefix:

| Signal | Endpoint |
|---|---|
| Logs | `/api/v1/logs` |
| Metrics | `/api/v1/metrics` |
| Traces | `/api/v1/traces` |
| Internal metrics | `/api/v1/internal/metrics` |

If you have tooling or dashboards that query the Vivo exporter HTTP endpoints directly, update the endpoint paths accordingly.

## Fluent Bit v4.0

### Package support for older Linux distributions

Official binary packages are no longer produced for the following Linux distributions:

- Ubuntu 16.04 (`Xenial`)
- Ubuntu 18.04 (`Bionic`)
- Ubuntu 20.04 (`Focal`)

Users on these platforms should upgrade their OS or build Fluent Bit from source.

### Kafka plugin support on older platforms

The Kafka input and output plugins are disabled in official packages for CentOS 7 and Amazon Linux 2 (ARM64). This is due to a Kafka library (`librdkafka`) update that requires a newer glibc version than these platforms provide.

Users who need Kafka support on these platforms must build Fluent Bit from source against a compatible version of `librdkafka`.

## Fluent Bit v3.0

### HTTP/2 enabled by default for HTTP-based input plugins

The following input plugins now have HTTP/2 support enabled by default (`http2 true`):

- `opentelemetry`
- `splunk`
- `elasticsearch`
- `http`

These plugins transparently support both HTTP/1.1 and HTTP/2 connections. If your clients don't support HTTP/2, or if you have a reverse proxy or load balancer that doesn't handle HTTP/2 correctly, add `http2 off` to the affected input plugin configuration section.

## Fluent Bit v2.0

### TLS library

mbedTLS is no longer supported as a TLS backend. All TLS connections now use OpenSSL. If you compile Fluent Bit from source and previously linked against mbedTLS, you must now link against OpenSSL. Official binary packages already use OpenSSL.

## Fluent Bit v1.9.9

The `td-agent-bit` package is no longer provided after this release. Users should switch to the `fluent-bit` package.

## Fluent Bit v1.6

If you are migrating from previous version of Fluent Bit, review the following important changes:

### Tail input plugin

By default, the tail input plugin follows a file from the end after the service starts, instead of reading it from the beginning. Every file found when the plugin starts is followed from it last position. New files discovered at runtime or when files rotate are read from the beginning.

To keep the old behavior, set the option `read_from_head` to `true`.

### Stackdriver output plugin

The `project_id` of [resource](https://docs.cloud.google.com/logging/docs/reference/v2/rest/v2/MonitoredResource) in [LogEntry](https://docs.cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) sent to Google Cloud Logging would be set to the `project_id` rather than the project number. To learn the difference between Project ID and project number, see [Creating and managing projects](https://docs.cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin).

If you have existing queries based on the resource's `project_id,` update your query accordingly.

## Fluent Bit v1.5

The migration from v1.4 to v1.5 is pretty straightforward.

- The `keepalive` configuration mode has been renamed to `net.keepalive`. Now, all Network I/O keepalive is enabled by default. To learn more about this and other associated configuration properties read the [Networking Administration](https://docs.fluentbit.io/manual/administration/networking#tcp-keepalive) section. - If you use the Elasticsearch output plugin, the default value of `type` [changed from `flb_type` to `_doc`](https://github.com/fluent/fluent-bit/commit/04ed3d8104ca8a2f491453777ae6e38e5377817e#diff-c9ae115d3acaceac5efb949edbb21196). Many versions of Elasticsearch tolerate this, but Elasticsearch v5.6 through v6.1 require a `type` without a leading underscore. See the [Elasticsearch output plugin documentation FAQ entry](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch#faq-underscore) for more.

## Fluent Bit v1.4

If you are migrating from Fluent Bit v1.3, there are no breaking changes.

## Fluent Bit v1.3

If you are migrating from Fluent Bit v1.2 to v1.3, there are no breaking changes. If you are upgrading from an older version, review the following incremental changes:

## Fluent Bit v1.2

### Docker, JSON, parsers, and decoders

Fluent Bit v1.2 fixed many issues associated with JSON encoding and decoding.

For example, when parsing Docker logs, it's no longer necessary to use decoders. The new Docker parser looks like this:

```text
[PARSER]
  Name        docker
  Format      json
  Time_Key    time
  Time_Format %Y-%m-%dT%H:%M:%S.%L
  Time_Keep   On
```

### Kubernetes filter

Fluent Bit made improvements to Kubernetes Filter handling of string-encoded `log` messages. If the `Merge_Log` option is enabled, it will try to handle the log content as a JSON map, if so, it will add the keys to the root map.

In addition, fixes and improvements were made to the `Merge_Log_Key` option. If a merge log succeed, all new keys will be packaged under the key specified by this option. A suggested configuration is as follows:

```text
[FILTER]
  Name Kubernetes
  Match kube.*
  Kube_Tag_Prefix kube.var.log.containers.
  Merge_Log On
  Merge_Log_Key log_processed
```

As an example, if the original log content is the following map:

```json
{"key1": "val1", "key2": "val2"}
```

the final record will be composed as follows:

```json
{"log": "{\"key1\": \"val1\", \"key2\": \"val2\"}", "log_processed": { "key1": "val1", "key2": "val2" } }
```

## Fluent Bit v1.1

If you are upgrading from Fluent Bit 1.0.x or earlier, review the following relevant changes when switching to Fluent Bit v1.1 or later series:

### Kubernetes filter

Fluent Bit introduced a new configuration property called `Kube_Tag_Prefix` to help Tag prefix resolution and address an unexpected behavior in previous versions.

During the `1.0.x` release cycle, a commit in the Tail input plugin changed the default behavior on how the Tag was composed when using the wildcard for expansion generating breaking compatibility with other services. Consider the following configuration example:

```text
[INPUT]
  Name tail
  Path /var/log/containers/*.log
  Tag kube.*
```

The expected behavior is that Tag will be expanded to:

```text kube.var.log.containers.apache.log ```

The change introduced in the 1.0 series switched from absolute path to the base filename only:

```text kube.apache.log ```

THe Fluent Bit v1.1 release restored the default behavior and now the Tag is composed using the absolute path of the monitored file.

Having absolute path in the Tag is relevant for routing and flexible configuration where it also helps to keep compatibility with Fluentd behavior.

This behavior switch in Tail input plugin affects how Filter Kubernetes operates. When the filter is used it needs to perform local metadata lookup that comes from the file names when using Tail as a source. With the new `Kube_Tag_Prefix` option you can specify the prefix used in the Tail input plugin. For the previous configuration example the new configuration will look like:

```text
[INPUT]
  Name tail
  Path /var/log/containers/*.log
  Tag kube.*

[FILTER]
  Name kubernetes
  Match *
  Kube_Tag_Prefix kube.var.log.containers.
```

The proper value for `Kube_Tag_Prefix` must be composed by Tag prefix set in Tail
input plugin plus the converted monitored directory replacing slashes with dots.
