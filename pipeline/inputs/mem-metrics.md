# Memory metrics 

The _mem_metrics_, or memory metrics plugin, generates metrics for memory statistics for processes using the `smaps_rollup` file for each process in /proc. This plugin works exclusively on Linux.

# Configuration Parameters

| **Key***      | Description                                        | Default      |
| :------------ | :------------------------------------------------- | :----------- |
| proc_path     | The path of the proc pseudo filesystem             | /proc        |
| filter_exec   | Filter for a single executable by path             | **inactive** |
| filter_cmd    | Filter by command line                             | **inactive** |
| filter_pid    | Filter by comma delimited list of PIDs             | **inactive** |
| interval_sec  | Set the interval seconds between events generation | 5            |
| interval_nsec | Set the nanoseconds interval (sub seconds)         | 0            |

The `filter_pid` can include or be set to either `0` or `self` to refer to the fluent-bit process itself.

## Getting Started

You can run the plugin from the command line or through a configuration file. By default metrics will be generated for all processes the current user can analyze.

### Command Line

```bash
$ fluent-bit -i mem_metrics -o stdout
Fluent Bit v2.1.8
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

2023-07-26T14:37:49.919778443Z node_smaps_rollup_rss{pid="4540"} = 21064
2023-07-26T14:37:49.919778443Z node_smaps_rollup_pss{pid="4540",type="clean"} = 9598
2023-07-26T14:37:49.919778443Z node_smaps_rollup_pss{pid="4540",type="dirty"} = 5998
2023-07-26T14:37:49.919778443Z node_smaps_rollup_pss{pid="4540",type="anon"} = 5996
2023-07-26T14:37:49.919778443Z node_smaps_rollup_pss{pid="4540",type="file"} = 3602
2023-07-26T14:37:49.919778443Z node_smaps_rollup_pss{pid="4540",type="shmem"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_shared{pid="4540",type="clean"} = 15008
2023-07-26T14:37:49.919778443Z node_smaps_rollup_shared{pid="4540",type="dirty"} = 4
2023-07-26T14:37:49.919778443Z node_smaps_rollup_private{pid="4540",type="clean"} = 56
2023-07-26T14:37:49.919778443Z node_smaps_rollup_private{pid="4540",type="dirty"} = 5996
2023-07-26T14:37:49.919778443Z node_smaps_rollup_referenced{pid="4540"} = 21064
2023-07-26T14:37:49.919778443Z node_smaps_rollup_anonymous{pid="4540"} = 5996
2023-07-26T14:37:49.919778443Z node_smaps_rollup_lazy_free{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_anon_huge_pages{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_shmem_pmd_mapped{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_file_pmd_mapped{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_shared_hugetlb{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_private_hugetlb{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_swap{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_swap_pss{pid="4540"} = 0
2023-07-26T14:37:49.919778443Z node_smaps_rollup_locked{pid="4540"} = 0
```

### Configuration File

Minimal pipeline for logging memory metrics to the console:

```ini
[INPUT]
    Name mem_metrics
    Tag  mem

[OUTPUT]
    Name  stdout
    Match mem
```

Log all instances of fluent-bit to prometheus:

```ini
[INPUT]
    Name       mem_metrics
    Filter_cmd fluent-bit
    Tag        mem

[OUTPUT]
    Name                 prometheus_remote_write
    Match                mem
    Host                 localhost
    Port                 9090
    Uri                  /prometheus/v1/write?prometheus_server=mem
```

### Exposed Metrics

All metrics are logged as gauges since they can both increase and decrease. Currenrtly supported gauges are:
  * node_smaps_rollup_rss
  * node_smaps_rollup_pss
    * type=clean
    * type=dirty
    * type=anon
    * type=file
    * type=shmem
  *  node_smaps_rollup_shared
    * type=clean
    * type=dirty
  *  node_smaps_rollup_private
    * type=dirty
    * type=clean
  * node_smaps_rollup_referenced
  * node_smaps_rollup_anonymous
  * node_smaps_rollup_lazy_free
  * node_smaps_rollup_anon_huge_pages
  * node_smaps_rollup_shmem_pmd_mapped
  * node_smaps_rollup_file_pmd_mapped
  * node_smaps_rollup_shared_hugetlb
  * node_smaps_rollup_private_hugetlb
  * node_smaps_rollup_swap
  * node_smaps_rollup_swap_pss
  * node_smaps_rollup_locked
