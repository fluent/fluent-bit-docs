---
description: An input plugin to ingest payloads of Prometheus remote write
---

# Prometheus remote write

The _Prometheus remote write_ input plugin lets you ingest a payload in the Prometheus remote-write format. A remote-write sender can transmit data to Fluent Bit.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `listen` | The address to listen on. | `0.0.0.0` |
| `port` | The port to listen on. | `8080` |
| `buffer_max_size` | Specifies the maximum buffer size in KB to receive a JSON message. | `4M` |
| `buffer_chunk_size` | Sets the chunk size for incoming JSON messages. These chunks are then stored and managed in the space specified by `buffer_max_size`. | `512K` |
| `successful_response_code` | Specifies the success response code. Supported values are `200`, `201`, and `204`. | `201` |
| `tag_from_uri` | If true, a tag will be created from the `uri` parameter (for example, `api_prom_push` from `/api/prom/push`), and any tag specified in the configuration will be ignored. If false, you must provide a tag in the configuration for this plugin. | `true` |
| `uri` | Specifies an optional HTTP URI for the target web server listening for Prometheus remote write payloads (for example, `/api/prom/push`). | _none_ |
| `threaded` | Specifies whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Configuration file

The following examples are sample configuration files for this input plugin:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: prometheus_remote_write
          listen: 127.0.0.1
          port: 8080
          uri: /api/prom/push

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    name prometheus_remote_write
    listen 127.0.0.1
    port 8080
    uri /api/prom/push

[OUTPUT]
    name stdout
    match *
```

{% endtab %}
{% endtabs %}

These sample configurations configure Fluent Bit to listen for data on port `8080`. You can send payloads in Prometheus remote-write format to the endpoint `/api/prom/push`.

## Examples

### Communicate with TLS

The Prometheus remote write input plugin supports TLS and SSL. For more details about the properties available and general configuration, refer to the [Transport security](../../administration/transport-security.md) documentation.

To communicate with TLS, you must use these TLS-related parameters:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: prometheus_remote_write
          listen: 127.0.0.1
          port: 8080
          uri: /api/prom/push
          tls: on
          tls.crt_file: /path/to/certificate.crt
          tls.key_file: /path/to/certificate.key
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name prometheus_remote_write
    Listen 127.0.0.1
    Port 8080
    Uri /api/prom/push
    Tls On
    tls.crt_file /path/to/certificate.crt
    tls.key_file /path/to/certificate.key
```

{% endtab %}
{% endtabs %}

Now, you should be able to send data over TLS to the remote-write input.
