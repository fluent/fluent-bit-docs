# MQTT

The **MQTT** input plugin, allows to retrieve messages/data from MQTT control packets over a TCP connection. The incoming data to receive _must_ be a JSON map.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         | Description                                                    | Default |
| :---------- | :------------------------------------------------------------- | :------ |
| Listen      | Listener network interface                                     | 0.0.0.0 |
| Port        | TCP port where listening for connections                       | 1883    |
| Payload_Key | Specify the key where the payload key/value will be preserved. |         |

## Getting Started

In order to start listening for MQTT messages, you can run the plugin from the command line or through the configuration file:

### Command Line

Since the **MQTT** input plugin let Fluent Bit behave as a server, we need to dispatch some messages using some MQTT client, in the following example _mosquitto_ tool is being used for the purpose:

```bash
$ fluent-bit -i mqtt -t data -o stdout -m '*'
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2016/05/20 14:22:52] [ info] starting engine
[0] data: [1463775773, {"topic"=>"some/topic", "key1"=>123, "key2"=>456}]
```

The following command line will send a message to the **MQTT** input plugin:

```bash
$ mosquitto_pub  -m '{"key1": 123, "key2": 456}' -t some/topic
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name   mqtt
    Tag    data
    Listen 0.0.0.0
    Port   1883

[OUTPUT]
    Name   stdout
    Match  *
```

