# Standard Output Filter

The _Standard Output Filter_ plugin allows to print to the standard output the data received through the _input_ plugin.

## Configuration Parameters

There are no parameters.

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.

### Command Line

```
$ fluent-bit -i cpu -t cpu.local -F stdout -m '*' -o null -m '*'
```

### Configuration File

In your main configuration file append the following _FILTER_ sections:

```python
[INPUT]
    Name cpu
    Tag  cpu.local

[FILTER]
    Name  stdout
    Match *

[OUTPUT]
    Name  null
    Match *
```