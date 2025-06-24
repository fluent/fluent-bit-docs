# Syslog

_Syslog_ input plugins allows to collect Syslog messages through a Unix socket server \(UDP or TCP\) or over the network using TCP or UDP.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Mode | Defines transport protocol mode: unix\_udp \(UDP over Unix socket\), unix\_tcp \(TCP over Unix socket\), tcp or udp | unix\_udp |
| Listen | If _Mode_ is set to _tcp_ or _udp_, specify the network interface to bind. | 0.0.0.0 |
| Port | If _Mode_ is set to _tcp_ or _udp_, specify the TCP port to listen for incoming connections. | 5140 |
| Path | If _Mode_ is set to _unix\_tcp_ or _unix\_udp_, set the absolute path to the Unix socket file. |  |
| Unix\_Perm | If _Mode_ is set to _unix\_tcp_ or _unix\_udp_, set the permission of the Unix socket file. | 0644 |
| Parser | Specify an alternative parser for the message. If _Mode_ is set to _tcp_ or _udp_ then the default parser is _syslog-rfc5424_ otherwise _syslog-rfc3164-local_ is used. If your syslog messages have fractional seconds set this Parser value to _syslog-rfc5424_ instead. |  |
| Buffer\_Chunk\_Size | By default the buffer to store the incoming Syslog messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Buffer\_Chunk\_Size_. If not set, _Buffer\_Chunk\_Size_ is equal to 32000 bytes \(32KB\). Read considerations below when using _udp_ or _unix\_udp_ mode. |  |
| Buffer\_Max\_Size | Specify the maximum buffer size to receive a Syslog message. If not set, the default size will be the value of _Buffer\_Chunk\_Size_. |  |
| Receive\_Buffer\_Size | Specify the maximum socket receive buffer size. If not set, the default value is OS-dependant, but generally too low to accept thousands of syslog messages per second without loss on _udp_ or _unix\_udp_ sockets. Note that on Linux the value is capped by `sysctl net.core.rmem_max`.| |
| Source\_Address\_Key| Specify the key where the source address will be injected. | |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

### Considerations

* When using Syslog input plugin, Fluent Bit requires access to the _parsers.conf_ file, the path to this file can be specified with the option _-R_ or through the _Parsers\_File_ key on the \[SERVICE\] section \(more details below\).
* When _udp_ or _unix\_udp_ is used, the buffer size to receive messages is configurable **only** through the _Buffer\_Chunk\_Size_ option which defaults to 32kb.

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

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[SERVICE]
    Flush               1
    Log_Level           info
    Parsers_File        parsers.conf

[INPUT]
    Name                syslog
    Path                /tmp/in_syslog
    Buffer_Chunk_Size   32000
    Buffer_Max_Size     64000
    Receive_Buffer_Size 512000

[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
service:
    flush: 1
    log_level: info
    parsers_file: parsers.conf
pipeline:
    inputs:
        - name: syslog
          path: /tmp/in_syslog
          buffer_chunk_size: 32000
          buffer_max_size: 64000
          receive_buffer_size: 512000
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

### Testing

Once Fluent Bit is running, you can send some messages using the _logger_ tool:

```bash
$ logger -u /tmp/in_syslog my_ident my_message
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -R ../conf/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/03/09 02:23:27] [ info] [engine] started
[0] syslog.0: [1489047822, {"pri"=>"13", "host"=>"edsiper:", "ident"=>"my_ident", "pid"=>"", "message"=>"my_message"}]
```

## Recipes

The following content aims to provide configuration examples for different use cases to integrate Fluent Bit and make it listen for Syslog messages from your systems.

### Rsyslog to Fluent Bit: Network mode over TCP <a id="rsyslog_to_fluentbit_network"></a>

#### Fluent Bit Configuration

Put the following content in your configuration file:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[SERVICE]
    Flush        1
    Parsers_File parsers.conf

[INPUT]
    Name     syslog
    Parser   syslog-rfc3164
    Listen   0.0.0.0
    Port     5140
    Mode     tcp

[OUTPUT]
    Name     stdout
    Match    *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
service:
    flush: 1
    parsers_file: parsers.conf
pipeline:
    inputs:
        - name: syslog
          parser: syslog-rfc3164
          listen: 0.0.0.0
          port: 5140
          mode: tcp
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

then start Fluent Bit.

#### RSyslog Configuration

Add a new file to your rsyslog config rules called _60-fluent-bit.conf_ inside the directory _/etc/rsyslog.d/_ and add the following content:

```text
action(type="omfwd" Target="127.0.0.1" Port="5140" Protocol="tcp")
```

then make sure to restart your rsyslog daemon:

```bash
$ sudo service rsyslog restart
```

### Rsyslog to Fluent Bit: Unix socket mode over UDP

#### Fluent Bit Configuration

Put the following content in your fluent-bit.conf file:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[SERVICE]
    Flush        1
    Parsers_File parsers.conf

[INPUT]
    Name      syslog
    Parser    syslog-rfc3164
    Path      /tmp/fluent-bit.sock
    Mode      unix_udp
    Unix_Perm 0644

[OUTPUT]
    Name      stdout
    Match     *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
service:
    flush: 1
    parsers_file: parsers.conf
pipeline:
    inputs:
        - name: syslog
          parser: syslog-rfc3164
          path: /tmp/fluent-bit.sock
          mode: unix_udp
          unix_perm: 0644
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

then start Fluent Bit.

#### RSyslog Configuration

Add a new file to your rsyslog config rules called _60-fluent-bit.conf_ inside the directory _/etc/rsyslog.d/_ and place the following content:

```text
$ModLoad omuxsock
$OMUxSockSocket /tmp/fluent-bit.sock
*.* :omuxsock:
```

Make sure that the socket file is readable by rsyslog \(tweak the `Unix_Perm` option shown above\).
