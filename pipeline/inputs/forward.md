# Forward

_Forward_ is the protocol used by [Fluent Bit](http://fluentbit.io) and [Fluentd](http://www.fluentd.org) to route messages between peers. This plugin implements the input service to listen for Forward messages.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                 | Description                                                                                                                                                                                                                                                                                                                                | Default   |
|:--------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------|
| `Listen`            | Listener network interface.                                                                                                                                                                                                                                                                                                                | `0.0.0.0` |
| `Port`              | TCP port to listen for incoming connections.                                                                                                                                                                                                                                                                                               | `24224`   |
| `Unix_Path`         | Specify the path to Unix socket to receive a Forward message. If set, `Listen` and `Port` are ignored.                                                                                                                                                                                                                                     | _none_    |
| `Unix_Perm`         | Set the permission of the Unix socket file. If `Unix_Path` isn't set, this parameter is ignored.                                                                                                                                                                                                                                           | _none_    |
| `Buffer_Max_Size`   | Specify the maximum buffer memory size used to receive a Forward message. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification.                                                                                                                                         | `6144000` |
| `Buffer_Chunk_Size` | By default the buffer to store the incoming Forward messages, don't allocate the maximum memory allowed, instead it allocate memory when it's required. The rounds of allocations are set by `Buffer_Chunk_Size`. The value must be according to the [Unit Size ](../../administration/configuring-fluent-bit/unit-sizes.md)specification. | `1024000` |
| `Tag_Prefix`        | Prefix incoming tag with the defined value.                                                                                                                                                                                                                                                                                                | _none_    |
| `Tag`               | Override the tag of the forwarded events with the defined value.                                                                                                                                                                                                                                                                           | _none_    |
| `Shared_Key`        | Shared key for secure forward authentication.                                                                                                                                                                                                                                                                                              | _none_    |
| `Empty_Shared_Key`  | Use this option to connect to Fluentd with a zero-length shared key.                                                                                                                                                                                                                                                                       | `false`   |
| `Self_Hostname`     | Hostname for secure forward authentication.                                                                                                                                                                                                                                                                                                | _none_    |
| `Security.Users`    | Specify the username and password pairs for secure forward authentication.                                                                                                                                                                                                                                                                 |           |
| `Threaded`          | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                                                                                                                                                                                                    | `false`   |

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

## Fluent Bit and Secure Forward Setup

In Fluent Bit v3 or later, `in_forward` can handle secure forward protocol.

For using user-password authentication, specify `security.users` in at least a one-pair. For using shared key, specify `shared_key` in both of forward output and forward input. `self_hostname` isn't able to specify with the same hostname between fluent servers and clients.

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
  Security.Users fluentbit changeme
  Shared_Key secret
  Self_Hostname flb.server.local

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
