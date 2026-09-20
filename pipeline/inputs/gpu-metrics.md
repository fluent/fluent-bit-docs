# GPU metrics

{% hint style="info" %}
**Supported event types:** `metrics`
{% endhint %}

The `gpu_metrics` input plugin collects graphics processing unit (GPU) performance metrics from graphics cards on Linux systems. It provides real-time monitoring of GPU utilization, memory usage (VRAM), clock frequencies, power consumption, temperature, and fan speeds.

The plugin supports two GPU vendors:

- **AMD**: Metrics are read directly from the Linux `sysfs` filesystem (`/sys/class/drm/`) through the `amdgpu` kernel driver, without requiring external tools or libraries.
- **NVIDIA**: Metrics are collected through the NVIDIA Management Library (NVML) when the `libnvidia-ml` shared library from the NVIDIA driver is available. NVML collection is enabled by default and can be turned off with `enable_nvml`.

Intel GPUs aren't supported.

## Metrics collected

The plugin collects the following metrics for each detected GPU:

| Key                       | Description      |
|---------------------------|------------------|
| `gpu_utilization_percent` | GPU core utilization as a percentage (`0` to `100`). Indicates how busy the GPU is when processing workloads. |
| `gpu_memory_used_bytes`   | Amount of video RAM (VRAM) currently in use, measured in bytes.  |
| `gpu_memory_total_bytes`  | Total video RAM (VRAM) capacity available on the GPU, measured in bytes. |
| `gpu_clock_mhz`           | Current GPU clock frequency in MHz. This metric has multiple instances with different type labels (see [Clock metrics](#clock-metrics)). |
| `gpu_power_watts`         | Current power consumption in watts. Can be disabled with `enable_power` set to `false`.|
| `gpu_temperature_celsius` | GPU die temperature in degrees Celsius. Can be disabled with `enable_temperature` set to `false`. |
| `gpu_fan_speed_rpm`       | Fan rotation speed in Revolutions per Minute (RPM). |
| `gpu_fan_pwm_percent`     | Fan PWM duty cycle as a percentage (0-100). Indicates fan intensity.  |
| `gpu_process_memory_used_bytes` | Per-process GPU memory usage in bytes, labeled by process ID (`pid`). NVIDIA (NVML) only. |
| `gpu_mig_device_info`     | Multi-Instance GPU (`MIG`) device information, labeled with `parent_uuid`, `gpu_instance_id`, and `compute_instance_id`. NVIDIA (NVML) only. |

Every metric includes `card` and `vendor` labels. The `vendor` label is `amd` or `nvidia`, depending on which GPU reported the metric.

### Clock metrics

The `gpu_clock_mhz` metric is reported separately for three clock domains:

| Type       | Description                          |
|------------|--------------------------------------|
| `graphics` | GPU core/shader clock frequency.     |
| `memory`   | VRAM clock frequency.                |
| `soc`      | System-on-chip clock frequency.      |

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                  | Description              | Default   |
|----------------------|-------------------------------------------------------------------------------------------------------------------------|-----------|
| `cards_exclude`      | Pattern specifying which GPU cards to exclude from monitoring. Uses the same syntax as `cards_include`.                   | _none_    |
| `cards_include`      | Pattern specifying which GPU cards to monitor. Supports wildcards (*), ranges (0-3), and comma-separated lists (0,2,4). | `*`       |
| `enable_nvml`        | Enable NVIDIA GPU metrics collection through NVML (the NVIDIA Management Library). Requires the `libnvidia-ml` shared library from the NVIDIA driver to be present. | `true`    |
| `enable_power`       | Enable collection of power consumption metrics (`gpu_power_watts`).                                                     | `true`    |
| `enable_temperature` | Enable collection of temperature metrics (`gpu_temperature_celsius`).                                                   | `true`    |
| `path_sysfs`         | Path to the `sysfs` root directory. Typically used for testing or non-standard systems.                                   | `/sys`    |
| `scrape_interval`    | Interval in seconds between metric collection cycles.                                                                   | `5`       |

## GPU detection

### `AMD` GPUs

The GPU metrics plugin scans for any supported AMD GPU using the `amdgpu` kernel driver. Any GPU using legacy drivers is ignored.

To check if your AMD GPU will be detected run:

```shell
lspci | grep -i vga | grep -i amd
```

Example output:

```text
03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M] (rev ce)
73:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Granite Ridge [Radeon Graphics] (rev c5)
```

### NVIDIA GPUs

When `enable_nvml` is `true` (the default), the plugin detects NVIDIA GPUs through NVML, provided the `libnvidia-ml` shared library from the NVIDIA driver is installed. If the library isn't present, NVML collection is skipped and a message is logged.

To confirm your NVIDIA driver and GPUs are visible run:

```shell
nvidia-smi -L
```

Example output:

```text
GPU 0: NVIDIA A100-SXM4-40GB (UUID: GPU-1a2b3c4d-5e6f-7890-abcd-ef1234567890)
```

### Multiple GPU systems

In systems with multiple GPUs, the GPU metrics plugin detects all supported AMD and NVIDIA cards by default. You can control which GPUs you want to monitor with the `cards_include` and `cards_exclude` parameters. Because AMD and NVIDIA cards are enumerated differently, choose filter values based on the card's vendor.

For AMD cards, `cards_include`, `cards_exclude`, and the `card` metric label use the numeric `sysfs` card number (for example, `0` for `card0`). To list the AMD cards in your system run the following command:

```shell
ls /sys/class/drm/card*/device/vendor
```

Example output:

```text
/sys/class/drm/card0/device/vendor
/sys/class/drm/card1/device/vendor
```

For NVIDIA cards, `cards_include` and `cards_exclude` use the NVML device index, which is the `GPU <n>` number reported by `nvidia-smi -L`. To list the NVIDIA cards and their indexes run the following command:

```shell
nvidia-smi -L
```

Example output:

```text
GPU 0: NVIDIA A100-SXM4-40GB (UUID: GPU-1a2b3c4d-5e6f-7890-abcd-ef1234567890)
GPU 1: NVIDIA A100-SXM4-40GB (UUID: GPU-0f9e8d7c-6b5a-4321-fedc-ba0987654321)
```

For example, `cards_include: 0` selects `GPU 0`. On emitted metrics, the NVIDIA `card` label is the GPU UUID shown by `nvidia-smi -L`, falling back to the NVML index only when the UUID can't be read.

## Getting started

To get GPU metrics from your system, you can run the plugin from either the command line or through the configuration file:

### Command line

Run the following command from the command line:

```shell
fluent-bit -i gpu_metrics -o stdout
```

Example output:

```text
2025-10-25T20:36:55.236905093Z gpu_utilization_percent{card="1",vendor="amd"} = 2
2025-10-25T20:36:55.237853918Z gpu_utilization_percent{card="0",vendor="amd"} = 0
2025-10-25T20:36:55.236905093Z gpu_memory_used_bytes{card="1",vendor="amd"} = 1580118016
2025-10-25T20:36:55.237853918Z gpu_memory_used_bytes{card="0",vendor="amd"} = 26083328
2025-10-25T20:36:55.236905093Z gpu_memory_total_bytes{card="1",vendor="amd"} = 17163091968
2025-10-25T20:36:55.237853918Z gpu_memory_total_bytes{card="0",vendor="amd"} = 2147483648
2025-10-25T20:36:55.236905093Z gpu_clock_mhz{card="1",vendor="amd",type="graphics"} = 45
2025-10-25T20:36:55.236905093Z gpu_clock_mhz{card="1",vendor="amd",type="memory"} = 96
2025-10-25T20:36:55.236905093Z gpu_clock_mhz{card="1",vendor="amd",type="soc"} = 500
2025-10-25T20:36:55.237853918Z gpu_clock_mhz{card="0",vendor="amd",type="graphics"} = 600
2025-10-25T20:36:55.237853918Z gpu_clock_mhz{card="0",vendor="amd",type="memory"} = 2800
2025-10-25T20:36:55.237853918Z gpu_clock_mhz{card="0",vendor="amd",type="soc"} = 1200
2025-10-25T20:36:55.236905093Z gpu_power_watts{card="1",vendor="amd"} = 28
2025-10-25T20:36:55.236905093Z gpu_temperature_celsius{card="1",vendor="amd"} = 28
2025-10-25T20:36:55.237853918Z gpu_temperature_celsius{card="0",vendor="amd"} = 39
2025-10-25T20:36:55.236905093Z gpu_fan_speed_rpm{card="1",vendor="amd"} = 0
2025-10-25T20:36:55.236905093Z gpu_fan_pwm_percent{card="1",vendor="amd"} = 0
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: gpu_metrics
      cards_exclude: "0"
      cards_include: "1"
      enable_nvml: true
      enable_power: true
      enable_temperature: true
      path_sysfs: /sys
      scrape_interval: 2

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name                gpu_metrics
  Cards_Exclude       0
  Cards_Include       1
  Enable_Nvml         true
  Enable_Power        true
  Enable_Temperature  true
  Path_Sysfs          /sys
  Scrape_Interval     2

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}
