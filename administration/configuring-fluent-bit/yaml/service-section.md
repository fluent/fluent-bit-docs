# Service

The `service` section of YAML configuration files defines global properties of the Fluent Bit service. The available configuration keys are:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `coro_stack_size` | Sets the coroutines stack size in bytes. The value must be greater than the page size of the running system. Setting the value too small (for example, `4096`) can cause coroutine threads to overrun the stack buffer. For best results, don't change this parameter from its default value. | `24576` |
| `daemon` | Specifies whether Fluent Bit should run as a daemon (background process). Possible values: `yes`, `no`, `on`, and `off`. Don't enable when using a Systemd-based unit, such as the one provided in Fluent Bit packages. | `off` |
| `dns.mode` | Sets the primary transport layer protocol used by the asynchronous DNS resolver. Can be overridden on a per-plugin basis. | `UDP` |
| `dns.prefer_ipv4` | If enabled, the DNS resolver prefers IPv4 results when resolving hostnames. Possible values: `off` or `on`. | `off` |
| `dns.prefer_ipv6` | If enabled, the DNS resolver prefers IPv6 results when resolving hostnames. Possible values: `off` or `on`. | `off` |
| `dns.resolver` | Sets the DNS resolver implementation. Possible values: `LEGACY`, `ASYNC`. | _none_ |
| `enable_chunk_trace` | If enabled, activates chunk tracing for debugging purposes. Requires Fluent Bit to be built with the `FLB_HAVE_CHUNK_TRACE` option. Possible values: `off` or `on`. | `off` |
| `flush` | Sets the flush time in `seconds.nanoseconds`. The engine loop uses a flush timeout to define when to flush the records ingested by input plugins through the defined output plugins. | `1` |
| `flush.adaptive` | If enabled, Fluent Bit adjusts the flush interval at runtime based on chunk backpressure. See [Adaptive flush intervals](#adaptive-flush-intervals). Possible values: `off` or `on`. | `off` |
| `flush.adaptive.down_steps` | Sets how many consecutive samples at a lower pressure level are required before Fluent Bit lengthens the flush interval. | `3` |
| `flush.adaptive.high_pressure` | Sets the chunk backpressure percentage that makes Fluent Bit target its shortest flush interval. | `75` |
| `flush.adaptive.low_pressure` | Sets the chunk backpressure percentage that makes Fluent Bit target its longest flush interval. | `25` |
| `flush.adaptive.max_interval` | Sets the upper bound in seconds for the adaptive flush interval. | `2` |
| `flush.adaptive.medium_pressure` | Sets the chunk backpressure percentage that makes Fluent Bit shorten the flush interval to three quarters of the `flush` value. | `50` |
| `flush.adaptive.min_interval` | Sets the lower bound in seconds for the adaptive flush interval. | `0.5` |
| `flush.adaptive.up_steps` | Sets how many consecutive samples at a higher pressure level are required before Fluent Bit shortens the flush interval. | `2` |
| `grace` | Sets the grace time in `seconds` as an integer value. The engine loop uses a grace timeout to define the wait time on exit. | `5` |
| `hc_errors_count` | Sets the number of errors that must occur within the health check period before the health check endpoint reports an unhealthy status. | `5` |
| `hc_period` | Sets the health check evaluation period in seconds. | `60` |
| `hc_retry_failure_count` | Sets the number of retry failures that must occur within the health check period before the health check endpoint reports an unhealthy status. | `5` |
| `health_check` | If enabled, registers a health check endpoint on the built-in HTTP server. Requires `http_server` to be enabled. Possible values: `off` or `on`. | `off` |
| `hot_reload` | Enables [hot reloading](../../../administration/hot-reload.md) of configuration with SIGHUP. | `on` |
| `hot_reload.ensure_thread_safety` | If enabled, ensures thread safety during configuration hot reload. Disabling this can reduce reload time but can cause instability. Possible values: `off` or `on`. | `on` |
| `hot_reload.timeout` | Sets a watchdog timeout in seconds for the hot reload process. If the reload doesn't complete within this time, Fluent Bit cancels the reload. A value of `0` disables the watchdog. | `0` |
| `http_listen` | Sets the listening interface for the HTTP Server when it's enabled. | `0.0.0.0` |
| `http_port` | Sets the TCP port for the HTTP server. | `2020` |
| `http_server` | Enables the built-in HTTP server. | `off` |
| `json.convert_nan_to_null` | If enabled, `NaN` is converted to `null` when Fluent Bit converts `msgpack` to JSON. | `false` |
| `json.escape_unicode` | Controls how Fluent Bit serializes non‑ASCII / multi‑byte Unicode characters in JSON strings. When enabled, Unicode characters are escaped as `\uXXXX` sequences (characters outside BMP become surrogate pairs). When disabled, Fluent Bit emits raw UTF‑8 bytes. | `true` |
| `log_file` | Absolute path for an optional log file. By default, all logs are redirected to the standard error interface (`stderr`). | _none_ |
| `log_level` | Sets the logging verbosity level. Possible values: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are cumulative. For example, if `debug` is set, it will include `error`, `warning`, `info`, and `debug`. The `trace` mode is only available if Fluent Bit was built with the `FLB_TRACE` option enabled. You can also set this value with the `FLB_LOG_LEVEL` environment variable. See [Log level](#log-level). | `info` |
| `multiline_buffer_limit` | Sets the default buffer size limit for multiline parsers. This value must follow [unit size](../../configuring-fluent-bit.md#unit-sizes) specifications. | `2MB` |
| `parsers_file` | Path for [standalone parsers configuration files](../yaml/parsers-section.md#standalone-parsers-files). You can include one or more files. | _none_ |
| `plugins_file` | Path for a `plugins` configuration file. This file specifies the paths to external plugins (.so files) that Fluent Bit can load at runtime. Plugins can also be declared directly in the [`plugins` section](../yaml/plugins-section.md) of YAML configuration files. | _none_ |
| `scheduler.base` | Sets the base of exponential backoff. | `5` |
| `scheduler.cap` | Sets a maximum retry time in seconds. | `2000` |
| `security.fips_mode` | If enabled, Fluent Bit requires the OpenSSL FIPS provider at startup and exits if it isn't available. See [FIPS mode](#fips-mode). Possible values: `off` or `on`. | `off` |
| `sp.convert_from_str_to_num` | If enabled, the stream processor converts strings that represent numbers to a numeric type. | `true` |
| `streams_file` | Path for the [stream processor](../../../stream-processing/overview.md) configuration file. This file defines the rules and operations for stream processing in Fluent Bit. Stream processor configurations can also be defined directly in the `streams` section of YAML configuration files. | _none_ |
| `windows.maxstdio` | If specified, adjusts the limit of `stdio`. Only provided for Windows. Values from `512` to `2048` are allowed. | `512` |

The `service` section only controls the built-in monitoring and control HTTP server. Plugin-specific HTTP listener settings such as `http_server.http2`, `http_server.buffer_max_size`, `http_server.buffer_chunk_size`, `http_server.max_connections`, `http_server.workers`, `http_server.ingress_queue_event_limit`, `http_server.ingress_queue_byte_limit`, and `http_server.idle_timeout` are configured on the relevant input plugin in the [`pipeline.inputs`](../yaml/pipeline-section.md#shared-http-listener-settings-for-inputs) section.

## Adaptive flush intervals

Adaptive flush intervals are available in Fluent Bit version 5.1 and greater.

The `flush` key sets a fixed flush interval. A short interval keeps latency low but wastes cycles when there's little data to deliver, and a long interval delays delivery when a pipeline is under load. Enabling `flush.adaptive` lets Fluent Bit move between those two behaviors on its own.

When `flush.adaptive` is enabled, Fluent Bit samples the highest chunk backpressure percentage across all input instances and maps that sample to a pressure level. Each level applies a multiplier to the configured `flush` value:

| Backpressure sample | Flush interval |
| --- | --- |
| `flush.adaptive.high_pressure` or greater | `flush` multiplied by `0.5` |
| `flush.adaptive.medium_pressure` or greater | `flush` multiplied by `0.75` |
| Greater than `flush.adaptive.low_pressure` | `flush` unchanged |
| `flush.adaptive.low_pressure` or less | `flush` multiplied by `2` |

The resulting interval is then clamped to the range set by `flush.adaptive.min_interval` and `flush.adaptive.max_interval`, so those two keys always take precedence over the multipliers.

To keep the interval from oscillating between levels, Fluent Bit requires repeated samples before it changes level: `flush.adaptive.up_steps` consecutive samples to move to a higher pressure level, and `flush.adaptive.down_steps` consecutive samples to move to a lower one. A sample that matches the current level resets the count. If Fluent Bit can't apply the new interval, it keeps the interval that's already in effect.

The following example flushes every 1.5 seconds under normal conditions, drops to 0.75 seconds when chunk backpressure reaches 80%, and backs off to a maximum of three seconds when the pipeline is idle:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1.5
  flush.adaptive: on
  flush.adaptive.min_interval: 0.5
  flush.adaptive.max_interval: 3
  flush.adaptive.high_pressure: 80
```

{% endtab %}
{% endtabs %}

## Log level

The `log_level` key sets the verbosity of the logs Fluent Bit produces about itself. You can set the same value with the `FLB_LOG_LEVEL` environment variable.

`FLB_LOG_LEVEL` accepts the same values as the `log_level` key. Values aren't case-sensitive, and `warning` is accepted as an alias for `warn`.

In Fluent Bit version 5.1.2 and greater, setting `FLB_LOG_LEVEL` takes precedence over the `log_level` key. Setting both is valid: Fluent Bit applies the value from the environment variable and ignores the configured value. This lets you raise verbosity for a single run without editing the configuration file:

```shell
FLB_LOG_LEVEL=debug fluent-bit --config fluent-bit.yaml
```

{% hint style="info" %}
In Fluent Bit versions 5.1.0 and 5.1.1, setting `FLB_LOG_LEVEL` and `log_level` at the same time causes startup to fail with `could not configure service property log_level`. Fluent Bit version 5.1.2 and greater applies the correct precedence instead.
{% endhint %}

## FIPS mode

FIPS mode is available in Fluent Bit version 5.1 and greater. It requires OpenSSL 3.0 or greater with the FIPS provider installed on the host.

When `security.fips_mode` is enabled, Fluent Bit activates the OpenSSL FIPS provider during startup and verifies that a FIPS-approved algorithm can be fetched from it. If the provider isn't available or can't be activated, Fluent Bit logs the OpenSSL errors and exits instead of starting with non-compliant cryptography. You can set the same behavior from the command line with the [`--enable-fips`](../../configuring-fluent-bit.md#require-fips-mode-with---enable-fips) flag.

FIPS mode can't be changed by [hot reload](../../../administration/hot-reload.md). If a reloaded configuration changes `security.fips_mode`, Fluent Bit halts the reload and keeps running with the previous configuration.

Enabling FIPS mode changes the behavior of plugins that rely on MD5:

- The [Amazon S3](../../../pipeline/outputs/s3.md) output rejects `send_content_md5` at startup, because that header requires MD5.
- The [Azure Blob](../../../pipeline/outputs/azure_blob.md) output derives block IDs using SHA-256 instead of MD5.

## Telemetry configuration

The `telemetry` key holds a nested block that controls optional internal metrics. Unlike the other `service` keys, these settings have no flat dotted-key form and no [classic mode](../classic-mode/configuration-file.md) equivalent. Define them as a nested map in YAML.

### Count log records by tag

Fluent Bit can count the log records each input ingests for every tag and expose the result as the `fluentbit_input_logs_tag_records_total` metric. For details about the metrics this feature produces, see [Monitoring](../../monitoring.md#v2-metrics).

This tracking is disabled by default because it creates one metric series for each combination of input and tag, which can increase cardinality in your metrics backend.

The following keys can be set as children to the `telemetry.metrics.logs.tag_records` key:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `enabled` | Enables per-tag counting of ingested log records. Individual inputs can override this value in the [`pipeline.inputs`](../yaml/pipeline-section.md#count-log-records-by-tag-for-inputs) section. Possible values: `false` or `true`. | `false` |
| `max_series` | Sets the maximum number of distinct input and tag combinations to track. This budget is shared across all inputs. After the limit is reached, records carrying a tag that isn't already tracked are counted in `fluentbit_input_logs_tag_records_untracked_total` with the reason `max_series`. Tags that are already tracked continue to be counted. Set to `0` or less to remove the limit. | `500` |
| `max_tag_length` | Sets the maximum length in bytes of a tag to track. Records with a longer tag are counted in `fluentbit_input_logs_tag_records_untracked_total` with the reason `tag_length_limit`. Longer tags are skipped rather than truncated. Set to `0` or less to remove the limit. | `128` |

Both `max_series` and `max_tag_length` can only be set in the `service` section.

Each of these two limits accepts an integer, or a string that contains only an integer. Strings are expanded for [environment variables](environment-variables-section.md) before they're parsed, so `${MAX_SERIES}` is valid. The resulting value must fit in a signed 32-bit integer.

Fluent Bit fails to start when a limit isn't a complete integer, such as `notanumber` or `10abc`, or falls outside the signed 32-bit range. Neither limit enforces a minimum. Both `0` and negative values are accepted and remove the limit instead of causing an error.

Fluent Bit also rejects unknown keys in this block at startup, so a misspelled key prevents the service from starting.

The following example enables per-tag counting and lowers both limits:

```yaml
service:
  flush: 1
  http_server: on
  telemetry:
    metrics:
      logs:
        tag_records:
          enabled: true
          max_series: 200
          max_tag_length: 64
```

## Storage configuration

The following storage-related keys can be set as children to the `storage` key:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `storage.backlog.flush_on_shutdown` | If enabled, Fluent Bit attempts to flush all backlog filesystem chunks to their destination during the shutdown process. This can help ensure data delivery before Fluent Bit stops, but can also increase shutdown time. Possible values: `off` or `on`. | `off` |
| `storage.backlog.mem_limit` | Sets the memory limit used by the `storage_backlog` input plugin when promoting backlog chunks (filesystem chunks left over from a previous Fluent Bit run) back into memory so they can be flushed by output plugins. While the up chunks owned by `storage_backlog` consume less memory than this limit, Fluent Bit continues to promote additional backlog chunks. This setting doesn't cap memory use for other input plugins that use filesystem storage. | `5M` |
| `storage.checksum` | Enables data integrity check when writing and reading data from the filesystem. The storage layer uses the CRC32 algorithm. Possible values: `off` or `on`. | `off` |
| `storage.delete_irrecoverable_chunks` | If enabled, deletes irrecoverable chunks during runtime and at startup. Possible values: `off` or `on`. | `off` |
| `storage.inherit` | If enabled, input plugins that don't explicitly set `storage.type` will inherit the global `storage.type` value. Possible values: `off` or `on`. | `off` |
| `storage.keep.rejected` | If enabled, the [dead letter queue](../../dead-letter-queue.md) stores failed chunks that can't be delivered. Possible values: `off` or `on`. | `off` |
| `storage.max_chunks_up` | Sets the number of chunks that can be `up` in memory for input plugins that use filesystem storage. | `128` |
| `storage.metrics` | If `http_server` option is enabled in the main `service` section, this option registers a new endpoint where internal metrics of the storage layer can be consumed. For more details, see [Monitoring](../../monitoring.md). Possible values: `off` or `on`. | `off` |
| `storage.path` | Sets a location to store streams and chunks of data. If this parameter isn't set, input plugins can't use filesystem buffering. | _none_ |
| `storage.rejected.limit` | Sets the maximum total size of the dead letter queue. Accepts size values such as `100M` or `1G`. When the limit is reached, new rejected chunks are skipped and a warning is logged. If not set, the DLQ size is unlimited. | _none_ |
| `storage.rejected.path` | Sets the subdirectory name under `storage.path` for storing rejected chunks in the dead letter queue. | `rejected` |
| `storage.sync` | Configures the synchronization mode used to store data in the file system. Using `full` increases the reliability of the filesystem buffer and ensures that data is guaranteed to be synced to the filesystem even if Fluent Bit crashes. On Linux, `full` corresponds with the `MAP_SYNC` option for [memory mapped files](https://man7.org/linux/man-pages/man2/mmap.2.html). Possible values: `normal`, `full`. | `normal` |
| `storage.trim_files` | If enabled, Fluent Bit trims chunk files in the filesystem to reclaim disk space after data is flushed. Possible values: `off` or `on`. | `off` |
| `storage.type` | Sets the default storage type for input plugins. Used in conjunction with `storage.inherit` to apply this type to all inputs that don't explicitly set their own `storage.type`. Possible values: `memory`, `filesystem`, `memrb`. | _none_ |

For storage and buffering details, see [Buffering](../../../pipeline/buffering.md) and [Backpressure](../../backpressure.md).

For scheduler and retry details, see [Scheduling and retries](../../scheduling-and-retries.md#Scheduling-and-Retries).

## Configuration example

The following configuration example defines a `service` section with [hot reloading](../../hot-reload.md) enabled and a pipeline with a `random` input and `stdout` output:

```yaml
service:
  flush: 1
  log_level: info
  http_server: true
  http_listen: 0.0.0.0
  http_port: 2020
  hot_reload: on

pipeline:
  inputs:
    - name: random

  outputs:
    - name: stdout
      match: '*'
```
