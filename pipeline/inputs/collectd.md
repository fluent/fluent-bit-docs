# Collectd

The _Collectd_ input plugin lets you receive datagrams from the `collectd` service over `UDP`. The plugin listens for collectd network protocol packets and converts them into Fluent Bit records.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key        | Description                                                                                             | Default                        |
|:-----------|:--------------------------------------------------------------------------------------------------------|:-------------------------------|
| `listen`   | Set the address to listen to.                                                                           | `0.0.0.0`                      |
| `port`     | Set the port to listen to.                                                                              | `25826`                        |
| `typesdb`  | Set the data specification file. You can specify multiple files separated by commas. Later entries take precedence over earlier ones. | `/usr/share/collectd/types.db` |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false`                        |

## Get started

To receive collectd datagrams, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can let Fluent Bit listen for `collectd` datagrams with the following options:

```shell
fluent-bit -i collectd -o stdout
```

By default, the service listens on all interfaces (`0.0.0.0`) using `UDP` port `25826`. You can change this directly:

```shell
fluent-bit -i collectd -p listen=192.168.3.2 -p port=9090 -o stdout
```

In this example, collectd datagrams will only arrive through the network interface at `192.168.3.2` address and `UDP` port `9090`.

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: collectd
      listen: 0.0.0.0
      port: 25826
      typesdb: '/usr/share/collectd/types.db,/etc/collectd/custom.db'

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name         collectd
  Listen       0.0.0.0
  Port         25826
  TypesDB      /usr/share/collectd/types.db,/etc/collectd/custom.db

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

With this configuration, Fluent Bit listens to `0.0.0.0:25826`, and outputs incoming datagram packets to `stdout`.

## `typesdb` configuration

You must set the same `types.db` files that your `collectd` server uses. Otherwise, Fluent Bit might not be able to interpret the payload properly.

The `typesdb` parameter supports multiple files separated by commas. When multiple files are specified, later entries take precedence over earlier ones if there are duplicate type definitions. This allows you to override default types with custom definitions.

For example:

```yaml
typesdb: '/usr/share/collectd/types.db,/etc/collectd/custom.db'
```

In this configuration, custom type definitions in `/etc/collectd/custom.db` will override any matching definitions from `/usr/share/collectd/types.db`.
