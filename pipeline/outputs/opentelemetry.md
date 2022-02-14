---
description: An output plugin to submit Metrics to an OpenTelemetry endpoint
---

# OpenTelemetry

The OpenTelemetry plugin allows you to take metrics from Fluent Bit and submit them to an OpenTelemetry HTTP endpoint.

Important Note: At the moment only HTTP endpoints are supported.

| Key                  | Description                                                  | Default   |
| -------------------- | ------------------------------------------------------------ | --------- |
| host                 | IP address or hostname of the target HTTP Server             | 127.0.0.1 |
| http_user            | Basic Auth Username                                          |           |
| http_passwd          | Basic Auth Password. Requires HTTP_user to be set            |           |
| port                 | TCP port of the target HTTP Server                           | 80        |
| proxy                | Specify an HTTP Proxy. The expected format of this value is `http://HOST:PORT`. Note that HTTPS is **not** currently supported. It is recommended not to set this and to configure the [HTTP proxy environment variables](https://docs.fluentbit.io/manual/administration/http-proxy) instead as they support both HTTP and HTTPS. |           |
| uri                  | Specify an optional HTTP URI for the target web server, e.g: /something | /         |
| header               | Add a HTTP header key/value pair. Multiple headers can be set. |           |
| log_response_payload | Log the response payload within the Fluent Bit log           | false     |
| add_label            | This allows you to add custom labels to all metrics exposed through the OpenTelemetry exporter. You may have multiple of these fields |           |

## Getting Started

The OpenTelemetry plugin only works with metrics collected by one of the from metric input plugins. In the following example, host metrics are collected by the node exporter metrics plugin and then delivered by the OpenTelemetry output plugin.

```
# Node Exporter Metrics + OpenTelemetry output plugin
# -------------------------------------------
# The following example collects host metrics on Linux and delivers
# them through the OpenTelemetry plugin to a local collector :
#
[SERVICE]
    Flush                1
    Log_level            info

[INPUT]
    Name                 node_exporter_metrics
    Tag                  node_metrics
    Scrape_interval      2

[OUTPUT]
    Name                 opentelemetry
    Match                node_metrics
    Host                 localhost
    Port                 443
    Uri                  /v1/metrics
    Log_response_payload True
    Tls                  On
    Tls.verify           Off
    # add user-defined labels
    add_label            app fluent-bit
    add_label            color blue
```
