# Docker metrics

The _Docker_ input plugin lets you collect Docker container metrics, including memory usage and CPU consumption.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key               | Description                                                                                             | Default                      |
|:------------------|:--------------------------------------------------------------------------------------------------------|:-----------------------------|
| `exclude`         | A space-separated list of containers to exclude.                                                        | _none_                       |
| `include`         | A space-separated list of containers to include.                                                        | _none_                       |
| `interval_nsec`   | Polling interval in nanoseconds.                                                                        | `0`                          |
| `interval_sec`    | Polling interval in seconds.                                                                            | `1`                          |
| `path.containers` | Container directory path, for custom Docker `data-root` configurations.                                 | `/var/lib/docker/containers` |
| `path.sysfs`      | Sysfs cgroup mount point.                                                                               | `/sys/fs/cgroup`             |
| `threaded`        | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false`                      |

If you set neither `include` nor `exclude`, the plugin will try to get metrics from all running containers.

## Configuration file

The following example configuration collects metrics from two docker instances (`6bab19c3a0f9` and `14159be4ca2c`).

{% tabs %}
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
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name         docker
  Include      6bab19c3a0f9 14159be4ca2c

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

This configuration will produce records like the following:

```text
[1] docker.0: [1571994772.00555745, {"id"=>"6bab19c3a0f9", "name"=>"postgresql", "cpu_used"=>172102435, "mem_used"=>5693400, "mem_limit"=>4294963200}]
```
