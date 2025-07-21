# Syslog

The _Syslog_ input plugin lets you collect `syslog` messages through a Unix socket server (UDP or TCP) or over the network using TCP or UDP.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                   | Description                                                                                                                                                                                                                                                                       | Default              |
|:----------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------|
| `Mode`                | Defines transport protocol mode: UDP over Unix socket (`unix_udp`), TCP over Unix socket (`unix_tcp`), `tcp`, or `udp`                                                                                                                                                            | `unix_udp`           |
| `Listen`              | If `Mode` is set to `tcp` or `udp`, specify the network interface to bind.                                                                                                                                                                                                        | `0.0.0.0`            |
| `Port`                | If `Mode` is set to `tcp` or `udp`, specify the TCP port to listen for incoming connections.                                                                                                                                                                                      | `5140`               |
| `Path`                | If `Mode` is set to `unix_tcp` or `unix_udp`, set the absolute path to the Unix socket file.                                                                                                                                                                                      | _none_               |
| `Unix_Perm`           | If `Mode` is set to `unix_tcp` or `unix_udp`, set the permission of the Unix socket file.                                                                                                                                                                                         | `0644`               |
| `Parser`              | Specify an alternative parser for the message. If `Mode` is set to `tcp` or `udp` then the default parser is `syslog-rfc5424`. Otherwise, `syslog-rfc3164-local` is used. If your syslog` messages have fractional seconds set this parser value to `syslog-rfc5424` instead.     | _none_               |
| `Buffer_Chunk_Size`   | By default, the buffer to store the incoming `syslog` messages. Doesn't allocate the maximum memory allowed, instead it allocates memory when required. The rounds of allocations are set by `Buffer_Chunk_Size`. There are considerations when using `udp` or `unix_udp` mode.   | `32KB` (set in code) |
| `Buffer_Max_Size`     | Specify the maximum buffer size to receive a `syslog` message. If not set, the default size is the value of `Buffer_Chunk_Size`.                                                                                                                                                  | _none_               |
| `Receive_Buffer_Size` | Specify the maximum socket receive buffer size. If not set, the default value is OS-dependant, but generally too low to accept thousands of syslog messages per second without loss on `udp` or `unix_udp` sockets. For Linux, the value is capped by `sysctl net.core.rmem_max`. | _none_               |
| `Source_Address_Key`  | Specify the key where the source address will be injected.                                                                                                                                                                                                                        | _none_               |
| `Threaded`            | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                           | `false`              |

### Considerations

- When using the Syslog input plugin, Fluent Bit requires access to the parsers configuration file. The path to this file can be specified with the option `-R` or through the `parsers_file` key in the service section.
- When using `udp` or `unix_udp`, the buffer size to receive messages is configurable only through the `buffer_chunk_size` option, which defaults to 32kb.

## Get started

To receive `syslog` messages, you can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can let Fluent Bit listen for `Forward` messages with the following options:

```shell
# For YAML configuration
./fluent-bit -R /path/to/parsers.yaml -i syslog -p path=/tmp/in_syslog -o stdout

# For classic configuration.
./fluent-bit -R /path/to/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
```

By default, the service will create and listen for Syslog messages on the Unix socket `/tmp/in_syslog`.

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
  parsers_file: parsers.yaml
    
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
{% tab title="fluent-bit.conf" %}

```text
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
{% endtabs %}

### Testing

When Fluent Bit is running, you can send some messages using the logger tool:

```shell
logger -u /tmp/in_syslog my_ident my_message
```

Then run Fluent bit using the following command:

```shell
# For YAML configuration.
./fluent-bit -R ../conf/parsers.yaml -i syslog -p path=/tmp/in_syslog -o stdout

# For classic configuration.
./fluent-bit -R ../conf/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
```

You should see the following output:

```text
...
[0] syslog.0: [1489047822, {"pri"=>"13", "host"=>"edsiper:", "ident"=>"my_ident", "pid"=>"", "message"=>"my_message"}]
...
```

## Examples

The following configuration examples cover different use cases to integrate Fluent Bit and make it listen for Syslog messages from your systems.

### `rsyslog` to Fluent Bit: Network mode over TCP

#### Fluent Bit configuration

Put the following content in your configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  parsers_file: parsers.yaml
    
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
{% endtabs %}

Then, start Fluent Bit.

#### `rsyslog` configuration

Add a new file to your `rsyslog` configuration rules called `60-fluent-bit.conf` inside the directory `/etc/rsyslog.d/` and add the following content:

```text
action(type="omfwd" Target="127.0.0.1" Port="5140" Protocol="tcp")
```

Then, restart your `rsyslog` daemon:

```shell
sudo service rsyslog restart
```

### `rsyslog` to Fluent Bit: Unix socket mode over UDP

#### Fluent Bit configuration

Put the following content in your Fluent Bit configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  parsers_file: parsers.yaml
    
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
{% endtabs %}

Then, start Fluent Bit.

#### `rsyslog` configuration

Add a new file to your `rsyslog` configuration rules called `60-fluent-bit.conf` inside the directory `/etc/rsyslog.d/` containing the following content:

```text
$ModLoad omuxsock
$OMUxSockSocket /tmp/fluent-bit.sock
*.* :omuxsock:
```

Make sure that the socket file is readable by `rsyslog` by modifying `Unix_Perm` key.