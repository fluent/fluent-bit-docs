# Build and install

[Fluent Bit](http://fluentbit.io) uses [CMake](http://cmake.org) as its build system.

## Requirements

- CMake 3.12 or greater. You might need to use `cmake3` instead of `cmake`.
- Flex
- Bison 3 or greater
- YAML headers
- OpenSSL headers

## Prepare environment

If you already know how CMake works, you can skip this section and review the available [build options](#general-options).

The following steps explain how to build and install the project with the default options.

1. Change to the `build/` directory inside the Fluent Bit sources:

   ```bash
   cd build/
   ```

1. Let [CMake](http://cmake.org) configure the project specifying where the root path is located:

   ```bash
   cmake ../
   ```

   This command displays a series of results similar to:

   ```text
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

1. Start the compilation process using the `make` command:

   ```bash
   make
   ```

   This command displays results similar to:

   ```text
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

1. To continue installing the binary on the system, use `make install`:

   ```bash
   make install
   ```

   If the command indicates insufficient permissions, prefix the command with `sudo`.

## Build options

Fluent Bit provides configurable options to CMake that can be enabled or disabled.

### General options

| Option | Description | Default |
| :--- | :--- | :--- |
| `FLB_ALL` | Enable all features available | _No_ |
| `FLB_JEMALLOC` | Use Jemalloc as default memory allocator | _No_ |
| `FLB_TLS` | Build with SSL/TLS support | _Yes_ |
| `FLB_BINARY` | Build executable | _Yes_ |
| `FLB_EXAMPLES` | Build examples | _Yes_ |
| `FLB_SHARED_LIB` | Build shared library | _Yes_ |
| `FLB_MTRACE` | Enable mtrace support | _No_ |
| `FLB_INOTIFY` | Enable Inotify support | _Yes_ |
| `FLB_POSIX_TLS` | Force POSIX thread storage | _No_ |
| `FLB_SQLDB` | Enable SQL embedded database support | _No_ |
| `FLB_HTTP_SERVER` | Enable HTTP Server | _No_ |
| `FLB_LUAJIT` | Enable Lua scripting support | _Yes_ |
| `FLB_RECORD_ACCESSOR` | Enable record accessor | _Yes_ |
| `FLB_SIGNV4` | Enable AWS Signv4 support | _Yes_ |
| `FLB_STATIC_CONF` | Build binary using static configuration files. The value of this option must be a directory containing configuration files. |  |
| `FLB_STREAM_PROCESSOR` | Enable Stream Processor | _Yes_ |
| `FLB_CONFIG_YAML` | Enable YAML configuration support | _Yes_ |
| `FLB_WASM` | Build with WASM runtime support | _Yes_ |
| `FLB_WAMRC` | Build with WASM AOT compiler executable | _No_ |

### Development options

| Option | Description | Default |
| :--- | :--- | :--- |
| `FLB_DEBUG` | Build binaries with debug symbols | _No_ |
| `FLB_VALGRIND` | Enable Valgrind support | _No_ |
| `FLB_TRACE` | Enable trace mode | _No_ |
| `FLB_SMALL` | Minimise binary size | _No_ |
| `FLB_TESTS_RUNTIME` | Enable runtime tests | _No_ |
| `FLB_TESTS_INTERNAL` | Enable internal tests | _No_ |
| `FLB_TESTS` | Enable tests | _No_ |
| `FLB_BACKTRACE` | Enable backtrace/stacktrace support | _Yes_ |

### Optimization options

| Option | Description | Default |
| :--- | :--- | :--- |
| `FLB_MSGPACK_TO_JSON_INIT_BUFFER_SIZE` | Determine initial buffer size for `msgpack` to `json` conversion in terms of memory used by payload. | `2.0` |
| `FLB_MSGPACK_TO_JSON_REALLOC_BUFFER_SIZE` | Determine percentage of reallocation size when `msgpack` to `json` conversion buffer runs out of memory. | `0.1` |

### Input plugins

Input plugins gather information from a specific source type like network interfaces, some built-in metrics, or through a specific input device. The following input plugins are available:

| Option | Description | Default |
| :--- | :--- | :--- |
| [`FLB_IN_COLLECTD`](../../pipeline/inputs/collectd.md) | Enable Collectd input plugin | _On_ |
| [`FLB_IN_CPU`](../../pipeline/inputs/cpu-metrics.md) | Enable CPU input plugin | _On_ |
| [`FLB_IN_DISK`](../../pipeline/inputs/disk-io-metrics.md) | Enable Disk I/O Metrics input plugin | _On_ |
| [`FLB_IN_DOCKER`](../../pipeline/inputs/docker-events.md) | Enable Docker metrics input plugin | _On_ |
| [`FLB_IN_EXEC`](../../pipeline/inputs/exec.md) | Enable Exec input plugin | _On_ |
| [`FLB_IN_EXEC_WASI`](../../pipeline/inputs/exec-wasi.md) | Enable Exec WASI input plugin | _On_ |
| [`FLB_IN_FLUENTBIT_METRICS`](../../pipeline/inputs/fluentbit-metrics.md) | Enable Fluent Bit metrics input plugin | _On_ |
| [`FLB_IN_ELASTICSEARCH`](../../pipeline/inputs/elasticsearch.md) | Enable Elasticsearch/OpenSearch Bulk input plugin | _On_ |
| [`FLB_IN_FORWARD`](../../pipeline/inputs/forward.md) | Enable Forward input plugin | _On_ |
| [`FLB_IN_HEAD`](../../pipeline/inputs/head.md) | Enable Head input plugin | _On_ |
| [`FLB_IN_HEALTH`](../../pipeline/inputs/health.md) | Enable Health input plugin | _On_ |
| [`FLB_IN_KMSG`](../../pipeline/inputs/kernel-logs.md) | Enable Kernel log input plugin | _On_ |
| [`FLB_IN_MEM`](../../pipeline/inputs/memory-metrics.md) | Enable Memory input plugin | _On_ |
| [`FLB_IN_MQTT`](../../pipeline/inputs/mqtt.md) | Enable MQTT Server input plugin | _On_ |
| [`FLB_IN_NETIF`](../../pipeline/inputs/network-io-metrics.md) | Enable Network I/O metrics input plugin | _On_ |
| [`FLB_IN_PROC`](../../pipeline/inputs/process.md) | Enable Process monitoring input plugin | _On_ |
| [`FLB_IN_RANDOM`](../../pipeline/inputs/random.md) | Enable Random input plugin | _On_ |
| [`FLB_IN_SERIAL`](../../pipeline/inputs/serial-interface.md) | Enable Serial input plugin | _On_ |
| [`FLB_IN_STDIN`](../../pipeline/inputs/standard-input.md) | Enable Standard input plugin | _On_ |
| [`FLB_IN_SYSLOG`](../../pipeline/inputs/syslog.md) | Enable Syslog input plugin | _On_ |
| [`FLB_IN_SYSTEMD`](../../pipeline/inputs/systemd.md) | Enable Systemd / Journald input plugin | _On_ |
| [`FLB_IN_TAIL`](../../pipeline/inputs/tail.md) | Enable Tail (follow files) input plugin | _On_ |
| [`FLB_IN_TCP`](../../pipeline/inputs/tcp.md) | Enable TCP input plugin | _On_ |
| [`FLB_IN_THERMAL`](../../pipeline/inputs/thermal.md) | Enable system temperature input plugin | _On_ |
| [`FLB_IN_UDP`](../../pipeline/inputs/udp.md) | Enable UDP input plugin | _On_ |
| [`FLB_IN_WINLOG`](../../pipeline/inputs/windows-event-log.md) | Enable Windows Event Log input plugin (Windows Only) | _On_ |
| [`FLB_IN_WINEVTLOG`](../../pipeline/inputs/windows-event-log-winevtlog.md) | Enable Windows Event Log input plugin using `winevt.h` API (Windows Only) | _On_ |

### Filter plugins

Filter plugins let you modify, enrich or drop records. The following table describes the filters available on this version:

| Option | Description | Default |
| :--- | :--- | :--- |
| [`FLB_FILTER_AWS`](../../pipeline/filters/aws-metadata.md) | Enable AWS metadata filter | _On_ |
| [`FLB_FILTER_ECS`](../../pipeline/filters/ecs-metadata.md) | Enable AWS metadata filter | _On_ |
| `FLB_FILTER_EXPECT` | Enable Expect data test filter | _On_ |
| [`FLB_FILTER_GREP`](../../pipeline/filters/grep.md) | Enable Grep filter | _On_ |
| [`FLB_FILTER_KUBERNETES`](../../pipeline/filters/kubernetes.md) | Enable Kubernetes metadata filter | _On_ |
| [`FLB_FILTER_LUA`](../../pipeline/filters/lua.md) | Enable Lua scripting filter | _On_ |
| [`FLB_FILTER_MODIFY`](../../pipeline/filters/modify.md) | Enable Modify filter | _On_ |
| [`FLB_FILTER_NEST`](../../pipeline/filters/nest.md) | Enable Nest filter | _On_ |
| [`FLB_FILTER_PARSER`](../../pipeline/filters/parser.md) | Enable Parser filter | _On_ |
| [`FLB_FILTER_RECORD_MODIFIER`](../../pipeline/filters/record-modifier.md) | Enable Record Modifier filter | _On_ |
| [`FLB_FILTER_REWRITE_TAG`](../../pipeline/filters/rewrite-tag.md) | Enable Rewrite Tag filter | _On_ |
| [`FLB_FILTER_STDOUT`](../../pipeline/filters/standard-output.md) | Enable Stdout filter | _On_ |
| [`FLB_FILTER_SYSINFO`](../../pipeline/filters/sysinfo.md) | Enable Sysinfo filter | _On_ |
| [`FLB_FILTER_THROTTLE`](../../pipeline/filters/throttle.md) | Enable Throttle filter | _On_ |
| [`FLB_FILTER_TYPE_CONVERTER`](../../pipeline/filters/type-converter.md) | Enable Type Converter filter | _On_ |
| [`FLB_FILTER_WASM`](../../pipeline/filters/wasm.md) | Enable WASM filter | _On_ |

### Output plugins

Output plugins let you flush the information to some external interface, service, or terminal. The following table describes the output plugins available:

| Option | Description | Default |
| :--- | :--- | :--- |
| [`FLB_OUT_AZURE`](../../pipeline/outputs/azure.md) | Enable Microsoft Azure output plugin | _On_ |
| [`FLB_OUT_AZURE_KUSTO`](../../pipeline/outputs/azure_kusto.md) | Enable Azure Kusto output plugin | _On_ |
| [`FLB_OUT_BIGQUERY`](../../pipeline/outputs/bigquery.md) | Enable Google BigQuery output plugin | _On_ |
| [`FLB_OUT_COUNTER`](../../pipeline/outputs/counter.md) | Enable Counter output plugin | _On_ |
| [`FLB_OUT_CLOUDWATCH_LOGS`](../../pipeline/outputs/cloudwatch.md) | Enable Amazon CloudWatch output plugin | _On_ |
| [`FLB_OUT_DATADOG`](../../pipeline/outputs/datadog.md) | Enable Datadog output plugin | _On_ |
| [`FLB_OUT_ES`](../../pipeline/outputs/elasticsearch.md) | Enable [Elastic Search](http://www.elastic.co) output plugin | _On_ |
| [`FLB_OUT_FILE`](../../pipeline/outputs/file.md) | Enable File output plugin | _On_ |
| [`FLB_OUT_KINESIS_FIREHOSE`](../../pipeline/outputs/firehose.md) | Enable Amazon Kinesis Data Firehose output plugin | _On_ |
| [`FLB_OUT_KINESIS_STREAMS`](../../pipeline/outputs/kinesis.md) | Enable Amazon Kinesis Data Streams output plugin | _On_ |
| [`FLB_OUT_FLOWCOUNTER`](../../pipeline/outputs/flowcounter.md) | Enable Flowcounter output plugin | _On_ |
| [`FLB_OUT_FORWARD`](../../pipeline/outputs/forward.md) | Enable [Fluentd](http://www.fluentd.org) output plugin | _On_ |
| [`FLB_OUT_GELF`](../../pipeline/outputs/gelf.md) | Enable Gelf output plugin | _On_ |
| [`FLB_OUT_HTTP`](../../pipeline/outputs/http.md) | Enable HTTP output plugin | _On_ |
| [`FLB_OUT_INFLUXDB`](../../pipeline/outputs/influxdb.md) | Enable InfluxDB output plugin | _On_ |
| [`FLB_OUT_KAFKA`](../../pipeline/outputs/kafka.md) | Enable Kafka output | Off |
| [`FLB_OUT_KAFKA_REST`](../../pipeline/outputs/kafka-rest-proxy.md) | Enable Kafka REST Proxy output plugin | _On_ |
| `FLB_OUT_LIB` | Enable Lib output plugin | _On_ |
| [`FLB_OUT_NATS`](../../pipeline/outputs/nats.md) | Enable [NATS](http://www.nats.io) output plugin | _On_ |
| `FLB_OUT_NULL` | Enable NULL output plugin | _On_ |
| `FLB_OUT_PGSQL` | Enable PostgreSQL output plugin | _On_ |
| `FLB_OUT_PLOT` | Enable Plot output plugin | _On_ |
| `FLB_OUT_SLACK` | Enable Slack output plugin | _On_ |
| [`FLB_OUT_S3`](../../pipeline/outputs/s3.md) | Enable Amazon S3 output plugin | _On_ |
| [`FLB_OUT_SPLUNK`](../../pipeline/outputs/splunk.md) | Enable Splunk output plugin | _On_ |
| [`FLB_OUT_STACKDRIVER`](../../pipeline/outputs/stackdriver.md) | Enable Google Stackdriver output plugin | _On_ |
| [`FLB_OUT_STDOUT`](build-and-install.md) | Enable STDOUT output plugin | _On_ |
| `FLB_OUT_TCP` | Enable TCP/TLS output plugin | _On_ |
| [`FLB_OUT_TD`](../../pipeline/outputs/treasure-data.md) | Enable [Treasure Data](http://www.treasuredata.com) output plugin | _On_ |

### Processor plugins

Processor plugins handle the events within the processor pipelines to allow modifying, enriching, or dropping events.

The following table describes the processors available:

| Option | Description | Default || :--- | :--- | :--- |
| [`FLB_PROCESSOR_METRICS_SELECTOR`](../../pipeline/processors/metrics-selector.md) | Enable metrics selector processor | _On_ |
| [`FLB_PROCESSOR_LABELS`](../../pipeline/processors/labels.md) | Enable metrics label manipulation processor | _On_ |
