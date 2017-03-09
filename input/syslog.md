# Syslog

_Syslog_ input plugins allows to collect messages using the syslog protocol through a Unix socket server.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         | Description       |
| ------------|-------------------|
| Path        | Absolute path to the Unix socket file. |
| Parser      | Optionally use a different parser for the message. By default Fluent BIt requires access to the parsers.conf file. |
| Buffer\_Size| Specify the maximum buffer size in KB to receive a Syslog message. If not set, the default size will be the value of _Chunk\_Size_. |
| Chunk_Size  | By default the buffer to store the incoming Syslog messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Chunk\_Size_ in KB. If not set, _Chunk\_Size_ is equal to 32 (32KB). |

## Getting Started

In order to receive Syslog messages, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit listen for _Forward_ messages with the following options:

```bash
$ fluent-bit -R /path/to/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
```

By default the service will create and listen for Syslog messages on the unix socket _/tmp/in\_syslog_

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[SERVER]
    Flush        1
    Log_Level    info
    Parsers_File parsers.conf

[INPUT]
    Name         syslog
    Path         /tmp/in_syslog
    Chunk_Size   32
    Buffer_Size  64

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you can send some messages using the _logger_ tool:

```bash
$ logger -u /tmp/in_syslog my_ident my_message
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -R ../conf/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
Fluent-Bit v0.11.0
Copyright (C) Treasure Data

[2017/03/09 02:23:27] [ info] [engine] started
[0] syslog.0: [1489047822, {"pri"=>"13", "host"=>"edsiper:", "ident"=>"my_ident", "pid"=>"", "message"=>"my_message"}]
```
