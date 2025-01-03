# Forward

_Forward_ is the protocol used by [Fluent Bit](http://fluentbit.io) and [Fluentd](http://www.fluentd.org) to route messages between peers.
This plugin implements the input service to listen for Forward messages.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key                 | Description                                                                                                                                                                                                                                                                                                                                 | Default |
|:--------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| :--- |
| Listen              | Listener network interface.                                                                                                                                                                                                                                                                                                                 | 0.0.0.0 |
| Port                | TCP port to listen for incoming connections.                                                                                                                                                                                                                                                                                                | 24224 |
| Unix_Path           | Specify the path to unix socket to receive a Forward message. If set, `Listen` and `Port` are ignored.                                                                                                                                                                                                                                      | |
| Unix_Perm           | Set the permission of the unix socket file. If `Unix_Path` is not set, this parameter is ignored.                                                                                                                                                                                                                                      | |
| Buffer\_Max\_Size   | Specify the maximum buffer memory size used to receive a Forward message. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification.                                                                                                                                          | 6144000 |
| Buffer\_Chunk\_Size | By default the buffer to store the incoming Forward messages, do not allocate the maximum memory allowed, instead it allocate memory when is required. The rounds of allocations are set by _Buffer\_Chunk\_Size_. The value must be according to the [Unit Size ](../../administration/configuring-fluent-bit/unit-sizes.md)specification. | 1024000 |
| Tag_Prefix          | Prefix incoming tag with the defined value.|  |
| Tag                 | Override the tag of the forwarded events with the defined value.|  |
| Shared\_Key         | Shared key for secure forward authentication. |  |
| Empty\_Shared\_Key  | Use this option to connect to Fluentd with a zero-length shared key. | `false` |
| Self\_Hostname      | Hostname for secure forward authentication.   |  |
| Security.Users      | Specify the username and password pairs for secure forward authentication. | |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Getting Started

In order to receive Forward messages, you can run the plugin from the command line or through the configuration file as shown in the following examples.

### Command Line

From the command line you can let Fluent Bit listen for _Forward_ messages with the following options:

```bash
$ fluent-bit -i forward -o stdout
```

By default the service will listen an all interfaces \(0.0.0.0\) through TCP port 24224, optionally you can change this directly, e.g:

```bash
$ fluent-bit -i forward -p listen="192.168.3.2" -p port=9090 -o stdout
```

In the example the Forward messages will only arrive through network interface under 192.168.3.2 address and TCP Port 9090.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
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
{% endtabs %}

## Fluent Bit + Secure Forward Setup

Since Fluent Bit v3, in\_forward can handle secure forward protocol.

For using user-password authentication, it needs to specify `security.users` at least an one-pair.
For using shared key, it needs to specify `shared_key` in both of forward output and forward input.
`self_hostname` is not able to specify with the same hostname between fluent servers and clients.

{% tabs %}
{% tab title="fluent-bit-secure-forward.conf" %}
```python
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
{% endtabs %}

## Testing

Once Fluent Bit is running, you can send some messages using the _fluent-cat_ tool \(this tool is provided by [Fluentd](http://www.fluentd.org):

```bash
$ echo '{"key 1": 123456789, "key 2": "abcdefg"}' | fluent-cat my_tag
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -i forward -o stdout
Fluent-Bit v0.9.0
Copyright (C) Treasure Data

[2016/10/07 21:49:40] [ info] [engine] started
[2016/10/07 21:49:40] [ info] [in_fw] binding 0.0.0.0:24224
[0] my_tag: [1475898594, {"key 1"=>123456789, "key 2"=>"abcdefg"}]
```
