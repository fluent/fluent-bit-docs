# Configuration Commands

Configuration files must be flexible enough for any deployment need, but they must keep a clean and readable format.

Fluent Bit _Commands_ extends a configuration file with specific built-in features. The list of commands available as of Fluent Bit 0.12 series are:

| Command | Prototype | Description |
| :--- | :--- | :--- |
| [@INCLUDE](commands.md#cmd_include) | @INCLUDE FILE | Include a configuration file |
| [@SET](commands.md#cmd_set) | @SET KEY=VAL | Set a configuration variable |

## @INCLUDE Command <a id="cmd_include"></a>

Configuring a logging pipeline might lead to an extensive configuration file. In order to maintain a human-readable configuration, it's suggested to split the configuration in multiple files.

The @INCLUDE command allows the configuration reader to include an external configuration file, e.g:

```text
[SERVICE]
    Flush 1

@INCLUDE inputs.conf
@INCLUDE outputs.conf
```

The above example defines the main service configuration file and also include two files to continue the configuration:

### inputs.conf

```text
[INPUT]
    Name cpu
    Tag  mycpu

[INPUT]
    Name tail
    Path /var/log/*.log
    Tag  varlog.*
```

### outputs.conf

```text
[OUTPUT]
    Name   stdout
    Match  mycpu

[OUTPUT]
    Name            es
    Match           varlog.*
    Host            127.0.0.1
    Port            9200
    Logstash_Format On
```

Note that despites the order of inclusion, Fluent Bit will **ALWAYS** respect the following order:

* Service
* Inputs
* Filters
* Outputs

## @SET Command <a id="cmd_set"></a>

Fluent Bit supports [configuration variables](variables.md), one way to expose this variables to Fluent Bit is through setting a Shell environment variable, the other is through the _@SET_ command.

The @SET command can only be used at root level of each line, meaning it cannot be used inside a section, e.g:

```text
@SET my_input=cpu
@SET my_output=stdout

[SERVICE]
    Flush 1

[INPUT]
    Name ${my_input}

[OUTPUT]
    Name ${my_output}
```

