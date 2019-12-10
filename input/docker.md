# Docker

The **docker** input plugin allows you to collect Docker container metrics
like memory usage and CPU consumption.

Content:

* [Configuration Parameters](docker.md#config)
* [Configuration Parameters](docker.md#config_example)

## Configuration Parameters {#config}

The plugin supports the following configuration parameters:

| Key           | Description                                     | Default  |
| :------------ | :---------------------------------------------- | :--------|
| Interval\_Sec | Polling interval in seconds                     | 1        |
| Include       | A space-separated list of containers to include |          |
| Exclude       | A space-separated list of containers to exclude |          |

If you set neither `Include` nor `Exclude`, the plugin will try to get
metrics from _all_ the running containers.

## Configuration Examples {#config_example}

Here is an example configuration that collects metrics from two docker
instances (`6bab19c3a0f9` and `14159be4ca2c`).

```python
[INPUT]
    Name         docker
    Include      6bab19c3a0f9 14159be4ca2c

[OUTPUT]
    Name   stdout
    Match  *
```

This configuration will produce records like below.

```
[1] docker.0: [1571994772.00555745, {"id"=>"6bab19c3a0f9", "name"=>"postgresql", "cpu_used"=>172102435, "mem_used"=>5693400, "mem_limit"=>4294963200}]
```
