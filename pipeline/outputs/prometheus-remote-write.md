---
description: An output plugin to submit Prometheus Metrics using the remote write protocol
---

# Prometheus Remote Write

The prometheus remote write plugin allows you to take metrics from Fluent Bit and submit them to a Prometheus server through the remote write mechanism.

Important Note: The prometheus exporter only works with metric plugins, such as Node Exporter Metrics

| Key                 | Description                                                                                                                                                                                                                                                            | Default   |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| host                | IP address or hostname of the target HTTP Server                                                                                                                                                                                                                       | 127.0.0.1 |
| http_user           | Basic Auth Username                                                                                                                                                                                                                                                    |           |
| http_passwd         | Basic Auth Password. Requires HTTP_user to be set                                                                                                                                                                                                                      |           |
| port                | TCP port of the target HTTP Server                                                                                                                                                                                                                                     | 80        |
| proxy               | Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host/:port). Note that _https_ is **not** supported yet. Please consider not setting this and use `HTTP_PROXY` environment variable instead, which supports both http and https. |           |
| uri                 | Specify an optional HTTP URI for the target web server, e.g: /something                                                                                                                                                                                                | /         |
| header              | Add a HTTP header key/value pair. Multiple headers can be set.                                                                                                                                                                                                         |           |
| log_response_payload | Log the response payload within the Fluent Bit log                                                                                                                                                                                                                     | false     |
| add_label            | This allows you to add custom labels to all metrics exposed through the prometheus exporter. You may have multiple of these fields                                                                                                                                     |           |
| Workers | Enables dedicated thread(s) for this output. Default value is set since version 1.8.12. For previous versions is 0. | 2 |

## Getting Started

The Prometheus remote write plugin only works with metrics collected by one of the from metric input plugins. In the following example, host metrics are collected by the node exporter metrics plugin and then delivered by the prometheus remote write output plugin.

```
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
    Header               Authorization Bearer YOUR_LICENSE_KEY
    Log_response_payload True
    Tls                  On
    Tls.verify           On
    # add user-defined labels
    add_label            app fluent-bit
    add_label            color blue

# Note : it would be necessary to replace both YOUR_DATA_SOURCE_NAME and YOUR_LICENSE_KEY
# with real values for this example to work.
```

## Examples

The following are examples of using Prometheus remote write with hosted services below

### Grafana Cloud

With [Grafana Cloud](https://grafana.com/products/cloud/) hosted metrics you will need to use the specific host that is mentioned as well as specify the HTTP username and password given within the Grafana Cloud page.

```
[OUTPUT]
    name prometheus_remote_write
    host prometheus-us-central1.grafana.net
    match *
    uri /api/prom/push
    port 443
    tls on
    tls.verify on
    http_user <GRAFANA Username>
    http_passwd <GRAFANA Password>
```

### Logz.io Infrastructure Monitoring

With Logz.io [hosted prometheus](https://logz.io/solutions/infrastructure-monitoring/) you will need to make use of the header option and add the Authorization Bearer with the proper key. The host and port may also differ within your specific hosted instance.

```
[OUTPUT]
    name prometheus_remote_write
    host listener.logz.io
    port 8053 
    match *
    header Authorization Bearer <LOGZIO Key>
    tls on
    tls.verify on
    log_response_payload true
```

### Coralogix

With [Coralogix Metrics](https://coralogix.com/platform/metrics/) you may need to customize the URI. Additionally, you will make use of the header key with Coralogix private key.

```
[OUTPUT]
    name prometheus_remote_write
    host metrics-api.coralogix.com
    uri prometheus/api/v1/write?appLabelName=path&subSystemLabelName=path&severityLabelName=severity 
    match *
    port 443
    tls on
    tls.verify on
    header Authorization Bearer <CORALOGIX Key>
```
