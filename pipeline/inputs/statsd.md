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
Including key-value format of tags:
`<METRIC_NAME>:<VALUE>|<TYPE>|@<SAMPLE_RATE>|#<TAG_KEY_1>:<TAG_VALUE_1>`
Events and ServiceChecks format are not supported yet with `Metrics On`.

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
