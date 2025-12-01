# Service

The `service` section defines global properties of the service. The available configuration keys are:


| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `flush`  | Sets the flush time in `seconds.nanoseconds`. The engine loop uses a flush timeout to define when to flush the records ingested by input plugins through the defined output plugins. | `1` |
| `grace`  | Sets the grace time in `seconds` as an integer value. The engine loop uses a grace timeout to define the wait time on exit. | `5` |
| `daemon` | Specifies whether Fluent Bit should run as a daemon (background process). Possible values: `yes`, `no`, `on`, and `off`. Don't enable when using a Systemd-based unit, such as the one provided in Fluent Bit packages. | `off` |
| `dns.mode` | Sets the primary transport layer protocol used by the asynchronous DNS resolver. Can be overridden on a per-plugin basis. | `UDP` |
| `log_file` | Absolute path for an optional log file. By default, all logs are redirected to the standard error interface (`stderr`). | _none_ |
| `log_level` | Sets the logging verbosity level. Possible values: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are cumulative. For example, if `debug` is set, it will include `error`, `warning`, `info`, and `debug`. The `trace` mode is only available if Fluent Bit was built with the `WITH_TRACE` option enabled. | `info` |
| `parsers_file` | Path for a parsers configuration file. Multiple `parsers_file` entries can be defined within the section. Parsers can be declared directly in the [`parsers` section](./parsers-section.md) of YAML configuration files. | _none_ |
| `plugins_file` | Path for a `plugins` configuration file. This file specifies the paths to custom plugins (.so files) that Fluent Bit can load at runtime. Plugins can be declared directly in the [`plugins` section](./plugins-section.md) of YAML configuration files. | _none_ |
| `streams_file` | Path for the [stream processor](../../../stream-processing/overview.md) configuration file. This file defines the rules and operations for stream processing in Fluent Bit. Stream processor configurations can also be defined directly in the `streams` section of YAML configuration files. | _none_ |
| `http_server` | Enables the built-in HTTP server. | `off` |
| `http_listen` | Sets the listening interface for the HTTP Server when it's enabled. | `0.0.0.0` |
| `http_port` | Sets the TCP port for the HTTP server. | `2020` |
| `hot_reload` | Enables [hot reloading](../../../administration/hot-reload.md) of configuration with SIGHUP. | `on` |
| `coro_stack_size` | Sets the coroutines stack size in bytes. The value must be greater than the page size of the running system. Setting the value too small (for example, `4096`) can cause coroutine threads to overrun the stack buffer. For best results, don't change this parameter from its default value. | `24576` |
| `scheduler.cap`   | Sets a maximum retry time in seconds. | `2000` |
| `scheduler.base`  | Sets the base of exponential backoff.  | `5` |
| `json.convert_nan_to_null` | If enabled, `NaN` is converted to `null` when Fluent Bit converts `msgpack` to JSON. | `false` |
| `json.escape_unicode` | Controls how Fluent Bit serializes non‑ASCII / multi‑byte Unicode characters in JSON strings. When enabled, Unicode characters are escaped as `\uXXXX` sequences (characters outside BMP become surrogate pairs). When disabled, Fluent Bit emits raw UTF‑8 bytes. | `true` |
| `sp.convert_from_str_to_num` | If enabled, the stream processor converts strings that represent numbers to a numeric type. | `true` |
| `windows.maxstdio` | If specified, adjusts the limit of `stdio`. Only provided for Windows. Values from `512` to `2048` are allowed. | `512` |

## Storage configuration

The following storage-related keys can be set in the `service` section:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `storage.path` | Set a location in the file system to store streams and chunks of data. Required for filesystem buffering. | _none_ |
| `storage.sync` | Configure the synchronization mode used to store data in the file system. Accepted values: `normal` or `full`. | `normal` |
| `storage.checksum` | Enable data integrity check when writing and reading data from the filesystem. Accepted values: `off` or `on`. | `off` |
| `storage.max_chunks_up` | Set the maximum number of chunks that can be `up` in memory when using filesystem storage. | `128` |
| `storage.backlog.mem_limit` | Set the memory limit for backlog data chunks. | `5M` |
| `storage.backlog.flush_on_shutdown` | Attempt to flush all backlog chunks during shutdown. Accepted values: `off` or `on`. | `off` |
| `storage.metrics` | Enable storage layer metrics on the HTTP endpoint. Accepted values: `off` or `on`. | `off` |
| `storage.delete_irrecoverable_chunks` | Delete irrecoverable chunks during runtime and at startup. Accepted values: `off` or `on`. | `off` |
| `storage.keep.rejected` | Enable the Dead Letter Queue (DLQ) to preserve chunks that fail to be delivered. Accepted values: `off` or `on`. | `off` |
| `storage.rejected.path` | Subdirectory name under `storage.path` for storing rejected chunks. | `rejected` |

For scheduler and retry details, see [scheduling and retries](../../scheduling-and-retries.md#Scheduling-and-Retries).

For storage and buffering details, see [buffering and storage](../../buffering-and-storage.md).

## Configuration example

The following configuration example that defines a `service` section with [hot reloading](../../hot-reload.md) enabled and a pipeline with a `random` input and `stdout` output:

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
