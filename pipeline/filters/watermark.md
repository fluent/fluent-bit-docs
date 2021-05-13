# Watermark

The _Watermark Filter_ plugin handles unbounded, unordered datastream. The idea of this plugin comes from the paper [The Dataflow Model: A Practical Approach to Balancing Correctness, Latency, and Cost in Massive-Scale, Unbounded, Out-of-Order Data Processing](https://research.google/pubs/pub43864/).

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Description |
| :--- | :--- | :--- |
| watermark | Integer | Fixed watermark value. Default 3. (Will improve its generation algorithm in the future.)|
| window\_size | Integer | The size of batch window in which record would be flushed out in a whole. Default 10. |
| time\_filed | String | The key by which event timestamp is specified. |

## Functional description

Lets imagine we have configured:

```text
watermark 10
window_size 10
time_field eventtime
```

we trigger the filter like this

```text
bin/fluent-bit -i tcp -F watermark -p 'time_field=eventtime' -p 'watermark=10' -m '*' -o stdout
```

we received a stream of message like below

```text
{"eventtime":"2021-11-12 18:30:00"}
{"eventtime":"2021-11-12 18:30:01"}
{"eventtime":"2021-11-12 18:30:02"}
{"eventtime":"2021-11-12 18:30:07"}
{"eventtime":"2021-11-12 18:30:06"}
{"eventtime":"2021-11-12 18:30:04"}
{"eventtime":"2021-11-12 18:30:05"}
{"eventtime":"2021-11-12 18:31:00"}
......
......
```


we could get output like below

```text
[0] tcp.0: [1620483146.702023972, {"time"=>"2021-11-12 18:30:00"}]
[1] tcp.0: [1620483150.354546260, {"time"=>"2021-11-12 18:30:01"}]
[2] tcp.0: [1620483153.771547131, {"time"=>"2021-11-12 18:30:02"}]
[3] tcp.0: [1620483176.174986006, {"time"=>"2021-11-12 18:30:04"}]
[4] tcp.0: [1620483180.376079757, {"time"=>"2021-11-12 18:30:05"}]
[5] tcp.0: [1620483169.903685948, {"time"=>"2021-11-12 18:30:06"}]
[6] tcp.0: [1620483163.781975807, {"time"=>"2021-11-12 18:30:07"}]
```

Firstly, current solution requires timestamp like this
```text
%Y-%m-%d %H:%M:%S
```

When out of order(event time) record arrive, it would be put into a batch window in which it is sorted in order of event timestamp. Of course, there are upper and lower limit for each piece of incoming data.

The first record is "2021-11-12 18:30:00", so the initial left\_edge is "2021-11-12 18:30:00" and the initial right\_edge is  "2021-11-12 18:30:00" + window\_size, which is "2021-11-12 18:30:10".

The second record is "2021-11-12 18:30:01", since "2021-11-12 18:30:01" > left\_edge, we sort and cache it.

The third record is "2021-11-12 18:30:02", since "2021-11-12 18:30:02" > left\_edge, we sort and cache it.

The fourth record is "2021-11-12 18:30:07", since "2021-11-12 18:30:07" > left\_edge, we sort and cache it.

The fifth, sixth, seventh are treated the same with the above.

The eighth record is "2021-11-12 18:31:00", since "2021-11-12 18:31:00" > left\_edge, we sort and cache it.
Since "2021-11-12 18:31:00" - watermark(10) > right\_edge, flush out the window [left\_edge, right\_edge].
Update batch window's new edges(left and right) with remaining data in cache.



### Limitations

Current solution use fixed watermark.
Number of records within a batch window is limited to 100.

### Command Line

> Note: It's suggested to use a configuration file.

The following command will load date from the _tcp_ plugin. Then the _watermark_ filter will apply a watermark and a batch window, once batch window has been tiggerred,  all the records in the window would be flush out in sorted order:

```text
$ bin/fluent-bit -i tcp -F watermark -p 'time_field=eventtime' -p 'watermark=20' -p 'window_size=10'  -m '*' -o stdout
```

### Configuration File

```python
[INPUT]
    Name   tcp

[FILTER]
    Name     watermark
    Match    *
    time_field    eventtime
    watermark   20
    window_size 10

[OUTPUT]
    Name   stdout
    Match  *
```

### Console output

```text
$ nc 127.0.0.1 5170
{"eventtime":"2021-11-12 18:30:00"}
{"eventtime":"2021-11-12 18:30:01"}
{"eventtime":"2021-11-12 18:30:02"}
{"eventtime":"2021-11-12 18:30:03"}
{"eventtime":"2021-11-12 18:29:55"}
{"eventtime":"2021-11-12 18:30:10"}
{"eventtime":"2021-11-12 18:30:08"}
{"eventtime":"2021-11-12 18:30:06"}
{"eventtime":"2021-11-12 18:30:04"}
{"eventtime":"2021-11-12 18:30:11"}
{"eventtime":"2021-11-12 18:30:12"}
{"eventtime":"2021-11-12 18:30:03"}
{"eventtime":"2021-11-12 18:30:14"}
{"eventtime":"2021-11-12 18:30:15"}
{"eventtime":"2021-11-12 18:30:17"]
{"eventtime":"2021-11-12 18:30:17"}
{"eventtime":"2021-11-12 18:30:18"}
{"eventtime":"2021-11-12 18:30:19"}
{"eventtime":"2021-11-12 18:30:20"}
{"eventtime":"2021-11-12 18:30:21"}
{"eventtime":"2021-11-12 18:30:25"}
{"eventtime":"2021-11-12 18:30:28"}
{"eventtime":"2021-11-12 18:30:21"}
{"eventtime":"2021-11-12 18:30:27"}
{"eventtime":"2021-11-12 18:30:26"}
{"eventtime":"2021-11-12 18:30:29"}
{"eventtime":"2021-11-12 18:30:30"}
{"eventtime":"2021-11-12 18:30:31"}
{"eventtime":"2021-11-12 18:30:40"}
{"eventtime":"2021-11-12 18:30:41"}
^C
```

```text
$ bin/fluent-bit -i tcp   -F watermark  -p 'time_field=eventtime' -p 'watermark=20' -p 'window_size=10' -m '*' -o stdout
Fluent Bit v1.7.4
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2021/05/13 18:17:55] [ info] [engine] started (pid=715)
[2021/05/13 18:17:55] [ info] [storage] version=1.1.1, initializing...
[2021/05/13 18:17:55] [ info] [storage] in-memory
[2021/05/13 18:17:55] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2021/05/13 18:17:55] [ info] [input:tcp:tcp.0] listening on 0.0.0.0:5170
[2021/05/13 18:17:55] [ info] [sp] stream processor started
[2021/05/13 18:18:23] [ warn] [filter:watermark:watermark.0] Record with timestamp Fri, 12 Nov 2021 18:29:55 +0800 arrives too late, Drop It!
[2021/05/13 18:19:27] [ warn] [input:tcp:tcp.0] invalid JSON message, skipping
[0] tcp.0: [1620901085.726788647, {"eventtime"=>"2021-11-12 18:30:00"}]
[1] tcp.0: [1620901090.113492716, {"eventtime"=>"2021-11-12 18:30:01"}]
[2] tcp.0: [1620901094.177045070, {"eventtime"=>"2021-11-12 18:30:02"}]
[3] tcp.0: [1620901098.923667415, {"eventtime"=>"2021-11-12 18:30:03"}]
[4] tcp.0: [1620901147.276058886, {"eventtime"=>"2021-11-12 18:30:03"}]
[5] tcp.0: [1620901123.428512147, {"eventtime"=>"2021-11-12 18:30:04"}]
[6] tcp.0: [1620901118.604112111, {"eventtime"=>"2021-11-12 18:30:06"}]
[7] tcp.0: [1620901113.726728854, {"eventtime"=>"2021-11-12 18:30:08"}]
[8] tcp.0: [1620901108.320379507, {"eventtime"=>"2021-11-12 18:30:10"}]
[0] tcp.0: [1620901137.811549945, {"eventtime"=>"2021-11-12 18:30:11"}]
[1] tcp.0: [1620901142.631455845, {"eventtime"=>"2021-11-12 18:30:12"}]
[2] tcp.0: [1620901153.615151549, {"eventtime"=>"2021-11-12 18:30:14"}]
[3] tcp.0: [1620901162.508698075, {"eventtime"=>"2021-11-12 18:30:15"}]
[4] tcp.0: [1620901172.552903712, {"eventtime"=>"2021-11-12 18:30:17"}]
[5] tcp.0: [1620901176.824674168, {"eventtime"=>"2021-11-12 18:30:18"}]
[6] tcp.0: [1620901180.852549067, {"eventtime"=>"2021-11-12 18:30:19"}]
[7] tcp.0: [1620901185.530243114, {"eventtime"=>"2021-11-12 18:30:20"}]
[8] tcp.0: [1620901189.802807474, {"eventtime"=>"2021-11-12 18:30:21"}]
[9] tcp.0: [1620901206.606016615, {"eventtime"=>"2021-11-12 18:30:21"}]
^C[2021/05/13 18:21:49] [engine] caught signal (SIGINT)
[2021/05/13 18:21:49] [ warn] [engine] service will stop in 5 seconds
[2021/05/13 18:21:54] [ info] [engine] service stopped
```
