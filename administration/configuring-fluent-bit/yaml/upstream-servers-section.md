# Upstream servers

The `upstream_servers` section of YAML configuration files defines a group of endpoints, referred to as nodes. Nodes are used by output plugins to distribute data in a round-robin fashion. Use this section for plugins that require load balancing when sending data. Examples of plugins that support this capability include [Forward](https://docs.fluentbit.io/manual/pipeline/outputs/forward) and [Elasticsearch](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch).

The `upstream_servers` section require specifying a `name` for the group and a list
of `nodes`. The following example defines two upstream server groups, `forward-balancing` and `forward-balancing-2`:

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
        tls_verify: false
        shared_key: secret

  - name: forward-balancing-2
    nodes:
      - name: node-A
        host: 192.168.1.10
        port: 50000

      - name: node-B
        host: 192.168.1.11
        port: 51000
```

Each node in the `upstream_servers` group must specify a `name`, `host`, and `port`. Additional settings like `tls`, `tls_verify`, and `shared_key` can be configured for secure communication.

While the `upstream_servers` section can be defined globally, some output plugins might require the configuration to be specified in a separate YAML file. Consult the documentation for each specific output plugin to understand its requirements.
