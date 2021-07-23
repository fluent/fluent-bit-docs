---
description: An output plugin to submit Prometheus Metrics using the remote write protocol
---

# Prometheus Remote Write

The prometheus remote write plugin allows you to take metrics from Fluent Bit and submit them to a Prometheus server through the remote write mechanism.

Important Note: The prometheus exporter only works with metric plugins, such as Node Exporter Metrics

| Key | Description | Default |
| :--- | :--- | :--- |
| host | IP address or hostname of the target HTTP Server | 127.0.0.1 |
| http\_user | Basic Auth Username |  |
| http\_passwd | Basic Auth Password. Requires HTTP\_user to be set |  |
| port | TCP port of the target HTTP Server | 80 |
| proxy | Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host:port). Note that _https_ is **not** supported yet. Please consider not setting this and use `HTTP_PROXY` environment variable instead, which supports both http and https. |  |
| uri | Specify an optional HTTP URI for the target web server, e.g: /something | / |
| header | Add a HTTP header key/value pair. Multiple headers can be set. |  |

## Getting Started

The Prometheus remote write plugin only works with metrics collected by one of the from metric input plugins. In the following example, host metrics are collected by the node exporter metrics plugin and then delivered by the prometheus remote write output plugin.

```text
# Node Exporter Metrics + Prometheus remote write output plugin
# -------------------------------------------
# The following example collects host metrics on Linux and delivers
# them through the Prometheus remote write plugin to new relic :
#
[SERVICE]
    Flush                1
    Log_level            info

[INPUT]
    Name                 node_exporter_metrics
    Tag                  node_metrics
    Scrape_interval      2

[OUTPUT]
    Name                 prometheus_remote_write
    Match                node_metrics
    Host                 metric-api.newrelic.com
    Port                 443
    Uri                  /prometheus/v1/write?prometheus_server=YOUR_DATA_SOURCE_NAME
    Header               bearer_token YOUR_LICENSE_KEY
    Log_response_payload True
    Tls                  On
    Tls.verify           On

# Note : it would be necessary to replace both YOUR_DATA_SOURCE_NAME and YOUR_LICENSE_KEY
# with real values for this example to work.
```

