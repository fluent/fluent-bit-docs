# Splunk

The _Splunk_ input plugin handles [Splunk HTTP HEC](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector) requests.

## Configuration parameters

This plugin uses the following configuration parameters:

| Key                        | Description                                                                                                                                                        | Default         |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| `listen`                   | The address to listen on.                                                                                                                                          | `0.0.0.0`       |
| `port`                     | The port for Fluent Bit to listen on.                                                                                                                              | `9880`          |
| `tag_key`                  | Specify the key name to overwrite a tag. If set, the tag will be overwritten by a value of the key.                                                                | _none_          |
| `buffer_max_size`          | Specify the maximum buffer size in KB to receive a JSON message.                                                                                                   | `4M`            |
| `buffer_chunk_size`        | This sets the chunk size for incoming JSON messages. These chunks are then stored and managed in the space available by `buffer_max_size`.                         | `512K`          |
| `successful_response_code` | Set the successful response code. Allowed values: `200`, `201`, and `204`                                                                                          | `201`           |
| `splunk_token`             | Specify a Splunk token for HTTP HEC authentication. If multiple tokens are specified (with commas and no spaces), usage will be divided across each of the tokens. | _none_          |
| `store_token_in_metadata`  | Store Splunk HEC tokens in the Fluent Bit metadata. If set to `false`, tokens will be stored as normal key-value pairs in the record data.                         | `true`          |
| `splunk_token_key`         | Use the specified key for storing the Splunk token for HTTP HEC. Use only when `store_token_in_metadata` is `false`.                                               | `@splunk_token` |
| `Threaded`                 | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs).                                                            | `false`         |

## Get started

To start performing the checks, you can run the plugin from the command line or through the configuration file.

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
  name   splunk
  listen 0.0.0.0
  port   8088

[OUTPUT]
  name  stdout
  match *
```

{% endtab %}
{% endtabs %}
