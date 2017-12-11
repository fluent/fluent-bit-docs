# Configuration File

There are some cases where using the command line to start Fluent Bit is not ideal for some scenarios, when running it as a service a configuration file it's times better.

Fluent Bit allows to use one configuration file which works at a global scope and uses the [schema](configuration_schema.md) defined previously.

The configuration file supports four types of sections:

- [Service](#config_section)
- [Input](#config_input)
- [Filter](#config_filter)
- [Output](#config_output)

In addition there is an additional feature to include external files:

- [Include File](#config_include_file)

## Service {#config_section}

The _Service_ section defines global properties of the service, the keys available as of this version are described in the following table:

| Key             | Description                    | Default Value |
|-----------------|--------------------------------|---------------|
| Flush           | Set the flush time in seconds. Everytime it timeouts, the engine will flush the records to the output plugin.| 5 |
| Daemon          | Boolean value to set if Fluent Bit should run as a Daemon (background) or not. Allowed values are: yes, no, on and off. | Off |
| Log_File        | Absolute path for an optional log file.| |
| Log_Level       | Set the logging verbosity level. Allowed values are: error, info, debug and trace. Values are accumulative, e.g: if 'debug' is set, it will include error, info and debug. Note that _trace_ mode is only available if Fluent Bit was built with the _WITH\_TRACE_ option enabled.| info |
| Parsers_File    | Path for a _parsers_ configuration file. Multiple Parsers\_File entries can be used. | |
| HTTP_Server     | Enable built-in HTTP Server    | Off |
| HTTP_Listen     | Set listening interface for HTTP Server when it's enabled | 0.0.0.0 |
| HTTP_Port       | Set TCP Port for the HTTP Server | 2020 |

### Example

The following is an example of a _SERVICE_ section:

```Python
[SERVICE]
    Flush           5
    Daemon          off
    Log_Level       debug
```

## Input {#config_input}

An _INPUT_ section defines a source (related to an input plugin), here we will describe the base configuration for each _INPUT_ section. Note that each input plugin may add it own configuration keys:

| Key    | Description               |
|--------|---------------------------|
| Name   | Name of the input plugin. |
| Tag    | Tag name associated to all records comming from this plugin. |


The _Name_ is mandatory and it let Fluent Bit know which input plugin should be loaded. The _Tag_ is mandatory for all plugins except for the _input forward_ plugin (as it provides dynamic tags).

### Example

The following is an example of an _INPUT_ section:

```Python
[INPUT]
    Name cpu
    Tag  my_cpu
```

## Filter {#config_filter}

A _FILTER_ section defines a filter (related to an filter plugin), here we will describe the base configuration for each _FILTER_ section. Note that each filter plugin may add it own configuration keys:

| Key    | Description               |
|--------|---------------------------|
| Name   | Name of the filter plugin. |
| Match  | It sets a pattern to match certain records Tag. It's case sensitive and support the start (*) character as a wildcard. | |


The _Name_ is mandatory and it let Fluent Bit know which filter plugin should be loaded. The _Match_ is mandatory for all plugins.

### Example

The following is an example of an _FILTER_ section:

```Python
[FILTER]
    Name  stdout
    Match *
```

## Output {#config_output}

The _OUTPUT_ section specify a destination that certain records should follow after a Tag match. The configuration support the following keys:

| Key    | Description                |
|--------|----------------------------|
| Name   | Name of the output plugin. |
| Match  | It sets a pattern to match certain records Tag. It's case sensitive and support the start (*) character as a wildcard. |

### Example

The following is an example of an _OUTPUT_ section:

```Python
[OUTPUT]
    Name  stdout
    Match my*cpu
```

### Example: collecting CPU metrics

The following configuration file example demonstrates how to collect CPU metrics and flush the results every five seconds to the standard output:

```Python
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

## Include File {#config_include_file}

To avoid complicated long configuration files is better to split specific parts in different files and call them (include) from one main file.

Starting from Fluent Bit 0.12 the new configuration command _@INCLUDE_ has been added and can be used in the following way:

```
@INCLUDE somefile.conf
```

The configuration reader will try to open the path _somefile.conf_, if not found, it will assume it's a relative path based on the path of the base configuration file, e.g:

- Main configuration file path: /tmp/main.conf
- Included file: somefile.conf
- Fluent Bit will try to open somefile.conf, if it fails it will try /tmp/somefile.conf.

The _@INCLUDE_ command only works at top-left level of the configuration line, it cannot be used inside sections.
