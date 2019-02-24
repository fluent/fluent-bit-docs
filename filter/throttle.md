# Throttle

The _Throttle Filter_ plugin sets the average _Rate_ of messages per _Interval_, based on leaky bucket and sliding window algorithm. In case of overflood, it will leak within certain rate.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Description |
| :--- | :--- | :--- |
| Rate | Integer | Amount of messages for the time. |
| Window | Integer | Amount of intervals to calculate average over. Default 5. |
| Interval | String | Time interval, expressed in "sleep" format. e.g 3s, 1.5m, 0.5h etc |
| Print\_Status | Bool | Whether to print status messages with current rate and the limits to information logs |

## Functional description

Lets imagine we have configured:

```text
Rate 5
Window 5
Interval 1s
```

we received 1 message first second, 3 messages 2nd, and 5 3rd. As you can see, disregard that Window is actually 5, we use "slow" start to prevent overflooding during the startup.

```text
+-------+-+-+-+ 
|1|3|5| | | | | 
+-------+-+-+-+ 
|  3  |         average = 3, and not 1.8 if you calculate 0 for last 2 panes. 
+-----+
```

But as soon as we reached Window size \* Interval, we will have true sliding window with aggregation over complete window.

```text
+-------------+ 
|1|3|5|7|3|4| | 
+-------------+ 
  |  4.4    |   
  ----------+
```

When we have average over window is more than Rate, we will start dropping messages, so that

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

As you can see, last pane of the window was overwritten and 1 message was dropped.

### Interval vs Window size

You might noticed possibility to configure _Interval_ of the _Window_ shift. It is counter intuitive, but there is a difference between two examples above:

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

Even though both examples will allow maximum Rate of 60 messages per minute, first example may get all 60 messages within first second, and will drop all the rest for the entire minute:

```text
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
XX        XX        XX
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

While the second example will not allow more than 1 message per second every second, making output rate more smooth:

```text
  X    X     X    X    X    X
XXXX XXXX  XXXX XXXX XXXX XXXX
+-+-+-+-+-+--+-+-+-+-+-+-+-+-+-+
```

It may drop some data if the rate is ragged. I would recommend to use bigger interval and rate for streams of rare but important events, while keep _Window_ bigger and _Interval_ small for constantly intensive inputs.

### Command Line

> Note: It's suggested to use a configuration file.

The following command will load the _tail_ plugin and read the content of _lines.txt_ file. Then the _throttle_ filter will apply a rate limit and only _pass_ the records which are read below the certain _rate_:

```text
$ bin/fluent-bit -i tail -p 'path=lines.txt' -F throttle -p 'rate=1' -m '*' -o stdout
```

### Configuration File

```python
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

The example above will pass 1000 messages per second in average over 300 seconds.

