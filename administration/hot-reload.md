---
description: Enable hot reload through SIGHUP signal or an HTTP endpoint
---

# Hot reload

Fluent Bit supports the reloading feature when enabled in the configuration file
or on the command line with `-Y` or `--enable-hot-reload` option.

Hot reloading is supported on Linux, macOS, and Windows operating systems.

## Update the configuration

To get started with reloading over HTTP, enable the HTTP Server
in the configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020
  hot_reload: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020
  Hot_Reload   On
```

{% endtab %}
{% endtabs %}

## How to reload

After updating the configuration, use one of the following methods to perform a
hot reload:

### HTTP

Use the following HTTP endpoints to perform a hot reload:

- `PUT /api/v2/reload`
- `POST /api/v2/reload`

For using curl to reload Fluent Bit, users must specify an empty request body as:

```shell
curl -X POST -d '{}' localhost:2020/api/v2/reload
```

### Signal

Hot reloading can be used with `SIGHUP`.

`SIGHUP` signal isn't supported on Windows.

## Confirm a reload

Use one of the following methods to confirm the reload occurred.

### HTTP

Obtain a count of hot reload using the HTTP endpoint:

- `GET /api/v2/reload`

The endpoint returns `hot_reload_count` as follows:

```json
{"hot_reload_count":3}
```

The default value of the counter is `0`.