---
description: The Podman Metrics input plugin allows you to collect metrics from podman containers, so they can be exposed later as, for example, Prometheus counters and gauges.
---

# Podman Metrics

## Configuration Parameters

| **Key**           | Description                                                | Default                                                        |
| ----------------- | ---------------------------------------------------------- | -------------------------------------------------------------- |
| scrape_interval   | Interval between each scrape of podman data (in seconds)   | 20                                                             |
| scrape_on_start   | Should this plugin scrape podman data after it is started  | false                                                          |
| config            | Custom path to podman containers configuration file        | /var/lib/containers/storage/overlay-containers/containers.json |

## Getting Started

The podman metrics input plugin allows Fluent Bit to gather podman container metrics. The entire procedure of collecting container list and gathering data associated with them bases on filesystem data.This plugin does not execute podman commands or send http requests to podman api - instead it reads podman configuration file and metrics exposed by */sys* and */proc* filesystems.

This plugin supports and automatically detects both cgroups v1 and v2.

**Example Curl message for one running container**

```
$> curl 0.0.0.0:2021/metrics
# HELP fluentbit_input_bytes_total Number of input bytes.
# TYPE fluentbit_input_bytes_total counter
fluentbit_input_bytes_total{name="podman_metrics.0"} 0
# HELP fluentbit_input_records_total Number of input records.
# TYPE fluentbit_input_records_total counter
fluentbit_input_records_total{name="podman_metrics.0"} 0
# HELP container_memory_usage_bytes Container memory usage in bytes
# TYPE container_memory_usage_bytes counter
container_memory_usage_bytes{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty"} 7806976
# HELP container_cpu_user_seconds_total Container cpu usage in bytes in user mode
# TYPE container_cpu_user_seconds_total counter
container_cpu_user_seconds_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty"} 13184
# HELP container_cpu_usage_seconds_total Container cpu usage in bytes
# TYPE container_cpu_usage_seconds_total counter
container_cpu_usage_seconds_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty"} 28981
# HELP container_network_receive_bytes_total Network received bytes
# TYPE container_network_receive_bytes_total counter
container_network_receive_bytes_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty",interface="eth0"} 10196
# HELP container_network_receive_errors_total Network received errors
# TYPE container_network_receive_errors_total counter
container_network_receive_errors_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty",interface="eth0"} 0
# HELP container_network_transmit_bytes_total Network transmited bytes
# TYPE container_network_transmit_bytes_total counter
container_network_transmit_bytes_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty",interface="eth0"} 682
# HELP container_network_transmit_errors_total Network transmitedd errors
# TYPE container_network_transmit_errors_total counter
container_network_transmit_errors_total{id="8a19d6058bfbe88cd0548eba9047d94c70161f5d74b545c7504b2f27491686d9",name="determined_mcnulty",interface="eth0"} 0
```

### Configuration File

```
[INPUT]
    name podman_metrics
    scrape_interval 10
    scrape_on_start true
[OUTPUT]
    name prometheus_exporter
```

### Command Line

```
$> fluent-bit -i podman_metrics -o prometheus_exporter
```

### Exposed metrics

Currently supported counters are:
- container_memory_usage_bytes
- container_memory_max_usage_bytes
- container_memory_rss
- container_spec_memory_limit_bytes
- container_cpu_user_seconds_total
- container_cpu_usage_seconds_total
- container_network_receive_bytes_total
- container_network_receive_errors_total
- container_network_transmit_bytes_total
- container_network_transmit_errors_total

> This plugin mimics naming convetion of docker metrics exposed by [cadvisor](https://github.com/google/cadvisor) project