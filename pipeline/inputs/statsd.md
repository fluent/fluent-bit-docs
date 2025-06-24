# StatsD

The **statsd** input plugin allows you to receive metrics via StatsD protocol.

Content:

* [Configuration Parameters](statsd.md#config)
* [Configuration Examples](statsd.md#config_example)

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Listen | Listener network interface. | 0.0.0.0 |
| Port | UDP port where listening for connections | 8125 |
| Threaded | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |
| Metrics | Ingested record will be marked as a metric record rather than a log record. | `off` |

Note: When enabling `Metrics On`, we will also handle metrics from the DogStatsD protocol and the internal record in Fluent Bit will be handled as a metric type for downstream processing.
[The full format of DogStatsD of metrics](https://docs.datadoghq.com/developers/dogstatsd/datagram_shell/?tab=metrics#the-dogstatsd-protocol) is not supported.
Including key-value format of tags as below is supported:
`<METRIC_NAME>:<VALUE>|<TYPE>|@<SAMPLE_RATE>|#<TAG_KEY_1>:<TAG_VALUE_1>`
[Events](https://docs.datadoghq.com/developers/dogstatsd/datagram_shell/?tab=events#the-dogstatsd-protocol) and [ServiceChecks](https://docs.datadoghq.com/developers/dogstatsd/datagram_shell/?tab=servicechecks#the-dogstatsd-protocol) formats are not supported yet with `Metrics On`.

## Configuration Examples <a id="config_example"></a>

Here is a configuration example.

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name   statsd
    Listen 0.0.0.0
    Port   8125

[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: statsd
          listen: 0.0.0.0
          port: 8125
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

Now you can input metrics through the UDP port as follows:

```bash
echo "click:10|c|@0.1" | nc -q0 -u 127.0.0.1 8125
echo "active:99|g"     | nc -q0 -u 127.0.0.1 8125
```

Fluent Bit will produce the following records:

```text
[0] statsd.0: [1574905088.971380537, {"type"=>"counter", "bucket"=>"click", "value"=>10.000000, "sample_rate"=>0.100000}]
[0] statsd.0: [1574905141.863344517, {"type"=>"gauge", "bucket"=>"active", "value"=>99.000000, "incremental"=>0}]
```

## Metrics Setup

Here is a configuration example for metrics setup.

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name   statsd
    Listen 0.0.0.0
    Port   8125
    Metrics On

[OUTPUT]
    Name   stdout
    Match  *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: statsd
          listen: 0.0.0.0
          port: 8125
          metrics: On
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

Now you can input metrics as metrics type of events through the UDP port as follows:

```bash
echo "click:+10|c|@0.01|#hello:tag"              | nc -q0 -u 127.0.0.1 8125
echo "active:+99|g|@0.01"                        | nc -q0 -u 127.0.0.1 8125
echo "inactive:29|g|@0.0125|#hi:from_fluent-bit" | nc -q0 -u 127.0.0.1 8125
```

Fluent Bit will procude the following metrics events:

```
2025-01-09T11:40:26.562424694Z click{incremental="true",hello="tag"} = 1000
2025-01-09T11:40:28.591477424Z active{incremental="true"} = 9900
2025-01-09T11:40:31.593118033Z inactive{hi="from_fluent-bit"} = 2320
```
