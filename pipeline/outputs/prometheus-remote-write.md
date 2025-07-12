---
description: An output plugin to submit Prometheus Metrics using the remote write protocol
---

# Prometheus remote write

The _Prometheus remote write_ plugin lets you take metrics from Fluent Bit and submit them to a Prometheus server through the remote write mechanism.

The Prometheus exporter works only with metric plugins, such as Node Exporter Metrics.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|-----|-------------|---------|
| `host` | IP address or hostname of the target HTTP server. | `127.0.0.1` |
| `http_user` | Basic Auth username. | _none_ |
| `http_passwd` | Basic Auth Password. Requires `HTTP_user` to be set. | _none_ |
| `AWS_Auth` | Enable AWS SigV4 authentication. | `false` |
| `AWS_Service` | For Amazon Managed Service for Prometheus, the service name is `aps`. | `aps` |
| `AWS_Region` | Region of your Amazon Managed Service for Prometheus workspace. | _none_ |
| `AWS_STS_Endpoint` | Specify the custom STS endpoint to be used with STS API, used with the `AWS_Role_ARN` option, used by SigV4 authentication. | _none_ |
| `AWS_Role_ARN` | AWS IAM Role to assume, used by SigV4 authentication. | _none_ |
| `AWS_External_ID` | External ID for the AWS IAM Role specified with `aws_role_arn`, used by SigV4 authentication. | _none_ |
| `port` | TCP port of the target HTTP server. | `80` |
| `proxy` | Specify an HTTP proxy. The expected format of this value is `http://HOST:PORT`. HTTPS isn't supported. Configure the [HTTP proxy environment variables](https://docs.fluentbit.io/manual/administration/http-proxy) instead as they support both HTTP and HTTPS. | _none_ |
| `uri` | Specify an optional HTTP URI for the target web server. For example: `/someuri` | `/` |
| `header` | Add a HTTP header key/value pair. Multiple headers can be set. | _none_ |
| `log_response_payload` | Log the response payload within the Fluent Bit log. | `false` |
| `add_label` | This lets you add custom labels to all metrics exposed through the Prometheus exporter. You can have multiple of these fields. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |
| `compression` | Payload compression algorithm. Supported options are `snappy`, `gzip` and `zstd`. | `snappy` |

## Get started

The Prometheus remote write plugin works only with metrics collected by one of the metric input plugins. In the following example, host metrics are collected by the node exporter metrics plugin and then delivered by the Prometheus remote write output plugin.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
# Node Exporter Metrics + Prometheus remote write output plugin
# -------------------------------------------
# The following example collects host metrics on Linux and delivers
# them through the Prometheus remote write plugin to new relic :
#
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: node_exporter_metrics
      tag: node_metrics
      scrape_interval: 2

  outputs:
    - name: prometheus_remote_write
      match: node_metrics
      host: metric-api.newrelic.com
      port: 443
      uri: /prometheus/v1/write?prometheus_server=YOUR_DATA_SOURCE_NAME
      header: 'Authorization Bearer YOUR_LICENSE_KEY'
      log_response_payload: true
      tls: on
      tls.verify: on
      # add user-defined labels
      add_label:
        - app fluent-bit
        - color blue
# Note : it would be necessary to replace both YOUR_DATA_SOURCE_NAME and YOUR_LICENSE_KEY
# with real values for this example to work.
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

## Examples

The following are examples of using Prometheus remote write with hosted services:

### Grafana Cloud

With [Grafana Cloud](https://grafana.com/products/cloud/) hosted metrics you will need to use the specific host mentioned and specify the HTTP username and password given within the Grafana Cloud page.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: prometheus_remote_write
      match: '*'
      host: prometheus-us-central1.grafana.net
      uri: /api/prom/push
      port: 443
      tls: on
      tls.verify: on
      http_user: <GRAFANA Username>
      http_passwd: <GRAFANA Password>
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  name        prometheus_remote_write
  match       *
  host        prometheus-us-central1.grafana.net
  uri         /api/prom/push
  port        443
  tls         on
  tls.verify  on
  http_user   <GRAFANA Username>
  http_passwd <GRAFANA Password>
```

{% endtab %}
{% endtabs %}

### Logz.io infrastructure monitoring

With Logz.io [hosted Prometheus](https://logz.io/solutions/infrastructure-monitoring/) you will need to make use of the header option and add the Authorization Bearer with the proper key. The host and port can also differ within your specific hosted instance.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: prometheus_remote_write
      match: '*'
      host: listener.logz.io
      port: 8053
      tls: on
      tls.verify: on
      log_response_payload: true
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  name                  prometheus_remote_write
  match                 *
  host                  listener.logz.io
  port                  8053
  header                Authorization Bearer <LOGZIO Key>
  tls                   on
  tls.verify            on
  log_response_payload true
```

{% endtab %}
{% endtabs %}

### Coralogix

With [Coralogix Metrics](https://coralogix.com/platform/metrics/) you might need to customize the URI. Additionally, you will make use of the header key with Coralogix private key.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: prometheus_remote_write
      match: '*'
      host: metrics-api.coralogix.com
      uri: prometheus/api/v1/write?appLabelName=path&subSystemLabelName=path&severityLabelName=severity
      port: 443
      header: 'Authorization Bearer <CORALOGIX Key>'
      tls: on
      tls.verify: on
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  name                  prometheus_remote_write
  match                 *
  host                  metrics-api.coralogix.com
  uri                   prometheus/api/v1/write?appLabelName=path&subSystemLabelName=path&severityLabelName=severity
  port                  443
  header                Authorization Bearer <CORALOGIX Key>
  tls                   on
  tls.verify            on
```

{% endtab %}
{% endtabs %}

### Levitate

With [Levitate](https://last9.io/levitate-tsdb), you must use the Levitate cluster-specific write URL and specify the HTTP username and password for the token created for your Levitate cluster.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: prometheus_remote_write
      match: '*'
      host: app-tsdb.last9.io
      uri: /v1/metrics/82xxxx/sender/org-slug/write
      port: 443
      tls: on
      tls.verify: on
      http_user: <Levitate Cluster Username>
      http_passwd: <Levitate Cluster Password>
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  name        prometheus_remote_write
  match       *
  host        app-tsdb.last9.io
  uri         /v1/metrics/82xxxx/sender/org-slug/write
  port        443
  tls         on
  tls.verify  on
  http_user   <Levitate Cluster Username>
  http_passwd <Levitate Cluster Password>
```

{% endtab %}
{% endtabs %}

### Add Prometheus-like labels

Ordinary Prometheus clients add some of the following labels:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: prometheus_remote_write
      match: your.metric
      host: xxxxxxx.yyyyy.zzzz
      port: 443
      uri: /api/v1/write
      header: 'Authorization Bearer YOUR_LICENSE_KEY'
      log_response_payload: true
      tls: on
      tls.verify: on
      # add user-defined labels
      add_label:
        - instance ${HOSTNAME}
        - job fluent-bit
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name                 prometheus_remote_write
  Match                your.metric
  Host                 xxxxxxx.yyyyy.zzzz
  Port                 443
  Uri                  /api/v1/write
  Header               Authorization Bearer YOUR_LICENSE_KEY
  Log_response_payload True
  Tls                  On
  Tls.verify           On
  # add user-defined labels
  add_label instance ${HOSTNAME}
  add_label job fluent-bit
```

{% endtab %}
{% endtabs %}

The `instance` label can be emulated with `add_label instance ${HOSTNAME}`. And other labels can be added with `add_label <key> <value>` setting.
