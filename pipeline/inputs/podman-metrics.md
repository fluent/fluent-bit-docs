---
description: The Podman Metrics input plugin allows you to collect metrics from podman containers, so they can be exposed later as, for example, Prometheus counters and gauges.
---

# Podman Metrics

## Configuration Parameters

| **Key**           | Description                                                | Default                                                        |
| ----------------- | ---------------------------------------------------------- | -------------------------------------------------------------- |
| scrape_interval   | Interval between each scrape of podman data (in seconds)   | 30                                                             |
| scrape_on_start   | Should this plugin scrape podman data after it is started  | false                                                          |
| path.config       | Custom path to podman containers configuration file        | /var/lib/containers/storage/overlay-containers/containers.json |
| path.sysfs        | Custom path to sysfs subsystem directory                   | /sys/fs/cgroup                                                 |
| path.procfs       | Custom path to proc subsystem directory                    | /proc                                                          |

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
container_memory_usage_bytes{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest"} 884736
# HELP container_cpu_user_seconds_total Container cpu usage in seconds in user mode
# TYPE container_cpu_user_seconds_total counter
container_cpu_user_seconds_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest"} 0
# HELP container_cpu_usage_seconds_total Container cpu usage in seconds
# TYPE container_cpu_usage_seconds_total counter
container_cpu_usage_seconds_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest"} 0
# HELP container_network_receive_bytes_total Network received bytes
# TYPE container_network_receive_bytes_total counter
container_network_receive_bytes_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest",interface="eth0"} 8515
# HELP container_network_receive_errors_total Network received errors
# TYPE container_network_receive_errors_total counter
container_network_receive_errors_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest",interface="eth0"} 0
# HELP container_network_transmit_bytes_total Network transmited bytes
# TYPE container_network_transmit_bytes_total counter
container_network_transmit_bytes_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest",interface="eth0"} 962
# HELP container_network_transmit_errors_total Network transmitedd errors
# TYPE container_network_transmit_errors_total counter
container_network_transmit_errors_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest",interface="eth0"} 0
# HELP fluentbit_input_storage_overlimit Is the input memory usage overlimit ?.
# TYPE fluentbit_input_storage_overlimit gauge
fluentbit_input_storage_overlimit{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_memory_bytes Memory bytes used by the chunks.
# TYPE fluentbit_input_storage_memory_bytes gauge
fluentbit_input_storage_memory_bytes{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_chunks Total number of chunks.
# TYPE fluentbit_input_storage_chunks gauge
fluentbit_input_storage_chunks{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_chunks_up Total number of chunks up in memory.
# TYPE fluentbit_input_storage_chunks_up gauge
fluentbit_input_storage_chunks_up{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_chunks_down Total number of chunks down.
# TYPE fluentbit_input_storage_chunks_down gauge
fluentbit_input_storage_chunks_down{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_chunks_busy Total number of chunks in a busy state.
# TYPE fluentbit_input_storage_chunks_busy gauge
fluentbit_input_storage_chunks_busy{name="podman_metrics.0"} 0
# HELP fluentbit_input_storage_chunks_busy_bytes Total number of bytes used by chunks in a busy state.
# TYPE fluentbit_input_storage_chunks_busy_bytes gauge
fluentbit_input_storage_chunks_busy_bytes{name="podman_metrics.0"} 0
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
