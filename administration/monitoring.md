---
description: Learn how to monitor your Fluent Bit data pipelines
---

# Monitor data pipelines

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=e9ca51eb-7faf-491d-a62e-618a21c94506" />

Fluent Bit includes features for monitoring the internals of your pipeline, in addition to connecting to Prometheus and Grafana, Health checks, and connectors to use external services:

- [HTTP Server: JSON and Prometheus Exporter-style metrics](monitoring.md#http-server)
- [Grafana Dashboards and Alerts](monitoring.md#grafana-dashboard-and-alerts)
- [Health Checks](monitoring.md#health-check-for-fluent-bit)
- [Telemetry Pipeline: hosted service to monitor and visualize your pipelines](monitoring.md#telemetry-pipeline)

## HTTP server

Fluent Bit includes an HTTP server for querying internal information and monitoring metrics of each running plugin.

You can integrate the monitoring interface with Prometheus.

### Get started

To get started, enable the HTTP server from the configuration file. The following configuration instructs Fluent Bit to start an HTTP server on TCP port `2020` and listen on all network interfaces:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020

pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020

[INPUT]
  Name cpu

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

Start Fluent Bit with the corresponding configuration chosen previously:

```shell
# For YAML configuration.
$ fluent-bit --config fluent-bit.yaml

# For classic configuration.
$ fluent-bit --config fluent-bit.conf
```

Fluent Bit starts and generates output in your terminal:

```shell
...
[2020/03/10 19:08:24] [ info] [engine] started
[2020/03/10 19:08:24] [ info] [http_server] listen iface=0.0.0.0 tcp_port=2020
```

Use `curl` to gather information about the HTTP server. The following command sends the command output to the `jq` program, which outputs human-readable JSON data to the terminal.

```shell
$ curl -s http://127.0.0.1:2020 | jq
{
  "fluent-bit": {
    "version": "0.13.0",
    "edition": "Community",
    "flags": [
      "FLB_HAVE_TLS",
      "FLB_HAVE_METRICS",
      "FLB_HAVE_SQLDB",
      "FLB_HAVE_TRACE",
      "FLB_HAVE_HTTP_SERVER",
      "FLB_HAVE_FLUSH_LIBCO",
      "FLB_HAVE_SYSTEMD",
      "FLB_HAVE_VALGRIND",
      "FLB_HAVE_FORK",
      "FLB_HAVE_PROXY_GO",
      "FLB_HAVE_REGEX",
      "FLB_HAVE_C_TLS",
      "FLB_HAVE_SETJMP",
      "FLB_HAVE_ACCEPT4",
      "FLB_HAVE_INOTIFY"
    ]
  }
}
```

### REST API interface

Fluent Bit exposes the following endpoints for monitoring.

| URI                        | Description   | Data format           |
| -------------------------- | ------------- | --------------------- |
| `/`                          | Fluent Bit build information. | JSON |
| `/api/v1/uptime`             | Return uptime information in seconds. | JSON |
| `/api/v1/metrics`            | Display internal metrics per loaded plugin. | JSON                  |
| `/api/v1/metrics/prometheus` | Display internal metrics per loaded plugin in Prometheus Server format. | Prometheus Text 0.0.4 |
| `/api/v1/storage`            | Get internal metrics of the storage layer / buffered data. This option is enabled only if in the `SERVICE` section of the property `storage.metrics` is enabled. | JSON |
| `/api/v1/health`             | Display the Fluent Bit health check result. | String |
| `/api/v2/metrics`            | Display internal metrics per loaded plugin. | [cmetrics text format](https://github.com/fluent/cmetrics) |
| `/api/v2/metrics/prometheus` | Display internal metrics per loaded plugin ready in Prometheus Server format. | Prometheus Text 0.0.4 |
| `/api/v2/reload`             | Execute hot reloading or get the status of hot reloading. See the [hot-reloading documentation](hot-reload.md). | JSON |

### v1 metrics

The following descriptions apply to v1 metric endpoints.

#### `/api/v1/metrics/prometheus` endpoint

The following descriptions apply to metrics outputted in Prometheus format by the `/api/v1/metrics/prometheus` endpoint.

The following terms are key to understanding how Fluent Bit processes metrics:

- **Record**: a single message collected from a source, such as a single long line in a file.
- **Chunk**: log records ingested and stored by Fluent Bit input plugin instances. A batch of records in a chunk are tracked together as a single unit.

  The Fluent Bit engine attempts to fit records into chunks of at most `2 MB`, but the size can vary at runtime. Chunks are then sent to an output. An output plugin instance can successfully send the full chunk to the destination and mark it as successful, or it can fail the chunk entirely if an unrecoverable error is encountered, or it can ask for the chunk to be retried.

| Metric name | Labels | Description | Type | Unit |
| ----------- | ------ | ----------- | ---- | ---- |
| `fluentbit_input_bytes_total`          | name: the name or alias for the input instance  | The number of bytes of log records that this input instance has ingested successfully. | counter | bytes   |
| `fluentbit_input_records_total`        | name: the name or alias for the input instance  | The number of log records this input ingested successfully. | counter | records |
| `fluentbit_output_dropped_records_total` | name: the name or alias for the output instance | The number of log records dropped by the output. These records hit an unrecoverable error or retries expired for their chunk. | counter | records |
| `fluentbit_output_errors_total`        | name: the name or alias for the output instance | The number of chunks with an error that's either unrecoverable or unable to retry. This metric represents the number of times a chunk failed, and doesn't correspond with the number of error messages visible in the Fluent Bit log output. | counter | chunks  |
| `fluentbit_output_proc_bytes_total`      | name: the name or alias for the output instance | The number of bytes of log records that this output instance sent successfully. This metric represents the total byte size of all unique chunks sent by this output. If a record isn't sent due to some error, it doesn't count towards this metric. | counter | bytes   |
| `fluentbit_output_proc_records_total`    | name: the name or alias for the output instance | The number of log records that this output instance sent successfully. This metric represents the total record count of all unique chunks sent by this output. If a record isn't sent successfully, it doesn't count towards this metric. | counter | records |
| `fluentbit_output_retried_records_total` | name: the name or alias for the output instance | The number of log records that experienced a retry. This metric is calculated at the chunk level, the count increased when an entire chunk is marked for retry. An output plugin might perform multiple actions that generate many error messages when uploading a single chunk. | counter | records |
| `fluentbit_output_retries_failed_total` | name: the name or alias for the output instance | The number of times that retries expired for a chunk. Each plugin configures a `Retry_Limit`, which applies to chunks. When the `Retry_Limit` is exceeded, the chunk is discarded and this metric is incremented. | counter | chunks  |
| `fluentbit_output_retries_total`         | name: the name or alias for the output instance | The number of times this output instance requested a retry for a chunk. | counter | chunks  |
| `fluentbit_uptime` | | The number of seconds that Fluent Bit has been running. | counter | seconds |
| `process_start_time_seconds` | | The Unix Epoch timestamp for when Fluent Bit started. | gauge   | seconds |

#### `/api/v1/storage` endpoint

The following descriptions apply to metrics outputted in JSON format by the `/api/v1/storage` endpoint.

| Metric Key                                    | Description   | Unit    |
|-----------------------------------------------|---------------|---------|
| `chunks.total_chunks`                         | The total number of chunks of records that Fluent Bit is currently buffering. | chunks  |
| `chunks.mem_chunks`                           | The total number of chunks that are currently buffered in memory. Chunks can be both in memory and on the file system at the same time. | chunks  |
| `chunks.fs_chunks`                            | The total number of chunks saved to the filesystem. | chunks  |
| `chunks.fs_chunks_up`                         | The count of chunks that are both in file system and in memory. | chunks  |
| `chunks.fs_chunks_down`                       | The count of chunks that are only in the file system. | chunks  |
| `input_chunks.{plugin name}.status.overlimit` | Indicates whether the input instance exceeded its configured `Mem_Buf_Limit.` | boolean |
| `input_chunks.{plugin name}.status.mem_size`  | The size of memory that this input is consuming to buffer logs in chunks. | bytes   |
| `input_chunks.{plugin name}.status.mem_limit` | The buffer memory limit (`Mem_Buf_Limit`) that applies to this input plugin. | bytes   |
| `input_chunks.{plugin name}.chunks.total`     | The current total number of chunks owned by this input instance. | chunks  |
| `input_chunks.{plugin name}.chunks.up`        | The current number of chunks that are in memory for this input. If file system storage is enabled, chunks that are "up" are also stored in the filesystem layer. | chunks  |
| `input_chunks.{plugin name}.chunks.down`      | The current number of chunks that are "down" in the filesystem for this input. | chunks  |
| `input_chunks.{plugin name}.chunks.busy`      | Chunks are that are being processed or sent by outputs and aren't eligible to have new data appended. | chunks  |
| `input_chunks.{plugin name}.chunks.busy_size` | The sum of the byte size of each chunk which is currently marked as busy. | bytes   |

### v2 metrics

The following descriptions apply to v2 metric endpoints.

#### `/api/v2/metrics/prometheus` or `/api/v2/metrics` endpoint

The following descriptions apply to metrics outputted in Prometheus format by the `/api/v2/metrics/prometheus` or `/api/v2/metrics` endpoints.

The following terms are key to understanding how Fluent Bit processes metrics:

- **Record**: a single message collected from a source, such as a single long line in a file.
- **Chunk**: log records ingested and stored by Fluent Bit input plugin instances. A batch of records in a chunk are tracked together as a single unit.

  The Fluent Bit engine attempts to fit records into chunks of at most `2 MB`, but the size can vary at runtime. Chunks are then sent to an output. An output plugin instance can either successfully send the full chunk to the destination and mark it as successful, or it can fail the chunk entirely if an unrecoverable error is encountered, or it can ask for the chunk to be retried.

| Metric Name                                | Labels                                                                  | Description | Type    | Unit    |
|--------------------------------------------|-------------------------------------------------------------------------|-------------|---------|---------|
| `fluentbit_input_bytes_total`            | name: the name or alias for the input instance  | The number of bytes of log records that this input instance has ingested successfully. | counter | bytes   |
| `fluentbit_input_records_total`          | name: the name or alias for the input instance  | The number of log records this input ingested successfully. | counter | records |
| `fluentbit_filter_bytes_total`           | name: the name or alias for the filter instance | The number of bytes of log records that this filter instance has ingested successfully. | counter | bytes   |
| `fluentbit_filter_records_total`         | name: the name or alias for the filter instance | The number of log records this filter has ingested successfully. | counter | records |
| `fluentbit_filter_added_records_total`   | name: the name or alias for the filter instance | The number of log records added by the filter into the data pipeline. | counter | records |
| `fluentbit_filter_drop_records_total`    | name: the name or alias for the filter instance | The number of log records dropped by the filter and removed from the data pipeline. | counter | records |
| `fluentbit_output_dropped_records_total` | name: the name or alias for the output instance | The number of log records dropped by the output. These records hit an unrecoverable error or retries expired for their chunk. | counter | records |
| `fluentbit_output_errors_total`          | name: the name or alias for the output instance | The number of chunks with an error that's either unrecoverable or unable to retry. This metric represents the number of times a chunk failed, and doesn't correspond with the number of error messages visible in the Fluent Bit log output. | counter | chunks  |
| `fluentbit_output_proc_bytes_total`      | name: the name or alias for the output instance | The number of bytes of log records that this output instance sent successfully. This metric represents the total byte size of all unique chunks sent by this output. If a record isn't sent due to some error, it doesn't count towards this metric. | counter | bytes   |
| `fluentbit_output_proc_records_total`    | name: the name or alias for the output instance | The number of log records that this output instance sent successfully. This metric represents the total record count of all unique chunks sent by this output. If a record isn't sent successfully, it doesn't count towards this metric. | counter | records |
| `fluentbit_output_retried_records_total` | name: the name or alias for the output instance | The number of log records that experienced a retry. This metric is calculated at the chunk level, the count increased when an entire chunk is marked for retry. An output plugin might perform multiple actions that generate many error messages when uploading a single chunk. | counter | records |
| `fluentbit_output_retries_failed_total` | name: the name or alias for the output instance | The number of times that retries expired for a chunk. Each plugin configures a `Retry_Limit`, which applies to chunks. When the `Retry_Limit` is exceeded, the chunk is discarded and this metric is incremented. | counter | chunks  |
| `fluentbit_output_retries_total`        | name: the name or alias for the output instance | The number of times this output instance requested a retry for a chunk. | counter | chunks  |
| `fluentbit_output_latency_seconds`      | input: the name of the input plugin instance, output: the name of the output plugin instance | End-to-end latency from chunk creation to successful delivery. Provides observability into chunk-level pipeline performance. | histogram | seconds |
| `fluentbit_uptime`                      | hostname: the hostname on running Fluent Bit | The number of seconds that Fluent Bit has been running. | counter | seconds |
| `fluentbit_process_start_time_seconds`  | hostname: the hostname on running Fluent Bit | The Unix Epoch time stamp for when Fluent Bit started. | gauge   | seconds |
| `fluentbit_build_info`                  | hostname: the hostname, version: the version of Fluent Bit, os: OS type | Build version information. The returned value is originated from initializing the Unix Epoch time stamp of configuration context. | gauge   | seconds |
| `fluentbit_hot_reloaded_times`          | hostname: the hostname on running Fluent Bit | Collect the count of hot reloaded times. | gauge   | seconds |

#### Storage layer

The following are detailed descriptions for the metrics collected by the storage layer.

| Metric Name                                 | Labels                       | Description   | Type    | Unit    |
|---------------------------------------------|------------------------------|---------------|---------|---------|
| `fluentbit_input_chunks.storage_chunks`     | None                         | The total number of chunks of records that Fluent Bit is currently buffering. | gauge | chunks |
| `fluentbit_storage_mem_chunk`               | None                         | The total number of chunks that are currently buffered in memory. Chunks can be both in memory and on the file system at the same time. | gauge | chunks |
| `fluentbit_storage_fs_chunks`               | None                         | The total number of chunks saved to the file system. | gauge | chunks |
| `fluentbit_storage_fs_chunks_up`            | None                         | The count of chunks that are both in file system and in memory. | gauge | chunks |
| `fluentbit_storage_fs_chunks_down`          | None                         | The count of chunks that are only in the file system. | gauge | chunks |
| `fluentbit_storage_fs_chunks_busy`          | None                         | The total number of chunks are in a busy state. | gauge | chunks |
| `fluentbit_storage_fs_chunks_busy_bytes`    | None                         | The total bytes of chunks are in a busy state. | gauge | bytes |
| `fluentbit_input_storage_overlimit`         | name: the name or alias for the input instance  | Indicates whether the input instance exceeded its configured `Mem_Buf_Limit.` | gauge | boolean |
| `fluentbit_input_storage_memory_bytes`      | name: the name or alias for the input instance  | The size of memory that this input is consuming to buffer logs in chunks. | gauge | bytes |
| `fluentbit_input_storage_chunks`            | name: the name or alias for the input instance  | The current total number of chunks owned by this input instance. | gauge | chunks |
| `fluentbit_input_storage_chunks_up`         | name: the name or alias for the input instance  | The current number of chunks that are in memory for this input. If file system storage is enabled, chunks that are "up" are also stored in the filesystem layer. | gauge | chunks |
| `fluentbit_input_storage_chunks_down`       | name: the name or alias for the input instance  | The current number of chunks that are "down" in the filesystem for this input. | gauge | chunks |
| `fluentbit_input_storage_chunks_busy`       | name: the name or alias for the input instance  | Chunks are that are being processed or sent by outputs and aren't eligible to have new data appended. | gauge | chunks |
| `fluentbit_input_storage_chunks_busy_bytes` | name: the name or alias for the input instance  | The sum of the byte size of each chunk which is currently marked as busy. | gauge | bytes |
| `fluentbit_output_upstream_total_connections` | name: the name or alias for the output instance | The sum of the connection count of each output plugins. | gauge | bytes |
| `fluentbit_output_upstream_busy_connections` | name: the name or alias for the output instance | The sum of the connection count in a busy state of each output plugins.                                                                                                  | gauge   | bytes   |

### Output latency metric

> note: feature introduced in v4.0.6.

The `fluentbit_output_latency_seconds` histogram metric captures end-to-end latency from the time a chunk is created by an input plugin until it is successfully delivered by an output plugin. This provides observability into chunk-level pipeline performance and helps identify slowdowns or bottlenecks in the output path.

#### Bucket configuration

The histogram uses the following default bucket boundaries, designed around Fluent Bit's typical flush interval of 1 second:

```
0.5, 1.0, 1.5, 2.5, 5.0, 10.0, 20.0, 30.0, +Inf
```

These boundaries provide:
- **High resolution around 1s latency**: Captures normal operation near the default flush interval
- **Small backpressure detection**: Identifies minor delays in the 1-2.5s range
- **Bottleneck identification**: Detects retry cycles, network stalls, or plugin bottlenecks in higher ranges
- **Complete coverage**: The `+Inf` bucket ensures all latencies are captured

#### Example output

When exposed via Fluent Bit's built-in HTTP server, the metric appears in Prometheus format:

```prometheus
# HELP fluentbit_output_latency_seconds End-to-end latency in seconds
# TYPE fluentbit_output_latency_seconds histogram
fluentbit_output_latency_seconds_bucket{le="0.5",input="random.0",output="stdout.0"} 0
fluentbit_output_latency_seconds_bucket{le="1.0",input="random.0",output="stdout.0"} 1
fluentbit_output_latency_seconds_bucket{le="1.5",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="2.5",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="5.0",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="10.0",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="20.0",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="30.0",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_bucket{le="+Inf",input="random.0",output="stdout.0"} 6
fluentbit_output_latency_seconds_sum{input="random.0",output="stdout.0"} 6.0015411376953125
fluentbit_output_latency_seconds_count{input="random.0",output="stdout.0"} 6
```

#### Use cases

**Performance monitoring**: Monitor overall pipeline health by tracking latency percentiles:

```promql
# 95th percentile latency
histogram_quantile(0.95, rate(fluentbit_output_latency_seconds_bucket[5m]))

# Average latency
rate(fluentbit_output_latency_seconds_sum[5m]) / rate(fluentbit_output_latency_seconds_count[5m])
```

**Bottleneck detection**: Identify specific input/output pairs experiencing high latency:

```promql
# Outputs with highest average latency
topk(5, rate(fluentbit_output_latency_seconds_sum[5m]) / rate(fluentbit_output_latency_seconds_count[5m]))
```

**SLA monitoring**: Track how many chunks are delivered within acceptable time bounds:

```promql
# Percentage of chunks delivered within 2 seconds
(
  rate(fluentbit_output_latency_seconds_bucket{le="2.0"}[5m]) /
  rate(fluentbit_output_latency_seconds_count[5m])
) * 100
```

**Alerting**: Create alerts for degraded pipeline performance:

```yaml
# Example Prometheus alerting rule
- alert: FluentBitHighLatency
  expr: histogram_quantile(0.95, rate(fluentbit_output_latency_seconds_bucket[5m])) > 5
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "Fluent Bit pipeline experiencing high latency"
    description: "95th percentile latency is {{ $value }}s for {{ $labels.input }} -> {{ $labels.output }}"
```

### Uptime example

Query the service uptime with the following command:

```shell
curl -s http://127.0.0.1:2020/api/v1/uptime | jq
```

The command prints a similar output like this:

```json
{
  "uptime_sec": 8950000,
  "uptime_hr": "Fluent Bit has been running:  103 days, 14 hours, 6 minutes and 40 seconds"
}
```

### Metrics example

Query internal metrics in JSON format with the following command:

```shell
curl -s http://127.0.0.1:2020/api/v1/metrics | jq
```

The command prints a similar output like this:

```json
{
  "input": {
    "cpu.0": {
      "records": 8,
      "bytes": 2536
    }
  },
  "output": {
    "stdout.0": {
      "proc_records": 5,
      "proc_bytes": 1585,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

### Query metrics in Prometheus format

Query internal metrics in Prometheus Text 0.0.4 format:

```shell
curl -s http://127.0.0.1:2020/api/v1/metrics/prometheus
```

This command returns the same metrics in Prometheus format instead of JSON:

```text
fluentbit_input_records_total{name="cpu.0"} 57 1509150350542
fluentbit_input_bytes_total{name="cpu.0"} 18069 1509150350542
fluentbit_output_proc_records_total{name="stdout.0"} 54 1509150350542
fluentbit_output_proc_bytes_total{name="stdout.0"} 17118 1509150350542
fluentbit_output_errors_total{name="stdout.0"} 0 1509150350542
fluentbit_output_retries_total{name="stdout.0"} 0 1509150350542
fluentbit_output_retries_failed_total{name="stdout.0"} 0 1509150350542
```

### Configure aliases

By default, configured plugins on runtime get an internal name in the format `_plugin_name.ID_`. For monitoring purposes, this can be confusing if many plugins of the same type were configured. To make a distinction each configured input or output section can get an _alias_ that will be used as the parent name for the metric.

The following example sets an alias to the `INPUT` section of the configuration file, which is using the [CPU](../pipeline/inputs/cpu-metrics.md) input plugin:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020

pipeline:
  inputs:
    - name: cpu
      alias: server1_cpu

  outputs:
    - name: stdout
      alias: raw_output
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020

[INPUT]
  Name  cpu
  Alias server1_cpu

[OUTPUT]
  Name  stdout
  Alias raw_output
  Match *
```

{% endtab %}
{% endtabs %}

When querying the related metrics, the aliases are returned instead of the plugin name:

```json
{
  "input": {
    "server1_cpu": {
      "records": 8,
      "bytes": 2536
    }
  },
  "output": {
    "raw_output": {
      "proc_records": 5,
      "proc_bytes": 1585,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

## Grafana dashboard and alerts

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=0b83cb05-4f52-4853-83cc-f4539b64044d" />

You can create Grafana dashboards and alerts using Fluent Bit exposed Prometheus style metrics.

The provided [example dashboard](https://github.com/fluent/fluent-bit-docs/blob/master/monitoring/dashboard.json) is heavily inspired by [Banzai Cloud](https://github.com/banzaicloud)'s [logging operator dashboard](https://grafana.com/grafana/dashboards/7752) with a few key differences, such as the use of the `instance` label, stacked graphs, and a focus on Fluent Bit metrics. See [this blog post](https://www.robustperception.io/controlling-the-instance-label) for more information.

![dashboard](/.gitbook/assets/dashboard.png)

### Alerts

Sample alerts [are available](https://github.com/fluent/fluent-bit-docs/blob/master/monitoring/alerts.yaml).

## Health check for Fluent Bit

Fluent Bit supports the following configurations to set up the health check.

| Configuration name     | Description | Default       |
| ---------------------- | ------------| ------------- |
| `Health_Check`           | Enable Health check feature | `Off` |
| `HC_Errors_Count`       | the error count to meet the unhealthy requirement, this is a sum for all output plugins in a defined `HC_Period`, example for output error: `[2022/02/16 10:44:10] [ warn] [engine] failed to flush chunk '1-1645008245.491540684.flb', retry in 7 seconds: task_id=0, input=forward.1 > output=cloudwatch_logs.3 (out_id=3)` | `5` |
| `HC_Retry_Failure_Count` | the retry failure count to meet the unhealthy requirement, this is a sum for all output plugins in a defined `HC_Period`, example for retry failure: `[2022/02/16 20:11:36] [ warn] [engine] chunk '1-1645042288.260516436.flb' cannot be retried: task_id=0, input=tcp.3 > output=cloudwatch_logs.1` | `5` |
| `HC_Period` | The time period by second to count the error and retry failure data point | `60` |

Not every error log means an error to be counted. The error retry failures count only on specific errors, which is the example in configuration table description.

Based on the `HC_Period` setting, if the real error number is over `HC_Errors_Count`, or retry failure is over `HC_Retry_Failure_Count`, Fluent Bit is considered unhealthy. The health endpoint returns an HTTP status `500` and an `error` message. Otherwise, the endpoint returns HTTP status `200` and an `ok` message.

The equation to calculate this behavior is:

```text
health status = (HC_Errors_Count > HC_Errors_Count config value) OR
(HC_Retry_Failure_Count > HC_Retry_Failure_Count config value) IN
the HC_Period interval
```

The `HC_Errors_Count` and `HC_Retry_Failure_Count` only count for output plugins and count a sum for errors and retry failures from all running output plugins.

The following configuration examples show how to define these settings:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  http_server: on
  http_listen: 0.0.0.0
  http_port: 2020
  health_check: on
  hc_errors_count: 5
  hc_retry_failure_count: 5
  hc_period: 5

pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  HTTP_Server  On
  HTTP_Listen  0.0.0.0
  HTTP_PORT    2020
  Health_Check On
  HC_Errors_Count 5
  HC_Retry_Failure_Count 5
  HC_Period 5

[INPUT]
  Name  cpu

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

Use the following command to call the health endpoint:

```shell
curl -s http://127.0.0.1:2020/api/v1/health
```

With the example configuration, the health status is determined by the following equation:

```text
Health status = (HC_Errors_Count > 5) OR (HC_Retry_Failure_Count > 5) IN 5 seconds
```

- If this equation evaluates to `TRUE`, then Fluent Bit is unhealthy.
- If this equation evaluates to `FALSE`, then Fluent Bit is healthy.

## Telemetry Pipeline

[Telemetry Pipeline](https://chronosphere.io/platform/telemetry-pipeline/) is a
hosted service that lets you monitor your Fluent Bit agents including data flow,
metrics, and configurations.
