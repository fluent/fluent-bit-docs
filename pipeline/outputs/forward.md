# Forward

_Forward_ is the protocol used by [Fluentd](http://www.fluentd.org) to route messages between peers. The **forward** output plugin provides interoperability between [Fluent Bit](http://fluentbit.io) and [Fluentd](http://fluentd.org).
There are no configuration steps required besides specifying where [Fluentd](http://fluentd.org) is located, which can be a local or a remote destination.

This plugin offers two different transports and modes:

* Forward (TCP): It uses a plain TCP connection.
* Secure Forward (TLS): when TLS is enabled, the plugin switch to Secure Forward mode.

## Configuration Parameters

The following parameters are mandatory for either Forward for Secure Forward modes:

| Key                  | Description                                                                                                                                                                                                                                                                                         | Default   |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| Host                 | Target host where Fluent-Bit or Fluentd are listening for Forward messages.                                                                                                                                                                                                                         | 127.0.0.1 |
| Port                 | TCP Port of the target service.                                                                                                                                                                                                                                                                     | 24224     |
| Time_as_Integer      | Set timestamps in integer format, it enable compatibility mode for Fluentd v0.12 series.                                                                                                                                                                                                            | False     |
| Upstream             | If Forward will connect to an _Upstream_ instead of a simple host, this property defines the absolute path for the Upstream configuration file, for more details about this refer to the [Upstream Servers ](../../administration/configuring-fluent-bit/classic-mode/upstream-servers.md)documentation section. |           |
| Unix_Path            | Specify the path to unix socket to send a Forward message. If set, `Upstream` is ignored.   |           |
| Tag                  | Overwrite the tag as we transmit. This allows the receiving pipeline start fresh, or to attribute source.                                                                                                                                                                                           |           |
| Send_options         | Always send options (with "size"=count of messages)                                                                                                                                                                                                                                                 | False     |
| Require_ack_response | Send "chunk"-option and wait for "ack" response from server. Enables at-least-once and receiving server can control rate of traffic. (Requires Fluentd v0.14.0+ server)                                                                                                                             | False     |
| Compress             | Set to 'gzip' to enable gzip compression. Incompatible with `Time_as_Integer=True` and tags set dynamically using the [Rewrite Tag](../filters/rewrite-tag.md) filter. Requires Fluentd server v0.14.7 or later. |  _none_  |
| Workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

## Secure Forward Mode Configuration Parameters

When using Secure Forward mode, the [TLS](../../administration/transport-security.md) mode requires to be enabled. The following additional configuration parameters are available:

| Key              | Description                                                                                                                               | Default   |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| Shared_Key       | A key string known by the remote Fluentd used for authorization.                                                                          |           |
| Empty_Shared_Key | Use this option to connect to Fluentd with a zero-length secret.                                                                          | False     |
| Username         | Specify the username to present to a Fluentd server that enables `user_auth`.                                                             |           |
| Password         | Specify the password corresponding to the username.                                                                                       |           |
| Self_Hostname    | Default value of the auto-generated certificate common name (CN).                                                                         | localhost |
| tls              | Enable or disable TLS support                                                                                                             | Off       |
| tls.verify       | Force certificate validation                                                                                                              | On        |
| tls.debug        | Set TLS debug verbosity level. It accept the following values: 0 (No debug), 1 (Error), 2 (State change), 3 (Informational) and 4 Verbose | 1         |
| tls.ca_file      | Absolute path to CA certificate file                                                                                                      |           |
| tls.crt_file     | Absolute path to Certificate file.                                                                                                        |           |
| tls.key_file     | Absolute path to private Key file.                                                                                                        |           |
| tls.key_passwd   | Optional password for tls.key_file file.                                                                                                  |           |

## Forward Setup

Before proceeding, make sure that [Fluentd](http://fluentd.org) is installed, if it's not the case please refer to the following [Fluentd Installation](http://docs.fluentd.org/v0.12/categories/installation) document and go ahead with that.

Once [Fluentd](http://fluentd.org) is installed, create the following configuration file example that will allow us to stream data into it:

```
<source>
  type forward
  bind 0.0.0.0
  port 24224
</source>

<match fluent_bit>
  type stdout
</match>
```

That configuration file specifies that it will listen for _TCP_ connections on the port _24224_ through the **forward** input type.
Then for every message with a _fluent_bit_ **TAG**, will print the message to the standard output.

In one terminal launch [Fluentd](http://fluentd.org) specifying the new configuration file created:

```bash
$ fluentd -c test.conf
2017-03-23 11:50:43 -0600 [info]: reading config file path="test.conf"
2017-03-23 11:50:43 -0600 [info]: starting fluentd-0.12.33
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
```

## Fluent Bit + Forward Setup <a href="forward_setup" id="forward_setup"></a>

Now that [Fluentd](http://fluentd.org) is ready to receive messages, we need to specify where the **forward** output plugin will flush the information using the following format:

```
bin/fluent-bit -i INPUT -o forward://HOST:PORT
```

If the **TAG** parameter is not set, the plugin will retain the tag.
Keep in mind that **TAG** is important for routing rules inside [Fluentd](http://fluentd.org).

Using the [CPU](../inputs/cpu-metrics.md) input plugin as an example we will flush CPU metrics to [Fluentd](http://fluentd.org) with tag _fluent_bit_:

```bash
bin/fluent-bit -i cpu -t fluent_bit -o forward://127.0.0.1:24224
```

Now on the [Fluentd](http://fluentd.org) side, you will see the CPU metrics gathered in the last seconds:

```bash
2017-03-23 11:53:06 -0600 fluent_bit: {"cpu_p":0.0,"user_p":0.0,"system_p":0.0,"cpu0.p_cpu":0.0,"cpu0.p_user":0.0,"cpu0.p_system":0.0,"cpu1.p_cpu":0.0,"cpu1.p_user":0.0,"cpu1.p_system":0.0,"cpu2.p_cpu":0.0,"cpu2.p_user":0.0,"cpu2.p_system":0.0,"cpu3.p_cpu":1.0,"cpu3.p_user":1.0,"cpu3.p_system":0.0}
2017-03-23 11:53:07 -0600 fluent_bit: {"cpu_p":2.25,"user_p":2.0,"system_p":0.25,"cpu0.p_cpu":3.0,"cpu0.p_user":3.0,"cpu0.p_system":0.0,"cpu1.p_cpu":1.0,"cpu1.p_user":1.0,"cpu1.p_system":0.0,"cpu2.p_cpu":1.0,"cpu2.p_user":1.0,"cpu2.p_system":0.0,"cpu3.p_cpu":3.0,"cpu3.p_user":2.0,"cpu3.p_system":1.0}
2017-03-23 11:53:08 -0600 fluent_bit: {"cpu_p":1.75,"user_p":1.0,"system_p":0.75,"cpu0.p_cpu":2.0,"cpu0.p_user":1.0,"cpu0.p_system":1.0,"cpu1.p_cpu":3.0,"cpu1.p_user":1.0,"cpu1.p_system":2.0,"cpu2.p_cpu":3.0,"cpu2.p_user":2.0,"cpu2.p_system":1.0,"cpu3.p_cpu":2.0,"cpu3.p_user":1.0,"cpu3.p_system":1.0}
2017-03-23 11:53:09 -0600 fluent_bit: {"cpu_p":4.75,"user_p":3.5,"system_p":1.25,"cpu0.p_cpu":4.0,"cpu0.p_user":3.0,"cpu0.p_system":1.0,"cpu1.p_cpu":5.0,"cpu1.p_user":4.0,"cpu1.p_system":1.0,"cpu2.p_cpu":3.0,"cpu2.p_user":2.0,"cpu2.p_system":1.0,"cpu3.p_cpu":5.0,"cpu3.p_user":4.0,"cpu3.p_system":1.0}
```

So we gathered [CPU](../inputs/cpu-metrics.md) metrics and flushed them out to [Fluentd](http://fluentd.org) properly.

## Fluent Bit + Secure Forward Setup <a href="secure_forward_setup" id="secure_forward_setup"></a>

> DISCLAIMER: the following example does not consider the generation of certificates for best practice on production environments.

Secure Forward aims to provide a secure channel of communication with the remote Fluentd service using [TLS](../../administration/transport-security.md).

### Fluent Bit

Paste this content in a file called _flb.conf_:

```
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

### Fluentd

Paste this content in a file called _fld.conf_:

```
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

If you're using Fluentd v1, set up it as below:

```
<source>
  @type forward
  <transport tls>
    cert_path /etc/td-agent/certs/fluentd.crt
    private_key_path /etc/td-agent/certs/fluentd.key
    private_key_passphrase password
  </transport>
  <security>
    self_hostname myserver.local
    shared_key secret
  </security>
</source>

<match **>
 @type stdout
</match>
```

### Test Communication

Start Fluentd:

```
fluentd -c fld.conf
```

Start Fluent Bit:

```
fluent-bit -c flb.conf
```

After five seconds, Fluent Bit will write records to Fluentd.
In Fluentd output you will see a message like this:

```
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
```
