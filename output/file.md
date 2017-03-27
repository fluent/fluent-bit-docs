# File

The __file__ output plugin allows to write the data received through the _input_ plugin to file. 

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key  | Description |
|------|-------------|
| Path | File path to output. If not set, the filename will be tag name.|

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit count up a data with the following options:

```bash
$ fluent-bit -i cpu -o file -p path=output.txt
```

### Configuration File

In your main configuration file append the following Input & Output sections:

```python
[INPUT]
    Name cpu
    Tag  cpu

[OUTPUT]
    Name file
    Match *
    Path output.txt
```
