---
description: Learn about the YAML configuration file used by Fluent Bit
---

# YAML configuration file

<img referrerpolicy="no-referrer-when-downgrade"
src="https://static.scarf.sh/a.png?x-pxid=864c6f0e-8977-4838-8772-84416943548e" alt="" />

One of the ways to configure Fluent Bit is using a YAML configuration file that works at a global scope.

The YAML configuration file supports the following sections:

- `Env`
- `Includes`
- `Service`
- `Pipeline`
  - `Inputs`
  - `Filters`
  - `Outputs`

The YAML configuration file doesn't support the following sections:

- `Parsers`

{% hint style="info" %}
YAML configuration is used in the smoke tests for containers. An always-correct up-to-date example is here: <https://github.com/fluent/fluent-bit/blob/master/packaging/testing/smoke/container/fluent-bit.yaml>.
{% endhint %}

## `env`

The `env` section allows the definition of configuration variables that will be used later in the configuration file.

Example:

```yaml
# Set up a local environment variable
env:
    flush_interval: 1

# service configuration
service:
    flush:       ${flush_interval}
    log_level:   info
    http_server: on
```

## Includes

The `includes` section allows the files to be merged into the YAML configuration to be identified as a list of filenames. If no path is provided, then the file is assumed to be in a folder relative to the file referencing it.

Example:

```yaml
# defining file(s) to include into the current configuration. This includes illustrating using a relative path reference
includes:
    - inclusion-1.yaml
    - subdir/inclusion-2.yaml

```

## Service

The `service` section defines the global properties of the service. The Service keys available as of this version are described in the following table:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `flush`  | Set the flush time in `seconds.nanoseconds`. The engine loop uses a Flush timeout to define when to flush the records ingested by input plugins through the defined output plugins. | `5` |
| `grace`  | Set the grace time in `seconds` as an Integer value. The engine loop uses a Grace timeout to define the wait time on exit. | `5` |
| `daemon` | Boolean value to set if Fluent Bit should run as a Daemon (background) or not. Allowed values are: `yes`, `no`, `on`, and `off`. If you are using a Systemd based unit like the one provided in the Fluent Bit packages, don't turn on this option. | `Off` |
| `dns.mode` | Sets the primary transport layer protocol used by the asynchronous DNS resolver, which can be overridden on a per plugin basis | `UDP` |
| `log_file` | Absolute path for an optional log file. By default, all logs are redirected to the standard error interface(`stderr`). | _none_ |
| `log_level` | Set the logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are accumulative. For example, if `debug` is set, it will include `error`, `warning`, `info`, and `debug`. `trace` mode is only available if Fluent Bit was built with the `WITH_TRACE` option enabled. | `info` |
| `parsers_file` | Path for a `parsers` configuration file. Only a single entry is supported. | _none_ |
| `plugins_file` | Path for a `plugins` configuration file. A `plugins` configuration file allows the definition of paths for external plugins; for an example, [see here](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf). | _none_ |
| `streams_file` | Path for the Stream Processor configuration file. Learn more about [Stream Processing configuration](../../../stream-processing/introduction.md). | _none_ |
| `http_server` | Enable built-in HTTP server. | `Off` |
| `http_listen` | Set listening interface for HTTP server when it's enabled. | `0.0.0.0` |
| `http_port` | Set TCP Port for the HTTP server | `2020` |
| `coro_stack_size` | Set the coroutines stack size in bytes. The value must be greater than the page size of the running system. Don't set too small a value (for example, `4096`), or coroutine threads can overrun the stack buffer. Don't change the default value of this parameter unless you know what you are doing. | `24576` |
| `scheduler.cap`   | Set a maximum retry time in seconds. Supported from v1.8.7. | `2000` |
| `scheduler.base`  | Sets the base of exponential backoff. Supported from v1.8.7. | `5` |
| `json.convert_nan_to_null` | If enabled, NaN is converted to null when Fluent Bit converts `msgpack` to JSON. | `false` |
| `json.escape_unicode` | Controls how Fluent Bit serializes non‑ASCII / multi‑byte Unicode characters in JSON strings. When enabled, Unicode characters are escaped as \uXXXX sequences (characters outside BMP become surrogate pairs). When disabled, Fluent Bit emits raw UTF‑8 bytes. | `true` |
| `sp.convert_from_str_to_num` | If enabled, Stream processor converts from number string to number type. | `true` |
| `windows.maxstdio` | If specified, the limit of stdio is adjusted. Only provided for Windows. From 512 to 2048 is allowed. | `512` |

The following is an example of a `service` section:

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug
```

For scheduler and retry details, see [scheduling and retries](../../scheduling-and-retries.md#Scheduling-and-Retries)

## Pipeline

A `pipeline` section will define a complete pipeline configuration, including `inputs`, `filters`, and `outputs` subsections.

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

```yaml
pipeline:
    inputs:
        - name: tail
          tag: syslog
          path: /var/log/syslog
        - name: http
          tag: http_server
          port: 8080
```

This pipeline consists of two `inputs`: a tail plugin and an HTTP server plugin. Each plugin has its own map in the array of `inputs` consisting of basic properties. To use more advanced properties that consist of multiple values the property itself can be defined using an array, such as the `record` and `allowlist_key` properties for the `record_modifier` `filter`:

```yaml
pipeline:
    inputs:
        - name: tail
          tag: syslog
          path: /var/log/syslog
    filters:
        - name: record_modifier
          match: syslog
          record:
              - powered_by calyptia
        - name: record_modifier
          match: syslog
          allowlist_key:
              - powered_by
              - message
```

In the cases where each value in a list requires two values they must be separated by a space, such as in the `record` property for the `record_modifier` filter.

### Input

An `input` section defines a source (related to an input plugin). Each section has a base configuration. Each input plugin can add it own configuration keys:

| Key | Description |
| --- |------------ |
| `Name` | Name of the input plugin. Defined as subsection of the `inputs` section. |
| `Tag` | Tag name associated to all records coming from this plugin. |
| `Log_Level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

The `Name` is mandatory and defines for Fluent Bit which input plugin should be loaded. `Tag` is mandatory for all plugins except for the `input forward` plugin which provides dynamic tags.

#### Example input

The following is an example of an `input` section for the `cpu` plugin.

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
```

### Filter

A `filter` section defines a filter (related to a filter plugin). Each section has a base configuration and each filter plugin can add its own configuration keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `Name`        | Name of the filter plugin. Defined as a subsection of the `filters` section. |
| `Match`       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level`   | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

`Name` is mandatory and lets Fluent Bit know which filter plugin should be loaded. The `Match` or `Match_Regex` is mandatory for all plugins. If both are specified, `Match_Regex` takes precedence.

#### Example filter

The following is an example of a `filter` section for the `grep` plugin:

```yaml
pipeline:
    filters:
        - name: grep
          match: '*'
          regex: log aa
```

### Output

The `outputs` section specifies a destination that certain records should follow after a `Tag` match. Fluent Bit can route up to 256 `OUTPUT` plugins. The configuration supports the following keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `Name`        | Name of the output plugin. Defined as a subsection of the `outputs` section. |
| `Match`       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (`*`) character as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level`   | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. The output log level defaults to the `SERVICE` section's `Log_Level`. |

#### Example output

The following is an example of an `output` section:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
```

#### Collecting `cpu` metrics example

The following configuration file example demonstrates how to collect CPU metrics and flush the results every five seconds to the standard output:

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug

pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
    outputs:
        - name: stdout
          match: 'my*cpu'
```

## Processors

Fluent Bit 2.1.2 and greater implements an interface called `processor` to extend the processing capabilities in input and output plugins directly without routing the data. The input and output plugins can run in separate threads. This interface allows users to apply data transformations and filtering to incoming data records before they're processed further in the pipeline.

This capability is only exposed in YAML configuration and not in classic configuration mode due to the restriction of nested levels of configuration.

[Processor example](configuration-file.md#example-using-processors)

### Example: Using processors

The following configuration file example demonstrates the use of processors to change the log record in the input plugin section by adding a new key `hostname` with the value `monox`. It uses Lua to append the tag to the log record. The output plugin section adds a new key named `output` with the value `new data`.

```yaml
  service:
    log_level: info
    http_server: on
    http_listen: 0.0.0.0
    http_port: 2021
  pipeline:
    inputs:
      - name: random
        tag: test-tag
        interval_sec: 1
        processors:
          logs:
            - name: modify
              add: hostname monox
            - name: lua
              call: append_tag
              code: |
                  function append_tag(tag, timestamp, record)
                     new_record = record
                     new_record["tag"] = tag
                     return 1, timestamp, new_record
                  end
    outputs:
      - name: stdout
        match: '*'
        processors:
          logs:
            - name: lua
              call: add_field
              code: |
                  function add_field(tag, timestamp, record)
                     new_record = record
                     new_record["output"] = "new data"
                     return 1, timestamp, new_record
                  end
```
