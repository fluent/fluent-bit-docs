# Vivo Exporter

{% hint style="info" %}
**Supported event types:** `logs` `metrics` `traces`
{% endhint %}

Vivo Exporter is an output plugin that exposes logs, metrics, and traces through an HTTP endpoint. This plugin aims to be used in conjunction with [Vivo project](https://github.com/chronosphereio/calyptia-vivo).

Vivo Exporter is a bounded, volatile, best-effort inspection output. A successful flush means the data entered a local in-memory queue, not that a client received it. Eviction and process exit lose history. Use a separate output when you need delivery or retention guarantees.

## Configuration parameters

This plugin supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `compress` | Compress HTTP response bodies with gzip when the client accepts it through `Accept-Encoding`. | `on` |
| `empty_stream_on_read` | Deprecated. Setting this to `on` causes startup to fail, because reads can't consume a stream shared by multiple viewers. | `off` |
| `host` | The network address for the HTTP server to listen on. | `127.0.0.1` |
| `http_cors_allow_origin` | Specify the value for the HTTP `Access-Control-Allow-Origin` header (CORS). | _none_ |
| `http_server.idle_timeout` | Maximum time an idle HTTP client connection is kept open. Connections that remain idle beyond this duration are closed. Accepts time values such as `10s` or `1m`. | `10s` |
| `port` | The TCP port for the HTTP server to listen on. | `2025` |
| `stream_page_size` | Maximum uncompressed size of a single stream response page, and of a single retained entry. The minimum value is `1K`. | `1M` |
| `stream_queue_size` | Maximum retained payload size per stream. Each stream for logs, metrics, and traces can hold up to `stream_queue_size` bytes. Must be greater than `0`. | `20M` |
| `workers` | Number of HTTP listener workers. For this plugin, `workers` is an alias of `http_server.workers`. Only `1` is supported; any other value causes startup to fail. | `1` |

{% hint style="warning" %}
The default `host` changed from `0.0.0.0` to `127.0.0.1`. Deployments that relied on the previous all-interface default must set `host` explicitly for remote access.

The HTTP listener has no authentication or TLS. For remote access, place it behind an authenticated HTTPS reverse proxy and restrict access to the listener. CORS doesn't provide access control.

Binding to `127.0.0.1` doesn't prevent browser access. When `http_cors_allow_origin` is `*`, any web page open in a browser on the same host can read the telemetry from the listener. Leave `http_cors_allow_origin` unset unless a browser UI needs access, and then set it to that UI's exact origin.
{% endhint %}

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
      host: 127.0.0.1
      port: 2025
      stream_queue_size: 20M
      stream_page_size: 1M
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  dummy
  Tag   events
  Rate  2

[OUTPUT]
  Name              vivo_exporter
  Match             *
  Host              127.0.0.1
  Port              2025
  Stream_Queue_Size 20M
  Stream_Page_Size  1M
```

{% endtab %}
{% endtabs %}

### How it works

Vivo Exporter provides buffers that serve as streams for each telemetry data type: `logs`, `metrics`, and `traces`. Each stream has a fixed capacity set by `stream_queue_size` (`20M` by default). The limit applies per stream and counts both the `v1` and `v2` representations of each entry. When data arrives at a stream, it's appended to the end. If the stream is full, the oldest entries are removed until the new entry fits.

The data that arrives is a `chunk`, a group of events of the same type (logs, metrics, or traces) with the same `tag`. Chunks that exceed the entry size limit are split at log record, metric context, or trace context boundaries, preserving order and log groups. Each resulting entry is assigned an auto-incremented ID. All entries for a chunk are published at once, so clients never see a partially published chunk. If a chunk's entries together exceed `stream_queue_size`, its own earliest entries are evicted to make room for its later entries before any client can read them. Their IDs are still allocated and counted as evictions, and the flush still succeeds. A single log record, metric context, or trace context too large to fit is rejected, along with the rest of its chunk, without evicting existing entries. Fluent Bit logs this as an output failure.

Reading a stream never removes entries, so multiple clients can inspect the same stream.

#### Requesting data from the streams

By using an HTTP request, you can retrieve the data from the streams. Two API versions are available, and both share the same entry IDs and retention:

- `v1` returns the legacy Fluent Bit JSON format as newline-delimited JSON (`application/x-ndjson`).
- `v2` returns `application/json`: one page envelope per response that contains OpenTelemetry (OTLP) JSON export request payloads.

| Endpoint | Description |
| -------- | ----------- |
| `/api/v1/logs`, `/api/v2/logs` | Exposes log events. |
| `/api/v1/metrics`, `/api/v2/metrics` | Exposes metrics events. |
| `/api/v1/traces`, `/api/v2/traces` | Exposes trace events. |
| `/api/v1/internal/metrics`, `/api/v2/internal/metrics` | Exposes a snapshot of internal Fluent Bit metrics. `v2` returns a single OTLP metrics export request with no page envelope or cursor. |
| `/api/v1/health`, `/api/v2/health` | Reports the supported API versions, framing, and compression without reading telemetry. |

The endpoints accept `GET`, `HEAD`, and `OPTIONS` requests. `HEAD` returns the same headers as `GET` without a body. Neither `HEAD` nor `OPTIONS` consume telemetry. Other methods return `405`. Responses include `Cache-Control: no-store`.

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
     Name  dummy
     Tag   events
     Rate  2

   [OUTPUT]
     Name   vivo_exporter
     Match  *
   ```

   {% endtab %}
   {% endtabs %}

1. Retrieve the data.

   ```shell
   curl -i http://127.0.0.1:2025/api/v1/logs
   ```

   The `-i` curl option prints the HTTP response headers.

The `v1` response contains one JSON object per line. Each object is one entry: the source plugin, the tag, the `records` array, where every record is `[[TIMESTAMP, METADATA], BODY]`, and a `record_groups` array. `record_groups` has one object per record, in the same order. Each object contains the record's group `metadata` and `attributes`. When the record has no group, both `metadata` and `attributes` are `null`:

```text
{"source_type":"dummy","source_name":"dummy.0","tag":"events","records":[[[1679416945459254000,{}],{"message":"dummy"}]],"record_groups":[{"metadata":null,"attributes":null}]}
{"source_type":"dummy","source_name":"dummy.0","tag":"events","records":[[[1679416945959398000,{}],{"message":"dummy"}]],"record_groups":[{"metadata":null,"attributes":null}]}
```

To retrieve the same entries as OTLP JSON, request the `v2` endpoint:

```shell
curl "http://127.0.0.1:2025/api/v2/logs?limit=100"
```

The `v2` response is a page envelope. Each entry's `payload` contains `resourceLogs`, `resourceMetrics`, or `resourceSpans` according to the signal, following the [OTLP JSON encoding](https://opentelemetry.io/docs/specs/otlp/#json-protobuf-encoding). The following example, formatted for readability, shows the same two `dummy` entries. These records have no group, so the resource and scope are empty, and the record body becomes an OTLP `kvlistValue`:

```json
{
  "schemaVersion": 2,
  "signal": "logs",
  "generation": "3f9c2a7e1b5d4c8f0a6e2d9b7c1f4a3e5d8b",
  "nextCursor": "2",
  "oldestCursor": "0",
  "tailCursor": "2",
  "gap": false,
  "entries": [
    {
      "id": "0",
      "source": {"type": "dummy", "name": "dummy.0", "tag": "events"},
      "payload": {
        "resourceLogs": [
          {
            "resource": {"attributes": []},
            "scopeLogs": [
              {
                "scope": {"attributes": []},
                "logRecords": [
                  {
                    "timeUnixNano": "1679416945459254000",
                    "attributes": [],
                    "body": {"kvlistValue": {"values": [{"key": "message", "value": {"stringValue": "dummy"}}]}}
                  }
                ]
              }
            ]
          }
        ]
      }
    },
    {
      "id": "1",
      "source": {"type": "dummy", "name": "dummy.0", "tag": "events"},
      "payload": {
        "resourceLogs": [
          {
            "resource": {"attributes": []},
            "scopeLogs": [
              {
                "scope": {"attributes": []},
                "logRecords": [
                  {
                    "timeUnixNano": "1679416945959398000",
                    "attributes": [],
                    "body": {"kvlistValue": {"values": [{"key": "message", "value": {"stringValue": "dummy"}}]}}
                  }
                ]
              }
            ]
          }
        ]
      }
    }
  ]
}
```

Empty pages contain `"entries": []` and the same cursor metadata.

#### Response compression

When `compress` is `on`, stream and internal metrics responses use gzip if the client accepts it through `Accept-Encoding`. Without that header, or when gzip isn't acceptable, the response is uncompressed. If the client accepts neither gzip nor uncompressed (`identity`) responses, the server returns `406`. Responses include `Vary: Accept-Encoding`. Browsers decompress `fetch()` responses automatically. To test with `curl`, use `curl --compressed`, or `curl -H 'Accept-Encoding: identity'` for an uncompressed response.

### Streams and IDs

As mentioned previously, each stream buffers entries, with each entry containing its own ID that's unique inside the stream.

Stream responses report the stream position in the following HTTP headers. Numeric values are decimal strings.

| Header | Description |
| ------ | ----------- |
| `vivo-stream-generation` | Random identifier for this plugin instance. It changes when Fluent Bit restarts. |
| `vivo-stream-start-id`, `vivo-stream-end-id` | First and last entry IDs returned. Absent on empty pages. |
| `vivo-stream-next-id` | Last returned ID plus one, or the current tail on an empty page. |
| `vivo-stream-oldest-id` | Earliest retained entry ID, or the tail when the stream is empty. |
| `vivo-stream-tail-id` | Next ID that will be allocated. |
| `vivo-stream-gap` | `true` when the requested `from` is older than the oldest retained entry or ahead of the tail, otherwise `false`. |
| `vivo-stream-retained-bytes`, `vivo-stream-retained-entries` | Current retained payload size and entry count. |
| `vivo-stream-evicted-entries`, `vivo-stream-evicted-bytes` | Cumulative count and size of entries evicted to make room. |
| `vivo-stream-rejected-entries` | Cumulative count of entries rejected for exceeding a size limit. |

Keep the generation together with the cursor. When the generation changes, restart from `vivo-stream-oldest-id` to replay retained data, or from `vivo-stream-tail-id` for new data only.

Within the same generation, compare the requested `from` with the response headers to identify the cause of a gap:

- `from` is less than `vivo-stream-oldest-id`: older entries expired before the client read them. Report the lost history and resume from the oldest retained ID. The response already starts at that entry.
- `from` is greater than `vivo-stream-tail-id`: the cursor is ahead of the stream and was never issued by this instance. No entries were lost, and the response is empty. Discard the cursor and resume from `vivo-stream-tail-id`, which equals `vivo-stream-next-id` in that response. Don't restart from `vivo-stream-oldest-id`, which would replay entries the client might already have processed.

### Retrieve ranges and use limits

A client might be interested in always retrieving the latest entries available and skip previous ones already processed. In a first request without any given range, Vivo Exporter returns retained entries for the stream, up to `stream_page_size` bytes. Use `vivo-stream-next-id` (or `nextCursor` in `v2`) as the `from` value of the next request.

You can use a mix of the following query string options:

| Query string option | Description |
| ------------------- | ----------- |
| `from` | First entry ID to retrieve, inclusive. If omitted, retrieval starts at the oldest retained entry. |
| `to` | Last entry ID to retrieve, inclusive. If omitted, retrieval continues to the tail. |
| `limit` | Maximum number of entries to return. Must be greater than `0`. |

Values must be non-negative integers. Unknown, duplicate, empty, or malformed options, `limit=0`, and a `from` greater than `to` return `400`.

The following example requests entries from ID `1` to ID `3`, returning at most one entry:

```shell
curl -i "http://127.0.0.1:2025/api/v1/logs?from=1&to=3&limit=1"
```

### Log output format with groups

Fluent Bit log events can include group metadata and attributes that provide additional context about the log source. Groups are automatically included in Vivo Exporter output when the input plugin provides them. No additional configuration is required on the Vivo Exporter.

Groups appear in the output when using input plugins that support log event grouping, such as the [OpenTelemetry input](../inputs/opentelemetry.md). In `v2`, groups map to OTLP resource and scope fields. In `v1`, the `record_groups` array always carries the group `metadata` and `attributes` of each record. When every record in an entry belongs to the same group, the entry also includes a single-group convenience field, whose format depends on whether the data is OpenTelemetry (`OTLP`) formatted or standard Fluent Bit data. When an entry mixes records from different groups, the convenience field is omitted and only `record_groups` identifies each record's group.

#### OTLP grouped output format

When receiving logs from the OpenTelemetry input (where `schema` is set to `otlp` in the group metadata), the `v1` output includes an `otlp` field containing `resource` and `scope` attributes:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: opentelemetry
      tag: otel.logs
      port: 4318

  outputs:
    - name: vivo_exporter
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name opentelemetry
  Tag  otel.logs
  Port 4318

[OUTPUT]
  Name  vivo_exporter
  Match *
```

{% endtab %}
{% endtabs %}

Retrieve the grouped logs:

```shell
curl -i http://127.0.0.1:2025/api/v1/logs
```

Example output with OTLP groups, formatted for readability. The `otlp` field copies the `resource` and `scope` values from the group attributes, and `record_groups` holds the full group of each record. Group contents are abbreviated:

```json
{
  "source_type": "opentelemetry",
  "source_name": "opentelemetry.0",
  "tag": "otel.logs",
  "records": [[[1679416945459254000, {"severity_text": "INFO"}], {"message": "example log"}]],
  "otlp": {
    "resource": {"service.name": "my-service", "host.name": "server-1"},
    "scope": {"name": "my-library", "version": "1.0.0"}
  },
  "record_groups": [
    {
      "metadata": {"schema": "otlp"},
      "attributes": {
        "resource": {"service.name": "my-service", "host.name": "server-1"},
        "scope": {"name": "my-library", "version": "1.0.0"}
      }
    }
  ]
}
```

#### Non-OTLP grouped output format

For non-OTLP data with group information (from other inputs that support grouping), the `v1` output includes a `flb_group` field, where `metadata` holds the group metadata and `body` holds the group attributes. In `record_groups`, the same group attributes appear under `attributes`:

```json
{
  "source_type": "forward",
  "source_name": "forward.0",
  "tag": "my.logs",
  "records": [[[1679416945459254000, {}], {"message": "example log"}]],
  "flb_group": {
    "metadata": {"custom_field": "value"},
    "body": {"additional_context": "data"}
  },
  "record_groups": [
    {
      "metadata": {"custom_field": "value"},
      "attributes": {"additional_context": "data"}
    }
  ]
}
```
