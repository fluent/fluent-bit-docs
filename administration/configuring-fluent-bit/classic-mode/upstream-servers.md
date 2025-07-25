# Upstream servers

Fluent Bit [output plugins](../../../pipeline/outputs/) aim to connect to external services to deliver logs over the network. Being able to connect to one node (host) is normal and enough for more of the use cases, but there are other scenarios where balancing across different nodes is required. The `Upstream` feature provides this capability.

An `Upstream` defines a set of nodes that will be targeted by an output plugin, by the nature of the implementation an output plugin must support the `Upstream` feature. The following plugin has `Upstream` support:

- [Forward](../../../pipeline/outputs/forward.md)

The current balancing mode implemented is `round-robin`.

## Configuration

To define an `Upstream` you must create an specific configuration file that contains an `UPSTREAM` and one or multiple `NODE` sections. The following table describes the properties associated with each section. All properties are mandatory:

| Section | Key | Description |
| :--- | :--- | :--- |
| `UPSTREAM` | `name` | Defines a name for the `Upstream in question. |
| `NODE` | `name` | Defines a name for the `Node` in question. |
|  | `host` | IP address or hostname of the target host. |
|  | `port` | TCP port of the target service. |

### Nodes and specific plugin configuration

A `Node` might contain additional configuration keys required by the plugin, to provide enough flexibility for the output plugin. A common use case is a `Forward` output where if TLS is enabled, it requires a shared key.

### Nodes and TLS (Transport Layer Security)

In addition to the properties defined in the configuration table, the network operations against a defined node can optionally be done through the use of TLS for further encryption and certificates use.

The TLS options available are described in the [TLS/SSL](../../transport-security.md) section and can be added to the any _Node_ section.

### Configuration file example

The following example defines an `Upstream` called forward-balancing which aims to be used by Forward output plugin, it register three `Nodes`:

- node-1: connects to 127.0.0.1:43000
- node-2: connects to 127.0.0.1:44000
- node-3: connects to 127.0.0.1:45000 using TLS without verification. It also defines a specific configuration option required by Forward output called `shared_key`.

```python
[UPSTREAM]
    name       forward-balancing

[NODE]
    name       node-1
    host       127.0.0.1
    port       43000

[NODE]
    name       node-2
    host       127.0.0.1
    port       44000

[NODE]
    name       node-3
    host       127.0.0.1
    port       45000
    tls        on
    tls.verify off
    shared_key secret
```

Every `Upstream` definition must exists in its own configuration file in the file system. Adding multiple `Upstream` configurations in the same file or different files isn't allowed.
