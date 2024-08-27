# Collectd

The **collectd** input plugin allows you to receive datagrams from collectd service.

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Listen | Set the address to listen to | 0.0.0.0 |
| Port | Set the port to listen to | 25826 |
| TypesDB | Set the data specification file | /usr/share/collectd/types.db |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Configuration Examples <a id="config_example"></a>

Here is a basic configuration example.

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

With this configuration, Fluent Bit listens to `0.0.0.0:25826`, and outputs incoming datagram packets to stdout.

You must set the same types.db files that your collectd server uses. Otherwise, Fluent Bit may not be able to interpret the payload properly.
