---
description: Send logs to Dynatrace
---

# Dynatrace

Stream logs to [Dynatrace](https://www.dynatrace.com) by utilizing the `http` plugin to send data to the [Dynatrace generic log ingest API](https://docs.dynatrace.com/docs/analyze-explore-automate/logs/lma-log-ingestion/lma-log-ingestion-via-api).

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `allow_duplicated_headers` | Specifies duplicated header use. | `false` |
| `format` | The data format to be used in the HTTP request body. | `json` |
| `header` | The specific header for content-type. | `Content-Type application/json; charset=utf-8` |
| `header` | The specific header for authorization token, where `{your-API-token-here}` is the Dynatrace API token with log ingest scope. | `Authorization Api-Token {your-API-token-here}` |
| `host` | Your Dynatrace environment hostname where `{your-environment-id}` is your environment ID. | `{your-environment-id}.live.dynatrace.com` |
| `json_date_format` | Date format standard for JSON. | `iso8601` |
| `json_date_key` | Field name specifying message timestamp. | `timestamp` |
| `port` | TCP port of your Dynatrace host. | `443` |
| `tls` | Specify to use TLS. | `on` |
| `tls.verify` | TLS verification. | `on` |
| `uri` | Specify the HTTP URI for Dynatrace log ingest API. | `/api/v2/logs/ingest` |

## Get started

To get started with sending logs to Dynatrace:

1. Get a [Dynatrace API](https://docs.dynatrace.com/docs/dynatrace-api/basics/dynatrace-api-authentication) token with the `logs.ingest` (Ingest Logs) scope.
1. Determine your Dynatrace [environment ID](https://docs.dynatrace.com/docs/shortlink/monitoring-environment#environment-id).
1. In your main Fluent Bit configuration file, append the following `Output` section:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

   ```yaml
   pipeline:

     outputs:
       - name: http
         match: '*'
         header:
           - 'Content-Type application/json; charset=utf-8'
           - 'Authorization Api-Token {your-API-token-here}'
         allow_duplicated_headers: false
         host: {your-environment-id}.live.dynatrace.com
         port: 443
         uri: /api/v2/logs/ingest
         format: json
         json_date_format: iso8601
         json_date_key: timestamp
         tls: on
         tls.verify: on
   ```

{% endtab %}
{% tab title="fluent-bit.conf" %}

   ```text
   [OUTPUT]
     Name                     http
     Match                    *
     Header                   Content-Type application/json; charset=utf-8
     Header                   Authorization Api-Token {your-API-token-here}
     Allow_duplicated_headers false
     Host                     {your-environment-id}.live.dynatrace.com
     Port                     443
     Uri                      /api/v2/logs/ingest
     Format                   json
     Json_date_format         iso8601
     Json_date_key            timestamp
     Tls                      On
     Tls.verify               On
   ```

{% endtab %}
{% endtabs %}

## References

<!-- vale FluentBit.Simplicity = NO -->

- [Dynatrace Fluent Bit documentation](https://docs.dynatrace.com/docs/shortlink/lma-stream-logs-with-fluent-bit)
- [Fluent Bit integration in Dynatrace Hub](https://www.dynatrace.com/hub/detail/fluent-bit/?filter=log-management-and-analytics)
- [Video: Stream a Log File to Dynatrace using Fluent Bit](https://www.youtube.com/watch?v=JJJNxhtJ6R0)
- [Blog: Easily stream logs from Fluent Bit to Dynatrace](https://docs.dynatrace.com/docs/analyze-explore-automate/logs/lma-log-ingestion/lma-stream-logs-with-fluent-bit)

<!-- vale FluentBit.Simplicity = YES -->
