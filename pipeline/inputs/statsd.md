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

## Configuration Examples <a id="config_example"></a>

Here is a configuration example.

```python
[INPUT]
    Name   statsd
    Listen 0.0.0.0
    Port   8125

[OUTPUT]
    Name   stdout
    Match  *
```

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

