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
| `log_level` | Sets the logging verbosity level. Possible values: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are cumulative. For example, if `debug` is set, it will include `error`, `warning`, `info`, and `debug`. The `trace` mode is only available if Fluent Bit was built with the `WITH_TRACE` option enabled. | `info` |
| `multiline_buffer_limit` | Sets the default buffer size limit for multiline parsers. This value must follow [unit size](../../configuring-fluent-bit.md#unit-sizes) specifications. | `2MB` |
| `parsers_file` | Path for [standalone parsers configuration files](../yaml/parsers-section.md#standalone-parsers-files). You can include one or more files. | _none_ |
| `plugins_file` | Path for a `plugins` configuration file. This file specifies the paths to external plugins (.so files) that Fluent Bit can load at runtime. Plugins can also be declared directly in the [`plugins` section](../yaml/plugins-section.md) of YAML configuration files. | _none_ |
| `scheduler.base` | Sets the base of exponential backoff. | `5` |
| `scheduler.cap` | Sets a maximum retry time in seconds. | `2000` |
| `sp.convert_from_str_to_num` | If enabled, the stream processor converts strings that represent numbers to a numeric type. | `true` |
| `streams_file` | Path for the [stream processor](../../../stream-processing/overview.md) configuration file. This file defines the rules and operations for stream processing in Fluent Bit. Stream processor configurations can also be defined directly in the `streams` section of YAML configuration files. | _none_ |
| `windows.maxstdio` | If specified, adjusts the limit of `stdio`. Only provided for Windows. Values from `512` to `2048` are allowed. | `512` |

## Storage configuration

The following storage-related keys can be set as children to the `storage` key:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `storage.backlog.flush_on_shutdown` | If enabled, Fluent Bit attempts to flush all backlog filesystem chunks to their destination during the shutdown process. This can help ensure data delivery before Fluent Bit stops, but can also increase shutdown time. Possible values: `off` or `on`. | `off` |
| `storage.backlog.mem_limit` | Sets the memory allocated for storing buffered data for input plugins that use filesystem storage. | `5M` |
| `storage.checksum` | Enables data integrity check when writing and reading data from the filesystem. The storage layer uses the CRC32 algorithm. Possible values: `off` or `on`. | `off` |
| `storage.delete_irrecoverable_chunks` | If enabled, deletes irrecoverable chunks during runtime and at startup. Possible values: `off` or `on`. | `off` |
| `storage.inherit` | If enabled, input plugins that don't explicitly set `storage.type` will inherit the global `storage.type` value. Possible values: `off` or `on`. | `off` |
| `storage.keep.rejected` | If enabled, the [dead letter queue](../../dead-letter-queue.md) stores failed chunks that can't be delivered. Possible values: `off` or `on`. | `off` |
| `storage.max_chunks_up` | Sets the number of chunks that can be `up` in memory for input plugins that use filesystem storage. | `128` |
| `storage.metrics` | If `http_server` option is enabled in the main `service` section, this option registers a new endpoint where internal metrics of the storage layer can be consumed. For more details, see [Monitoring](../../monitoring.md). Possible values: `off` or `on`. | `off` |
| `storage.path` | Sets a location to store streams and chunks of data. If this parameter isn't set, input plugins can't use filesystem buffering. | _none_ |
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
