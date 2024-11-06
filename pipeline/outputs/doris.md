---
description: Send logs to Apache Doris
---

# Apache Doris

The **doris** output plugin lets you ingest your records into an
[Apache Doris](https://doris.apache.org) database. To use this plugin, you must have an
operational Doris service running in your environment.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `host` | HTTP address of the target Doris frontend (fe) or frontend (be). | `127.0.0.1` |
| `port` | HTTP port of the target Doris frontend (fe) or frontend (be). | `8030` |
| `user` | Username for Doris access. | _none_ |
| `password` | Password for Doris access. | _none_ |
| `database` | The target Doris database. | _none_ |
| `table` | The target Doris table. | _none_ |
| `label_prefix` | Label prefix of Doris stream load, the final generated Label is {label_prefix}\_{timestamp}\_{uuid}. | `fluentbit` |
| `time_key` | The name of the time key in the output record. | `date` |
| `header` | Headers of Doris stream load. Multiple headers can be set. See [Doris stream load](https://doris.apache.org/docs/data-operate/import/import-way/stream-load-manual) for details. | _none_ |
| `log_request` | Whether to output Doris Stream Load request and response metadata in logs for troubleshooting. | `true` |
| `log_progress_interval` | The time interval in seconds to calculate and output the speed in the log. Set to 0 to disable this type of logging. | `10` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `2` |

### TLS / SSL

The Doris output plugin supports TLS/SSL. See [TLS/SSL](../../administration/transport-security.md)
for more details about the supported properties and general configuration.

## Get started

To insert records into a Doris database, run the plugin from the command line or define a configuration file:

### Command Line

The Doris plugin can read the parameters from the command through the `-p` argument,

as shown in the following example:

```shell copy
fluent-bit -i cpu -t cpu -o doris \
    -m '*' \
    -p host=127.0.0.1 \
    -p port=8030 \
    -p user=admin \
    -p password=admin \
    -p database=d_fb \
    -p table=t_fb \
    -p header='columns date, cpu_p, log=cast(cpu_p as string)'
```

### Configuration File

In your main configuration file, append the following `Input` and `Output` sections.

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python copy
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    name  doris
    match *
    host  127.0.0.1
    port  8030
    user admin
    password admin
    database d_fb
    table t_fb
    header columns date, cpu_p, log=cast(cpu_p as string)
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml copy
pipeline:
    inputs:
        - name: cpu
          tag: cpu
    outputs:
        - name: doris
          match: '*'
          host: 127.0.0.1
          port: 8030
          user: admin
          password: admin
          database: d_fb
          table: t_fb
          header: 
            - columns date, cpu_p, log=cast(cpu_p as string)
```
{% endtab %}
{% endtabs %}
