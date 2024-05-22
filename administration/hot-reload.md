---
description: Enable hot reload through SIGHUP signal or an HTTP endpoint
---

# Hot Reload

Fluent Bit supports the hot reloading feature when enabled via the configuration file or command line with `-Y` or `--enable-hot-reload` option.

## Getting Started

To get started with reloading via HTTP, the first step is to enable the HTTP Server from the configuration file:

```toml
[SERVICE]
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_PORT    2020
    Hot_Reload   On
...
```

The above configuration snippet will enable the HTTP endpoint for hot reloading.

## How to reload

### Via HTTP

Hot reloading can be kicked via HTTP endpoints that are:

* `PUT /api/v2/reload`
* `POST /api/v2/reload`

If users don't enable the hot reloading feature, hot reloading via these endpoints will not work.

For using curl to reload Fluent Bit, users must specify an empty request body as:

```text
$ curl -X POST -d '{}' localhost:2020/api/v2/reload
```

### Via Signal

Hot reloading also can be kicked via `SIGHUP`.

`SIGHUP` signal is not supported on Windows. So, users can't enable this feature on Windows.

## How to confirm reloaded or not

### via HTTP

The number of hot reloaded count can be obtained via the HTTP endpoint that is:

* `GET /api/v2/reload`

The endpoint returns the count of hot-reloaded as follows:

```json
{"hot_reload_count":3}
```

The default value of that number is 0.

## Limitations

The hot reloading feature is currently working on Linux, macOS and Windows.
