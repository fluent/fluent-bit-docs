# SOMEIP

The **someip** input plugin is used to interact with a SOME/IP communication network to subscribe to events and to exchange request/response with SOME/IP services.

This plugin uses the [vsomeip library](https://github.com/COVESA/vsomeip) \(built-in dependency\).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description |
| ------------ | ----------- |
| Event        | SOME/IP event to subscribe to. The configuration can have multiple events, one on each line. An event is identified by a comma separated list with, "_service ID_, _event ID_, _event group ID 1_, _event group ID 2_, ...". The Event must include at least one _event group ID_, but can be associated with multiple. |
| RPC          | SOME/IP request to send when service is available. The configuration can have multiple RPCs, one on each line. An RPC is composed as a comma separated list with, "_service ID_, _service instance_, _method ID_, _request payload_". The request payload should be a should be base64 encoded |

## Getting Started

In order to subscribe to SOME/IP events or send request/receive SOME/IP response, you can run the plugin from the command line or through the configuration file:

### Command Line

The **someip** plugin can be enabled with options from the command line:

```bash
$ ./fluent-bit -i someip -p Event=4,1,32768,1 -o stdout
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

{% tabs %}
{% tab title="fluent-bit.conf" %}
```text
[INPUT]
    Name someip
    Tag  in.someip

    Event 4,1,32768,1
    Event 4,1,32769,2
    RPC   4,1,1,CgAQAw==

[OUTPUT]
    Name        stdout
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
  inputs:
    - name: someip
      Event: '4,1,32768,1'
      Event: '4,1,32769,2'
      RPC: '4,1,1,CgAQAw=='
```
{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you can send some SOME/IP messages using the SOME/IP test service provided.

```bash
$ bin/someip_test_service 
2025-02-06 22:18:06.211337  [info] Parsed vsomeip configuration in 0ms
...
Sending event with message Event Number 1
Sent notification for service 4, event 32768
Sending event with message Event Number 2
Sent notification for service 4, event 32768
```

In [Fluent Bit](http://fluentbit.io) we should see the following output:

```bash
$ bin/fluent-bit -i someip -p Event=4,1,32768,1 -o stdout
Fluent Bit v3.2.0
* Copyright (C) 2015-2024 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _           _____  _____ 
|  ___| |                | |   | ___ (_) |         |____ |/ __  \
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __   / /`' / /'
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / /   \ \  / /  
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /.___/ /./ /___
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/ \____(_)_____/


[2025/02/06 22:12:23] [ info] [fluent bit] version=3.2.0, commit=239b46be20, pid=51044
[2025/02/06 22:12:23] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/02/06 22:12:23] [ info] [simd    ] disabled
[2025/02/06 22:12:23] [ info] [cmetrics] version=0.9.8
[2025/02/06 22:12:23] [ info] [ctraces ] version=0.5.7
[2025/02/06 22:12:23] [ info] [input:someip:someip.0] initializing
[2025/02/06 22:12:23] [ info] [input:someip:someip.0] storage_strategy='memory' (memory only)
[2025/02/06 22:12:23] [ info] [input:someip:someip.0] Received 1 configured events
[2025/02/06 22:12:23] [ info] [input:someip:someip.0] No RPC configured.
...
2025-02-06 22:18:03.130557  [info] vSomeIP 3.5.1 | (default)
2025-02-06 22:18:06.223714  [info] Application/Client 0101 is registering.
2025-02-06 22:18:06.225581  [info] Client [100] is connecting to [101] at /tmp/vsomeip-101 endpoint > 0x79a50c000e30
2025-02-06 22:18:06.230477  [info] REGISTERED_ACK(0101)
2025-02-06 22:18:06.236103  [info] Port configuration missing for [4.1]. Service is internal.
2025-02-06 22:18:06.236923  [info] OFFER(0101): [0004.0001:0.0] (true)
2025-02-06 22:18:06.240237  [info] SUBSCRIBE ACK(0101): [0004.0001.0001.ffff]
Received message for service 4 event = 32768
[0] someip.0: [[1738880288.622425534, {}], {"record type"=>"event", "service"=>4, "instance"=>1, "event"=>32768, "payload"=>"RXZlbnQgTnVtYmVyIDE="}]
Received message for service 4 event = 32768
[0] someip.0: [[1738880290.622781511, {}], {"record type"=>"event", "service"=>4, "instance"=>1, "event"=>32768, "payload"=>"RXZlbnQgTnVtYmVyIDI="}]
...
```


