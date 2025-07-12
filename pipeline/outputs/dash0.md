---
description: Send logs to Dash0
---

# Dash0

Stream logs to [Dash0](https://www.dash0.com) by utilizing the [OpenTelemetry plugin](opentelemetry.md) to send data to the Dash0 log ingress.

## Configuration parameters

| Key                        | Description | Default |
| -------------------------- | ----------- | ------- |
| `header`                   | The specific header for bearer authorization, where {your-Auth-token-here} is your Dash0 Auth Token. | Authorization Bearer {your-Auth-token-here} |
| `host`                     | Your Dash0 ingress endpoint. | `ingress.eu-west-1.aws.dash0.com` |
| `port`                     | TCP port of your Dash0 ingress endpoint. | `443` |
| `metrics_uri`              | Specify an optional HTTP URI for the target web server listening for metrics | `/v1/metrics` |
| `logs_uri`                 | Specify an optional HTTP URI for the target web server listening for logs | `/v1/logs` |
| `traces_uri`               | Specify an optional HTTP URI for the target web server listening for traces | `/v1/traces`  |

### TLS / SSL

The OpenTelemetry output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Getting started

To get started with sending logs to Dash0:

1. Get an [Auth Token](https://www.dash0.com/documentation/dash0/key-concepts/auth-tokens) from **Settings** > **Auth Tokens**.
1. In your main Fluent Bit configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    
  outputs:
    - name: opentelemetry      
      match: '*'
      host: ingress.eu-west-1.aws.dash0.com
      port: 443
      header: Authorization Bearer {your-Auth-token-here}
      metrics_uri: /v1/metrics
      logs_uri: /v1/logs
      traces_uri: /v1/traces
```
{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name         opentelemetry
  Match        *
  Host         ingress.eu-west-1.aws.dash0.com
  Port         443
  Header       Authorization Bearer {your-Auth-token-here}
  Metrics_uri  /v1/metrics
  Logs_uri     /v1/logs
  Traces_uri   /v1/traces
```

{% endtab %}
{% endtabs %}

## References

- [Dash0 documentation](https://www.dash0.com/documentation/dash0)