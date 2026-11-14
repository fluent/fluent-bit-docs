# Syslog

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Syslog_ input plugin lets you collect `syslog` messages through a Unix socket server (UDP or TCP) or over the network using TCP or UDP.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                   | Description                                                                                                                                                                                                                                                                       | Default              |
|:----------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------|
| `buffer_chunk_size`   | Set the buffer size to store incoming `syslog` messages. Memory is allocated on demand in chunks of this size. In `udp` or `unix_udp` mode, this also sets the maximum message size. Must be between `2` and `2147483647` bytes.                                                  | `32768`              |
| `buffer_max_size`     | Specify the maximum buffer size to receive a `syslog` message. If not set, or set to `0`, the value of `buffer_chunk_size` is used. Must be between `0` and `2147483647` bytes.                                                                                                   | _none_               |
| `format`              | Specify the TCP framing format. Set to `octet_counting` for RFC 6587 compliant octet-counting framing, or `newline` for newline-delimited framing. Only applies to TCP modes (`tcp` or `unix_tcp`). In v5.1.3 or later, an invalid `octet_counting` length closes the connection. | `newline`            |
| `listen`              | If `mode` is set to `tcp` or `udp`, specify the network interface to bind.                                                                                                                                                                                                        | `0.0.0.0`            |
| `mode`                | Defines transport protocol mode: UDP over Unix socket (`unix_udp`), TCP over Unix socket (`unix_tcp`), `tcp`, or `udp`                                                                                                                                                            | `unix_udp`           |
| `parser`              | Specify an alternative parser for the message. If `mode` is set to `tcp` or `udp`, the default parser is `syslog-rfc5424`. Otherwise, `syslog-rfc3164-local` is used. If your syslog messages have fractional seconds, set this parser value to `syslog-rfc5424` instead.     | _none_               |
| `path`                | If `mode` is set to `unix_tcp` or `unix_udp`, set the absolute path to the Unix socket file.                                                                                                                                                                                      | _none_               |
| `port`                | If `mode` is set to `tcp` or `udp`, specify the port to listen for incoming messages.                                                                                                                                                                                          | `5140`               |
| `raw_message_key`     | Specify the key where the original raw `syslog` message will be preserved.                                                                                                                                                                                                        | _none_               |
| `receive_buffer_size` | Specify the maximum socket receive buffer size. If not set, the default value is OS-dependent, but generally too low to accept thousands of syslog messages per second without loss on `udp` or `unix_udp` sockets. On Linux, the value is capped by `sysctl net.core.rmem_max`.  | _none_               |
| `source_address_key`  | Specify the key where the source address will be injected.                                                                                                                                                                                                                        | _none_               |
| `threaded`            | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                           | `false`              |
| `unix_perm`           | If `mode` is set to `unix_tcp` or `unix_udp`, set the permissions of the Unix socket file as an octal value. See [Unix socket files](#unix-socket-files).                                                                                                                         | `0644`               |

### Considerations

- When using the Syslog input plugin, Fluent Bit requires access to the parsers configuration file. The path to this file can be specified with the option `-R` or through the `parsers_file` key in the service section.
- When using `udp` or `unix_udp`, the buffer size to receive messages is configurable only through the `buffer_chunk_size` option, which defaults to 32,768 bytes.
- In v5.1.3 or later, when using `tcp` or `unix_tcp` with `newline` framing, empty lines are ignored and don't produce records.
- `buffer_chunk_size` and `buffer_max_size` use decimal [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes), so `32KB` is 32,000 bytes.
- In `tcp` and `unix_tcp` modes, each connection buffer starts at `buffer_chunk_size` and grows in steps of `buffer_chunk_size` only while it stays within `buffer_max_size`. The largest message a connection accepts is therefore limited by the largest multiple of `buffer_chunk_size` that doesn't exceed `buffer_max_size`, and is never smaller than `buffer_chunk_size`, even if `buffer_max_size` is smaller. To enforce `buffer_max_size` exactly, set it to a multiple of `buffer_chunk_size`.
- In v5.2 or later, Fluent Bit fails to start if `buffer_chunk_size` or `buffer_max_size` is invalid or outside its valid range, and logs `buffer_chunk_size must be between 2 and 2147483647 bytes` or `buffer_max_size must be between 0 and 2147483647 bytes`.

### Unix socket files

In `unix_tcp` and `unix_udp` modes, Fluent Bit checks `path` before it creates the socket:

- In v5.2 or later, if `path` is longer than the operating system allows for a Unix socket path, which is 107 bytes on Linux and 103 bytes on macOS, startup fails with `configured unix socket path is too long`. Earlier versions silently truncated the path.
- If a Unix socket already exists at `path`, Fluent Bit removes it and creates a new one, even if another process is still listening on it. If Fluent Bit can't check or remove the existing file, startup fails with `could not remove existing unix socket <path>. Aborting`.
- If anything else exists at `path`, startup fails with `<path> exists and it is not a unix socket. Aborting`. In v5.2 or later, this includes any symbolic link, even one that points to a socket. Earlier versions followed symbolic links, so a link to a socket was replaced with a new socket. If `path` is a symbolic link, for example `/dev/log` on many systemd-based systems, point `path` at a regular location before you upgrade. Applications that write to the old path don't follow the change, so either configure them to use the new socket or forward their messages to it, for example with [`rsyslog`](#rsyslog-to-fluent-bit-unix-socket-mode-over-udp).

In v5.2 or later, Fluent Bit creates the socket in a temporary directory named `.fb-` followed by six random characters, in the same directory as `path`. It sets the socket permissions to `unix_perm`, renames the socket to `path`, and removes the temporary directory. The socket never appears at `path` with other permissions. If Fluent Bit stops during this step, the temporary directory can remain and is safe to delete. If Fluent Bit can't create the directory or set the permissions, startup fails with a `could not create staging directory` or `cannot set permission on` error.

Fluent Bit reads `unix_perm` as an octal number and ignores everything from the first character that isn't an octal digit, without logging an error. For example, `rw-r--r--` results in permissions `0000`. A leading `+` or `-` sign is also accepted and the result is masked to `07777`, so `-1` results in `07777`, which lets every local user write to the socket. Use an unsigned octal value such as `0660`.

Clients need write permission on the socket to send messages. With the default `0644`, only the user that runs Fluent Bit and privileged processes, such as an `rsyslog` daemon running as `root`, can send messages. Grant more access only when a client needs it, preferably with a shared group and `0660`. A value such as `0666` lets any local user that can reach the socket's directory send messages, including forged ones.

## Get started

To receive `syslog` messages, you can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can let Fluent Bit listen for Syslog messages with the following options:

```shell
# For YAML configuration
./fluent-bit -R /path/to/parsers.yaml -i syslog -p path=/tmp/in_syslog -o stdout

# For classic configuration.
./fluent-bit -R /path/to/parsers.conf -i syslog -p path=/tmp/in_syslog -o stdout
```

With these options, Fluent Bit creates and listens for Syslog messages on the Unix socket `/tmp/in_syslog`, using the default `unix_udp` mode.

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info

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

Then run Fluent Bit using the following command:

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

#### Fluent Bit configuration [#config-tcp]

Put the following content in your configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1

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

#### `rsyslog` configuration [#rsyslog-tcp]

Add a new file to your `rsyslog` configuration rules called `60-fluent-bit.conf` inside the directory `/etc/rsyslog.d/` and add the following content:

```text
action(type="omfwd" Target="127.0.0.1" Port="5140" Protocol="tcp")
```

Then, restart your `rsyslog` daemon:

```shell
sudo service rsyslog restart
```

### `rsyslog` to Fluent Bit: Unix socket mode over UDP

#### Fluent Bit configuration [#config-udp]

Put the following content in your Fluent Bit configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1

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

#### `rsyslog` configuration [#rsyslog-udp]

Add a new file to your `rsyslog` configuration rules called `60-fluent-bit.conf` inside the directory `/etc/rsyslog.d/` containing the following content:

```text
$ModLoad omuxsock
$OMUxSockSocket /tmp/fluent-bit.sock
*.* :omuxsock:
```

Make sure that `rsyslog` can write to the socket file. An `rsyslog` daemon running as `root` can write to the default `0644` socket. If `rsyslog` runs as a different, unprivileged user, give the socket a group that `rsyslog` belongs to and set `unix_perm` to `0660`. See [Unix socket files](#unix-socket-files).
