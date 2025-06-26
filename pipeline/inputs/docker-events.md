# Docker events

The _Docker events_ input plugin uses the Docker API to capture server events. A complete list of possible events returned by this plugin can be found [in the Docker documentation](https://docs.docker.com/engine/reference/commandline/events/).

## Configuration parameters

This plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Unix_Path` | The docker socket Unix path. | `/var/run/docker.sock` |
| `Buffer_Size` | The size of the buffer used to read docker events in bytes. | `8192` |
| `Parser` | Specify the name of a parser to interpret the entry as a structured message. | _none_ |
| `Key` | When a message is unstructured (no parser applied), it's appended as a string under the key name `message`. | `message` |
| `Reconnect.Retry_limits`| The maximum number of retries allowed. The plugin tries to reconnect with docker socket when `EOF` is detected. | `5` |
| `Reconnect.Retry_interval`| The retry interval in seconds. | `1` |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

### Command line

You can run this plugin from the command line:

```shell
$ fluent-bit -i docker_events -o stdout
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: docker_events

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name   docker_events

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}