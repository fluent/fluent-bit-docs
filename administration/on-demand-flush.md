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

For using curl to trigger a flush, users must specify an empty request body as:

```shell
curl -X POST -d '{}' localhost:2020/api/v2/flush
```

Obtain a count of on-demand flushes using the HTTP endpoint:

- `GET /api/v2/flush`

The endpoint returns `flush_now_count` as follows:

```json
{"flush_now_count":3}
```

The default value of the counter is `0`.

## Confirm a flush

Use the `flush_now_count` returned by the `POST`/`PUT` response, or by a separate `GET /api/v2/flush` call, to confirm that a specific request resulted in a new flush. If the pipeline doesn't acknowledge the flush within the internal timeout, the `POST`/`PUT` endpoint responds with HTTP status `503` instead:

```json
{"flush":"timeout","flush_now_count":0}
```
