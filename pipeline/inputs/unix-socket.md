---
description: Receive records from a Unix domain socket
---

# Unix socket

The _Unix socket_ input plugin lets you receive structured JSON or raw messages from a Unix domain socket. Unix domain sockets provide efficient inter-process communication on the same host, typically offering better performance than TCP/IP sockets for local communication.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:--- |:----------- |:------- |
| `socket_path` | Path to the Unix domain socket file. Fluent Bit will create and listen on this socket file. If the file already exists, it will be removed before creating the new socket. | _none_ |
| `socket_mode` | Unix socket mode. Supported values: `STREAM` (connection-oriented, similar to TCP) or `DGRAM` (datagram-oriented, similar to UDP). | `STREAM` |
| `socket_permissions` | Set the permissions for the Unix socket file. Specify as an octal string (for example, `0666` or `0600`). | _none_ |
| `format` | Specify the expected payload format. Supported values: `json` and `none`. When set to `json` it expects JSON maps. When set to `none`, every record splits using the defined `separator`. | `json` |
| `separator` | When `format` is set to `none`, Fluent Bit needs a separator string to split the records. You can use escape sequences like `\n` for newline. | `\n` (newline) |
| `chunk_size` | The default buffer to store incoming messages. It doesn't allocate the maximum memory allowed; instead it allocates memory when required. The rounds of allocations are set by `chunk_size` in KB. | `32` |
| `buffer_size` | Specify the maximum buffer size in KB to receive a message. If not set, the default is the value of `chunk_size`. | `chunk_Size` (value) |

## Get started

You can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for messages on a Unix socket with the following options:

```shell
fluent-bit -i unix_socket -o stdout
```

By default, the plugin expects a `socket_path` parameter. You can specify it:

```shell
fluent-bit -i unix_socket -p socket_path=/tmp/fluent-bit.sock -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/fluent-bit.sock
      format: json
      chunk_size: 32
      buffer_size: 64

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name           unix_socket
  socket_path    /tmp/fluent-bit.sock
  format         json
  chunk_size     32
  buffer_size    64

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

## Socket modes

### `STREAM` mode

`STREAM` mode provides connection-oriented communication, similar to `TCP`. This mode:

- Accepts multiple client connections
- Provides reliable, ordered delivery of records
- Maintains persistent connections with clients
- Is suitable for most use cases where you need reliable delivery

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/fluent-bit.sock
      socket_mode: STREAM
      format: json
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        unix_socket
  socket_path /tmp/fluent-bit.sock
  socket_mode STREAM
  format      json
```

{% endtab %}
{% endtabs %}

### `DGRAM` mode

`DGRAM` mode provides datagram-oriented communication, similar to `UDP`. This mode:

- Receives records as individual datagrams
- Does not maintain persistent connections
- May be faster for high-throughput scenarios
- Is suitable for scenarios where connection state is not needed

Example configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/fluent-bit.sock
      socket_mode: DGRAM
      format: json
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        unix_socket
  socket_path /tmp/fluent-bit.sock
  socket_mode DGRAM
  format      json
```

{% endtab %}
{% endtabs %}

## Input formats

### `JSON` format

When `Format` is set to `json`, the plugin expects `JSON` map objects. Each `JSON` object becomes a record:

```json
{"key1": "value1", "key2": 123}
{"key1": "value2", "key2": 456}
```

### None format

When `Format` is set to `none`, the plugin treats incoming data as raw text and splits records using the `Separator` parameter. This avoids `JSON` parsing overhead and can provide better performance.

Example with newline separator:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/fluent-bit.sock
      format: none
      separator: "\n"
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        unix_socket
  socket_path /tmp/fluent-bit.sock
  format      none
  separator   \n
```

{% endtab %}
{% endtabs %}

## Socket permissions

You can control the permissions of the Unix socket file using the `socket_permissions` parameter. This restricts access to the socket:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/fluent-bit.sock
      socket_permissions: "0600"
      format: json
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name              unix_socket
  socket_path       /tmp/fluent-bit.sock
  socket_permissions 0600
  format            json
```

{% endtab %}
{% endtabs %}

The permissions are specified as an octal string. Common values:
- `0600`: Read/write for owner only
- `0666`: Read/write for all users
- `0644`: Read/write for owner, read for others

## Example usage

### Example 1: Receiving `JSON` messages

This example listens on a Unix socket and receives `JSON` messages:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/app-logs.sock
      format: json
      chunk_size: 64
      buffer_size: 128

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        unix_socket
  socket_path /tmp/app-logs.sock
  Format      json
  chunk_size  64
  buffer_size 128

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

### Example 2: High-throughput with `DGRAM` mode

For high-throughput scenarios using datagram mode:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: unix_socket
      socket_path: /tmp/high-throughput.sock
      socket_mode: DGRAM
      format: none
      separator: "\n"
      chunk_size: 128
      buffer_size: 256

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        unix_socket
  socket_path /tmp/high-throughput.sock
  socket_mode DGRAM
  Format      none
  Separator   \n
  chunk_size  128
  buffer_size 256

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

### Example 3: Testing with `socat`

You can test the Unix socket input using `socat` to send data:

1. Start Fluent Bit:

```shell
fluent-bit -i unix_socket -p socket_path=/tmp/test.sock -o stdout -f 1
```

2. In another terminal, send `JSON` messages using `socat`:

```shell
echo '{"message": "test", "level": "info"}' | socat - UNIX-CONNECT:/tmp/test.sock
```

You should see output similar to:

```text
[0] unix_socket.0: [1644834856.905985, {"message"=>"test", "level"=>"info"}]
```

## Performance considerations

- When receiving payloads in `JSON` format, there are high performance penalties. Parsing `JSON` is a very expensive task so you could expect your CPU usage to increase under high load environments.
- To get faster data ingestion, consider using the option `Format none` to avoid `JSON` parsing if not needed.
- Unix domain sockets provide lower latency and higher throughput than `TCP/IP` sockets for local communication.
- `STREAM` mode maintains connection state and may use more resources than `DGRAM` mode for high-throughput scenarios.

## Platform support

The Unix socket input plugin is available on Unix-like operating systems, including:
- Linux
- macOS (Darwin)

Unix domain sockets are not available on Windows.

## Notes

- The socket file is created automatically when Fluent Bit starts. If the file already exists, it will be removed before creating the new socket.
- Ensure the directory containing the socket file exists and Fluent Bit has write permissions to create the socket file.
- The socket path length is limited by the operating system (typically 108 characters on Linux, 104 characters on macOS).
- Unix domain sockets only work for communication between processes on the same host.
- When using `STREAM` mode, the plugin can handle multiple concurrent client connections.
- The `socket_permissions` parameter only affects the socket file permissions, not the directory permissions.
