# Head

The **head** input plugin, allows to read events from the head of file. It's behavior is similar to the _head_ command.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| File | Absolute path to the target file, e.g: /proc/uptime |
| Buf\_Size | Buffer size to read the file. |
| Interval\_Sec | Polling interval \(seconds\). |
| Interval\_NSec | Polling interval \(nanosecond\). |
| Add\_Path | If enabled, filepath is appended to each records. Default value is _false_. |
| Key | Rename a key. Default: head. |
| Lines | Line number to read. If the number N is set, in\_head reads first N lines like head\(1\) -n. |
| Split\_line | If enabled, in\_head generates key-value pair per line. |
| Encoder | Optionally encode input to UTF-8. E.g. `iso-8859-1` |

### Split Line Mode

This mode is useful to get a specific line. This is an example to get CPU frequency from /proc/cpuinfo.

/proc/cpuinfo is a special file to get cpu information.

```text
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 42
model name    : Intel(R) Core(TM) i7-2640M CPU @ 2.80GHz
stepping    : 7
microcode    : 41
cpu MHz        : 2791.009
cache size    : 4096 KB
physical id    : 0
siblings    : 1
```

Cpu frequency is "cpu MHz : 2791.009". We can get the line with this configuration file.

```python
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

Output is

```bash
$ bin/fluent-bit -c head.conf 
Fluent-Bit v0.12.0
Copyright (C) Treasure Data

[2017/06/26 22:38:24] [ info] [engine] started
[0] head.cpu: [1498484305.000279805, {"line7"=>"cpu MHz        : 2791.009"}]
[1] head.cpu: [1498484306.011680137, {"line7"=>"cpu MHz        : 2791.009"}]
[2] head.cpu: [1498484307.010042482, {"line7"=>"cpu MHz        : 2791.009"}]
[3] head.cpu: [1498484308.008447978, {"line7"=>"cpu MHz        : 2791.009"}]
```

## Getting Started

In order to read the head of a file, you can run the plugin from the command line or through the configuration file:

### Command Line

The following example will read events from the /proc/uptime file, tag the records with the _uptime_ name and flush them back to the _stdout_ plugin:

```bash
$ fluent-bit -i head -t uptime -p File=/proc/uptime -o stdout -m '*'
Fluent-Bit v0.8.0
Copyright (C) Treasure Data

[2016/05/17 21:53:54] [ info] starting engine
[0] uptime: [1463543634, {"head"=>"133517.70 194870.97"}]
[1] uptime: [1463543635, {"head"=>"133518.70 194872.85"}]
[2] uptime: [1463543636, {"head"=>"133519.70 194876.63"}]
[3] uptime: [1463543637, {"head"=>"133520.70 194879.72"}]
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
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

Note: Total interval \(sec\) = Interval\_Sec + \(Interval\_Nsec / 1000000000\).

e.g. 1.5s = 1s + 500000000ns

