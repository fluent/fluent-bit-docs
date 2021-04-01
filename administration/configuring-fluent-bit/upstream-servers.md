# Upstream Servers

It's common that Fluent Bit [output plugins](../../pipeline/outputs/) aims to connect to external services to deliver the logs over the network, this is the case of [HTTP](../../pipeline/outputs/http.md), [Elasticsearch](../../pipeline/outputs/elasticsearch.md) and [Forward](../../pipeline/outputs/forward.md) within others. Being able to connect to one node \(host\) is normal and enough for more of the use cases, but there are other scenarios where balancing across different nodes is required. The _Upstream_ feature provides such capability.

An _Upstream_ defines a set of nodes that will be targeted by an output plugin, by the nature of the implementation an output plugin **must** support the _Upstream_ feature. The following plugin\(s\) have _Upstream_ support:

* [Forward](../../pipeline/outputs/forward.md)

The current balancing mode implemented is _round-robin_.

## Configuration

To define an _Upstream_ it's required to create an specific configuration file that contains an UPSTREAM and one or multiple NODE sections. The following table describe the properties associated to each section. Note that all of them are mandatory:

| Section | Key | Description |
| :--- | :--- | :--- |
| UPSTREAM | name | Defines a name for the _Upstream_ in question. |
| NODE | name | Defines a name for the _Node_ in question. |
|  | host | IP address or hostname of the target host. |
|  | port | TCP port of the target service. |

### Nodes and specific plugin configuration

A _Node_ might contain additional configuration keys required by the plugin, on that way we provide enough flexibility for the output plugin, a common use case is Forward output where if TLS is enabled, it requires a shared key \(more details in the example below\).

### Nodes and TLS \(Transport Layer Security\)

In addition to the properties defined in the table above, the network operations against a defined node can optionally be done through the use of TLS for further encryption and certificates use.

The TLS options available are described in the [TLS/SSL](../security.md) section and can be added to the any _Node_ section.

### Configuration File Example

The following example defines an _Upstream_ called forward-balancing which aims to be used by Forward output plugin, it register three _Nodes_:

* node-1: connects to 127.0.0.1:43000
* node-2: connects to 127.0.0.1:44000
* node-3: connects to 127.0.0.1:45000 using TLS without verification. It also defines a specific configuration option required by Forward output called _shared\_key_. 

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

Note that every _Upstream_ definition **must** exists on it own configuration file in the file system. Adding multiple _Upstreams_ in the same file or different files is not allowed.

