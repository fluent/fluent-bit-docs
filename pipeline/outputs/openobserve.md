---
title: OpenObserve
description: Send logs to OpenObserve using Fluent Bit
---

# OpenObserve

Use the OpenObserve output plugin to ingest logs into [OpenObserve](https://openobserve.ai/).

Before you begin, you need a [OpenObserve account](https://cloud.openobserve.ai/), a HTTP_User and HTTP_Passwd that will be available under Ingestion of your O2 platform. Alternatively, you can achieve this with various installation types as mentioned in this [documentation](https://openobserve.ai/docs/quickstart/)

## Configuration Parameters

| Key             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                | Default                          |
| --------------- | -----------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                          | -------------------------------- |
| Host            | _Required_ - The OpenObserve server where you are sending your logs.                                                                                                                                                                                                                                                                                                                                                                           | `localhost` |
| TLS             | _Required_ - Enable end-to-end security using TLS. Set to `on` to enable TLS communication with OpenObserve.                                                                                                                                                                                                                                                                                                                                | `on`                            |
| compress        | _Recommended_ - Compresses the payload in GZIP format. OpenObserve supports and recommends setting this to `gzip` for optimized log ingestion.                                                                                                                                                                                                                                                                                                                             |                                  |
| HTTP_User          | _Required_ - Username for HTTP authentication.                                                                                                                                                                                                                                                                                                                                                       |                                  |
| HTTP_Passwd          | _Required_ - Password for HTTP authentication.                                                                                                                                                                                                                                                                                                                                                       |                                  |
| URI        | _Required_ - The API path where the logs will be sent.                                                                                                                                                                                                                                                                                                                                                           |         `/api/default/default/_json`                         |
| Format        | _Required_ - The format of the log payload. OpenObserve expects json.                                                                                                                                                                                                                                                                                                                                                           |         `json`                         |
| json_date_key   | _Optional_ The JSON key used for timestamps in the logs.                                                                                                                                                                                                                                                                                                                                                                                                                  | `timestamp`                      |
| json_date_format   | _Optional_ The format of the date in logs. OpenObserve supports iso8601.                                                                                                                                                                                                                                                                                                                                                                                                                  | `iso8601`                      |
| include_tag_key | If enabled, a tag is appended to output. The key name is used `tag_key` property.                                                                                                                                                                                                                                                                                                                                                          | `false`                          |

### Configuration File

Get started quickly with this configuration file:

```
[OUTPUT]
  Name http
  Match *
  URI /api/default/default/_json
  Host localhost
  Port 5080
  tls Off
  Format json
  Json_date_key    _timestamp
  Json_date_format iso8601
  HTTP_User <your_http_user>
  HTTP_Passwd <your_http_password>
  compress gzip
```