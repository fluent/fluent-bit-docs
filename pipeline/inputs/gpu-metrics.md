# GPU metrics

The **gpu_metrics** input plugin collects graphics processing unit (GPU) performance metrics from graphics cards on Linux systems. It provides real-time monitoring of GPU utilization, memory usage (VRAM), clock frequencies, power consumption, temperature, and fan speeds.

The plugin reads metrics directly from the Linux sysfs filesystem (`/sys/class/drm/`) without requiring external tools or libraries. Currently, **only AMD GPUs are supported** through the amdgpu kernel driver. NVIDIA and Intel GPUs aren't supported at this time.

## Metrics collected

The plugin collects the following metrics for each detected GPU:

| Key                       | Description                                                                                                                              |
|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| `gpu_utilization_percent` | GPU core utilization as a percentage (0-100). Indicates how busy the GPU is processing workloads.                                        |
| `gpu_memory_used_bytes`   | Amount of video RAM (VRAM) currently in use, measured in bytes.                                                                          |
| `gpu_memory_total_bytes`  | Total video RAM (VRAM) capacity available on the GPU, measured in bytes.                                                                 |
| `gpu_clock_mhz`           | Current GPU clock frequency in MHz. This metric has multiple instances with different type labels (see [Clock metrics](#clock-metrics)). |
| `gpu_power_watts`         | Current power consumption in watts. Can be disabled with enable_power false.                                                             |
| `gpu_temperature_celsius` | GPU die temperature in degrees Celsius. Can be disabled with enable_temperature false.                                                   |
| `gpu_fan_speed_rpm`       | Fan rotation speed in revolutions per minute (RPM).                                                                                      |
| `gpu_fan_pwm_percent`     | Fan PWM duty cycle as a percentage (0-100). Indicates fan intensity.                                                                     |

### Clock metrics

The `gpu_clock_mhz` metric is reported separately for three clock domains:

| Type       | Description                          |
|------------|--------------------------------------|
| `graphics` | GPU core/shader clock frequency.     |
| `memory`   | VRAM clock frequency.                |
| `soc`      | System-on-chip clock frequency.      |

## Configuration parameters

The plugin supports the following configuration parameters:

| Key                  | Description                                                                                                             | Default   |
|----------------------|-------------------------------------------------------------------------------------------------------------------------|-----------|
| `scrape_interval`    | Interval in seconds between metric collection cycles.                                                                   | `5`       |
| `path_sysfs`         | Path to the sysfs root directory. Typically used for testing or non-standard systems.                                   | `/sys`    |
| `cards_include`      | Pattern specifying which GPU cards to monitor. Supports wildcards (*), ranges (0-3), and comma-separated lists (0,2,4). | `*`       |
| `cards_exclude`      | Pattern specifying which GPU cards to exclude from monitoring. Uses the same syntax as cards_include.                   | _none_    |
| `enable_power`       | Enable collection of power consumption metrics (`gpu_power_watts`).                                                     | `true`    |
| `enable_temperature` | Enable collection of temperature metrics (`gpu_temperature_celsius`).                                                   | `true`    |

## GPU detection

The GPU metrics plugin will automatically scan for supported **AMD GPUs** that are using the `amdgpu` kernel driver. GPUs using legacy drivers will be ignored.

To check if your AMD GPU will be detected run:

```bash
lspci | grep -i vga | grep -i amd
```

Example output:

```bash
03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M] (rev ce)
73:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Granite Ridge [Radeon Graphics] (rev c5)
```

### Multiple GPU systems

In systems with multiple GPUs, the GPU metrics plugin will detect all AMD cards by default. You can control which GPUs you want to monitor with the `cards_include` and `cards_exclude` parameters.

To list the GPUs running in your system run the following command:

```bash
ls /sys/class/drm/card*/device/vendor
```

Example output:

```bash
/sys/class/drm/card0/device/vendor
/sys/class/drm/card1/device/vendor
```

## Getting started

To get GPU metrics from your system, you can run the plugin from either the command line or through the configuration file:

### Command line

Run the following command from the command line:

```bash
fluent-bit -i gpu_metrics -o stdout
```

Example output:

```json
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
        scrape_interval: 2
        path_sysfs: /sys
        cards_include: "1"
        cards_exclude: "0"
        enable_power: true
        enable_temperature: true

   outputs:
      - name: stdout
        match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
   Name                gpu_metrics
   scrape_interval     2
   path_sysfs          /sys
   cards_include       1
   cards_exclude       0
   enable_power        true
   enable_temperature  true

[OUTPUT]
   Name   stdout
   Match  *
```

{% endtab %}
{% endtabs %}


