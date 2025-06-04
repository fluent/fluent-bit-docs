# Collectd

The _Collectd_ input plugin lets you receive datagrams from the `collectd` service.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Listen` | Set the address to listen to. | `0.0.0.0` |
| `Port` | Set the port to listen to. | `25826` |
| `TypesDB` | Set the data specification file. | `/usr/share/collectd/types.db` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Configuration examples

Here is a basic configuration example:

```python
[INPUT]
    Name         collectd
    Listen       0.0.0.0
    Port         25826
    TypesDB      /usr/share/collectd/types.db,/etc/collectd/custom.db

[OUTPUT]
    Name   stdout
    Match  *
```

With this configuration, Fluent Bit listens to `0.0.0.0:25826`, and outputs incoming datagram packets to `stdout`.

You must set the same `types.db` files that your `collectd` server uses. Otherwise, Fluent Bit might not be able to interpret the payload properly.
