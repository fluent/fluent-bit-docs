# Docker events

The _Docker events_ input plugin uses the Docker API to capture server events. A complete list of possible events returned by this plugin can be found [in the Docker documentation](https://docs.docker.com/reference/cli/docker/system/events/).

## Configuration parameters

This plugin supports the following configuration parameters:

| Key                        | Description                                                                                                     | Default                |
|:---------------------------|:----------------------------------------------------------------------------------------------------------------|:-----------------------|
| `buffer_size`              | The size of the buffer used to read docker events in bytes.                                                     | `8192`                 |
| `key`                      | When a message is unstructured (no parser applied), it's appended as a string under the key name `message`.     | `message`              |
| `parser`                   | Specify the name of a parser to interpret the entry as a structured message.                                    | _none_                 |
| `reconnect.retry_interval` | The retry interval in seconds.                                                                                  | `1`                    |
| `reconnect.retry_limits`   | The maximum number of retries allowed. The plugin tries to reconnect with docker socket when `EOF` is detected. | `5`                    |
| `threaded`                 | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).         | `false`                |
| `unix_path`                | The docker socket Unix path.                                                                                    | `/var/run/docker.sock` |

## Get started

To capture Docker events, you can run the plugin from the command line or through the configuration file.

### Command line

From the command line you can run the plugin with the following options:

```shell
fluent-bit -i docker_events -o stdout
```

### Configuration file

In your main configuration file, append the following:

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
