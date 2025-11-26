# Vivo Exporter

Vivo Exporter is an output plugin that exposes logs, metrics, and traces through an HTTP endpoint. This plugin aims to be used in conjunction with [Vivo project](https://github.com/calyptia/vivo) .

## Configuration parameters

This plugin supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ---------|
| `empty_stream_on_read` | If enabled, when an HTTP client consumes the data from a stream, the stream content will be removed. | `Off` |
| `host` | The network address for the HTTP server to listen on. | `0.0.0.0` |
| `http_cors_allow_origin` | Specify the value for the HTTP `Access-Control-Allow-Origin` header (CORS). | _none_ |
| `port` | The TCP port for the HTTP server to listen on. | `2025` |
| `stream_queue_size`| Specify the maximum queue size per stream. Each specific stream for logs, metrics, and traces can hold up to `stream_queue_size` bytes. | `20M` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

### Get started

The following is an example configuration of Vivo Exporter. This example isn't based on defaults.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: events
      rate: 2

  outputs:
    - name: vivo_exporter
      match: '*'
      empty_stream_on_read: off
      stream_queue_size: 20M
      http_cors_allow_origin: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name  dummy
  tag   events
  rate  2

[OUTPUT]
  name                   vivo_exporter
  match                  *
  empty_stream_on_read   off
  stream_queue_size      20M
  http_cors_allow_origin *
```

{% endtab %}
{% endtabs %}

### How it works

Vivo Exporter provides buffers that serve as streams for each telemetry data type, in this case, `logs`, `metrics`, and `traces`. Each buffer contains a fixed capacity in terms of size (`20M` by default). When the data arrives at a stream, it's appended to the end. If the buffer is full, it removes the older entries to make room for new data.

The `data` that arrives is a `chunk`. A chunk is a group of events that belongs to the same type (logs, metrics, or traces) and contains the same `tag`. Every chunk placed in a stream is assigned with an auto-incremented `id`.

#### Requesting data from the streams

By using an HTTP request, you can retrieve the data from the streams. The following are the endpoints available:

| Endpoint                     | Description                                                                                                                   |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `/api/v1/logs`               | Exposes log events in JSON format. Each event contains a timestamp, metadata and the event content.                           |
| `/api/v1/metrics`            | Exposes metrics events in JSON format. Each metric contains name, metadata, metric type and labels (dimensions).              |
| `/api/v1/traces`             | Exposes trace events in JSON format. Each trace contains a name, resource spans, spans, attributes, events information, and so on. |
| `/api/v1/internal/metrics`   | Exposes internal Fluent Bit metrics in JSON format.                                                                          |

The following example generates dummy log events for consumption by using `curl` HTTP command line client:

1. Configure and start Fluent Bit.

   {% tabs %}
   {% tab title="fluent-bit.yaml" %}

   ```yaml
   pipeline:
     inputs:
       - name: dummy
         tag: events
         rate: 2

     outputs:
       - name: vivo_exporter
         match: '*'
   ```

   {% endtab %}
   {% tab title="fluent-bit.conf" %}

   ```text
   [INPUT]
     name  dummy
     tag   events
     rate  2

   [OUTPUT]
     name   vivo_exporter
     match  *
   ```

   {% endtab %}
   {% endtabs %}

1. Retrieve the data.

   ```shell
   curl -i http://127.0.0.1:2025/api/v1/logs
   ```

   The `-i` curl option prints the HTTP response headers.

Curl output would look like this:

```shell
HTTP/1.1 200 OK
Server: Monkey/1.7.0
Date: Tue, 21 Mar 2023 16:42:28 GMT
Transfer-Encoding: chunked
Content-Type: application/json
Vivo-Stream-Start-ID: 0
Vivo-Stream-End-ID: 3

[[1679416945459254000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416945959398000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416946459271000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416946959943000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416947459806000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416947958777000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416948459391000,{"_tag":"events"}],{"message":"dummy"}]
...
```

### Streams and IDs

As mentioned previously, each stream buffers a `chunk` that contains `N` events, with each chunk containing its own ID that's unique inside the stream.

After receiving the HTTP response, Vivo Exporter also reports the range of chunk IDs that were served in the response using the HTTP headers `Vivo-Stream-Start-ID` and `Vivo-Stream-End-ID`.

The values of these headers can be used by the client application to specify a range between IDs or set limits for the number of chunks to retrieve from the stream.

### Retrieve ranges and use limits

A client might be interested in always retrieving the latest chunks available and skip previous ones already processed. In a first request without any given range, Vivo Exporter will provide all the content that exists in the buffer for the specific stream. On that response, the client might want to keep the last ID (`Vivo-Stream-End-ID`) that was received.

To query ranges or starting from specific chunks IDs, remember that they're incremental. You can use a mix of the following options:

| Query string option | Description |
|---------------------|-------------|
| `from` | Specify the first chunk ID to be retrieved. If the `chunk` ID doesn't exist, the next one in the queue will be provided. |
| `to` | The last chunk ID to be retrieved. If not found, the whole stream will be provided (starting from `from` if was set). |
| `limit` | Limit the output to a specific number of chunks. The default value is `0`, which sends everything. |

The following example specifies the range from chunk ID `1` to chunk ID `3` and only one chunk:

```shell
curl -i "http://127.0.0.1:2025/api/v1/logs?from=1&to=3&limit=1"
```

Output:

```shell
HTTP/1.1 200 OK
Server: Monkey/1.7.0
Date: Tue, 21 Mar 2023 16:45:05 GMT
Transfer-Encoding: chunked
Content-Type: application/json
Vivo-Stream-Start-ID: 1
Vivo-Stream-End-ID: 1

[[1679416945959398000,{"_tag":"events"}],{"message":"dummy"}]
[[1679416946459271000,{"_tag":"events"}],{"message":"dummy"}]
...
```

### Log output format with groups

When log events contain group metadata or attributes, the Vivo Exporter includes additional fields in the JSON output. The output format depends on whether the data is `OTLP` (OpenTelemetry) formatted or standard Fluent Bit data.

For `OTLP` data (when `schema` is set to `otlp`), the output includes an `otlp` field:

```json
{
  "source_type": "opentelemetry",
  "source_name": "opentelemetry.0",
  "tag": "my.logs",
  "records": [...],
  "otlp": {
    "resource": {...},
    "scope": {...}
  }
}
```

For non-`OTLP` data with group information, the output includes a `flb_group` field:

```json
{
  "source_type": "forward",
  "source_name": "forward.0",
  "tag": "my.logs",
  "records": [...],
  "flb_group": {
    "metadata": {...},
    "body": {...}
  }
}
```
