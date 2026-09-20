---
description: Enable hot reload through SIGHUP signal or an HTTP endpoint
---

# Hot reload

Fluent Bit supports the reloading feature when enabled in the configuration file or on the command line with `-Y` or `--enable-hot-reload` option.

Hot reloading is supported on Linux, macOS, and Windows operating systems.

## Update the configuration

To get started with reloading over HTTP, enable the HTTP Server in the configuration file:

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

## Relative paths

A configuration file can reference other files with a relative path, including `parsers_file`, `plugins_file`, upstream high availability files, and the stream processor `streams_file`.

Fluent Bit resolves a relative reference in two steps. It first looks for the file at the path exactly as written, relative to the working directory of the Fluent Bit process. If no file exists there, it looks for the file in the directory that holds the main configuration file. An absolute path is used as provided and isn't retried.

Fluent Bit version 5.1.2 and greater keeps track of the main configuration file's directory across a hot reload. In earlier versions, the reloaded configuration lost that directory, so a relative reference that resolved at startup failed to resolve after a reload. On those versions, use absolute paths for referenced files if you rely on hot reload.

If Fluent Bit can't preserve the directory while reloading, it stops the reload, keeps the previous configuration running, and logs:

```text
[reload] copying configuration path failed. Reloading is halted
```

## How to reload

After updating the configuration, use one of the following methods to perform a hot reload:

### HTTP

Use the following HTTP endpoints to perform a hot reload:

- `PUT /api/v2/reload`
- `POST /api/v2/reload`

For using curl to reload Fluent Bit, users must specify an empty request body as:

```shell
curl -X POST -d '{}' localhost:2020/api/v2/reload
```

Obtain a count of hot reload using the HTTP endpoint:

- `GET /api/v2/reload`

The endpoint returns `hot_reload_count` as follows:

```json
{"hot_reload_count":3}
```

The default value of the counter is `0`.

### Signal

Hot reloading can be used with `SIGHUP`.

`SIGHUP` signal isn't supported on Windows.

## Confirm a reload

Use one of the following methods to confirm the reload occurred.
