# Input Plugins

The _input plugins_ defines the source from where [Fluent Bit](http://fluentbit.io) can collect data, it can be through a network interface, radio hardware or some built-in metric. As of this version the following input plugins are available:

| name | title | description |
| :--- | :--- | :--- |
| [collectd](collectd.md) | Collectd | Listen for UDP packets from Collectd. |
| [cpu](cpu.md) | CPU Usage | measure total CPU usage of the system. |
| [disk](disk.md) | Disk Usage | measure Disk I/Os. |
| [dummy](dummy.md) | Dummy | generate dummy event. |
| [exec](exec.md) | Exec | executes external program and collects event logs. |
| [forward](forward.md) | Forward | Fluentd forward protocol. |
| [head](head.md) | Head | read first part of files. |
| [health](health.md) | Health | Check health of TCP services. |
| [kmsg](kmsg.md) | Kernel Log Buffer | read the Linux Kernel log buffer messages. |
| [mem](mem.md) | Memory Usage | measure the total amount of memory used on the system. |
| [mqtt](mqtt.md) | MQTT | start a MQTT server and receive publish messages. |
| [netif](netif.md) | Network Traffic | measure network traffic. |
| [proc](proc.md) | Process | Check health of Process. |
| [random](random.md) | Random | Generate Random samples. |
| [serial](serial.md) | Serial Interface | read data information from the serial interface. |
| [stdin](stdin.md) | Standard Input | read data from the standard input. |
| [syslog](syslog.md) | Syslog | read syslog messages from a Unix socket. |
| [systemd](systemd.md) | Systemd | read logs from Systemd/Journald. |
| [tail](tail.md) | Tail | Tail log files |
| [tcp](tcp.md) | TCP | Listen for JSON messages over TCP. |
| [thermal](thermal.md) | Thermal | measure system temperature\(s\). |

