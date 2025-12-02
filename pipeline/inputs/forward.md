# Forward

_Forward_ is the protocol used by [Fluent Bit](http://fluentbit.io) and [Fluentd](http://www.fluentd.org) to route messages between peers. This plugin implements the input service to listen for Forward messages.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                 | Description                                                                                                                                                                                                                                                                                                                                | Default   |
|:--------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------|
| `buffer_chunk_size` | By default the buffer to store the incoming Forward messages, don't allocate the maximum memory allowed, instead it allocate memory when it's required. The rounds of allocations are set by `buffer_chunk_size`. The value must be according to the [Unit Size ](../../administration/configuring-fluent-bit.md#unit-sizes)specification. | `1024000` |
| `buffer_max_size`   | Specify the maximum buffer memory size used to receive a Forward message. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit.md#unit-sizes) specification.                                                                                                                                         | `6144000` |
| `empty_shared_key`  | Enable secure forward protocol with a zero-length shared key. Use this to enable user authentication without requiring a shared key, or to connect to Fluentd with a zero-length shared key.                                                                                                                                              | `false`   |
| `listen`            | Listener network interface.                                                                                                                                                                                                                                                                                                                | `0.0.0.0` |
| `port`              | TCP port to listen for incoming connections.                                                                                                                                                                                                                                                                                               | `24224`   |
| `security.users`    | Specify the username and password pairs for secure forward authentication. Requires `shared_key` or `empty_shared_key` to be set.                                                                                                                                                                                                          |           |
| `self_hostname`     | Hostname for secure forward authentication.                                                                                                                                                                                                                                                                                                | `localhost` |
| `shared_key`        | Shared key for secure forward authentication.                                                                                                                                                                                                                                                                                              | _none_    |
| `tag`               | Override the tag of the forwarded events with the defined value.                                                                                                                                                                                                                                                                           | _none_    |
| `tag_prefix`        | Prefix incoming tag with the defined value.                                                                                                                                                                                                                                                                                                | _none_    |
| `threaded`          | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                                                                                    | `false`   |
| `unix_path`         | Specify the path to Unix socket to receive a Forward message. If set, `listen` and `port` are ignored.                                                                                                                                                                                                                                     | _none_    |
| `unix_perm`         | Set the permission of the Unix socket file. If `unix_path` isn't set, this parameter is ignored.                                                                                                                                                                                                                                           | _none_    |

### TLS / SSL

The Forward input plugin supports TLS/SSL. For more details about the properties available and general configuration, refer to [Transport Security](../../administration/transport-security.md).

## Get started

To receive Forward messages, you can run the plugin from the command line or through the configuration file as shown in the following examples.

### Command line

From the command line you can let Fluent Bit listen for Forward messages with the following options:

```shell
fluent-bit -i forward -o stdout
```

By default, the service listens on all interfaces (`0.0.0.0`) through TCP port `24224`. You can change this by passing parameters to the command:

```shell
fluent-bit -i forward -p listen="192.168.3.2" -p port=9090 -o stdout
```

In the example, the Forward messages arrive only through network interface `192.168.3.2` address and TCP Port `9090`.

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: forward
      listen: 0.0.0.0
      port: 24224
      buffer_chunk_size: 1M
      buffer_max_size: 6M

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name              forward
  Listen            0.0.0.0
  Port              24224
  Buffer_Chunk_Size 1M
  Buffer_Max_Size   6M

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Fluent Bit and secure forward setup

In Fluent Bit v3 or later, `in_forward` can handle secure forward protocol.

{% hint style="warning" %}
When using `security.users` for user-password authentication, you **must** also configure either `shared_key` or set `empty_shared_key` to `true`. The Forward input plugin will reject a configuration that has `security.users` set without one of these options.
{% endhint %}

For shared key authentication, specify `shared_key` in both forward output and forward input. For user-password authentication, specify `security.users` with at least one user-password pair along with a shared key. To use user authentication without requiring clients to know a shared key, set `empty_shared_key` to `true`.

The `self_hostname` value can't be the same between Fluent Bit servers and clients.

{% tabs %}
{% tab title="fluent-bit-secure-forward.yaml" %}

```yaml
pipeline:
  inputs:
    - name: forward
      listen: 0.0.0.0
      port: 24224
      buffer_chunk_size: 1M
      buffer_max_size: 6M
      security.users: fluentbit changeme
      shared_key: secret
      self_hostname: flb.server.local

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit-secure-forward.conf" %}

```text
[INPUT]
  Name              forward
  Listen            0.0.0.0
  Port              24224
  Buffer_Chunk_Size 1M
  Buffer_Max_Size   6M
  Security.Users    fluentbit changeme
  Shared_Key        secret
  Self_Hostname     flb.server.local

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

### User authentication with `empty_shared_key`

To use username and password authentication without requiring clients to know a shared key, set `empty_shared_key` to `true`:

{% tabs %}
{% tab title="fluent-bit-user-auth.yaml" %}

```yaml
pipeline:
  inputs:
    - name: forward
      listen: 0.0.0.0
      port: 24224
      buffer_chunk_size: 1M
      buffer_max_size: 6M
      security.users: fluentbit changeme
      empty_shared_key: true
      self_hostname: flb.server.local

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit-user-auth.conf" %}

```text
[INPUT]
  Name              forward
  Listen            0.0.0.0
  Port              24224
  Buffer_Chunk_Size 1M
  Buffer_Max_Size   6M
  Security.Users    fluentbit changeme
  Empty_Shared_Key  true
  Self_Hostname     flb.server.local

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Testing

After Fluent Bit is running, you can send some messages using the `fluent-cat` tool, provided by [Fluentd](http://www.fluentd.org):

```shell
echo '{"key 1": 123456789, "key 2": "abcdefg"}' | fluent-cat my_tag
```

When you run the plugin with the following command:

```shell
fluent-bit -i forward -o stdout
```

In [Fluent Bit](http://fluentbit.io) you should see the following output:

```text
...
[0] my_tag: [1475898594, {"key 1"=>123456789, "key 2"=>"abcdefg"}]
...
```
