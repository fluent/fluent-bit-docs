# Podman metrics

The Podman metrics input plugin lets Fluent Bit gather Podman container metrics. The procedure for collecting container list and gathering data associated with them is based on filesystem data.

The metrics can be exposed later as, for example, Prometheus counters and gauges.

## Configuration parameters

| Key               | Description                                                                                             | Default                                                          |
|-------------------|---------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| `scrape_interval` | Interval between each scrape of Podman data (in seconds).                                               | `30`                                                             |
| `scrape_on_start` | Sets whether this plugin scrapes Podman data on startup.                                                | `false`                                                          |
| `path.config`     | Custom path to the Podman containers configuration file.                                                | `/var/lib/containers/storage/overlay-containers/containers.json` |
| `path.sysfs`      | Custom path to the `sysfs` subsystem directory.                                                         | `/sys/fs/cgroup`                                                 |
| `path.procfs`     | Custom path to the `proc` subsystem directory.                                                          | `/proc`                                                          |
| `threaded`        | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false`                                                          |

## Get started

This plugin doesn't execute `podman` commands or send HTTP requests to Podman API. It reads a Podman configuration file and metrics exposed by the `/sys` and `/proc` filesystems.

This plugin supports and automatically detects both `cgroups v1` and `v2`.

### Example `curl` message for one running container

You can run the following `curl` command:

```shell
curl 0.0.0.0:2021/metrics
```

Which returns information like:

```text
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
# HELP container_network_transmit_bytes_total Network transmitted bytes
# TYPE container_network_transmit_bytes_total counter
container_network_transmit_bytes_total{id="858319c39f3f52cd44aa91a520aafb84ded3bc4b4a1e04130ccf87043149bbbf",name="blissful_wescoff",image="docker.io/library/ubuntu:latest",interface="eth0"} 962
# HELP container_network_transmit_errors_total Network transmitted errors
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

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: podman_metrics
      scrape_interval: 10
      scrape_on_start: true
      
  outputs:
    - name: prometheus_exporter
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  name podman_metrics
  scrape_interval 10
  scrape_on_start true
    
[OUTPUT]
  name prometheus_exporter
```

{% endtab %}
{% endtabs %}

### Command line

```shell
fluent-bit -i podman_metrics -o prometheus_exporter
```

### Exposed metrics

Currently supported counters are:

- `container_memory_usage_bytes`
- `container_memory_max_usage_bytes`
- `container_memory_rss`
- `container_spec_memory_limit_bytes`
- `container_cpu_user_seconds_total`
- `container_cpu_usage_seconds_total`
- `container_network_receive_bytes_total`
- `container_network_receive_errors_total`
- `container_network_transmit_bytes_total`
- `container_network_transmit_errors_total`

This plugin mimics the naming convention of Docker metrics exposed by [`cadvisor`](https://github.com/google/cadvisor).