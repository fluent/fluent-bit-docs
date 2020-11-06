---
description: User a http proxy via HTTP\_PROXY environment variable.
---

# HTTP Proxy

Fluent Bit supports setting up a HTTP proxy for all egress HTTP/HTTPS traffic by setting `HTTP_PROXY` environment variable:

- You can setup `HTTP_PROXY=http://username:password@your-proxy.com:port` to use a `username` and `password` when connecting to the proxy.
- You can also setup `HTTP_PROXY=http://your-proxy.com:port` to omit `username` and `password` if there is none.

The `HTTP_PROXY` environment variable is a standard way for setting a HTTP proxy in a containerized environment ([reference](https://docs.docker.com/network/proxy/#use-environment-variables)), and it is also natively supported by any application written in Go. Therefore, we follow and implement the same convention for Fluent Bit.

**Note**: we also have an older way for http proxy support in specific output plugins `output` plugin by its configuration. The configuration continues to work, however it _should not_ be used together with the `HTTP_PROXY` environment variable. This is because: under the hood, the `HTTP_RPOXY` based proxy support is implemented by setting up a TCP connection tunnel via [HTTP CONNECT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/CONNECT). Both HTTP and HTTPS egress traffic can work this way. And this is different than the current plugin's implementation.
