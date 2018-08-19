# TCP

The **tcp** input plugin allows to listen for JSON messages through a network interface \(TCP port\).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Listen | Listener network interface, default: 0.0.0.0. |
| Port | TCP port where listening for connections, default: 5170. |
| Buffer\_Size | Specify the maximum buffer size in KB to receive a JSON message. If not set, the default size will be the value of _Chunk\_Size_. |
| Chunk\_Size | By default the buffer to store the incoming JSON messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Chunk\_Size_ in KB. If not set, _Chunk\_Size_ is equal to 32 \(32KB\). |

## Getting Started

In order to receive JSON messages over TCP, you can run the plugin from the command line or through the configuration file:

### Command Line

From the command line you can let Fluent Bit listen for _JSON_ messages with the following options:

```bash
$ fluent-bit -i tcp -o stdout
```

By default the service will listen an all interfaces \(0.0.0.0\) through TCP port 5170, optionally you can change this directly, e.g:

```bash
$ fluent-bit -i tcp://192.168.3.2:9090 -o stdout
```

In the example the JSON messages will only arrive through network interface under 192.168.3.2 address and TCP Port 9090.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name        tcp
    Listen      0.0.0.0
    Port        5170
    Chunk_Size  32
    Buffer_Size 64

[OUTPUT]
    Name   stdout
    Match  *
```

## Testing

Once Fluent Bit is running, you can send some messages using the _netcat_:

```bash
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | nc 127.0.0.1 5170
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -i tcp -o stdout
Fluent-Bit v0.11.0
Copyright (C) Treasure Data

[2017/01/02 10:57:44] [ info] [engine] started
[2017/01/02 10:57:44] [ info] [in_tcp] binding 0.0.0.0:5170
[0] tcp.0: [1483376268, {"msg"=>{"key 1"=>123456789, "key 2"=>"abcdefg"}}]
```

