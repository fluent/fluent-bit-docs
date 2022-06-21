---
description: This page describes the yaml configuration file used by Fluent Bit
---

# YAML Configuration File

One of the ways to configure Fluent Bit is using a YAML configuration file that works at a global scope.

The yaml configuration file supports the following sections:

* Env
* Service
* Pipeline
  * Inputs
  * Filters
  * Outputs

## Env <a href="config_env" id="config_env"></a>

The _env_ section allows to configure variables that will be used later on this configuration file.

Example:

```yaml
# setting up a local environment variable
env:
    flush_interval: 1

# service configuration
service:
    flush:       ${flush_interval}
    log_level:   info
    http_server: on
```

## Service <a href="config_section" id="config_section"></a>

The _service_ section defines global properties of the service, the keys available as of this version are described in the following table:

| Key             | Description                                                                                                                                                                                                                                                                                             | Default Value |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| flush           | Set the flush time in `seconds.nanoseconds`. The engine loop uses a Flush timeout to define when is required to flush the records ingested by input plugins through the defined output plugins.                                                                                                         | 5             |
| grace           | Set the grace time in `seconds` as Integer value. The engine loop uses a Grace timeout to define wait time on exit                                                                                                                                                                                      | 5             |
| daemon          | Boolean value to set if Fluent Bit should run as a Daemon (background) or not. Allowed values are: yes, no, on and off.  note: If you are using a Systemd based unit as the one we provide in our packages, do not turn on this option.                                                                 | Off           |
| dns.mode        | Set the primary transport layer protocol used by the asynchronous DNS resolver which can be overriden on a per plugin basis                                                                                                                                                                             | UDP           |
| log_file        | Absolute path for an optional log file. By default all logs are redirected to the standard error interface (stderr).                                                                                                                                                                                    |               |
| log_level       | Set the logging verbosity level. Allowed values are: off, error, warn, info, debug and trace. Values are accumulative, e.g: if 'debug' is set, it will include error, warning, info and debug.  Note that _trace_ mode is only available if Fluent Bit was built with the _WITH\_TRACE_ option enabled. | info          |
| parsers_file    | Path for a `parsers` configuration file. Multiple Parsers_File entries can be defined within the section.                                                                                                                                                                                               |               |
| plugins_file    | Path for a `plugins` configuration file. A _plugins_ configuration file allows to define paths for external plugins, for an example [see here](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf).                                                                                     |               |
| streams_file    | Path for the Stream Processor configuration file. To learn more about Stream Processing configuration go [here](../../../stream-processing/introduction.md).                                                                                                                                               |               |
| http_server     | Enable built-in HTTP Server                                                                                                                                                                                                                                                                             | Off           |
| http_listen     | Set listening interface for HTTP Server when it's enabled                                                                                                                                                                                                                                               | 0.0.0.0       |
| http_port       | Set TCP Port for the HTTP Server                                                                                                                                                                                                                                                                        | 2020          |
| coro_stack_size | Set the coroutines stack size in bytes. The value must be greater than the page size of the running system. Don't set too small value (say 4096), or coroutine threads can overrun the stack buffer. Do not change the default value of this parameter unless you know what you are doing.              | 24576         |
| scheduler.cap   | Set a maximum retry time in second. The property is supported from v1.8.7.                                                                                                                                                                                                                              | 2000          |
| scheduler.base  | Set a base of exponential backoff. The property is supported from v1.8.7.                                                                                                                                                                                                                               | 5             |

The following is an example of a _service_ section:

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug
```

## Pipeline <a href="config_pipeline" id="config_pipeline"></a>

A _pipeline_ section will define a complete pipeline configuration, including _inputs_, _filters_ and _outputs_ subsections.

```yaml
pipeline:
    inputs:
        ...
    filters:
        ...
    outputs:
        ...
```

### Input <a href="config_input" id="config_input"></a>

An _input_ section defines a source (related to an input plugin). Here we will describe the base configuration for each _input_ section. Note that each input plugin may add it own configuration keys:

| Key  | Description                                                              |
| ---- |--------------------------------------------------------------------------|
| Name | Name of the input plugin. Defined as subsection of the _inputs_ section. |
| Tag  | Tag name associated to all records coming from this plugin.              |

The _Name_ is mandatory and it let Fluent Bit know which input plugin should be loaded. The _Tag_ is mandatory for all plugins except for the _input forward_ plugin (as it provides dynamic tags).

#### Example

The following is an example of an _input_ section for the _cpu_ plugin.

```yaml
pipeline:
    inputs:
        - cpu:
            tag: my_cpu
```

### Filter <a href="config_filter" id="config_filter"></a>

A _filter_ section defines a filter (related to an filter plugin). Here we will describe the base configuration for each _filter_ section. Note that each filter plugin may add it own configuration keys:

| Key | Description                                                                                                                     |
|--- |---------------------------------------------------------------------------------------------------------------------------------|
| Name        | Name of the filter plugin. Defined as a subsection of the _filters_ section.                                                    |
| Match       | A pattern to match against the tags of incoming records. It's case sensitive and support the star (\*) character as a wildcard. |
| Match_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax.   |

The _Name_ is mandatory and it let Fluent Bit know which filter plugin should be loaded. The _Match_ or _Match_Regex_ is mandatory for all plugins. If both are specified, _Match_Regex_ takes precedence.

#### Example

The following is an example of a _filter_ section for the grep plugin:

```yaml
pipeline:
    filters:
        - grep:
            match: *
            regex: log aa
```

### Output <a href="config_output" id="config_output"></a>

The _outputs_ section specify a destination that certain records should follow after a Tag match. Currently, Fluent Bit can route up to 256 _OUTPUT_ plugins. The configuration support the following keys:

| Key         | Description                                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Name        | Name of the output plugin. Defined as a subsection of the _outputs_ section.                                                                                                      |   |
| Match       | A pattern to match against the tags of incoming records. It's case sensitive and support the star (\*) character as a wildcard. |
| Match_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax.   |

#### Example

The following is an example of an _output_ section:

```yaml
pipeline:
    outputs:
        - stdout:
            match: my*cpu
```

#### Example: collecting CPU metrics

The following configuration file example demonstrates how to collect CPU metrics and flush the results every five seconds to the standard output:

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug

pipeline:
    inputs:
        - cpu:
            tag: my_cpu
    outputs:
        - stdout:
            match: my*cpu
```
