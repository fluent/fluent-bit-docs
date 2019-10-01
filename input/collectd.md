# Collectd

The **collectd** input plugin allows you to receive datagrams from collectd.

Content:

* [Configuration Parameters](collectd.md#config)
* [Configuration Parameters](collectd.md#config_example)

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Address | Set the address to listen to | 0.0.0.0 |
| Port | Set the port to listen to | 25826 |
| TypesDB | Set the data specification file | /usr/share/collectd/types.db |

## Configuration Examples <a id="config_example"></a>

Here is a basic configuration example.

```python
[INPUT]
    Name         collectd
    Address      0.0.0.0
    Port         25826
    TypesDB      /usr/share/collectd/types.db,/etc/collectd/custom.db

[OUTPUT]
    Name   stdout
    Match  *
```

With this configuration, fluent-bit listens to `0.0.0.0:25826`, and outputs incoming datagram packets to stdout.

You must set the same types.db files that your collectd server uses. Otherwise, fluent-bit may not be able to interpret the payload properly.

