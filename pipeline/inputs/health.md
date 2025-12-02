# Health

The _Health_ input plugin lets you check how healthy a TCP server is. It checks by issuing a TCP connection at regular intervals.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key             | Description                                                                                                        | Default |
|:----------------|:-------------------------------------------------------------------------------------------------------------------|:--------|
| `add_host`      | If enabled, hostname is appended to each record.                                                                   | `false` |
| `add_port`      | If enabled, port number is appended to each record.                                                                | `false` |
| `alert`         | If enabled, it generates messages only when the target TCP service is down.                                        | `false` |
| `host`          | Name of the target host or IP address.                                                                             | _none_  |
| `interval_nsec` | Specify a nanoseconds interval for service checks. Works in conjunction with the `interval_sec` configuration key. | `0`     |
| `interval_sec`  | Interval in seconds between the service checks.                                                                    | `1`     |
| `port`          | TCP port where to perform the connection request.                                                                  | _none_  |
| `threaded`      | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).            | `false` |

## Get started

To start performing the checks, you can run the plugin from the command line or through the configuration file:

### Command line

From the command line you can let Fluent Bit generate the checks with the following options:

```shell
fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: health
      host: 127.0.0.1
      port: 80
      interval_sec: 1
      interval_nsec: 0

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name          health
  Host          127.0.0.1
  Port          80
  Interval_Sec  1
  Interval_NSec 0

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

## Testing

Once Fluent Bit is running, you will see health check results in the output interface similar to this:

```shell
$ fluent-bit -i health -p host=127.0.0.1 -p port=80 -o stdout

...
[0] health.0: [1624145988.305640385, {"alive"=>true}]
[1] health.0: [1624145989.305575360, {"alive"=>true}]
[2] health.0: [1624145990.306498573, {"alive"=>true}]
[3] health.0: [1624145991.305595498, {"alive"=>true}]
...
```