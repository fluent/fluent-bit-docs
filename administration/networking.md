# Networking

[Fluent Bit](https://fluentbit.io) implements a unified networking interface that is exposed to components like plugins. This interface abstract all the complexity of general I/O and is fully configurable.

A common use case is when a component or plugin needs to connect to a service to send and receive data. Despite the operational mode sounds easy to deal with, there are many factors that can make things hard like unresponsive services, networking latency or any kind of connectivity error. The networking interface aims to abstract and simplify the network I/O handling, minimize risks and optimize performance.

## Concepts

### TCP Connect Timeout

Most of the time creating a new TCP connection to a remote server is straightforward and takes a few milliseconds. But there are cases where DNS resolving, slow network or incomplete TLS handshakes might create long delays, or incomplete connection statuses.

The `net.connect_timeout` allows to configure the maximum time to wait for a connection to be established, note that this value already considers the TLS handshake process.

The `net.connect_timeout_log_error` indicates if an error should be logged in case of connect timeout. If disabled, the timeout is logged as debug level message instead.

### TCP Source Address

On environments with multiple network interfaces, might be desired to choose which interface to use for our data that will flow through the network.

The `net.source_address` allows to specify which network address must be used for a TCP connection and data flow.

### Connection Keepalive

TCP is a _connected oriented_ channel, to deliver and receive data from a remote end-point in most of cases we use a TCP connection. This TCP connection can be created and destroyed once is not longer needed, this approach has pros and cons, here we will refer to the opposite case: keep the connection open.

The concept of `Connection Keepalive` refers to the ability of the client \(Fluent Bit on this case\) to keep the TCP connection open in a persistent way, that means that once the connection is created and used, instead of close it, it can be recycled. This feature offers many benefits in terms of performance since communication channels are always established before hand.

Any component that uses TCP channels like HTTP or [TLS](security.md), can take advantage of this feature. For configuration purposes use the `net.keepalive` property.

### Connection Keepalive Idle Timeout

If a connection is keepalive enabled, there might be scenarios where the connection can be unused for long periods of time. Having an idle keepalive connection is not helpful and is recommendable to keep them alive if they are used.

In order to control how long a keepalive connection can be idle, we expose the configuration property called `net.keepalive_idle_timeout`.

### DNS mode

If a transport layer protocol is specified, the plugin whose configuration section the `net.dns.mode` setting is specified on overrides the global `dns.mode` value and issues DNS requests using the specified protocol which can be either TCP or UDP

## Configuration Options

For plugins that rely on networking I/O, the following section describes the network configuration properties available and how they can be used to optimize performance or adjust to different configuration needs:

| Property | Description | Default |
| :--- | :--- | :--- |
| `net.connect_timeout` | Set maximum time expressed in seconds to wait for a TCP connection to be established, this include the TLS handshake time. | 10 |
| `net.connect_timeout_log_error` | On connection timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message. | true |
| `net.dns.mode` | Select the primary DNS connection type (TCP or UDP). Can be set in the [SERVICE] section and overridden on a per plugin basis if desired. |  |
| `net.dns.prefer_ipv4` |  Prioritize IPv4 DNS results when trying to establish a connection. | false |
| `net.dns.resolver`| Select the primary DNS resolver type (LEGACY or ASYNC). | |
| `net.keepalive` | Enable or disable connection keepalive support. Accepts a boolean value: on / off. | on |
| `net.keepalive_idle_timeout` | Set maximum time expressed in seconds for an idle keepalive connection. | 30 |
| `net.keepalive_max_recycle` | Set maximum number of times a keepalive connection can be used before it is retired. | 2000 |
| `net.source_address` | Specify network address to bind for data traffic. |  |

## Example

As an example, we will send 5 random messages through a TCP output connection, in the remote side we will use `nc` \(netcat\) utility to see the data.

Put the following configuration snippet in a file called `fluent-bit.conf`:

```text
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      random
    samples   5

[OUTPUT]
    name      tcp
    match     *
    host      127.0.0.1
    port      9090
    format    json_lines
    # Networking Setup
    net.dns.mode                TCP
    net.connect_timeout         5
    net.source_address          127.0.0.1
    net.keepalive               on
    net.keepalive_idle_timeout  10
```

In another terminal, start `nc` and make it listen for messages on TCP port 9090:

```text
$ nc -l 9090
```

Now start Fluent Bit with the configuration file written above and you will see the data flowing to netcat:

```text
$ nc -l 9090
{"date":1587769732.572266,"rand_value":9704012962543047466}
{"date":1587769733.572354,"rand_value":7609018546050096989}
{"date":1587769734.572388,"rand_value":17035865539257638950}
{"date":1587769735.572419,"rand_value":17086151440182975160}
{"date":1587769736.572277,"rand_value":527581343064950185}
```

If the `net.keepalive` option is not enabled, Fluent Bit will close the TCP connection and netcat will quit, here we can see how the keepalive connection works.

After the 5 records arrive, the connection will keep idle and after 10 seconds it will be closed due to `net.keepalive_idle_timeout`.
