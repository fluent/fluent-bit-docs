---
description: >-
  The docker input plugin allows you to collect Docker container metrics such as
  memory usage and CPU consumption.
---

# Docker Metrics

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key          | Description                                     | Default |
| ------------ | ----------------------------------------------- | ------- |
| Interval_Sec | Polling interval in seconds                     | 1       |
| Include      | A space-separated list of containers to include |         |
| Exclude      | A space-separated list of containers to exclude |         |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |
| path.containers | Used to specify the container directory if Docker is configured with a custom "data-root" directory. | `/var/lib/docker/containers` |

If you set neither `Include` nor `Exclude`, the plugin will try to get metrics from _all_ the running containers.

## Configuration File

Here is an example configuration that collects metrics from two docker instances (`6bab19c3a0f9` and `14159be4ca2c`).

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name         docker
    Include      6bab19c3a0f9 14159be4ca2c
[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: docker
          include: 6bab19c3a0f9 14159be4ca2c

    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

This configuration will produce records like below.

```
[1] docker.0: [1571994772.00555745, {"id"=>"6bab19c3a0f9", "name"=>"postgresql", "cpu_used"=>172102435, "mem_used"=>5693400, "mem_limit"=>4294963200}]
```
