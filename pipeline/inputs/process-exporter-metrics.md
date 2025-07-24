---
description: A plugin based on Process Exporter to collect process level of metrics of system
  metrics
---

# Process exporter metrics

[Prometheus Node exporter](https://github.com/prometheus/node_exporter) is a popular way to collect system level metrics from operating systems such as CPU, disk, network, and process statistics.

Fluent Bit 2.2 and later includes a process exporter plugin that builds off the Prometheus design to collect process level metrics without having to manage two separate processes or agents.

The Process Exporter Metrics plugin implements collecting of the various metrics available from [the third party implementation of Prometheus Process Exporter](https://github.com/ncabatoff/process-exporter) and these will be expanded over time as needed.

{% hint style="info" %}

All metrics including those collected with this plugin flow through a separate pipeline from logs and current filters don't operate on top of metrics. This plugin is only supported on Linux based operating systems as it uses the `proc` filesystem to access the relevant metrics. MacOS doesn't have the `proc` filesystem so this plugin won't work for it.

{% endhint %}

## Configuration

| Key                       | Description                                                                                                                                                                                                                                                                           | Default                                                                  |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `scrape_interval`         | The rate, in seconds, at which metrics are collected.                                                                                                                                                                                                                                 | `5`                                                                      |
| `path.procfs`             | The mount point used to collect process information and metrics. Read-only permissions are enough.                                                                                                                                                                                    | `/proc/`                                                                 |
| `process_include_pattern` | Regular expression to determine which names of processes are included in the metrics produced by this plugin. It's applied for all process unless explicitly set.                                                                                                                     | `.+`                                                                     |
| `process_exclude_pattern` | Regular expression to determine which names of processes are excluded in the metrics produced by this plugin. It's not applied unless explicitly set.                                                                                                                                 | `NULL`                                                                   |
| `metrics`                 | Specify which process level of metrics are collected from the host operating system. Actual values of metrics will be read from `/proc` when needed. `cpu`, `io`, `memory`, `state`, `context_switches`, `fd,` `start_time`, `thread_wchan`, and `thread` metrics depend on `procfs`. | `cpu,io,memory,state,context_switches,fd,start_time,thread_wchan,thread` |

## Available  metrics

| Name               | Description                                         |
|--------------------|-----------------------------------------------------|
| `cpu`              | Exposes CPU statistics from `/proc`.                |
| `io`               | Exposes I/O statistics from `/proc`.                |
| `memory`           | Exposes memory statistics from `/proc`.             |
| `state`            | Exposes process state statistics from `/proc`.      |
| `context_switches` | Exposes `context_switches` statistics from `/proc`. |
| `fd`               | Exposes file descriptors statistics from `/proc`.   |
| `start_time`       | Exposes `start_time` statistics from `/proc`.       |
| `thread_wchan`     | Exposes `thread_wchan` from `/proc`.                |
| `thread`           | Exposes thread statistics from `/proc`.             |

## Threading

This input always runs in its own [thread](../../administration/multithreading.md#inputs).

## Getting started

### Configuration file

In the following configuration file, the input plugin `process_exporter_metrics` collects metrics every 2 seconds and exposes them through the [Prometheus Exporter](../outputs/prometheus-exporter.md) output plugin on HTTP/TCP port 2021.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
# Process Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collect host metrics on Linux and expose
# them through a Prometheus HTTP end-point.
#
# After starting the service try it with:
#
# $ curl http://127.0.0.1:2021/metrics
#
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: process_exporter_metrics
      tag:  process_metrics
      scrape_interval: 2

  outputs:
    - name: prometheus_exporter
      match: process_metrics
      host: 0.0.0.0
      port: 2021
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
# Process Exporter Metrics + Prometheus Exporter
# -------------------------------------------
# The following example collect host metrics on Linux and expose
# them through a Prometheus HTTP end-point.
#
# After starting the service try it with:
#
# $ curl http://127.0.0.1:2021/metrics
#
[SERVICE]
  flush           1
  log_level       info

[INPUT]
  name            process_exporter_metrics
  tag             process_metrics
  scrape_interval 2

[OUTPUT]
  name            prometheus_exporter
  match           process_metrics
  host            0.0.0.0
  port            2021
```

{% endtab %}
{% endtabs %}

You can see the metrics by using `curl`:

```shell
curl http://127.0.0.1:2021/metrics
```

### Container to collect host metrics

When deploying Fluent Bit in a container you will need to specify additional settings to ensure that Fluent Bit has access to the process details.

The following `docker` command deploys Fluent Bit with a specific mount path for `procfs` and settings enabled to ensure that Fluent Bit can collect from the host. These are then exposed over port 2021.

```shell
docker run -ti -v /proc:/host/proc:ro \
            -p 2021:2021        \
            fluent/fluent-bit:2.2 \
            /fluent-bit/bin/fluent-bit \
            -i process_exporter_metrics \
            -p path.procfs=/host/proc  \
            -o prometheus_exporter \
            -f 1
```

## Enhancement requests

Development prioritises a subset of the available collectors in the [third party implementation of Prometheus Process Exporter](https://github.com/ncabatoff/process-exporter). To request others, open a GitHub issue by using the following template:

- [`in_process_exporter_metrics`](https://github.com/fluent/fluent-bit/issues/new?assignees=\&labels=\&template=feature_request.md\&title=in_process_exporter_metrics:%20add%20ABC%20collector)
