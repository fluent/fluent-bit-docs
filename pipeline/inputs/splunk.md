# Splunk

The _Splunk_ input plugin handles [Splunk HTTP HEC](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector) requests.

## Configuration parameters

This plugin uses the following configuration parameters:

| Key                       | Description                                                                                                                                                        | Default         |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| `add_remote_addr`         | Inject the client remote address into the record. The value is extracted from the X-Forwarded-For header if present, otherwise from the connection address.        | `false`         |
| `buffer_chunk_size`       | Set the chunk size for incoming JSON messages. These chunks are then stored and managed in the space available by `buffer_max_size`.                               | `512K`          |
| `buffer_max_size`         | Set the maximum buffer size to receive a JSON message.                                                                                                             | `4M`            |
| `http2`                   | Enable HTTP/2 support.                                                                                                                                             | `true`          |
| `listen`                  | The address to listen on.                                                                                                                                          | `0.0.0.0`       |
| `port`                    | The port for Fluent Bit to listen on.                                                                                                                              | `8088`          |
| `remote_addr_key`         | Set the record key used to store the remote address when `add_remote_addr` is enabled.                                                                             | `remote_addr`   |
| `splunk_token`            | Specify a Splunk token for HTTP HEC authentication. If multiple tokens are specified (with commas and no spaces), usage will be divided across each of the tokens. | _none_          |
| `splunk_token_key`        | Set a record key for storing the Splunk token for HTTP HEC. Use only when `store_token_in_metadata` is `false`.                                                    | `@splunk_token` |
| `store_token_in_metadata` | Store Splunk HEC tokens in the Fluent Bit metadata. If set to `false`, they will be stored as key-value pairs in the record data.                                  | `true`          |
| `success_header`          | Add an HTTP header key/value pair on success. Multiple headers can be set.                                                                                         | _none_          |
| `tag_key`                 | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                                                | _none_          |
| `threaded`                | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                            | `false`         |

## Get started

To get started, you can run the plugin from the command line or through the configuration file.

### Set a tag

The tag for the Splunk input plugin is set by adding the tag to the end of the request URL by default. This tag is then used to route the event through the system. The default behavior of the Splunk input sets the tags for the following endpoints:

- `/services/collector`
- `/services/collector/event`
- `/services/collector/raw`

The requests for these endpoints are interpreted as `services_collector`, `services_collector_event`, and `services_collector_raw`.

To use the other tags for multiple instantiating input Splunk plugins, you must specify the `tag` property on each Splunk plugin configuration to prevent data pipeline collisions.

### Command line

From the command line you can configure Fluent Bit to handle HTTP HEC requests with the following options:

```shell
fluent-bit -i splunk -p port=8088 -o stdout
```

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: splunk
      listen: 0.0.0.0
      port: 8088

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name   splunk
    Listen 0.0.0.0
    Port   8088

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

### Authentication with `HEC` tokens

To require authentication, specify one or more `Splunk` `HEC` tokens. Multiple tokens can be provided as a comma-separated list:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: splunk
      port: 8088
      splunk_token: "my-secret-token,another-token"

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name         splunk
    Port         8088
    Splunk_Token my-secret-token,another-token

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

### Custom success headers

Use `success_header` to add custom HTTP headers to successful responses. Use this for CORS or other HTTP requirements:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: splunk
      port: 8088
      success_header: "X-Custom-Header myvalue"

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name           splunk
    Port           8088
    Success_Header X-Custom-Header myvalue

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}
