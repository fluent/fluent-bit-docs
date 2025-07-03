---
description: An input plugin to ingest payloads of Prometheus remote write
---

# Prometheus Remote Write

This input plugin allows you to ingest a payload in the Prometheus remote-write format, i.e. a remote write sender can transmit data to Fluent Bit.

## Configuration

| Key           | Description                                                                                                                                    | default |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| listen            | The address to listen on                                                                                                                       | 0.0.0.0 |
| port              | The port for Fluent Bit to listen on                                                                                                           | 8080    |
| buffer\_max\_size   | Specify the maximum buffer size in KB to receive a JSON message.                                                                               | 4M      |
| buffer\_chunk\_size | This sets the chunk size for incoming JSON messages. These chunks are then stored/managed in the space available by buffer_max_size.  | 512K    |
|successful\_response\_code | It allows to set successful response code. `200`, `201` and `204` are supported.| 201 |
| tag\_from\_uri      | If true, tag will be created from uri, e.g. api\_prom\_push from /api/prom/push, and any tag specified in the config will be ignored. If false then a tag must be provided in the config for this input. | true    |
| uri               | Specify an optional HTTP URI for the target web server listening for prometheus remote write payloads, e.g: /api/prom/push                       | |
| threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

A sample config file to get started will look something like the following:

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

With the above configuration, Fluent Bit will listen on port `8080` for data.
You can now send payloads in Prometheus remote write format to the endpoint `/api/prom/push`.

## Examples

### Communicate with TLS

Prometheus Remote Write input plugin supports TLS/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](../../administration/transport-security.md) section.

Communicating with TLS, you will need to use the tls related parameters:

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

Now, you should be able to send data over TLS to the remote write input.