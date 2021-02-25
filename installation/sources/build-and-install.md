# Build and Install

[Fluent Bit](http://fluentbit.io) uses [CMake](http://cmake.org) as it build system. The suggested procedure to prepare the build system consists on the following steps:

## Prepare environment

> In the following steps you can find exact commands to build and install the project with the default options. If you already know how CMake works you can skip this part and look at the build options available. Note that Fluent Bit requires CMake 3.x. You may need to use `cmake3` instead of `cmake` to complete the following steps on your system.

Change to the _build/_ directory inside the Fluent Bit sources:

```bash
$ cd build/
```

Let [CMake](http://cmake.org) configure the project specifying where the root path is located:

```bash
$ cmake ../
-- The C compiler identification is GNU 4.9.2
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- The CXX compiler identification is GNU 4.9.2
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
...
-- Could NOT find Doxygen (missing:  DOXYGEN_EXECUTABLE)
-- Looking for accept4
-- Looking for accept4 - not found
-- Configuring done
-- Generating done
-- Build files have been written to: /home/edsiper/coding/fluent-bit/build
```

Now you are ready to start the compilation process through the simple _make_ command:

```bash
$ make
Scanning dependencies of target msgpack
[  2%] Building C object lib/msgpack-1.1.0/CMakeFiles/msgpack.dir/src/unpack.c.o
[  4%] Building C object lib/msgpack-1.1.0/CMakeFiles/msgpack.dir/src/objectc.c.o
[  7%] Building C object lib/msgpack-1.1.0/CMakeFiles/msgpack.dir/src/version.c.o
...
[ 19%] Building C object lib/monkey/mk_core/CMakeFiles/mk_core.dir/mk_file.c.o
[ 21%] Building C object lib/monkey/mk_core/CMakeFiles/mk_core.dir/mk_rconf.c.o
[ 23%] Building C object lib/monkey/mk_core/CMakeFiles/mk_core.dir/mk_string.c.o
...
Scanning dependencies of target fluent-bit-static
[ 66%] Building C object src/CMakeFiles/fluent-bit-static.dir/flb_pack.c.o
[ 69%] Building C object src/CMakeFiles/fluent-bit-static.dir/flb_input.c.o
[ 71%] Building C object src/CMakeFiles/fluent-bit-static.dir/flb_output.c.o
...
Linking C executable ../bin/fluent-bit
[100%] Built target fluent-bit-bin
```

to continue installing the binary on the system just do:

```bash
$ make install
```

it's likely you may need root privileges so you can try to prefixing the command with _sudo_.

## Build Options

Fluent Bit provides certain options to CMake that can be enabled or disabled when configuring, please refer to the following tables under the _General Options_, _Development Options_, Input Plugins _and \_Output Plugins_ sections.

### General Options

| option | description | default |
| :--- | :--- | :--- |
| FLB\_ALL | Enable all features available | No |
| FLB\_JEMALLOC | Use Jemalloc as default memory allocator | No |
| FLB\_TLS | Build with SSL/TLS support | Yes |
| FLB\_BINARY | Build executable | Yes |
| FLB\_EXAMPLES | Build examples | Yes |
| FLB\_SHARED\_LIB | Build shared library | Yes |
| FLB\_MTRACE | Enable mtrace support | No |
| FLB\_INOTIFY | Enable Inotify support | Yes |
| FLB\_POSIX\_TLS | Force POSIX thread storage | No |
| FLB\_SQLDB | Enable SQL embedded database support | No |
| FLB\_HTTP\_SERVER | Enable HTTP Server | No |
| FLB\_LUAJIT | Enable Lua scripting support | Yes |
| FLB\_RECORD\_ACCESSOR | Enable record accessor | Yes |
| FLB\_SIGNV4 | Enable AWS Signv4 support | Yes |
| FLB\_STATIC\_CONF | Build binary using static configuration files. The value of this option must be a directory containing configuration files. |  |
| FLB\_STREAM\_PROCESSOR | Enable Stream Processor | Yes |

### Development Options

| option | description | default |
| :--- | :--- | :--- |
| FLB\_DEBUG | Build binaries with debug symbols | No |
| FLB\_VALGRIND | Enable Valgrind support | No |
| FLB\_TRACE | Enable trace mode | No |
| FLB\_SMALL | Minimise binary size | No |
| FLB\_TESTS\_RUNTIME | Enable runtime tests | No |
| FLB\_TESTS\_INTERNAL | Enable internal tests | No |
| FLB\_TESTS | Enable tests | No |
| FLB\_BACKTRACE | Enable backtrace/stacktrace support | Yes |

### Input Plugins

The _input plugins_ provides certain features to gather information from a specific source type which can be a network interface, some built-in metric or through a specific input device, the following input plugins are available:

| option | description | default |
| :--- | :--- | :--- |
| [FLB\_IN\_COLLECTD](../../pipeline/inputs/collectd.md) | Enable Collectd input plugin | On |
| [FLB\_IN\_CPU](../../pipeline/inputs/cpu-metrics.md) | Enable CPU input plugin | On |
| [FLB\_IN\_DISK](../../pipeline/inputs/disk-io-metrics.md) | Enable Disk I/O Metrics input plugin | On |
| [FLB\_IN\_DOCKER](../../pipeline/inputs/docker-events.md) | Enable Docker metrics input plugin | On |
| [FLB\_IN\_EXEC](../../pipeline/inputs/exec.md) | Enable Exec input plugin | On |
| [FLB\_IN\_FORWARD](../../pipeline/inputs/forward.md) | Enable Forward input plugin | On |
| [FLB\_IN\_HEAD](../../pipeline/inputs/head.md) | Enable Head input plugin | On |
| [FLB\_IN\_HEALTH](../../pipeline/inputs/health.md) | Enable Health input plugin | On |
| [FLB\_IN\_KMSG](../../pipeline/inputs/kernel-logs.md) | Enable Kernel log input plugin | On |
| [FLB\_IN\_MEM](../../pipeline/inputs/memory-metrics.md) | Enable Memory input plugin | On |
| [FLB\_IN\_MQTT](../../pipeline/inputs/mqtt.md) | Enable MQTT Server input plugin | On |
| [FLB\_IN\_NETIF](../../pipeline/inputs/network-io-metrics.md) | Enable Network I/O metrics input plugin | On |
| [FLB\_IN\_PROC](../../pipeline/inputs/process.md) | Enable Process monitoring input plugin | On |
| [FLB\_IN\_RANDOM](../../pipeline/inputs/random.md) | Enable Random input plugin | On |
| [FLB\_IN\_SERIAL](../../pipeline/inputs/serial-interface.md) | Enable Serial input plugin | On |
| [FLB\_IN\_STDIN](../../pipeline/inputs/standard-input.md) | Enable Standard input plugin | On |
| [FLB\_IN\_SYSLOG](../../pipeline/inputs/syslog.md) | Enable Syslog input plugin | On |
| [FLB\_IN\_SYSTEMD](../../pipeline/inputs/systemd.md) | Enable Systemd / Journald input plugin | On |
| [FLB\_IN\_TAIL](../../pipeline/inputs/tail.md) | Enable Tail \(follow files\) input plugin | On |
| [FLB\_IN\_TCP](../../pipeline/inputs/tcp.md) | Enable TCP input plugin | On |
| [FLB\_IN\_THERMAL](../../pipeline/inputs/thermal.md) | Enable system temperature\(s\) input plugin | On |
| [FLB\_IN\_WINLOG](../../pipeline/inputs/windows-event-log.md) | Enable Windows Event Log input plugin \(Windows Only\) | On |

### Filter Plugins

The _filter plugins_ allows to modify, enrich or drop records. The following table describes the filters available on this version:

| option | description | default |
| :--- | :--- | :--- |
| [FLB\_FILTER\_AWS](../../pipeline/filters/aws-metadata.md) | Enable AWS metadata filter | On |
| FLB\_FILTER\_EXPECT | Enable Expect data test filter | On |
| [FLB\_FILTER\_GREP](../../pipeline/filters/grep.md) | Enable Grep filter | On |
| [FLB\_FILTER\_KUBERNETES](../../pipeline/filters/kubernetes.md) | Enable Kubernetes metadata filter | On |
| [FLB\_FILTER\_LUA](../../pipeline/filters/lua.md) | Enable Lua scripting filter | On |
| [FLB\_FILTER\_MODIFY](../../pipeline/filters/modify.md) | Enable Modify filter | On |
| [FLB\_FILTER\_NEST](../../pipeline/filters/nest.md) | Enable Nest filter | On |
| [FLB\_FILTER\_PARSER](../../pipeline/filters/parser.md) | Enable Parser filter | On |
| [FLB\_FILTER\_RECORD\_MODIFIER](../../pipeline/filters/record-modifier.md) | Enable Record Modifier filter | On |
| [FLB\_FILTER\_REWRITE\_TAG](../../pipeline/filters/rewrite-tag.md) | Enable Rewrite Tag filter | On |
| [FLB\_FILTER\_STDOUT](../../pipeline/filters/standard-output.md) | Enable Stdout filter | On |
| [FLB\_FILTER\_THROTTLE](../../pipeline/filters/throttle.md) | Enable Throttle filter | On |

### Output Plugins

The _output plugins_ gives the capacity to flush the information to some external interface, service or terminal, the following table describes the output plugins available as of this version:

| option | description | default |
| :--- | :--- | :--- |
| [FLB\_OUT\_AZURE](../../pipeline/outputs/azure.md) | Enable Microsoft Azure output plugin | On |
| [FLB\_OUT\_BIGQUERY](../../pipeline/outputs/bigquery.md) | Enable Google BigQuery output plugin | On |
| [FLB\_OUT\_COUNTER](../../pipeline/outputs/counter.md) | Enable Counter output plugin | On |
| [FLB\_OUT\_CLOUDWATCH\_LOGS](../../pipeline/outputs/cloudwatch.md) | Enable Amazon CloudWatch output plugin | On |
| [FLB\_OUT\_DATADOG](../../pipeline/outputs/datadog.md) | Enable Datadog output plugin | On |
| [FLB\_OUT\_ES](../../pipeline/outputs/elasticsearch.md) | Enable [Elastic Search](http://www.elastic.co) output plugin | On |
| [FLB\_OUT\_FILE](../../pipeline/outputs/file.md) | Enable File output plugin | On |
| [FLB\_OUT\_KINESIS\_FIREHOSE](../../pipeline/outputs/firehose.md) | Enable Amazon Kinesis Data Firehose output plugin | On |
| [FLB\_OUT\_KINESIS\_STREAMS](../../pipeline/outputs/kinesis.md) | Enable Amazon Kinesis Data Streams output plugin | On |
| [FLB\_OUT\_FLOWCOUNTER](../../pipeline/outputs/flowcounter.md) | Enable Flowcounter output plugin | On |
| [FLB\_OUT\_FORWARD](build-and-install.md) | Enable [Fluentd](http://www.fluentd.org) output plugin | On |
| [FLB\_OUT\_GELF](../../pipeline/outputs/gelf.md) | Enable Gelf output plugin | On |
| [FLB\_OUT\_HTTP](../../pipeline/outputs/http.md) | Enable HTTP output plugin | On |
| [FLB\_OUT\_INFLUXDB](../../pipeline/outputs/influxdb.md) | Enable InfluxDB output plugin | On |
| [FLB\_OUT\_KAFKA](../../pipeline/outputs/kafka.md) | Enable Kafka output | Off |
| [FLB\_OUT\_KAFKA\_REST](../../pipeline/outputs/kafka-rest-proxy.md) | Enable Kafka REST Proxy output plugin | On |
| FLB\_OUT\_LIB | Enable Lib output plugin | On |
| [FLB\_OUT\_NATS](../../pipeline/outputs/nats.md) | Enable [NATS](http://www.nats.io) output plugin | Off |
| FLB\_OUT\_NULL | Enable NULL output plugin | On |
| FLB\_OUT\_PGSQL | Enable PostgreSQL output plugin | On |
| FLB\_OUT\_PLOT | Enable Plot output plugin | On |
| FLB\_OUT\_SLACK | Enable Slack output plugin | On |
| [FLB\_OUT\_S3](../../pipeline/outputs/s3.md) | Enable Amazon S3 output plugin | On |
| [FLB\_OUT\_SPLUNK](../../pipeline/outputs/splunk.md) | Enable Splunk output plugin | On |
| [FLB\_OUT\_STACKDRIVER](../../pipeline/outputs/stackdriver.md) | Enable Google Stackdriver output plugin | On |
| [FLB\_OUT\_STDOUT](build-and-install.md) | Enable STDOUT output plugin | On |
| FLB\_OUT\_TCP | Enable TCP/TLS output plugin | On |
| [FLB\_OUT\_TD](../../pipeline/outputs/treasure-data.md) | Enable [Treasure Data](http://www.treasuredata.com) output plugin | On |

