# Dummy

The _Dummy_ input plugin generates dummy events. Use this plugin for testing, debugging, benchmarking and getting started with Fluent Bit.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:----|:------------|:--------|
| `copies` | Number of messages to generate each time messages are generated. | `1` |
| `dummy` | Dummy JSON record. | `{"message":"dummy"}` |
| `fixed_timestamp` | If enabled, use a fixed timestamp. This allows the message to be pre-generated once. | `false` |
| `flush_on_startup` | If set to `true`, the first dummy event is generated at startup. | `false` |
| `interval_nsec` | Set time interval, in nanoseconds, at which every message is generated. If set, `rate` configuration is ignored. | `0` |
| `interval_sec` | Set time interval, in seconds, at which every message is generated. If set, `rate` configuration is ignored. | `0` |
| `metadata` | Dummy JSON metadata. | `{}` |
| `rate` | Rate at which messages are generated, expressed in how many times per second. | `1` |
| `samples` | Limit the number of events generated. For example, if `samples=3`, the plugin generates only three events and stops. `0` means no limit. | `0` |
| `start_time_nsec` | Set a dummy base timestamp, in nanoseconds. If set to `-1`, the current time is used. | `-1` |
| `start_time_sec` | Set a dummy base timestamp, in seconds. If set to `-1`, the current time is used. | `-1` |
| `threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

Run the plugin from the command line using the following command:

```shell
fluent-bit -i dummy -o stdout
```

which returns results like the following:

```text
...
[0] dummy.0: [[1686451466.659962491, {}], {"message"=>"dummy"}]
[0] dummy.0: [[1686451467.659679509, {}], {"message"=>"dummy"}]
...
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
  Dummy  {"message": "custom dummy"}

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}
