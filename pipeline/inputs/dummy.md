# Dummy

The _Dummy_ input plugin, generates dummy events. Use this plugin for testing, debugging, benchmarking and getting started with Fluent Bit.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                | Description | Default |
| :----------------- | :---------- | :------ |
| `Dummy`              | Dummy JSON record. | `{"message":"dummy"}` |
| `Metadata`           | Dummy JSON metadata. | `{}` |
| `Start_time_sec`   | Dummy base timestamp, in seconds. | `0` |
| `Start_time_nsec`  | Dummy base timestamp, in nanoseconds. | `0` |
| `Rate`               | Rate at which messages are generated expressed in how many times per second. | `1` |
| `Interval_sec`      | Set time interval, in seconds, at which every message is generated. If set, `Rate` configuration is ignored. | `0` |
| `Interval_nsec`     | Set time interval, in nanoseconds, at which every message is generated. If set, `Rate` configuration is ignored. | `0` |
| `Samples`            | If set, the events number will be limited. For example, if Samples=3, the plugin generates only three events and stops. | _none_ |
| `Copies`             | Number of messages to generate each time messages generate. | `1` |
| `Flush_on_startup` | If set to `true`, the first dummy event is generated at startup. | `false` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

Run the plugin from the command line using the following command:

```shell
fluent-bit -i dummy -o stdout
```

which returns results like the following:

```text
Fluent Bit v2.x.x
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[0] dummy.0: [[1686451466.659962491, {}], {"message"=>"dummy"}]
[0] dummy.0: [[1686451467.659679509, {}], {"message"=>"dummy"}]
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"message": "custom dummy"}'
  
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name   dummy
    Dummy {"message": "custom dummy"}

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}