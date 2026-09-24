---
description: Trigger an immediate flush over HTTP, independent of the periodic Flush interval
---

# On-demand flush

Fluent Bit supports triggering a flush of currently buffered records on demand, over the HTTP server, independent of the configured periodic `Flush` interval.

## Enable the HTTP server

To get started with on-demand flush over HTTP, enable the HTTP Server in the configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020
```

{% endtab %}
{% endtabs %}

## How to flush

After enabling the HTTP server, use one of the following methods to trigger an on-demand flush:

### HTTP

Use the following HTTP endpoints to trigger an on-demand flush:

- `PUT /api/v2/flush`
- `POST /api/v2/flush`

The endpoint ignores the request body, so no payload is required. To trigger a flush with curl:

```shell
curl -X POST http://localhost:2020/api/v2/flush
```

Obtain a count of on-demand flushes using the HTTP endpoint:

- `GET /api/v2/flush`

The endpoint returns `flush_now_count` as follows:

```json
{"flush_now_count":3}
```

The default value of the counter is `0`.

## What a flush does

An on-demand flush performs two steps. Fluent Bit first invalidates any pending retries and reschedules them to run immediately, so chunks waiting in retry backoff are sent without waiting out their backoff timer. Tasks that are already running are left untouched. Fluent Bit then dispatches the currently buffered chunks to the output plugins, which is the same work the periodic `Flush` interval performs.

## Confirm a flush

A successful request returns HTTP status `200` with the incremented counter:

```json
{"flush":"done","flush_now_count":3}
```

`flush_now_count` is a process-wide counter incremented once per on-demand flush processed by the engine. It's incremented when buffered chunks are dispatched to the output plugins. A `200` only guarantees the engine is processing chunks, not that they got pushed out or received by the outputs. Because the counter is global, it can't be used to correlate a response with a specific request when several flushes are issued concurrently.

If the engine doesn't acknowledge the request within 2 seconds, the endpoint responds with HTTP status `503`. The reported counter is the current process-wide value, which doesn't include this request:

```json
{"flush":"timeout","flush_now_count":2}
```

A `503` means the engine didn't acknowledge the request in time, not that the flush was cancelled. The request stays queued and the engine can still process it later, incrementing the counter after the response was sent.

The endpoint responds with HTTP status `500` and an empty body in two cases. If the request can't be delivered to the engine, no flush is triggered and the counter isn't incremented. If the JSON response can't be encoded, the flush was already requested and might have completed, so the counter can still advance. A `GET` request returns `500` with an empty body under the same encoding failure.
