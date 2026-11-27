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
        tls.verify: true
        shared_key: secret
```

Each node in the `upstream_servers` group must specify a `name`, `host`, and `port`. If a node is missing one of them, Fluent Bit logs an error such as `no 'host' has been set on node #1` and fails to start. Additional settings like `tls`, `tls.verify`, and `shared_key` can be configured for secure communication.

Define the `upstream_servers` section in its own file, and set the output plugin's `upstream` parameter to the path of that file. The filename must end in `.yaml` or `.yml`. Otherwise, Fluent Bit reads it as a classic configuration file. Each file must define only one group. Consult the documentation for each output plugin for details about its `upstream` parameter.

If a file defines more than one group, Fluent Bit uses only the last one, and logs a warning for each extra group, such as `<file> defines more than one upstream, ignoring '<previous_group>' and using '<next_group>'`. Treat this warning as a configuration error: a group left at the end of the file, such as one used for testing, becomes the destination for your data. Fluent Bit still applies its general checks to every group, and a failed check stops Fluent Bit from starting even if the group is ignored. For example, every group needs a `name`, every node needs a `name`, `host`, and `port`, and the TLS settings of a node with `tls` on must load, so a `tls.ca_file` that can't be read is an error. The whole file must also be valid YAML. Settings specific to an output plugin are checked only in the group that Fluent Bit uses.

The group that Fluent Bit uses must define at least one node, even if an earlier group in the file defines nodes. If it doesn't, or if the file defines no group, Fluent Bit fails to start and logs `no nodes defined`, followed by `cannot load Upstream file`.

Fluent Bit reads the upstream file only when the output plugin starts, so `--dry-run` and the validation that runs before a [hot reload](../../hot-reload.md) don't detect these errors. If a reload loads an upstream file with one of these errors, the reload is aborted and Fluent Bit exits.
