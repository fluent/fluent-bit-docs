# Prometheus Scrape Metrics

Fluent Bit 1.9 includes additional metrics features to allow you to collect both logs and metrics with the same collector.&#x20;

The initial release of the Prometheus Scrape metric allows you to collect metrics from a Prometheus-based endpoint at a set interval. These metrics can be routed to metric supported endpoints such as [Prometheus Exporter](../outputs/prometheus-exporter.md), [InfluxDB](../outputs/influxdb.md), or [Prometheus Remote Write](../outputs/prometheus-remote-write.md)

## Configuration <a href="#configuration" id="configuration"></a>

| Key             | Description                                                                                                                                          | Default  |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| host            | The host of the prometheus metric endpoint that you want to scrape                                                                                   |          |
| port            | The port of the prometheus metric endpoint that you want to scrape                                                                                    |          |
| scrape\_interval | The interval to scrape metrics                                                                                                                       | 10s      |
| metrics\_path   | <p>The metrics URI endpoint, that must start with a forward slash.<br><br>Note: Parameters can also be added to the path by using <code>?</code></p> | /metrics |

## Example

If an endpoint exposes Prometheus Metrics we can specify the configuration to scrape and then output the metrics. In the following example, we retrieve metrics from the HashiCorp Vault application.

```
[INPUT]
    name prometheus_scrape
    host 0.0.0.0 
    port 8201
    tag vault 
    metrics_path /v1/sys/metrics?format=prometheus 
    scrape_interval 10s

[OUTPUT]
    name stdout
    match *

```

**Example Output**

```
2022-03-26T23:01:29.836663788Z go_memstats_alloc_bytes_total = 31891336
2022-03-26T23:01:29.836663788Z go_memstats_frees_total = 313264
2022-03-26T23:01:29.836663788Z go_memstats_lookups_total = 0
2022-03-26T23:01:29.836663788Z go_memstats_mallocs_total = 378992
2022-03-26T23:01:29.836663788Z process_cpu_seconds_total = 1.6200000000000001
2022-03-26T23:01:29.836663788Z go_goroutines = 19
2022-03-26T23:01:29.836663788Z go_info{version="go1.17.7"} = 1
2022-03-26T23:01:29.836663788Z go_memstats_alloc_bytes = 12547800
2022-03-26T23:01:29.836663788Z go_memstats_buck_hash_sys_bytes = 1468900
2022-03-26T23:01:29.836663788Z go_memstats_gc_cpu_fraction = 8.1509688352783453e-06
2022-03-26T23:01:29.836663788Z go_memstats_gc_sys_bytes = 5875576
2022-03-26T23:01:29.836663788Z go_memstats_heap_alloc_bytes = 12547800
2022-03-26T23:01:29.836663788Z go_memstats_heap_idle_bytes = 2220032
2022-03-26T23:01:29.836663788Z go_memstats_heap_inuse_bytes = 14000128
2022-03-26T23:01:29.836663788Z go_memstats_heap_objects = 65728
2022-03-26T23:01:29.836663788Z go_memstats_heap_released_bytes = 2187264
2022-03-26T23:01:29.836663788Z go_memstats_heap_sys_bytes = 16220160
2022-03-26T23:01:29.836663788Z go_memstats_last_gc_time_seconds = 1648335593.2483871
2022-03-26T23:01:29.836663788Z go_memstats_mcache_inuse_bytes = 2400
2022-03-26T23:01:29.836663788Z go_memstats_mcache_sys_bytes = 16384
2022-03-26T23:01:29.836663788Z go_memstats_mspan_inuse_bytes = 150280
2022-03-26T23:01:29.836663788Z go_memstats_mspan_sys_bytes = 163840
2022-03-26T23:01:29.836663788Z go_memstats_next_gc_bytes = 16586496
2022-03-26T23:01:29.836663788Z go_memstats_other_sys_bytes = 422572
2022-03-26T23:01:29.836663788Z go_memstats_stack_inuse_bytes = 557056
2022-03-26T23:01:29.836663788Z go_memstats_stack_sys_bytes = 557056
2022-03-26T23:01:29.836663788Z go_memstats_sys_bytes = 24724488
2022-03-26T23:01:29.836663788Z go_threads = 8
2022-03-26T23:01:29.836663788Z process_max_fds = 65536
2022-03-26T23:01:29.836663788Z process_open_fds = 12
2022-03-26T23:01:29.836663788Z process_resident_memory_bytes = 200638464
2022-03-26T23:01:29.836663788Z process_start_time_seconds = 1648333791.45
2022-03-26T23:01:29.836663788Z process_virtual_memory_bytes = 865849344
2022-03-26T23:01:29.836663788Z process_virtual_memory_max_bytes = 1.8446744073709552e+19
2022-03-26T23:01:29.836663788Z vault_runtime_alloc_bytes = 12482136
2022-03-26T23:01:29.836663788Z vault_runtime_free_count = 313256
2022-03-26T23:01:29.836663788Z vault_runtime_heap_objects = 65465
2022-03-26T23:01:29.836663788Z vault_runtime_malloc_count = 378721
2022-03-26T23:01:29.836663788Z vault_runtime_num_goroutines = 12
2022-03-26T23:01:29.836663788Z vault_runtime_sys_bytes = 24724488
2022-03-26T23:01:29.836663788Z vault_runtime_total_gc_pause_ns = 1917611
2022-03-26T23:01:29.836663788Z vault_runtime_total_gc_runs = 19
```



