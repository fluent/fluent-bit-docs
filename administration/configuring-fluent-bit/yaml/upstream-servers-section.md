# Upstream servers

The `upstream_servers` section of YAML configuration files defines a group of endpoints, referred to as nodes. Nodes are used by output plugins to distribute data in a round-robin fashion. Use this section for plugins that require load balancing when sending data. Examples of plugins that support this capability include [Forward](../../../pipeline/outputs/forward.md) and [Elasticsearch](../../../pipeline/outputs/elasticsearch.md).

The `upstream_servers` section requires a `name` for the group and a list of `nodes`. The following example defines an upstream server group named `forward-balancing`:

```yaml
upstream_servers:
  - name: forward-balancing
    nodes:
      - name: node-1
        host: 127.0.0.1
        port: 43000

      - name: node-2
        host: 127.0.0.1
        port: 44000

      - name: node-3
        host: 127.0.0.1
        port: 45000
        tls: true
        tls.verify: false
        shared_key: secret
```

Each node in the `upstream_servers` group must specify a `name`, `host`, and `port`. Additional settings like `tls`, `tls.verify`, and `shared_key` can be configured for secure communication.

Define the `upstream_servers` section in its own file, and set the output plugin's `upstream` parameter to the path of that file. Each file must define only one group. If a file defines more than one group, Fluent Bit uses only the last one. Consult the documentation for each output plugin for details about its `upstream` parameter.
