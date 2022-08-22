# Kernel Logs

The **kmsg** input plugin reads the Linux Kernel log buffer since the beginning, it gets every record and parse it field as priority, sequence, seconds, useconds, and message.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| Prio_Level | The log level to filter. The kernel log is dropped if its priority is more than prio_level. Allowed values are 0-8. Default is 8. 8 means all logs are saved. | 8 |

## Getting Started

In order to start getting the Linux Kernel messages, you can run the plugin from the command line or through the configuration file:

### Command Line

```bash
$ bin/fluent-bit -i kmsg -t kernel -o stdout -m '*'
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[0] kernel: [1463421823, {"priority"=>3, "sequence"=>1814, "sec"=>11706, "usec"=>732233, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[1] kernel: [1463421823, {"priority"=>3, "sequence"=>1815, "sec"=>11706, "usec"=>732300, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[2] kernel: [1463421829, {"priority"=>3, "sequence"=>1816, "sec"=>11712, "usec"=>729728, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec profile =20:3a:07:9e:4a:ac"}]
[3] kernel: [1463421829, {"priority"=>3, "sequence"=>1817, "sec"=>11712, "usec"=>729802, "msg"=>"ERROR @wl_cfg80211_get_station : Wrong Mac address, mac = 34:a8:4e:d3:40:ec
...
```

As described above, the plugin processed all messages that the Linux Kernel reported, the output has been truncated for clarification.

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name   kmsg
    Tag    kernel

[OUTPUT]
    Name   stdout
    Match  *
```

