# Networking

[Fluent Bit](https://fluentbit.io) implements a unified networking interface that's
exposed to components like plugins. This interface abstracts the complexity of
general I/O and is fully configurable.

A common use case is when a component or plugin needs to connect with a service to send
and receive data. There are many challenges to handle like unresponsive services,
networking latency, or any kind of connectivity error. The networking interface aims
to abstract and simplify the network I/O handling, minimize risks, and optimize
performance.

## Networking concepts

Fluent Bit uses the following networking concepts:

### TCP connect timeout

Typically, creating a new TCP connection to a remote server is straightforward
and takes a few milliseconds. However, there are cases where DNS resolving, a slow
network, or incomplete TLS handshakes might create long delays, or incomplete
connection statuses.

- `net.connect_timeout` lets you configure the maximum time to wait for a connection
  to be established. This value already considers the TLS handshake process.

- `net.connect_timeout_log_error` indicates if an error should be logged in case of
  connect timeout. If disabled, the timeout is logged as a debug level message.

### TCP source address

On environments with multiple network interfaces, you can choose which
interface to use for Fluent Bit data that will flow through the network.

Use `net.source_address` to specify which network address to use for a TCP connection
and data flow.

### Connection keepalive

A connection keepalive refers to the ability of a client to keep the TCP connection
open in a persistent way. This feature offers many benefits in terms
of performance because communication channels are always established beforehand.

Any component that uses TCP channels like HTTP or [TLS](transport-security.md), can
take use feature. For configuration purposes use the `net.keepalive`
property.

### Connection keepalive idle timeout

If a connection keepalive is enabled, there might be scenarios where the connection
can be unused for long periods of time. Unused connections can be removed. To control
how long a keepalive connection can be idle, Fluent Bit uses a configuration property
called `net.keepalive_idle_timeout`.

### DNS mode

The global `dns.mode` value issues DNS requests using the specified protocol, either
TCP or UDP. If a transport layer protocol is specified, plugins that configure the
`net.dns.mode` setting override the global setting.

### Maximum connections per worker

For optimal performance, Fluent Bit tries to deliver data quickly and create
TCP connections on-demand and in keepalive mode. In highly scalable
environments, you might limit how many connections are created in
parallel.

Use the `net.max_worker_connections` property in the output plugin section to set
the maximum number of allowed connections. This property acts at the worker level.
For example, if you have five workers and `net.max_worker_connections` is set
to 10, a maximum of 50 connections is allowed. If the limit is reached, the output
plugin issues a retry.

## Configuration options

The following table describes the network configuration properties available and
their usage in optimizing performance or adjusting configuration needs for plugins
that rely on networking I/O:

| Property | Description | Default |
| :------- |:------------|:--------|
| `net.connect_timeout` | Set maximum time expressed in seconds to wait for a TCP connection to be established, including the TLS handshake time. | `10` |
| `net.connect_timeout_log_error` | On connection timeout, specify if it should log an error. When disabled, the timeout is logged as a debug message. | `true` |
| `net.dns.mode` | Select the primary DNS connection type (TCP or UDP). Can be set in the `[SERVICE]` section and overridden on a per plugin basis if desired. | _none_ |
| `net.dns.prefer_ipv4` | Prioritize IPv4 DNS results when trying to establish a connection. | `false` |
| `net.dns.resolver`| Select the primary DNS resolver type (`LEGACY` or `ASYNC`). | _none_ |
| `net.keepalive` | Enable or disable connection keepalive support. Accepts a Boolean value: `on` or `off`.  | `on` |
| `net.keepalive_idle_timeout` | Set maximum time expressed in seconds for an idle keepalive connection. | `30` |
| `net.keepalive_max_recycle` | Set maximum number of times a keepalive connection can be used before it's retired. | `2000` |
| `net.max_worker_connections` | Set maximum number of TCP connections that can be established per worker. | `0` (unlimited) |
| `net.source_address` | Specify network address to bind for data traffic. | _none_ |

## Example

This example sends five random messages through a TCP output connection. The remote
side uses the `nc` (netcat) utility to see the data.

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
nc -l 9090
```

Start Fluent Bit with the configuration file you defined previously to see
data flowing to netcat:

```text
$ nc -l 9090
{"date":1587769732.572266,"rand_value":9704012962543047466}
{"date":1587769733.572354,"rand_value":7609018546050096989}
{"date":1587769734.572388,"rand_value":17035865539257638950}
{"date":1587769735.572419,"rand_value":17086151440182975160}
{"date":1587769736.572277,"rand_value":527581343064950185}
```

If the `net.keepalive` option isn't enabled, Fluent Bit closes the TCP connection
and netcat quits.

After the five records arrive, the connection idles. After 10 seconds, the connection
closes due to `net.keepalive_idle_timeout`.
