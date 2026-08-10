---
description: Send logs to Bronto
---

# Bronto

Stream logs to [Bronto](https://docs.bronto.io) by using the [HTTP plugin](http.md) to send data to a Bronto ingestion endpoint. Bronto parses and structures logs after ingestion, so you can send raw log records as JSON lines.

Bronto exposes region-specific ingestion endpoints:

| Region | Host |
| :--- | :--- |
| `EU` | `ingestion.eu.bronto.io` |
| `US` | `ingestion.us.bronto.io` |

## Configuration parameters

Bronto uses the standard [HTTP output plugin](http.md) parameters together with a set of Bronto-specific HTTP headers.

| Key | Description | Default |
| :--- | :--- | :--- |
| `compress` | Compress the payload before sending. Use `gzip` for Bronto. | _none_ |
| `format` | The payload format to send. Use `json_lines` for Bronto. | `json` |
| `host` | Your Bronto ingestion endpoint: `ingestion.eu.bronto.io` (`EU`) or `ingestion.us.bronto.io` (`US`). | `127.0.0.1` |
| `port` | TCP port of the Bronto ingestion endpoint. Use `443`. | `80` |
| `tls` | Enable TLS. Required by Bronto endpoints. Use `on`. | `off` |

### Headers

| Header | Description | Required |
| :--- | :--- | :--- |
| `x-bronto-api-key` | Your Bronto API key. | Yes |
| `x-bronto-collection` | The collection used to group datasets. | Yes |
| `x-bronto-dataset` | The target dataset name. | Yes |
| `x-bronto-tags` | Key-value pairs for partitioning, for example `env=prod,team=platform`. | No |

The `x-bronto-dataset` and `x-bronto-collection` headers are required when using the HTTP plugin. When you send data using OpenTelemetry, they're optional. See [Send logs using OpenTelemetry](#send-logs-using-opentelemetry).

### TLS / SSL

The HTTP output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To get started with sending logs to Bronto:

1. In the Bronto UI, go to **Settings** > **API Keys** > **Add API Key** and create a key. An **Ingestion** role is sufficient for sending logs.
1. In your main Fluent Bit configuration file, append the following, replacing `<REGION>`, `<YOUR_API_KEY>`, `<YOUR_DATASET_NAME>`, and `<YOUR_COLLECTION_NAME>` with your values:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: http
      match: '*'
      host: ingestion.<REGION>.bronto.io
      port: 443
      tls: on
      format: json_lines
      compress: gzip
      header:
        - x-bronto-api-key <YOUR_API_KEY>
        - x-bronto-dataset <YOUR_DATASET_NAME>
        - x-bronto-collection <YOUR_COLLECTION_NAME>
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name       http
  Match      *
  Host       ingestion.<REGION>.bronto.io
  Port       443
  Tls        On
  Format     json_lines
  Compress   gzip
  Header     x-bronto-api-key    <YOUR_API_KEY>
  Header     x-bronto-dataset    <YOUR_DATASET_NAME>
  Header     x-bronto-collection <YOUR_COLLECTION_NAME>
```

{% endtab %}
{% endtabs %}

## Send logs using OpenTelemetry

Bronto also accepts OTLP over HTTP at the same ingestion endpoints. If you're standardizing on OpenTelemetry across your pipeline, you can use the [OpenTelemetry plugin](opentelemetry.md) instead.

With this approach, Bronto can derive the dataset from the `service.name` resource attribute and the collection from `service.namespace`. Fluent Bit doesn't attach these resource attributes by default, so set the `x-bronto-dataset` and `x-bronto-collection` headers explicitly to control the target dataset and collection.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: opentelemetry
      match: '*'
      host: ingestion.<REGION>.bronto.io
      port: 443
      tls: on
      logs_uri: /v1/logs
      header:
        - x-bronto-api-key <YOUR_API_KEY>
        - x-bronto-dataset <YOUR_DATASET_NAME>
        - x-bronto-collection <YOUR_COLLECTION_NAME>
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name       opentelemetry
  Match      *
  Host       ingestion.<REGION>.bronto.io
  Port       443
  Tls        On
  Logs_Uri   /v1/logs
  Header     x-bronto-api-key    <YOUR_API_KEY>
  Header     x-bronto-dataset    <YOUR_DATASET_NAME>
  Header     x-bronto-collection <YOUR_COLLECTION_NAME>
```

{% endtab %}
{% endtabs %}

## References

- [Bronto Fluent Bit documentation](https://docs.bronto.io/agent-setup/fluent-bit)
