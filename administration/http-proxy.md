---
description: Enable traffic through a proxy server using the HTTP_PROXY environment variable.
---

# HTTP proxy

Fluent Bit supports configuring an HTTP proxy for all egress HTTP/HTTPS traffic using the `HTTP_PROXY` or `http_proxy` environment variable.

The format for the HTTP proxy environment variable is `http://USER:PASS@HOST:PORT`, where:

- _`USER`_ is the username when using basic authentication.
- _`PASS`_ is the password when using basic authentication.
- _`HOST`_ is the HTTP proxy hostname or IP address.
- _`PORT`_ is the port the HTTP proxy is listening on.

To use an HTTP proxy with basic authentication, provide the username and password:

```text
HTTP_PROXY='http://example_user:example_pass@proxy.example.com:8080'
```

When no authentication is required, omit the username and password:

```text
HTTP_PROXY='http://proxy.example.com:8080'
```

The `HTTP_PROXY` environment variable is a [standard way](https://docs.docker.com/network/proxy/#use-environment-variables) of setting a HTTP proxy in a containerized environment, and it's also natively supported by any application written in Go. Fluent Bit implements the same convention. The `http_proxy` environment variable is also supported. When both the `HTTP_PROXY` and `http_proxy` environment variables are provided, `HTTP_PROXY` will be preferred.

{% hint style="info" %}

The [HTTP output plugin](../pipeline/outputs/http.md) also supports configuring an HTTP proxy. This configuration works, but shouldn't be used with the `HTTP_PROXY` or `http_proxy` environment variable. The environment variable-based proxy configuration is implemented by creating a TCP connection tunnel using [HTTP CONNECT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods/CONNECT). Unlike the plugin's implementation, this supports both HTTP and HTTPS egress traffic.

{% endhint %}

## `NO_PROXY`

Use the `NO_PROXY` environment variable when traffic shouldn't flow through the HTTP proxy. The `no_proxy` environment variable is also supported. When both `NO_PROXY` and `no_proxy` environment variables are provided, `NO_PROXY` takes precedence.

The format for the `no_proxy` environment variable is a comma-separated list of host names or IP addresses.

A domain name matches itself and all of its subdomains (for example, `example.com` matches both `example.com` and `test.example.com`):

```text
NO_PROXY='foo.com,127.0.0.1,localhost'
```

A domain with a leading dot (`.`) matches only its subdomains (for example, `.example.com` matches `test.example.com` but not `example.com`):

```text
NO_PROXY='.example.com,127.0.0.1,localhost'
```

As an example, you might use `NO_PROXY` when running Fluent Bit in a Kubernetes environment, where and you want:

- All real egress traffic to flow through an HTTP proxy.
- All local Kubernetes traffic to not flow through the HTTP proxy.

In this case, set:

```text
NO_PROXY='127.0.0.1,localhost,kubernetes.default.svc'
```
