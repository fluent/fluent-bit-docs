# Scheduling and retries

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=a70a6008-106f-43c8-8930-243806371482" />

[Fluent Bit](https://fluentbit.io) has an engine that helps to coordinate the data ingestion from input plugins. The engine calls the _scheduler_ to decide when it's time to flush the data through one or multiple output plugins. The scheduler flushes new data at a fixed number of seconds, and retries when asked.

When an output plugin gets called to flush some data, after processing that data it can notify the engine using these possible return statuses:

- `OK`: Data successfully processed and flushed.
- `Retry`: If a retry is requested, the engine asks the scheduler to retry flushing that data. The scheduler decides how many seconds to wait before retry.
- `Error`: An unrecoverable error occurred and the engine shouldn't try to flush that data again.
- `Throttle`: In v5.2 or later, the destination asked Fluent Bit to slow down. If [throttling](#throttling) is enabled for the output, the engine pauses that output for a cooldown period. Otherwise, the engine handles it like `Retry`.

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

{% hint style="info" %}
When a chunk exhausts all retry attempts or retries are disabled, the data is discarded by default. To preserve rejected data for later analysis, enable the [Dead Letter Queue (DLQ)](./dead-letter-queue.md) feature by setting `storage.keep.rejected` to `on` in the Service section.
{% endhint %}

In v5.1.3 or later, if too many flush requests are already in flight when a retry is due, Fluent Bit reschedules the retry without counting it against `Retry_Limit`.

### Retry example

The following example configures two outputs, where the HTTP plugin has an unlimited number of retries, and the Elasticsearch plugin have a limit of `5` retries:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

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

## Throttling

In v5.2 or later, some outputs recognize when a destination asks Fluent Bit to slow down, for example with an HTTP `429 Too Many Requests` response. You can configure each output instance to respond to these signals with a cooldown that pauses its deliveries. Throttling is off by default.

Set the following keys in each output section:

| Key | Description | Default |
| --- | ----------- | ------- |
| `throttle` | Enable a destination-driven cooldown for this output instance. | `false` |
| `throttle.base` | Set the minimum cooldown in seconds. The value must be a positive whole number without a unit suffix, such as `5`, not `5s`. | `1` |
| `throttle.cap` | Set the maximum cooldown in seconds that Fluent Bit calculates on its own. The value must be a positive whole number without a unit suffix, and greater than or equal to `throttle.base`. A delay requested by the destination can be longer. | `60` |

Fluent Bit fails to start if `throttle.base` or `throttle.cap` isn't a positive whole number, or if `throttle.cap` is less than `throttle.base`. This check applies even when `throttle` is off, so if you set `throttle.base` greater than `60`, also raise `throttle.cap`.

The following outputs report throttle signals. Other outputs don't, so these keys have no effect on them.

| Output | Throttle signals |
| --- | --- |
| [HTTP](../pipeline/outputs/http.md) | HTTP `429`, or HTTP `503` with a valid `Retry-After` value. |
| [Elasticsearch](../pipeline/outputs/elasticsearch.md) and [OpenSearch](../pipeline/outputs/opensearch.md) | HTTP `429` for the whole request, or a `429` status for any document in a `_bulk` response. For OpenSearch, per-document statuses are checked for log records only. |
| [OpenTelemetry](../pipeline/outputs/opentelemetry.md) | OTLP/HTTP `429`, or `503` with a valid `Retry-After` value. OTLP/gRPC `UNAVAILABLE` or `RESOURCE_EXHAUSTED` with a valid `google.rpc.RetryInfo` delay. |

When `throttle` is off, Fluent Bit handles these signals like any other retry: the scheduler waits as described in [Configure wait time for retry](#configure-wait-time-for-retry), and any delay requested by the destination is ignored.

### How the cooldown works

When `throttle` is on and an output reports a throttle signal, Fluent Bit does the following:

- It pauses the whole output instance for the cooldown period. Fluent Bit doesn't start new flushes to that output, including retries of other chunks, until the cooldown ends. Flushes that are already in progress continue, and other outputs aren't affected.
- It holds the throttled chunk and sends it again after the cooldown. Waiting for a cooldown doesn't count against `Retry_Limit`, and isn't counted in the retry metrics. With filesystem buffering, Fluent Bit can discard a held chunk if the output reaches `storage.total_limit_size` during the cooldown. See [Per-output settings](../pipeline/buffering.md#per-output-settings).
- It logs a warning similar to `[engine] throttled flush for chunk '...', resume in N seconds`.

Fluent Bit calculates the cooldown with exponential backoff and jitter. The limit starts at `throttle.base` and doubles with each consecutive cooldown, up to `throttle.cap`. The cooldown is a random value between half of the limit and the limit, and is never shorter than `throttle.base`. After a successful flush, the limit starts again from `throttle.base`.

If the destination requests a delay that's longer than the calculated cooldown, Fluent Bit waits for the requested delay instead. Fluent Bit reads the delay from an HTTP `Retry-After` header or trailer, as a number of seconds or an HTTP date, or from a gRPC `google.rpc.RetryInfo` message. Fluent Bit ignores malformed values. When a response has several valid `Retry-After` values, the HTTP, Elasticsearch, and OpenSearch outputs use the largest, and log ignored malformed values at the `debug` level.

{% hint style="warning" %}
Fluent Bit honors the delay requested by the destination in full. `throttle.cap` doesn't limit it, and there's no other upper bound, so a very large `Retry-After` value can pause the output indefinitely. Enable `throttle` only for destinations that you trust to request reasonable delays.
{% endhint %}

With `Retry_Limit` set to `no_retries`, Fluent Bit doesn't hold a throttled chunk. It discards the chunk, or moves it to the [Dead Letter Queue](./dead-letter-queue.md) if that's enabled. The output still pauses for the cooldown.

The [monitoring metrics](./monitoring.md#v2-metrics) `fluentbit_output_throttle_active`, `fluentbit_output_throttle_remaining_seconds`, `fluentbit_output_throttle_events_total`, `fluentbit_output_throttle_deferred_routes`, and `fluentbit_output_throttle_duration_seconds_total` report the cooldown state of each output.

### Throttling example

The following example enables throttling for an HTTP output. Fluent Bit calculates a cooldown between `2` and `120` seconds, but a delay requested by the destination can be longer than `120` seconds:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: http
      match: '*'
      host: 192.168.5.6
      port: 8080
      throttle: on
      throttle.base: 2
      throttle.cap: 120
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name          http
  Match         *
  Host          192.168.5.6
  Port          8080
  Throttle      On
  Throttle.Base 2
  Throttle.Cap  120
```

{% endtab %}
{% endtabs %}
