---
description: Enable traffic through a proxy server via HTTP_PROXY environment variable
---

# HTTP Proxy

Fluent Bit supports configuring an HTTP proxy for all egress HTTP/HTTPS traffic via the `HTTP_PROXY` or `http_proxy` environment variable.

The format for the HTTP proxy environment variable is `http://USER:PASS@HOST:PORT`, where:

* `USER` is the username when using basic authentication.
* `PASS` is the password when using basic authentication.
* `HOST` is the HTTP proxy hostname or IP address.
* `PORT` is the port the HTTP proxy is listening on.

To use an HTTP proxy with basic authentication, provide the username and password:

```bash
HTTP_PROXY='http://example_user:example_pass@proxy.example.com:8080'
```

When no authentication is required, omit the username and password:

```bash
HTTP_PROXY='http://proxy.example.com:8080'
```

The `HTTP_PROXY` environment variable is a [standard way](https://docs.docker.com/network/proxy/#use-environment-variables) for setting a HTTP proxy in a containerized environment, and it is also natively supported by any application written in Go. Therefore, we follow and implement the same convention for Fluent Bit. For convenience and compatibility, the `http_proxy` environment variable is also supported. When both the `HTTP_PROXY` and `http_proxy` environment variables are provided, `HTTP_PROXY` will be preferred.

{% hint style="info" %}
**Note**: The [HTTP output plugin](https://docs.fluentbit.io/manual/pipeline/outputs/http) also supports configuring an HTTP proxy. This configuration continues to work, however it _should not_ be used together with the `HTTP_PROXY` or `http_proxy` environment variable. This is because under the hood, the environment variable based proxy configuration is implemented by setting up a TCP connection tunnel via [HTTP CONNECT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/CONNECT). Unlike the plugin's implementation, this supports both HTTP and HTTPS egress traffic.
{% endhint %}

# NO_PROXY

Not all traffic should flow through the HTTP proxy. In this case, the `NO_PROXY` or `no_proxy` environment variable should be used.

The format for the no proxy environment variable is a comma-separated list of hostnames or IP addresses whose traffic should not flow through the HTTP proxy.

A domain name matches itself and all its subdomains (i.e. `foo.com` matches `foo.com` and `bar.foo.com`):

```bash
NO_PROXY='foo.com,127.0.0.1,localhost'
```

A domain with a leading `.` only matches its subdomains (i.e. `.foo.com` matches `bar.foo.com` but not `foo.com`):

```bash
NO_PROXY='.foo.com,127.0.0.1,localhost'
```

One typical use case for `NO_PROXY` is when running Fluent Bit in a Kubernetes environment, where we want:

* All real egress traffic to flow through an HTTP proxy.
* All local Kubernetes traffic to not flow through the HTTP proxy.

In this case, we can set:

```bash
NO_PROXY='127.0.0.1,localhost,kubernetes.default.svc'
```

For convenience and compatibility, the `no_proxy` environment variable is also supported. When both the `NO_PROXY` and `no_proxy` environment variables are provided, `NO_PROXY` will be preferred.
