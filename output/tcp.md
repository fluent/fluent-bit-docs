# TCP & TLS

The **tcp** output plugin allows to send records to a remote TCP server. The payload can be formatted in different ways as required.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | Target host where Fluent-Bit or Fluentd are listening for Forward messages. | 127.0.0.1 |
| Port | TCP Port of the target service. | 5170 |
| Format | Specify the data format to be printed. Supported formats are _msgpack_ _json_, _json\_lines_ and _json\_stream_. | msgpack |
| json\_date\_key | Specify the name of the date field in output | date |
| json\_date\_format | Specify the format of the date. Supported formats are _double_ , _iso8601_ \(eg: _2018-05-30T09:39:52.000681Z_\) and _epoch_. | double |

## TLS Configuration Parameters

The following parameters are available to configure a secure channel connection through TLS:

| Key | Description | Default |
| :--- | :--- | :--- |
| tls | Enable or disable TLS support | Off |
| tls.verify | Force certificate validation | On |
| tls.debug | Set TLS debug verbosity level. It accept the following values: 0 \(No debug\), 1 \(Error\), 2 \(State change\), 3 \(Informational\) and 4 Verbose | 1 |
| tls.ca\_file | Absolute path to CA certificate file |  |
| tls.crt\_file | Absolute path to Certificate file. |  |
| tls.key\_file | Absolute path to private Key file. |  |
| tls.key\_passwd | Optional password for tls.key\_file file. |  |

### Command Line

```bash
$ bin/fluent-bit -i cpu -o tcp://127.0.0.1:5170 -p format=json_lines -v
```

We have specified to gather [CPU](../input/cpu.md) usage metrics and send them in JSON lines mode to a remote end-point using netcat service, e.g:

#### Start the TCP listener

Run the following in a separate terminal, netcat will start listening for messages on TCP port 5170

```text
$ nc -l 5170
```

Start Fluent Bit

```bash
$ bin/fluent-bit -i cpu -o stdout -p format=msgpack -v
Fluent-Bit v1.2.x
Copyright (C) Treasure Data

[2016/10/07 21:52:01] [ info] [engine] started
[0] cpu.0: [1475898721, {"cpu_p"=>0.500000, "user_p"=>0.250000, "system_p"=>0.250000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>1.000000}]
[1] cpu.0: [1475898722, {"cpu_p"=>0.250000, "user_p"=>0.250000, "system_p"=>0.000000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[2] cpu.0: [1475898723, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>2.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>1.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>1.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[3] cpu.0: [1475898724, {"cpu_p"=>1.000000, "user_p"=>0.750000, "system_p"=>0.250000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>2.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
```

No more, no less, it just works.

