# NULL

The **null** output plugin just throws away events.

## Configuration Parameters

The plugin doesn't support configuration parameters.

## Getting Started

You can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit throws away events with the following options:

```bash
fluent-bit -i cpu -o null
```

### Configuration File

In your main configuration file append the following Input & Output sections:

```python
[INPUT]
    Name cpu
    Tag  cpu

[OUTPUT]
    Name null
    Match *
```

