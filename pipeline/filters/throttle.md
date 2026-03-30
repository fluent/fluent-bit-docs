# Throttle

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _Throttle_ filter sets the average `rate` of messages per `interval`, based on the leaky bucket and sliding window algorithm. In case of flooding, it will leak at a certain rate.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Description |
| :--- | :--- | :--- |
| `interval` | `String` | Time interval, expressed in `sleep` format. For example, `3s`, `1.5m`, `0.5h`. |
| `print_status` | `Bool` | Whether to print status messages with current rate and the limits to information logs. |
| `rate` | `Integer` | Amount of messages for the time. |
| `window` | `Integer` | Amount of intervals to calculate average over. Default: `5`. |

## Functional description

Using the following configuration:

```text
Rate 5
Window 5
Interval 1s
```

You would receive 1 message in the first second, 3 messages second, and 5 third. Disregard that Window is actually 5, because the configuration uses `slow` start to prevent flooding during the startup.

```text
+-------+-+-+-+
|1|3|5| | | | |
+-------+-+-+-+
|  3  |         average = 3, and not 1.8 if you calculate 0 for last 2 panes.
+-----+
```

But as soon as you reach `Window size * Interval`, you will have true sliding window with aggregation over complete window.

```text
+-------------+
|1|3|5|7|3|4| |
+-------------+
  |  4.4    |
  ----------+
```

When the average over window is more than `Rate`, Fluent Bit starts dropping messages, so the following:

```text
+-------------+
|1|3|5|7|3|4|7|
+-------------+
    |   5.2   |
    +---------+
```

will become:

```text
+-------------+
|1|3|5|7|3|4|6|
+-------------+
    |   5     |
    +---------+
```

The last pane of the window was overwritten and 1 message was dropped.

### `interval` versus `window` size

You might notice it's possible to configure the `interval` of the `window` shift. It's counterintuitive, but there is a difference between the two previous examples:

```text
Rate 60
Window 5
Interval 1m
```

and

```text
Rate 1
Window 300
Interval 1s
```

Even though both examples will allow maximum `rate` of 60 messages per minute, the first example might get all 60 messages within first second, and will drop all the rest for the entire minute:

```text
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

While the second example won't allow more than 1 message per second every second, making output rate more smooth:

```text
  X    X     X    X    X    X
XXXX XXXX  XXXX XXXX XXXX XXXX
+-+-+-+-+-+--+-+-+-+-+-+-+-+-+-+
```

Fluent Bit might drop some data if the rate is ragged. Use bigger intervals and rates for streams of rare but important events, while keeping `window` bigger and `interval` smaller for constantly intensive inputs.

### Command line

It's suggested to use a configuration file.

The following command will load the Tail plugin and read the content of the `lines.txt` file. Then, the Throttle filter will apply a rate limit and only pass the records which are within the `rate`:

```shell
fluent-bit -i tail -p 'path=lines.txt' -F throttle -p 'rate=1' -m '*' -o stdout
```

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      path: lines.txt

  filters:
    - name: throttle
      match: '*'
      rate: 1000
      window: 300
      interval: 1s

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   tail
  Path   lines.txt

[FILTER]
  Name     throttle
  Match    *
  Rate     1000
  Window   300
  Interval 1s

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}

This example will pass 1000 messages per second in average over 300 seconds.
