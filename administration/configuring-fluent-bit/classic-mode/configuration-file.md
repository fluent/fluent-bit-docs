---
description: This page describes the main configuration file used by Fluent Bit.
---

# Configuration file

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=5e67142e-3887-4b56-b940-18494bcc23a7" />

One of the ways to configure Fluent Bit is using a main configuration file. Fluent Bit allows the use one configuration file that works at a global scope and uses the defined [Format and Schema](format-schema.md).

The main configuration file supports four sections:

- Service
- Input
- Filter
- Output

It's also possible to split the main configuration file into multiple files using the Include File feature to include external files.

## Service

The `Service` section defines global properties of the service. The following keys are:

| Key             | Description   | Default Value |
| --------------- | ------------- | ------------- |
| `flush`           | Set the flush time in `seconds.nanoseconds`. The engine loop uses a Flush timeout to define when it's required to flush the records ingested by input plugins through the defined output plugins.  | `1` |
| `grace`           | Set the grace time in `seconds` as an integer value. The engine loop uses a grace timeout to define wait time on exit. | `5` |
| daemon          | Boolean. Determines whether Fluent Bit should run as a Daemon (background). Allowed values are: `yes`, `no`, `on`, and `off`. Don't enable when using a Systemd based unit, such as the one provided in Fluent Bit packages.  | `Off` |
| `dns.mode`        | Set the primary transport layer protocol used by the asynchronous DNS resolver. Can be overridden on a per plugin basis. | `UDP` |
| `log_file`        | Absolute path for an optional log file. By default all logs are redirected to the standard error interface (stderr). | _none_ |
| `log_level`       | Set the logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Values are cumulative. If `debug` is set, it will include `error`, `warning`, `info`, and `debug`. Trace mode is only available if Fluent Bit was built with the _`WITH_TRACE`_ option enabled. | `info` |
| `parsers_file`    | Path for a `parsers` configuration file. Multiple `Parsers_File` entries can be defined within the section. | _none_ |
| `plugins_file`    | Path for a `plugins` configuration file. A `plugins` configuration file defines paths for external plugins. [See an example](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf). | _none_ |
| `streams_file`    | Path for the Stream Processor configuration file. [Learn more about Stream Processing configuration](../../../stream-processing/introduction.md). | _none_|
| `http_server`     | Enable the built-in HTTP Server. | `Off` |
| `http_listen`     | Set listening interface for HTTP Server when it's enabled. | `0.0.0.0` |
| `http_port`       | Set TCP Port for the HTTP Server. | `2020` |
| `coro_stack_size` | Set the coroutines stack size in bytes. The value must be greater than the page size of the running system. Setting the value too small (`4096`) can cause coroutine threads to overrun the stack buffer. The default value of this parameter shouldn't be changed. | `24576` |
| `scheduler.cap`   | Set a maximum retry time in seconds. Supported in v1.8.7 and greater. | `2000` |
| `scheduler.base`  | Set a base of exponential backoff. Supported in v1.8.7 and greater. | `5` |
| `json.convert_nan_to_null` | If enabled, `NaN` converts to `null` when Fluent Bit converts `msgpack` to `json`. | `false` |
| `sp.convert_from_str_to_num` | If enabled, Stream processor converts from number string to number type. | `true` |

The following is an example of a `SERVICE` section:

```python
[SERVICE]
    Flush           5
    Daemon          off
    Log_Level       debug
```

For scheduler and retry details, see [scheduling and retries](../../scheduling-and-retries.md#Scheduling-and-Retries).

## Config input

The `INPUT` section defines a source (related to an input plugin). Each [input plugin](https://docs.fluentbit.io/manual/pipeline/inputs) can add its own configuration keys:

| Key         | Description |
| ----------- | ------------|
| `Name`      | Name of the input plugin.  |
| `Tag`       | Tag name associated to all records coming from this plugin. |
| `Log_Level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

`Name` is mandatory and tells Fluent Bit which input plugin to load. `Tag` is mandatory for all plugins except for the `input forward` plugin, which provides dynamic tags.

### Example

The following is an example of an `INPUT` section:

```python
[INPUT]
    Name cpu
    Tag  my_cpu
```

## Config filter

The `FILTER` section defines a filter (related to an filter plugin). Each filter plugin can add it own configuration keys. The base configuration for each `FILTER` section contains:

| Key         | Description  |
| ----------- | ------------ |
| `Name`      | Name of the filter plugin. |
| `Match`     | A pattern to match against the tags of incoming records. Case sensitive, supports asterisk (`*`) as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level`   | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

`Name` is mandatory and lets Fluent Bit know which filter plugin should be loaded. `Match` or `Match_Regex` is mandatory for all plugins. If both are specified, `Match_Regex` takes precedence.

### Filter example

The following is an example of a `FILTER` section:

```python
[FILTER]
    Name  grep
    Match *
    Regex log aa
```

## Config output

The `OUTPUT` section specifies a destination that certain records should go to after a `Tag` match. Fluent Bit can route up to 256 `OUTPUT` plugins. The configuration supports the following keys:

| Key         | Description    |
| ----------- | -------------- |
| `Name`      | Name of the output plugin. |
| `Match`     | A pattern to match against the tags of incoming records. Case sensitive and supports the asterisk (`*`) character as a wildcard. |
| `Match_Regex` | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regular expression syntax. |
| `Log_Level` | Set the plugin's logging verbosity level. Allowed values are: `off`, `error`, `warn`, `info`, `debug`, and `trace`. Defaults to the `SERVICE` section's `Log_Level`. |

### Output example

The following is an example of an `OUTPUT` section:

```python
[OUTPUT]
    Name  stdout
    Match my*cpu
```

### Example: collecting CPU metrics

The following configuration file example demonstrates how to collect CPU metrics and flush the results every five seconds to the standard output:

```python
[SERVICE]
    Flush     5
    Daemon    off
    Log_Level debug

[INPUT]
    Name  cpu
    Tag   my_cpu

[OUTPUT]
    Name  stdout
    Match my*cpu
```

## Config Include File

To avoid complicated long configuration files is better to split specific parts in different files and call them (include) from one main file. The `@INCLUDE` can be used in the following way:

```text
@INCLUDE somefile.conf
```

The configuration reader will try to open the path `somefile.conf`. If not found, the reader assumes the file is on a relative path based on the path of the base configuration file:

- Main configuration path: `/tmp/main.conf`
- Included file: `somefile.conf`
- Fluent Bit will try to open `somefile.conf`, if it fails it will try `/tmp/somefile.conf`.

The `@INCLUDE` command only works at top-left level of the configuration line, and can't be used inside sections.

Wildcard character (`*`) supports including multiple files. For example:

```text
@INCLUDE input_*.conf
```

Files matching the wildcard character are included unsorted. If plugin ordering between files needs to be preserved, the files should be included explicitly.
