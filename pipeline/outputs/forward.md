# Forward

_Forward_ is the protocol used by [Fluentd](http://www.fluentd.org) to route messages between peers. The `forward` output plugin provides interoperability between [Fluent Bit](http://fluentbit.io) and [Fluentd](http://fluentd.org).

There are no configuration steps required besides specifying where [Fluentd](http://fluentd.org) is located, which can be a local or a remote destination.

This plugin offers the following transports and modes:

- Forward (TCP): Uses a plain TCP connection.
- Secure Forward (TLS): When TLS is enabled, the plugin switches to Secure Forward mode.

## Configuration parameters

The following parameters are mandatory for both Forward and Secure Forward modes:

| Key | Description | Default   |
| --- | ------------ | --------- |
| `Host` | Target host where Fluent Bit or Fluentd are listening for Forward messages. | `127.0.0.1` |
| `Port` | TCP Port of the target service. | `24224` |
| `Time_as_Integer` | Set timestamps in integer format, it enables compatibility mode for Fluentd v0.12 series. | `False` |
| `Upstream` | If Forward will connect to an `Upstream` instead of a basic host, this property defines the absolute path for the Upstream configuration file, for more details about this, see [Upstream Servers ](../../administration/configuring-fluent-bit/classic-mode/upstream-servers.md). | _none_ |
| `Unix_Path` | Specify the path to a Unix socket to send a Forward message. If set, `Upstream` is ignored.   | _none_ |
| `Tag` | Overwrite the tag as Fluent Bit transmits. This allows the receiving pipeline start fresh, or to attribute a source.  |  _none_ |
| `Send_options` | Always send options (with `"size"=count of messages`) | `False` |
| `Require_ack_response` | Send `chunk` option and wait for an `ack` response from the server. Enables at-least-once and receiving server can control rate of traffic. Requires Fluentd v0.14.0+ or later | `False` |
| `Compress` | Set to `gzip` to enable gzip compression. Incompatible with `Time_as_Integer=True` and tags set dynamically using the [Rewrite Tag](../filters/rewrite-tag.md) filter. Requires Fluentd server v0.14.7 or later. |  _none_  |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

## Secure Forward mode configuration parameters

When using Secure Forward mode, the [TLS](../../administration/transport-security.md) mode must be enabled. The following additional configuration parameters are available:

| Key | Description | Default |
| --- | ----------- | ------- |
| `Shared_Key` | A key string known by the remote Fluentd used for authorization. |  _none_ |
| `Empty_Shared_Key` | Use this option to connect to Fluentd with a zero-length secret. | `False` |
| `Username` | Specify the username to present to a Fluentd server that enables `user_auth`. | _none_ |
| `Password` | Specify the password corresponding to the username. | _none_ |
| `Self_Hostname` | Default value of the auto-generated certificate common name (CN). | `localhost` |
| `tls` | Enable or disable TLS support. | `Off` |
| `tls.verify` | Force certificate validation. | `On` |
| `tls.debug` | Set TLS debug verbosity level. Allowed values: `0` (No debug), `1` (Error), `2` (State change), `3` (Informational), and `4` (Verbose). | `1` |
| `tls.ca_file` | Absolute path to CA certificate file. | _none_ |
| `tls.crt_file` | Absolute path to Certificate file. | _none_ |
| `tls.key_file` | Absolute path to private Key file. | _none_ |
| `tls.key_passwd` | Optional password for `tls.key_file`. | _none_ |
| `tls.windows.certstore_name`  | (Windows only) Specify the name of the Windows Certificate Store to load certificates from.  | `Root` |
| `tls.windows.use_enterprise_store` | (Windows only) Enable loading certificates from the Local Machine Enterprise Certificate Store. | `Off` |

## Forward setup

Before proceeding, ensure that [Fluentd](http://fluentd.org) is installed. If it's not, refer to the [Fluentd Installation](http://docs.fluentd.org/installation) document.

After installing Fluentd, create the following configuration file example which lets you to stream data into it:

```text
<source>
  type forward
  bind 0.0.0.0
  port 24224
</source>

<match fluent_bit>
  type stdout
</match>
```

That configuration file specifies that it will listen for TCP connections on port `24224` through the `forward` input type.

Every message with a `fluent_bit` tag will print a message to the standard output.

In one terminal, launch Fluentd while specifying the new configuration file created:

```shell
fluentd -c test.conf
```

Which should return a response similar to the following:

```text
...
2017-03-23 11:50:43 -0600 [info]: reading config file path="test.conf"
...
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-mixin-config-placeholders' version '0.3.1'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-docker' version '0.1.0'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-elasticsearch' version '1.4.0'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-flatten-hash' version '0.2.0'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-flowcounter-simple' version '0.0.4'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-influxdb' version '0.2.8'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-json-in-json' version '0.1.4'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-mongo' version '0.7.10'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-out-http' version '0.1.3'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-parser' version '0.6.0'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-record-reformer' version '0.7.0'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-rewrite-tag-filter' version '1.5.1'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-stdin' version '0.1.1'
2017-03-23 11:50:43 -0600 [info]: gem 'fluent-plugin-td' version '0.10.27'
2017-03-23 11:50:43 -0600 [info]: adding match pattern="fluent_bit" type="stdout"
2017-03-23 11:50:43 -0600 [info]: adding source type="forward"
2017-03-23 11:50:43 -0600 [info]: using configuration file: <ROOT>
  <source>
    type forward
    bind 0.0.0.0
    port 24224
  </source>
  <match fluent_bit>
    type stdout
  </match>
</ROOT>
2017-03-23 11:50:43 -0600 [info]: listening fluent socket on 0.0.0.0:24224
...
```

## Fluent Bit and Forward setup

When Fluentd is ready to receive messages, specify where the `forward` output plugin will flush the information using the following format:

```shell
fluent-bit -i INPUT -o forward://HOST:PORT
```

If the `tag` parameter isn't set, the plugin will retain the tag. The `tag` is important for routing rules inside Fluentd.

Using the [CPU](../inputs/cpu-metrics.md) input plugin as an example, you can flush `cpu` metrics with the `tag` `fluent_bit` to Fluentd:

```shell
fluent-bit -i cpu -t fluent_bit -o forward://127.0.0.1:24224
```

In Fluentd, you will see the CPU metrics gathered in the last seconds:

```text
...
2017-03-23 11:53:06 -0600 fluent_bit: {"cpu_p":0.0,"user_p":0.0,"system_p":0.0,"cpu0.p_cpu":0.0,"cpu0.p_user":0.0,"cpu0.p_system":0.0,"cpu1.p_cpu":0.0,"cpu1.p_user":0.0,"cpu1.p_system":0.0,"cpu2.p_cpu":0.0,"cpu2.p_user":0.0,"cpu2.p_system":0.0,"cpu3.p_cpu":1.0,"cpu3.p_user":1.0,"cpu3.p_system":0.0}
2017-03-23 11:53:07 -0600 fluent_bit: {"cpu_p":2.25,"user_p":2.0,"system_p":0.25,"cpu0.p_cpu":3.0,"cpu0.p_user":3.0,"cpu0.p_system":0.0,"cpu1.p_cpu":1.0,"cpu1.p_user":1.0,"cpu1.p_system":0.0,"cpu2.p_cpu":1.0,"cpu2.p_user":1.0,"cpu2.p_system":0.0,"cpu3.p_cpu":3.0,"cpu3.p_user":2.0,"cpu3.p_system":1.0}
2017-03-23 11:53:08 -0600 fluent_bit: {"cpu_p":1.75,"user_p":1.0,"system_p":0.75,"cpu0.p_cpu":2.0,"cpu0.p_user":1.0,"cpu0.p_system":1.0,"cpu1.p_cpu":3.0,"cpu1.p_user":1.0,"cpu1.p_system":2.0,"cpu2.p_cpu":3.0,"cpu2.p_user":2.0,"cpu2.p_system":1.0,"cpu3.p_cpu":2.0,"cpu3.p_user":1.0,"cpu3.p_system":1.0}
2017-03-23 11:53:09 -0600 fluent_bit: {"cpu_p":4.75,"user_p":3.5,"system_p":1.25,"cpu0.p_cpu":4.0,"cpu0.p_user":3.0,"cpu0.p_system":1.0,"cpu1.p_cpu":5.0,"cpu1.p_user":4.0,"cpu1.p_system":1.0,"cpu2.p_cpu":3.0,"cpu2.p_user":2.0,"cpu2.p_system":1.0,"cpu3.p_cpu":5.0,"cpu3.p_user":4.0,"cpu3.p_system":1.0}
...
```

This shows that [CPU](../inputs/cpu-metrics.md) metrics were gathered and flushed out to Fluentd properly.

## Fluent Bit and Secure Forward setup

The following example doesn't consider the generation of certificates for best practice on production environments.

Secure Forward provides a secure channel of communication with the remote Fluentd service using [TLS](../../administration/transport-security.md).

### Fluent Bit

Paste this content in a file called `flb` :

{% tabs %}
{% tab title="flb.yaml" %}

```yaml
service:
  flush: 5
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: cpu
      tag: cpu_usage

  outputs:
    - name: forward
      match: '*'
      host: 127.0.0.1
      port: 24284
      shared_key: secret
      self_hostname: flb.local
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="flb.conf" %}

```text
[SERVICE]
  Flush      5
  Daemon     off
  Log_Level  info

[INPUT]
  Name       cpu
  Tag        cpu_usage

[OUTPUT]
  Name          forward
  Match         *
  Host          127.0.0.1
  Port          24284
  Shared_Key    secret
  Self_Hostname flb.local
  tls           on
  tls.verify    off
```

{% endtab %}
{% endtabs %}

### Fluentd

Paste this content in a file called `fld.conf`:

```text
<source>
  @type         secure_forward
  self_hostname myserver.local
  shared_key    secret
  secure no
</source>

<match **>
 @type stdout
</match>
```

### Test communication

1. Start Fluentd:

   ```shell
   fluentd -c fld.conf
   ```

1. Start Fluent Bit:

   ```shell
   # For YAML configuration.
   fluent-bit --config flb.yaml

   # For classic configuration
   fluent-bit --config flb.conf
   ```

After five seconds, Fluent Bit will write records to Fluentd. In Fluentd output you will see a message like this:

```text
...
2017-03-23 13:34:40 -0600 [info]: using configuration file: <ROOT>
  <source>
    @type secure_forward
    self_hostname myserver.local
    shared_key xxxxxx
    secure no
  </source>
  <match **>
    @type stdout
  </match>
</ROOT>
2017-03-23 13:34:41 -0600 cpu_usage: {"cpu_p":1.0,"user_p":0.75,"system_p":0.25,"cpu0.p_cpu":1.0,"cpu0.p_user":1.0,"cpu0.p_system":0.0,"cpu1.p_cpu":2.0,"cpu1.p_user":1.0,"cpu1.p_system":1.0,"cpu2.p_cpu":1.0,"cpu2.p_user":1.0,"cpu2.p_system":0.0,"cpu3.p_cpu":2.0,"cpu3.p_user":1.0,"cpu3.p_system":1.0}
2017-03-23 13:34:42 -0600 cpu_usage: {"cpu_p":1.75,"user_p":1.75,"system_p":0.0,"cpu0.p_cpu":3.0,"cpu0.p_user":3.0,"cpu0.p_system":0.0,"cpu1.p_cpu":2.0,"cpu1.p_user":2.0,"cpu1.p_system":0.0,"cpu2.p_cpu":0.0,"cpu2.p_user":0.0,"cpu2.p_system":0.0,"cpu3.p_cpu":1.0,"cpu3.p_user":1.0,"cpu3.p_system":0.0}
2017-03-23 13:34:43 -0600 cpu_usage: {"cpu_p":1.75,"user_p":1.25,"system_p":0.5,"cpu0.p_cpu":3.0,"cpu0.p_user":3.0,"cpu0.p_system":0.0,"cpu1.p_cpu":2.0,"cpu1.p_user":2.0,"cpu1.p_system":0.0,"cpu2.p_cpu":0.0,"cpu2.p_user":0.0,"cpu2.p_system":0.0,"cpu3.p_cpu":1.0,"cpu3.p_user":0.0,"cpu3.p_system":1.0}
2017-03-23 13:34:44 -0600 cpu_usage: {"cpu_p":5.0,"user_p":3.25,"system_p":1.75,"cpu0.p_cpu":4.0,"cpu0.p_user":2.0,"cpu0.p_system":2.0,"cpu1.p_cpu":8.0,"cpu1.p_user":5.0,"cpu1.p_system":3.0,"cpu2.p_cpu":4.0,"cpu2.p_user":3.0,"cpu2.p_system":1.0,"cpu3.p_cpu":4.0,"cpu3.p_user":2.0,"cpu3.p_system":2.0}
...
```
