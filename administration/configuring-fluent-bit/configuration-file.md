---
description: This page describes the main configuration file used by Fluent Bit
---

# Configuration File

One of the ways to configure Fluent Bit is using a main configuration file. Fluent Bit allows to use one configuration file which works at a global scope and uses the [Format and Schema](format-schema.md) defined previously.

The main configuration file supports four types of sections:

* Service
* Input
* Filter
* Output

In addition, it's also possible to split the main configuration file in multiple files using the feature to include external files:

* Include File

## Service <a id="config_section"></a>

The _Service_ section defines global properties of the service, the keys available as of this version are described in the following table:

| Key | Description | Default Value |
| :--- | :--- | :--- |
| Flush | Set the flush time in `seconds.nanoseconds`. The engine loop uses a Flush timeout to define when is required to flush the records ingested by input plugins through the defined output plugins. | 5 |
| Grace | Set the grace time in `seconds` as Integer value. The engine loop uses a Grace timeout to define wait time on exit | 5 |
| Daemon | Boolean value to set if Fluent Bit should run as a Daemon \(background\) or not. Allowed values are: yes, no, on and off.  note: If you are using a Systemd based unit as the one we provide in our packages, do not turn on this option. | Off |
| Log\_File | Absolute path for an optional log file. By default all logs are redirected to the standard error interface \(stderr\). |  |
| Log\_Level | Set the logging verbosity level. Allowed values are: error, warn, info, debug and trace. Values are accumulative, e.g: if 'debug' is set, it will include error, warning, info and debug.  Note that _trace_ mode is only available if Fluent Bit was built with the _WITH\_TRACE_ option enabled. | info |
| Parsers\_File | Path for a `parsers` configuration file. Multiple Parsers\_File entries can be defined within the section. |  |
| Plugins\_File | Path for a `plugins` configuration file. A _plugins_ configuration file allows to define paths for external plugins, for an example [see here](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf). |  |
| Streams\_File | Path for the Stream Processor configuration file. To learn more about Stream Processing configuration go [here](../../stream-processing/introduction.md). |  |
| HTTP\_Server | Enable built-in HTTP Server | Off |
| HTTP\_Listen | Set listening interface for HTTP Server when it's enabled | 0.0.0.0 |
| HTTP\_Port | Set TCP Port for the HTTP Server | 2020 |
| Coro\_Stack\_Size | Set the coroutines stack size in bytes. The value must be greater than the page size of the running system. Don't set too small value \(say 4096\), or coroutine threads can overrun the stack buffer. Do not change the default value of this parameter unless you know what you are doing. | 24576 |
| scheduler.cap | Set a maximum retry time in second. The property is supported from v1.8.7. |2000|
| scheduler.base | Set a base of exponential backoff. The property is supported from v1.8.7. |5|

The following is an example of a _SERVICE_ section:

```python
[SERVICE]
    Flush           5
    Daemon          off
    Log_Level       debug
```

## Input <a id="config_input"></a>

An _INPUT_ section defines a source \(related to an input plugin\), here we will describe the base configuration for each _INPUT_ section. Note that each input plugin may add it own configuration keys:

| Key | Description |
| :--- | :--- |
| Name | Name of the input plugin. |
| Tag | Tag name associated to all records coming from this plugin. |

The _Name_ is mandatory and it let Fluent Bit know which input plugin should be loaded. The _Tag_ is mandatory for all plugins except for the _input forward_ plugin \(as it provides dynamic tags\).

### Example

The following is an example of an _INPUT_ section:

```python
[INPUT]
    Name cpu
    Tag  my_cpu
```

## Filter <a id="config_filter"></a>

A _FILTER_ section defines a filter \(related to an filter plugin\), here we will describe the base configuration for each _FILTER_ section. Note that each filter plugin may add it own configuration keys:

| Key | Description |  |
| :--- | :--- | :--- |
| Name | Name of the filter plugin. |  |
| Match | A pattern to match against the tags of incoming records. It's case sensitive and support the star \(\*\) character as a wildcard. |  |
| Match\_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax. |  |

The _Name_ is mandatory and it let Fluent Bit know which filter plugin should be loaded. The _Match_ or _Match\_Regex_ is mandatory for all plugins. If both are specified, _Match\_Regex_ takes precedence.

### Example

The following is an example of an _FILTER_ section:

```python
[FILTER]
    Name  stdout
    Match *
```

## Output <a id="config_output"></a>

The _OUTPUT_ section specify a destination that certain records should follow after a Tag match. The configuration support the following keys:

| Key | Description |  |
| :--- | :--- | :--- |
| Name | Name of the output plugin. |  |
| Match | A pattern to match against the tags of incoming records. It's case sensitive and support the star \(\*\) character as a wildcard. |  |
| Match\_Regex | A regular expression to match against the tags of incoming records. Use this option if you want to use the full regex syntax. |  |

### Example

The following is an example of an _OUTPUT_ section:

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

## Visualize <a id="config_include_file"></a>

You can also visualize Fluent Bit INPUT, FILTER, and OUTPUT configuration via [https://config.calyptia.com](https://config.calyptia.com)

![](../../.gitbook/assets/image.png)

## Include File <a id="config_include_file"></a>

To avoid complicated long configuration files is better to split specific parts in different files and call them \(include\) from one main file.

Starting from Fluent Bit 0.12 the new configuration command _@INCLUDE_ has been added and can be used in the following way:

```text
@INCLUDE somefile.conf
```

The configuration reader will try to open the path _somefile.conf_, if not found, it will assume it's a relative path based on the path of the base configuration file, e.g:

* Main configuration file path: /tmp/main.conf
* Included file: somefile.conf
* Fluent Bit will try to open somefile.conf, if it fails it will try /tmp/somefile.conf.

The _@INCLUDE_ command only works at top-left level of the configuration line, it cannot be used inside sections.

Wildcard character \(\*\) is supported to include multiple files, e.g:

```text
@INCLUDE input_*.conf
```

