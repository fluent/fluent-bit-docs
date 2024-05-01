---
description: An input plugin to ingest payloads of Prometheus remote write
---

# Prometheus Remote Write

This input plugin allows you to ingest a payload in the Prometheus remote-write format, i.e. a remote write sender can transmit data to Fluent Bit.

The OpenTelemetry plugin allows you to ingest telemetry data as per the OTLP specification, from various OpenTelemetry exporters, the OpenTelemetry Collector, or Fluent Bit's OpenTelemetry output plugin.

## Configuration <a href="#configuration" id="configuration"></a>

| Key           | Description                                                                                                                                    | default |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| listen            | The address to listen on                                                                                                                       | 0.0.0.0 |
| port              | The port for Fluent Bit to listen on                                                                                                           | 80    |
| buffer\_max\_size   | Specify the maximum buffer size in KB to receive a JSON message.                                                                               | 4M      |
| buffer\_chunk\_size | This sets the chunk size for incoming incoming JSON messages. These chunks are then stored/managed in the space available by buffer_max_size.  | 512K    |
|successful\_response\_code | It allows to set successful response code. `200`, `201` and `204` are supported.| 201 |
| tag\_from\_uri      | If true, tag will be created from uri. e.g. v1_metrics from /v1/metrics .                                                                      | true    |



A sample config file to get started will look something like the following:


{% tabs %}
{% tab title="fluent-bit.conf" %}
```
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
{% endtabs %}

With the above configuration, Fluent Bit will listen on port `8080` for data. You can now send payloads of Prometheus remote write to the endpoints `/api/prom/push`.
