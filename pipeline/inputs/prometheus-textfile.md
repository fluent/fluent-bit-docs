# Prometheus text file

The _Prometheus text file_ input plugin allows Fluent Bit to read metrics from Prometheus text format files (`.prom` files) on the local filesystem. Use this plugin to collect custom metrics that are written to files by external applications or scripts, similar to the Prometheus Node Exporter text file collector.

## Configuration parameters

| Key | Description | Default |
|-----|-------------|---------|
| `path` | File or directory path pattern. Supports glob patterns with `*` wildcard (for example, `/var/lib/prometheus/*.prom`). | _none_ |
| `scrape_interval` | Interval in seconds between file scans. | `10s` |

## Get started

### Basic configuration

The following configuration will monitor `/var/lib/prometheus/textfile` directory for `.prom` files every 15 seconds:

```yaml
pipeline:
  inputs:
    - name: prometheus_textfile
      tag: custom_metrics
      path: '/var/lib/prometheus/textfile/*.prom'
      scrape_interval: 15
  outputs:
    - name: prometheus_exporter
      match: custom_metrics
      host: 192.168.100.61
      port: 2021
```

## Prometheus text format

The plugin expects files to be in the standard Prometheus text exposition format. Here's an example of a valid `.prom` file:

```text
# HELP custom_counter_total A custom counter metric
# TYPE custom_counter_total counter
custom_counter_total{instance="server1",job="myapp"} 42

# HELP custom_gauge A custom gauge metric
# TYPE custom_gauge gauge
custom_gauge{environment="production"} 1.23

# HELP custom_histogram_bucket A custom histogram
# TYPE custom_histogram_bucket histogram
custom_histogram_bucket{le="0.1"} 10
custom_histogram_bucket{le="0.5"} 25
custom_histogram_bucket{le="1.0"} 40
custom_histogram_bucket{le="+Inf"} 50
custom_histogram_sum 125.5
custom_histogram_count 50
```

## Use cases

### Custom application metrics

Applications can write custom metrics to `.prom` files, and this plugin will collect them:

```bash
# Script writes metrics to file
echo "# HELP app_requests_total Total HTTP requests" > /var/lib/prometheus/textfile/app.prom
echo "# TYPE app_requests_total counter" >> /var/lib/prometheus/textfile/app.prom
echo "app_requests_total{status=\"200\"} 1500" >> /var/lib/prometheus/textfile/app.prom
echo "app_requests_total{status=\"404\"} 23" >> /var/lib/prometheus/textfile/app.prom
```

### Batch job metrics

Cron jobs or batch processes can write completion metrics:

```bash
#!/bin/bash
# Backup script writes completion metrics
BACKUP_START=$(date +%s)
# ... perform backup ...
BACKUP_END=$(date +%s)
DURATION=$((BACKUP_END - BACKUP_START))

cat > /var/lib/prometheus/textfile/backup.prom << EOF
# HELP backup_duration_seconds Time taken to complete backup
# TYPE backup_duration_seconds gauge
backup_duration_seconds ${DURATION}

# HELP backup_last_success_timestamp_seconds Last successful backup timestamp
# TYPE backup_last_success_timestamp_seconds gauge
backup_last_success_timestamp_seconds ${BACKUP_END}
EOF
```

### System integration

External monitoring tools can write metrics that Fluent Bit will collect and forward.

## Integration with other plugins


### OpenTelemetry destination

```yaml
pipeline:
  inputs:
    - name: prometheus_textfile
      tag: textfile_metrics
      path: /var/lib/prometheus/textfile
    - name: node_exporter_metrics
      tag: system_metrics
      scrape_interval: 15
  outputs:
    - name: opentelemetry
      match: '*'
      host: 192.168.56.4
      port: 2021
```
