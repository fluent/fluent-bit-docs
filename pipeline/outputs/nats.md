# NATS

The _NATS_ output plugin lets you flush your records into a [NATS Server](https://docs.nats.io/) server endpoint.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `host` | The IP address or hostname of the NATS server. | `127.0.0.1` |
| `port` | The TCP port of the target NATS server. | `4222` |
| `workers` | The number of [workers](../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

{% hint style="info" %}

To override the default configuration values, this plugin uses the optional Fluent Bit network address format (for example, `nats://host:port`).

{% endhint %}

## Get started

You can get started with the NATS output plugin through the command line. If you use the following command without specifying parameter values, Fluent Bit uses the default values defined in the previous section.

```shell
$ fluent-bit -i cpu -o nats -V -f 5

...
[2016/03/04 10:17:33] [ info] Configuration
flush time     : 5 seconds
input plugins  : cpu
collectors     :
[2016/03/04 10:17:33] [ info] starting engine
cpu[all] all=3.250000 user=2.500000 system=0.750000
cpu[i=0] all=3.000000 user=1.000000 system=2.000000
cpu[i=1] all=3.000000 user=2.000000 system=1.000000
cpu[i=2] all=2.000000 user=2.000000 system=0.000000
cpu[i=3] all=6.000000 user=5.000000 system=1.000000
[2016/03/04 10:17:33] [debug] [in_cpu] CPU 3.25%
...
```

## Data format

For every set of records flushed to a NATS server, Fluent Bit uses the following format:

```text
[
  [UNIX_TIMESTAMP, JSON_MAP_1],
  [UNIX_TIMESTAMP, JSON_MAP_2],
  [UNIX_TIMESTAMP, JSON_MAP_N],
]
```

Each record is an individual entity represented in a JSON array that contains a Unix timestamp and a JSON map with a set of key/value pairs. A summarized output of the CPU input plugin will resemble the following:

```json
[
  [1457108504,{"tag":"fluentbit","cpu_p":1.500000,"user_p":1,"system_p":0.500000}],
  [1457108505,{"tag":"fluentbit","cpu_p":4.500000,"user_p":3,"system_p":1.500000}],
  [1457108506,{"tag":"fluentbit","cpu_p":6.500000,"user_p":4.500000,"system_p":2}]
]
```
