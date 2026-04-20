# Environment variables

The `env` section of YAML configuration files lets you define environment variables. These variables can then be used to dynamically replace values throughout your configuration using the `${VARIABLE_NAME}` syntax. The `env` section supports two forms: a map form for static key-value pairs and an extended list form for advanced use cases like file-backed secrets with automatic refresh.

Values set in the `env` section are case-sensitive. However, as a best practice, Fluent Bit recommends using uppercase names for environment variables.

## Map form

The map form defines variables as key-value pairs. The following example defines two variables, `FLUSH_INTERVAL` and `STDOUT_FMT`, which can be accessed in the configuration using `${FLUSH_INTERVAL}` and `${STDOUT_FMT}`:

```yaml
env:
  FLUSH_INTERVAL: 1
  STDOUT_FMT: 'json_lines'

service:
  flush: ${FLUSH_INTERVAL}
  log_level: info

pipeline:
  inputs:
    - name: random

  outputs:
    - name: stdout
      match: '*'
      format: ${STDOUT_FMT}
```

## Extended list form

The `env` section also accepts a YAML list of entries. Each entry is a mapping with the following properties:

| Property | Required | Description |
| :------- | :------- | :---------- |
| `name` | Yes | The name of the environment variable. |
| `value` | No | An explicit value for the variable. Mutually exclusive with `uri`. |
| `uri` | No | A URI pointing to the variable's value source. Currently supports `file://` URIs (for example, `file:///run/secrets/my_secret`). The file contents are read and used as the variable's value. |
| `refresh_interval` | No | How often (in seconds) to re-read the value from the `uri` source. Only meaningful when `uri` is set. Default is `0` (read once at startup). |

Either `value` or `uri` must be provided for each entry.

When `uri` and `refresh_interval` are both set, Fluent Bit re-reads the file at the specified interval. This enables dynamic configuration values, such as rotating secrets, without restarting Fluent Bit. If `refresh_interval` is `0` or omitted, the file is read only once at startup.

```yaml
env:
  - name: DB_PASSWORD
    uri: file:///run/secrets/db_password
    refresh_interval: 60
  - name: REGION
    value: us-east-1

service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: random

  outputs:
    - name: stdout
      match: '*'
```

In this example, `${DB_PASSWORD}` is read from the file `/run/secrets/db_password` and refreshed every 60 seconds. `${REGION}` is set to the static value `us-east-1`.

## Predefined variables

Fluent Bit supports the following predefined environment variables. You can reference these variables in configuration files without defining them in the `env` section.

| Name | Description |
| ---- | ----------- |
| `${HOSTNAME}` | The system's hostname. |

## External variables

In addition to variables defined in the configuration file or the predefined ones, Fluent Bit can access system environment variables set in the user space. These external variables can be referenced in the configuration using the same `${VARIABLE_NAME}` pattern.

{% hint style="info" %}
Variables set in the `env` section can't be overridden by system environment variables.
{% endhint %}

For example, to set the `FLUSH_INTERVAL` system environment variable to `2` and use it in your configuration:

```shell
export FLUSH_INTERVAL=2
```

In the configuration file, you can then access this value as follows:

```yaml
service:
  flush: ${FLUSH_INTERVAL}
  log_level: info

pipeline:
  inputs:
    - name: random

  outputs:
    - name: stdout
      match: '*'
      format: json_lines
```

This approach lets you manage and override configuration values using environment variables, providing flexibility in various deployment environments.
