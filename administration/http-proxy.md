---
description: Enable traffic through a proxy server via HTTP_PROXY environment variable
---

# HTTP Proxy

Fluent Bit supports setting up a HTTP proxy for all egress HTTP/HTTPS traffic by setting `HTTP_PROXY` environment variable:

* You can set up basic authentication with `HTTP_PROXY=http://<username>:<password>@<proxy host>:<port>` to provide your `username` and `password` when connecting to the proxy.
* You can also set up `HTTP_PROXY=http://<proxy host>:<port>` to omit `username` and `password` if there is none.

The `HTTP_PROXY` environment variable is a [standard way](https://docs.docker.com/network/proxy/#use-environment-variables) for setting a HTTP proxy in a containerized environment, and it is also natively supported by any application written in Go. Therefore, we follow and implement the same convention for Fluent Bit.

**Note**: HTTP proxy is also supported using the [HTTP output plugin](https://docs.fluentbit.io/manual/pipeline/outputs/http). This configuration continues to work, however it _should not_ be used together with the `HTTP_PROXY` environment variable. This is because under the hood, the `HTTP_PROXY` environment variable based proxy support is implemented by setting up a TCP connection tunnel via [HTTP CONNECT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/CONNECT). Unlike the plugin's implementation, this supports both HTTP and HTTPS egress traffic.

# NO_PROXY

In some environments, we wish HTTP traffic for some domains don't go through the HTTP_PROXY, and this is where we need to use `NO_PROXY` environment variable.

`NO_PROXY` is a comma-separated list of host names that shouldn't go through any proxy is set in (only an asterisk, * matches all hosts), e.g. `foo.com,bar.com`. This is as a [curl convention](https://curl.se/docs/manual.html).

One typical use case for `NO_PROXY` is when running fluent-bit in a Kubernetes environment, where we want:

* All real egress traffic goes through a HTTP proxy.
* All "Kubernetes local" traffic does not go through the HTTP proxy.
* We can set `NO_PROXY=127.0.0.1,localhost,kubernetes.default.svc` in this case.
