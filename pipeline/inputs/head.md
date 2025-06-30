# Head

The _Head_ input plugin reads events from the head of a file. Its behavior is similar to the `head` command.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :-- | :---------- |
| `File` | Absolute path to the target file. For example: `/proc/uptime`. |
| `Buf_Size` | Buffer size to read the file. |
| `Interval_Sec` | Polling interval (seconds). |
| `Interval_NSec` | Polling interval (nanoseconds). |
| `Add_Path` | If enabled, the path is appended to each records. Default: `false`. |
| `Key` | Rename a key. Default: `head`. |
| `Lines` | Line number to read. If the number N is set, `in_head` reads first N lines like `head(1) -n`. |
| `Split_line` | If enabled, `in_head` generates key-value pair per line. |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). Default: `false`. |

### Split line mode

Use this mode to get a specific line. The following example gets CPU frequency from `/proc/cpuinfo`.

`/proc/cpuinfo` is a special file to get CPU information.

```text
processor    : 0
vendor_id    : GenuineIntel
cpu family   : 6
model        : 42
model name   : Intel(R) Core(TM) i7-2640M CPU @ 2.80GHz
stepping     : 7
microcode    : 41
cpu MHz      : 2791.009
cache size   : 4096 KB
physical id  : 0
siblings     : 1
```

The CPU frequency is `cpu MHz : 2791.009`. The following configuration file gets the needed line:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: head
          tag: head.cpu
          file: /proc/cpuinfo
          lines: 8
          split_line: true
          
    filters:
        - name: record_modifier
          match: '*'
          whitelist_key: line7
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name           head
    Tag            head.cpu
    File           /proc/cpuinfo
    Lines          8
    Split_line     true
    # {"line0":"processor    : 0", "line1":"vendor_id    : GenuineIntel" ...}

[FILTER]
    Name           record_modifier
    Match          *
    Whitelist_key  line7

[OUTPUT]
    Name           stdout
    Match          *
```

{% endtab %}
{% endtabs %}

If you run the following command:

```shell
$ fluent-bit -c head.conf
```

The output is something similar to;

```text
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/06/26 22:38:24] [ info] [engine] started
[0] head.cpu: [1498484305.000279805, {"line7"=>"cpu MHz        : 2791.009"}]
[1] head.cpu: [1498484306.011680137, {"line7"=>"cpu MHz        : 2791.009"}]
[2] head.cpu: [1498484307.010042482, {"line7"=>"cpu MHz        : 2791.009"}]
[3] head.cpu: [1498484308.008447978, {"line7"=>"cpu MHz        : 2791.009"}]
```

## Get started

To read the head of a file, you can run the plugin from the command line or through the configuration file.

### Command line

The following example will read events from the `/proc/uptime` file, tag the records with the `uptime` name and flush them back to the `stdout` plugin:

```shell
$ fluent-bit -i head -t uptime -p File=/proc/uptime -o stdout -m '*'
```

The output will look similar to:

```text
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2016/05/17 21:53:54] [ info] starting engine
[0] uptime: [1463543634, {"head"=>"133517.70 194870.97"}]
[1] uptime: [1463543635, {"head"=>"133518.70 194872.85"}]
[2] uptime: [1463543636, {"head"=>"133519.70 194876.63"}]
[3] uptime: [1463543637, {"head"=>"133520.70 194879.72"}]
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: head
          tag: uptime
          file: /proc/uptime
          buf_size: 256
          interval_sec: 1
          interval_nsec: 0
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```shell
[INPUT]
    Name          head
    Tag           uptime
    File          /proc/uptime
    Buf_Size      256
    Interval_Sec  1
    Interval_NSec 0

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

The interval is calculated like this:

`Total interval (sec) = Interval_Sec + (Interval_Nsec / 1000000000)`.

For example: `1.5s = 1s + 500000000ns`.