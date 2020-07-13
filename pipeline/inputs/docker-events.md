# Docker events

The **docker events** input plugin uses the docker API to capture server events. A complete list of possible events returned by this plugin can be found [here](https://docs.docker.com/engine/reference/commandline/events/)

## Configuration Parameters

This plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Unix_Path | The docker socket unix path | /var/run/docker.sock |
| Buffer_Size | The size of the buffer used to read docker events (in bytes) | 8192 |
| Parser | Specify the name of a parser to interpret the entry as a structured message. | None |
| Key | When a message is unstructured \(no parser applied\), it's appended as a string under the key name _message_. | message |

### Command Line

```bash
$ fluent-bit -i docker_events -o stdout
```

### Configuration File

In your main configuration file append the following **Input** & **Output** sections:

```yaml
[INPUT]
    Name   docker_events

[OUTPUT]
    Name   stdout
    Match  *
```

