# Networking

[Fluent Bit](https://fluentbit.io) implements a unified networking interface that is exposed to components like plugins. This interface abstract all the complexity of general I/O and is fully configurable.

A common use case is when a component or plugin needs to connect to a service to send and receive data. Despite the operational mode sounds easy to deal with, there are many factors that can make things hard like unresponsive services, networking latency or any kind of connectivity error. The networking interface aims to abstract and simplify the network I/O handling, minimize risks and optimize performance.

## Concepts

### TCP Connect Timeout

Most of the time creating a new TCP connection to a remote server is straightforward and takes a few milliseconds. But there are cases where DNS resolving, slow network or incomplete TLS handshakes might create long delays, or incomplete connection statuses.

The `net.connect_timeout` allows to configure the maximum time to wait for a connection to be established, note that this value already considers the TLS handshake process.

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

### TCP Keepalive

An open TCP connection to a remote server is subject to be _silently dropped_ by intermediate equipment in the network \(e.g., routers\) if it's quiet for too long. What _too long_ means depends on manufacturers and configurations outside of the control of fluentbit.

If you're using the _Connection Keepalive_ feature, but not achieving the desired connectivity rates, you might want to try setting `net.tcp_keepalive` to `on`. This will configure the socket to periodically send _keepalive probes_ if the connection is silent. These probes will be sent all the way to the server, making the equipment in between consider the connection as active. Is then expected that the server will acknowledge the probe, allowing fluentbit to detect a broken connection right away.

### TCP Keepalive Time

If TCP keepalive is used, `net.tcp_keepalive_time` allows to override the OS default configuration with the desired period to wait between the last data packet is sent and TCP keepalive probing starts.

### TCP Keepalive Interval

If TCP keepalive is used, `net.tcp_keepalive_interval` allows to override the OS default configuration with the desired period between probes if the first one fails to be acknowledged.

### TCP Keepalive Probes

If TCP keepalive is used, `net.tcp_keepalive_probes` allows to override the OS default configuration with the desired number of unacknowledged probes before deeming a connection dead.

### TCP Keepalive Recycling

If a TCP connection is keepalive enabled and has very high traffic, the connection may _never_ be killed. In a situation where the remote endpoint is load-balanced in some way, this may lead to an unequal distribution of traffic. Setting `net.keepalive_max_recycle` causes keepalive connections to be recycled after a number of messages are sent over that connection. Once this limit is reached, the connection is terminated gracefully, and a new connection will be created for subsequent messages.

## Configuration Options

For plugins that rely on networking I/O, the following section describes the network configuration properties available and how they can be used to optimize performance or adjust to different configuration needs:

| Property | Description | Default |
| :--- | :--- | :--- |
| `net.connect_timeout` | Set maximum time expressed in seconds to wait for a TCP connection to be established, this include the TLS handshake time. | 10 |
| `net.source_address` | Specify network address \(interface\) to use for connection and data traffic. |  |
| `net.keepalive` | Enable or disable connection keepalive support. Accepts a boolean value: on / off. | on |
| `net.keepalive_idle_timeout` | Set maximum time expressed in seconds for an idle keepalive connection. | 30 |
| `net.tcp_keepalive` | Enable or disable TCP keepalive support. Accepts a boolean value: on / off. | off |
| `net.tcp_keepalive_time` | Interval between the last data packet sent and the first TCP keepalive probe. |  |
| `net.tcp_keepalive_interval` | Interval between TCP keepalive probes when no response is received on a keepidle probe. |  |
| `net.tcp_keepalive_probes` | Number of unacknowledged probes to consider a connection dead. |  |
| `net.keepalive_max_recycle` | Set the maximum number of times a keepalive connection can be used before it is destroyed. | 0 |

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

