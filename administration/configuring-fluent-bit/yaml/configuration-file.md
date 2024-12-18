---
description: This page describes the yaml configuration file used by Fluent Bit
---

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=864c6f0e-8977-4838-8772-84416943548e" />

# YAML Configuration File

One of the ways to configure Fluent Bit is using a YAML configuration file that works at a global scope.

The YAML configuration file supports the following sections:

* Env
* Includes
* Service
* Pipeline
  * Inputs
  * Filters
  * Outputs

The YAML configuration file does not support the following sections yet:
* Parsers

{% hint style="info" %}
YAML configuration is used in the smoke tests for containers, so an always-correct up-to-date example is here: <https://github.com/fluent/fluent-bit/blob/master/packaging/testing/smoke/container/fluent-bit.yaml>.
{% endhint %}

## Env <a href="config_env" id="config_env"></a>

The _env_ section allows the definition of configuration variables that will be used later in the configuration file.

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



## Includes<a href="config_env" id="config_env"></a>

The _includes_ section allows the files to be merged into the YAML configuration to be identified as a list of filenames. If no path is provided, then the file is assumed to be in a folder relative to the file referencing it.

Example:

```yaml
# defining file(s) to include into the current configuration. This includes illustrating using a relative path reference
includes:
    - inclusion-1.yaml
    - subdir/inclusion-2.yaml

```

## Service <a href="config_section" id="config_section"></a>

The _service_ section defines the global properties of the service. The Service keys available as of this version are described in the following table:

| Key             | Description                                                                                                                                                                                                                                                                                             | Default Value |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| flush           | Set the flush time in `seconds.nanoseconds`. The engine loop uses a Flush timeout to define when is required to flush the records ingested by input plugins through the defined output plugins.                                                                                                         | 5             |
| grace           | Set the grace time in `seconds` as an Integer value. The engine loop uses a Grace timeout to define the wait time on exit                                                                                                                                                                               | 5             |
| daemon          | Boolean value to set if Fluent Bit should run as a Daemon (background) or not. Allowed values are: yes, no, on, and off.  note: If you are using a Systemd based unit like the one we provide in our packages, do not turn on this option.                                                            | Off           |
| dns.mode        | Sets the primary transport layer protocol used by the asynchronous DNS resolver, which can be overridden on a per plugin basis                                                                                                                                                                       | UDP           |
| log_file        | Absolute path for an optional log file. By default, all logs are redirected to the standard error interface (stderr).                                                                                                                                                                                   |               |
| log_level       | Set the logging verbosity level. Allowed values are: off, error, warn, info, debug and trace. Values are accumulative, e.g., if 'debug' is set, it will include error, warning, info, and debug.  Note that _trace_ mode is only available if Fluent Bit was built with the _WITH\_TRACE_ option enabled. | info          |
| parsers_file    | Path for a `parsers` configuration file. Only a single entry is currently supported.                                                                                                                                                                                               |               |
| plugins_file    | Path for a `plugins` configuration file. A _plugins_ configuration file allows the definition of paths for external plugins; for an example, [see here](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf).                                                         |               |
| streams_file    | Path for the Stream Processor configuration file. To learn more about Stream Processing configuration go [here](../../../stream-processing/introduction.md).                                                                                                                                               |               |
| http_server     | Enable built-in HTTP Server                                                                                                                                                                                                                                                                             | Off           |
| http_listen     | Set listening interface for HTTP Server when it's enabled                                                                                                                                                                                                                                               | 0.0.0.0       |
| http_port       | Set TCP Port for the HTTP Server                                                                                                                                                                                                                                                                        | 2020          |
| coro_stack_size | Set the coroutines stack size in bytes. The value must be greater than the page size of the running system. Don't set too small a value (say 4096), or coroutine threads can overrun the stack buffer. Do not change the default value of this parameter unless you know what you are doing.            | 24576         |
| scheduler.cap   | Set a maximum retry time in seconds. The property is supported from v1.8.7.                                                                                                                                                                                                                             | 2000          |
| scheduler.base  | Sets the base of exponential backoff. The property is supported from v1.8.7.                                                                                                                                                                                                                          | 5             |
| json.convert_nan_to_null | If enabled, NaN is converted to null when fluent-bit converts msgpack to json.    | false         |
| sp.convert_from_str_to_num | If enabled, Stream processor converts from number string to number type.        | true          |
| max\_stdio | If specified, the limit of stdio is adjusted. Only provided for Windows. From 512 to 2048 is allowed. | 512 |

The following is an example of a _service_ section:

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug
```

For scheduler and retry details, please check there: [scheduling and retries](../../scheduling-and-retries.md#Scheduling-and-Retries)

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

Each of the subsections for _inputs_, _filters_ and _outputs_ constitutes an array of maps that has the parameters for each. Most properties are either simple strings or numbers so can be define directly, ie:

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

This pipeline consists of two _inputs_; a tail plugin and an http server plugin. Each plugin has its own map in the array of _inputs_ consisting of simple properties. To use more advanced properties that consist of multiple values the property itself can be defined using an array, ie: the _record_ and _allowlist_key_ properties for the _record_modifier_ _filter_:

```
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

In the cases where each value in a list requires two values they must be separated by a space, such as in the _record_ property for the _record_modifier_ filter.

### Input <a href="config_input" id="config_input"></a>

An _input_ section defines a source (related to an input plugin). Here we will describe the base configuration for each _input_ section. Note that each input plugin may add it own configuration keys:

| Key         | Description                                                                                                                                             |
| ----------- |-------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Name        | Name of the input plugin. Defined as subsection of the _inputs_ section.                                                                                |
| Tag         | Tag name associated to all records coming from this plugin.                                                                                             |
| Log_Level   | Set the plugin's logging verbosity level. Allowed values are: off, error, warn, info, debug and trace. Defaults to the _SERVICE_ section's _Log_Level._ |

The _Name_ is mandatory and it lets Fluent Bit know which input plugin should be loaded. The _Tag_ is mandatory for all plugins except for the _input forward_ plugin (as it provides dynamic tags).

#### Example input

The following is an example of an _input_ section for the _cpu_ plugin.

```yaml
pipeline:
    inputs:
        - name: cpu
          tag: my_cpu
```

### Filter <a href="config_filter" id="config_filter"></a>

A _filter_ section defines a filter (related to a filter plugin). Here we will describe the base configuration for each _filter_ section. Note that each filter plugin may add its own configuration keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| Name        | Name of the filter plugin. Defined as a subsection of the _filters_ section. |
| Match       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (\*) character as a wildcard. |
| Match_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax. |
| Log_Level   | Set the plugin's logging verbosity level. Allowed values are: off, error, warn, info, debug and trace. Defaults to the _SERVICE_ section's _Log_Level._ |

The _Name_ is mandatory and it lets Fluent Bit know which filter plugin should be loaded. The _Match_ or _Match_Regex_ is mandatory for all plugins. If both are specified, _Match_Regex_ takes precedence.

#### Example filter

The following is an example of a _filter_ section for the grep plugin:

```yaml
pipeline:
    filters:
        - name: grep
          match: '*'
          regex: log aa
```

### Output <a href="config_output" id="config_output"></a>

The _outputs_ section specify a destination that certain records should follow after a Tag match. Currently, Fluent Bit can route up to 256 _OUTPUT_ plugins. The configuration supports the following keys:

| Key         | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| Name        | Name of the output plugin. Defined as a subsection of the _outputs_ section. |
| Match       | A pattern to match against the tags of incoming records. It's case-sensitive and supports the star (\*) character as a wildcard. |
| Match_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax. |
| Log_Level   | Set the plugin's logging verbosity level. Allowed values are: off, error, warn, info, debug and trace. The output log level defaults to the _SERVICE_ section's _Log_Level._ |

#### Example output

The following is an example of an _output_ section:

```yaml
pipeline:
    outputs:
        - name: stdout
          match: 'my*cpu'
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
        - name: cpu
          tag: my_cpu
    outputs:
        - name: stdout
          match: 'my*cpu'
```

## Processors <a href="config_processors" id="config_processors"></a>

In recent versions of Fluent-Bit, the input and output plugins can run in separate threads. In Fluent-Bit 2.1.2, we have implemented a new interface called "processor" to extend the processing capabilities in input and output plugins directly without routing the data. This interface allows users to apply data transformations and filtering to incoming data records before they are processed further in the pipeline.

This functionality is only exposed in YAML configuration and not in classic configuration mode due to the restriction of nested levels of configuration.

[Processor example](configuration-file.md#example-using-processors)

### Example: Using processors.

The following configuration file example demonstrates the use of processors to change the log record in the input plugin section by adding a new key "hostname" with the value "monox", and we use lua to append the tag to the log record. Also in the ouput plugin section we added a new key named "output" with the value "new data". All these without the need of routing the logs further in the pipeline.

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
