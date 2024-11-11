## Service Section

The `service` section defines global properties of the service. The available configuration keys are:

| Key | Description | Default |
|---|---|---|
| `flush` | Sets the flush time in `seconds.nanoseconds`. The engine loop uses a flush timeout to determine when to flush records ingested by input plugins to output plugins. | `1` |
| `grace` | Sets the grace time in `seconds` as an integer value. The engine loop uses a grace timeout to define the wait time before exiting. | `5` |
| `daemon` | Boolean. Specifies whether Fluent Bit should run as a daemon (background process). Allowed values are: `yes`, `no`, `on`, and `off`. Do not enable when using a Systemd-based unit, such as the one provided in Fluent Bit packages. | `off` |
| `dns.mode` | Sets the primary transport layer protocol used by the asynchronous DNS resolver. Can be overridden on a per-plugin basis. | `UDP` |
| `log_file` | Absolute path for an optional log file. By default, all logs are redirected to the standard error interface (stderr). | _none_ |
| `log_level` | Sets the logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are cumulative. If `debug` is set, it will include `error`, `warn`, `info`, and `debug`. Trace mode is only available if Fluent Bit was built with the _`WITH_TRACE`_ option enabled. | `info` |
| `parsers_file` | Path for a `parsers` configuration file. Multiple `parsers_file` entries can be defined within the section. However, with the new YAML configuration schema, defining parsers using this key is now optional. Parsers can be declared directly in the `parsers` section of your YAML configuration, offering a more streamlined and integrated approach. | _none_ |
| `plugins_file` | Path for a `plugins` configuration file. This file specifies the paths to external plugins (.so files) that Fluent Bit can load at runtime. With the new YAML schema, the `plugins_file` key is optional. External plugins can now be referenced directly within the `plugins` section, simplifying the plugin management process. [See an example](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf). | _none_ |
| `streams_file` | Path for the Stream Processor configuration file. This file defines the rules and operations for stream processing within Fluent Bit. The `streams_file` key is optional, as Stream Processor configurations can be defined directly in the `streams` section of the YAML schema. This flexibility allows for easier and more centralized configuration. [Learn more about Stream Processing configuration](../../../stream-processing/introduction.md). | _none_ |
| `http_server` | Enables the built-in HTTP Server. | `off` |
| `http_listen` | Sets the listening interface for the HTTP Server when it's enabled. | `0.0.0.0` |
| `http_port` | Sets the TCP port for the HTTP Server. | `2020` |
| `coro_stack_size` | Sets the coroutine stack size in bytes. The value must be greater than the page size of the running system. Setting the value too small (`4096`) can cause coroutine threads to overrun the stack buffer. The default value of this parameter should not be changed. | `24576` |
| `scheduler.cap` | Sets a maximum retry time in seconds. Supported in v1.8.7 and greater. | `2000` |
| `scheduler.base` | Sets the base of exponential backoff. Supported in v1.8.7 and greater. | `5` |
| `json.convert_nan_to_null` | If enabled, `NaN` is converted to `null` when Fluent Bit converts `msgpack` to `json`. | `false` |
| `sp.convert_from_str_to_num` | If enabled, the Stream Processor converts strings that represent numbers to a numeric type. | `true` |

### Configuration Example

Below is a simple configuration example that defines a `service` section and a pipeline with a `random` input and `stdout` output:

```yaml
service:
  flush: 1
  log_level: info
  http_server: true
  http_listen: 0.0.0.0
  http_port: 2020

pipeline:
  inputs:
    - name: random

  outputs:
    - name: stdout
      match: '*'
```
