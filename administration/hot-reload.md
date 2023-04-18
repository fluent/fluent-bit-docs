---
description: Enable hot reload through a command line argument or a HTTP endpoint
---

# Hot Reload

FLuent Bit supports hot relaoding feature when enabling via command line with `-Y` or `--enable-hot-reload` option.

## Getting Started

To get started, the first step is to enable the HTTP Server from the configuration file:

```
[SERVICE]
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_PORT    2020

# Other stuffs of plugin configurations
```

The above configuration snippet will enable HTTP endpoint for hot reloading.

## How to reload

### via HTTP

Hot reloading can be kicked via HTTP endpoints that are:

* `PUT /api/v2/reload`
* `POST /api/v2/reload`

If users don't enable hot reloading feature, hot reloading via these endpoinds does not work.

For using curl to reload fluent-bit, users must specify empty request body as:


```text
$ curl -XPOST -d {} localhost:2020/api/v2/reload
```

### via Signal

Hot reloading also can be kicked via `SIGHUP`.

`SIGHUP` signal is not supported on Windows. So, users can't enable this feature on Windows.

## Limitations

Hot reloading feature is currently working on Linux and macOS. And Windows is not supported yet.
