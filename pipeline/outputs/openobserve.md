---
title: OpenObserve
description: Send logs to OpenObserve using Fluent Bit
---

# OpenObserve

Use the OpenObserve output plugin to ingest logs into [OpenObserve](https://openobserve.ai/).

Before you begin, you need an [OpenObserve account](https://cloud.openobserve.ai/), an
`HTTP_User`, and an `HTTP_Passwd`. You can find these fields under **Ingestion** in
OpenObserve Cloud. Alternatively, you can achieve this with various installation
types as mentioned in the
[OpenObserve documentation](https://openobserve.ai/docs/quickstart/)

## Configuration Parameters

| Key             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                | Default                          |
| --------------- | -----------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                          | -------------------------------- |
| Host            | Required. The OpenObserve server where you are sending logs.                                                                                                                                                                                                                                                                                                                                                                           | `localhost` |
| TLS             | Required: Enable end-to-end security using TLS. Set to `on` to enable TLS communication with OpenObserve.                                                                                                                                                                                                                                                                                                                                | `on`                            |
| compress        | Recommended: Compresses the payload in GZIP format. OpenObserve supports and recommends setting this to `gzip` for optimized log ingestion.                                                                                                                                                                                                                                                                                                                             |    _none_                   |
| HTTP_User          | Required: Username for HTTP authentication.                                                                                                                                                                                                                                                                                                                                                       |                 _none_          |
| HTTP_Passwd          | Required: Password for HTTP authentication.                                                                                                                                                                                                                                                                                                                                                       |     _none_                             |
| URI        | Required: The API path used to send logs.                                                                                                                                                                                                                                                                                                                                                           |         `/api/default/default/_json`                         |
| Format        | Required: The format of the log payload. OpenObserve expects JSON.                                                                                                                                                                                                                                                                                                                                                           |         `json`                         |
| json_date_key   | Optional: The JSON key used for timestamps in the logs.                                                                                                                                                                                                                                                                                                                                                                                                                  | `timestamp`                      |
| json_date_format   | Optional: The format of the date in logs. OpenObserve supports ISO 8601.                                                                                                                                                                                                                                                                                                                                                                                                                  | `iso8601`                      |
| include_tag_key | If `true`, a tag is appended to the output. The key name is used in the `tag_key` property.                                                                                                                                                                                                                                                                                                                                                          | `false`                          |

### Configuration File

Use this configuration file to get started:

```
[OUTPUT]
  Name http
  Match *
  URI /api/default/default/_json
  Host localhost
  Port 5080
  tls on
  Format json
  Json_date_key    timestamp
  Json_date_format iso8601
  HTTP_User <YOUR_HTTP_USER>
  HTTP_Passwd <YOUR_HTTP_PASSWORD>
  compress gzip
```