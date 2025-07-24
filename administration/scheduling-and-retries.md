# Scheduling and retries

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=a70a6008-106f-43c8-8930-243806371482" />

[Fluent Bit](https://fluentbit.io) has an engine that helps to coordinate the data ingestion from input plugins. The engine calls the _scheduler_ to decide when it's time to flush the data through one or multiple output plugins. The scheduler flushes new data at a fixed number of seconds, and retries when asked.

When an output plugin gets called to flush some data, after processing that data it can notify the engine using these possible return statuses:

- `OK`: Data successfully processed and flushed.
- `Retry`: If a retry is requested, the engine asks the scheduler to retry flushing that data. The scheduler decides how many seconds to wait before retry.
- `Error`: An unrecoverable error occurred and the engine shouldn't try to flush that data again.

## Configure wait time for retry

The scheduler provides two configuration options, called `scheduler.cap` and `scheduler.base`, which can be set in the Service section. These determine the waiting time before a retry happens.

| Key | Description | Default |
| --- | ------------| --------------|
| `scheduler.cap` | Set a maximum retry time in seconds. Supported in v1.8.7 or later. | `2000` |
| `scheduler.base` | Set a base of exponential backoff. Supported in v1.8.7 or later. | `5` |

The `scheduler.base` determines the lower bound of time and the `scheduler.cap` determines the upper bound for each retry.

Fluent Bit uses an exponential backoff and jitter algorithm to determine the waiting time before a retry. The waiting time is a random number between a configurable upper and lower bound. For a detailed explanation of the exponential backoff and jitter algorithm, see [Exponential Backoff And Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).

For example:

For the Nth retry, the lower bound of the random number will be:

`base`

The upper bound will be:

`min(base * (Nth power of 2), cap)`

For example:

When `base` is set to 3 and `cap` is set to 30:

First retry: The lower bound will be 3. The upper bound will be `3 * 2 = 6`. The waiting time will be a random number between (3, 6).

Second retry: The lower bound will be 3. The upper bound will be `3 * (2 * 2) = 12`. The waiting time will be a random number between (3, 12).

Third retry: The lower bound will be 3. The upper bound will be `3 * (2 * 2 * 2) =24`. The waiting time will be a random number between (3, 24).

Fourth retry: The lower bound will be 3, because `3 * (2 * 2 * 2 * 2) = 48` > `30`. The upper bound will be 30. The waiting time will be a random number between (3, 30).

### Wait time example

The following example configures the `scheduler.base` as `3` seconds and `scheduler.cap` as `30` seconds.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 5
    daemon: off
    log_level: debug
    scheduler.base: 3
    scheduler.cap: 30
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Flush            5
    Daemon           off
    Log_Level        debug
    scheduler.base   3
    scheduler.cap    30
```

{% endtab %}
{% endtabs %}

The waiting time will be:

| Nth retry | Waiting time range (seconds) |
| --- | --- |
| 1 | (3, 6)  |
| 2 | (3, 12) |
| 3 | (3, 24) |
| 4 | (3, 30) |

## Configure retries

The scheduler provides a configuration option called `Retry_Limit`, which can be set independently for each output section. This option lets you disable retries or impose a limit to try N times and then discard the data after reaching that limit:

|  | Value | Description |
| :--- | :--- | :--- |
| `Retry_Limit` | N | Integer value to set the maximum number of retries allowed. N must be &gt;= 1 (default: `1`) |
| `Retry_Limit` | `no_limits` or `False` | When set there no limit for the number of retries that the scheduler can do. |
| `Retry_Limit` | `no_retries` | When set, retries are disabled and scheduler doesn't try to send data to the destination if it failed the first time. |

### Retry example

The following example configures two outputs, where the HTTP plugin has an unlimited number of retries, and the Elasticsearch plugin have a limit of `5` retries:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        ...

    outputs:
        - name: http
          host: 192.168.5.6
          port: 8080
          retry_limit: false

        - name: es
          host: 192.168.5.20
          port: 9200
          logstash_format: on
          retry_limit: 5
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
    Name        http
    Host        192.168.5.6
    Port        8080
    Retry_Limit False

[OUTPUT]
    Name            es
    Host            192.168.5.20
    Port            9200
    Logstash_Format On
    Retry_Limit     5
```

{% endtab %}
{% endtabs %}
