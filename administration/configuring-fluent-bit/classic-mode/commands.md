# Commands

Configuration files must be flexible enough for any deployment need, but they must keep a clean and readable format.

Fluent Bit `Commands` extends a configuration file with specific built-in features. The following commands are available:

| Command | Prototype | Description |
| :--- | :--- | :--- |
| [`@INCLUDE`](#include) | `@INCLUDE FILE` | Include a configuration file. |
| [`@SET`](#set) | `@SET KEY=VAL` | Set a configuration variable. |

## `@INCLUDE`

Configuring a logging pipeline might lead to an extensive configuration file. In order to maintain a human-readable configuration, split the configuration in multiple files.

The `@INCLUDE` command allows the configuration reader to include an external configuration file:

```text
[SERVICE]
    Flush 1

@INCLUDE inputs.conf
@INCLUDE outputs.conf
```

This example defines the main service configuration file and also includes two files to continue the configuration.

Fluent Bit will respects the following order when including:

- Service
- Inputs
- Filters
- Outputs

### `inputs.conf`

The following is an example of an `inputs.conf` file, like the one called in the previous example.

```text
[INPUT]
    Name cpu
    Tag  mycpu

[INPUT]
    Name tail
    Path /var/log/*.log
    Tag  varlog.*
```

### `outputs.conf`

The following is an example of an `outputs.conf` file, like the one called in the previous example.

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

## `@SET`

Fluent Bit supports [configuration variables](variables.md). One way to expose this variables to Fluent Bit is through setting a shell environment variable, the other is through the `@SET` command.

The `@SET` command can only be used at root level of each line. It can't be used inside a section:

```text
// DO NOT USE
@SET my_input=cpu
@SET my_output=stdout

[SERVICE]
    Flush 1

[INPUT]
    Name ${my_input}

[OUTPUT]
    Name ${my_output}
```
