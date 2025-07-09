# MQTT

The _MQTT_ input plugin retrieves messages and data from MQTT control packets over a TCP connection. The incoming data to receive must be a JSON map.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key         | Description                                                    | Default |
| :---------- | :------------------------------------------------------------- | :------ |
| `Listen`      | Listener network interface. | `0.0.0.0` |
| `Port`        | TCP port where listening for connections. | `1883` |
| `Payload_Key` | Specify the key where the payload key/value will be preserved. | _none_ |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To listen for MQTT messages, you can run the plugin from the command line or through the configuration file.

### Command line

The MQTT input plugin lets Fluent Bit behave as a server. Dispatch some messages using a MQTT client. In the following example, the `mosquitto` tool is being used for the purpose:

Running the following command:

```shell
fluent-bit -i mqtt -t data -o stdout -m '*'
```

Returns a response like the following:

```text
Fluent Bit v4.0.3
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/07/01 14:44:47] [ info] [fluent bit] version=4.0.3, commit=f5f5f3c17d, pid=1
[2025/07/01 14:44:47] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/01 14:44:47] [ info] [simd    ] disabled
[2025/07/01 14:44:47] [ info] [cmetrics] version=1.0.3
[2025/07/01 14:44:47] [ info] [ctraces ] version=0.6.6
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] initializing
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] storage_strategy='memory' (memory only)
[2025/07/01 14:44:47] [ info] [sp] stream processor started
[2025/07/01 14:44:47] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
[2025/07/01 14:44:47] [ info] [output:stdout:stdout.0] worker #0 started
[0] data: [1463775773, {"topic"=>"some/topic", "key1"=>123, "key2"=>456}]
```

The following command line will send a message to the MQTT input plugin:

```shell
mosquitto_pub  -m '{"key1": 123, "key2": 456}' -t some/topic
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mqtt
          tag: data
          listen: 0.0.0.0
          port: 1883
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name   mqtt
    Tag    data
    Listen 0.0.0.0
    Port   1883

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}