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

   ```shell
   cd build/
   ```

1. Let [CMake](http://cmake.org) configure the project specifying where the root path is located:

   ```shell
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

   ```shell
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

   ```shell
   make install
   ```

   If the command indicates insufficient permissions, prefix the command with `sudo`.

## Build options

Fluent Bit provides configurable options to CMake that can be enabled or disabled.

### General options

| Option                   | Description                                                                                                                 | Default                       |
|:-------------------------|:----------------------------------------------------------------------------------------------------------------------------|:------------------------------|
| `FLB_ALL`                | Enable all features available                                                                                               | `No`                          |
| `FLB_ARROW`              | Build with Apache Arrow support                                                                                             | `No`                          |
| `FLB_AVRO_ENCODER`       | Build with Avro encoding support                                                                                            | `No`                          |
| `FLB_AWS`                | Enable AWS support                                                                                                          | `Yes`                         |
| `FLB_AWS_ERROR_REPORTER` | Build with aws error reporting support                                                                                      | `No`                          |
| `FLB_BENCHMARKS`         | Enable benchmarks                                                                                                           | `No`                          |
| `FLB_BINARY`             | Build executable                                                                                                            | `Yes`                         |
| `FLB_CHUNK_TRACE`        | Enable chunk traces                                                                                                         | `Yes`                         |
| `FLB_COVERAGE`           | Build with code-coverage                                                                                                    | `No`                          |
| `FLB_CONFIG_YAML`        | Enable YAML configuration support                                                                                           | `Yes`                         |
| `FLB_CORO_STACK_SIZE`    | Set coroutine stack size                                                                                                    |                               |
| `FLB_CUSTOM_CALYPTIA`    | Enable Calyptia Support                                                                                                     | `Yes`                         |
| `FLB_ENFORCE_ALIGNMENT`  | Enable limited platform specific aligned memory access                                                                      | `No`                          |
| `FLB_EXAMPLES`           | Build examples                                                                                                              | `Yes`                         |
| `FLB_HTTP_SERVER`        | Enable HTTP Server                                                                                                          | `Yes`                         |
| `FLB_INOTIFY`            | Enable Inotify support                                                                                                      | `Yes`                         |
| `FLB_JEMALLOC`           | Build with Jemalloc support                                                                                                 | `No`                          |
| `FLB_KAFKA`              | Enable Kafka support                                                                                                        | `Yes`                         |
| `FLB_LUAJIT`             | Enable Lua scripting support                                                                                                | `Yes`                         |
| `FLB_METRICS`            | Enable metrics support                                                                                                      | `Yes`                         |
| `FLB_MTRACE`             | Enable `mtrace` support                                                                                                     | `No`                          |
| `FLB_PARSER`             | Build with Parser support                                                                                                   | `Yes`                         |
| `FLB_POSIX_TLS`          | Force POSIX thread storage                                                                                                  | `No`                          |
| `FLB_PROFILES`           | Enable profiles support                                                                                                     | `Yes`                         |
| `FLB_PROXY_GO`           | Enable Go plugins support                                                                                                   | `Yes`                         |
| `FLB_RECORD_ACCESSOR`    | Enable record accessor                                                                                                      | `Yes`                         |
| `FLB_REGEX`              | Build with Regex support                                                                                                    | `Yes`                         |
| `FLB_RELEASE`            | Build with release mode (`-O2 -g -DNDEBUG`)                                                                                 | `No`                          |
| `FLB_SHARED_LIB`         | Build shared library                                                                                                        | `Yes`                         |
| `FLB_SIGNV4`             | Enable AWS Signv4 support                                                                                                   | `Yes`                         |
| `FLB_SIMD`               | Enable SIMD support                                                                                                         | `No`                          |
| `FLB_SQLDB`              | Enable SQL embedded database support                                                                                        | `Yes`                         |
| `FLB_STATIC_CONF`        | Build binary using static configuration files. The value of this option must be a directory containing configuration files. |                               |
| `FLB_STREAM_PROCESSOR`   | Enable Stream Processor                                                                                                     | `Yes`                         |
| `FLB_TLS`                | Build with SSL/TLS support                                                                                                  | `Yes`                         |
| `FLB_UNICODE_ENCODER`    | Build with Unicode (`UTF-16LE`, `UTF-16BE`) encoding support                                                                | `Yes` (if C++ compiler found) |
| `FLB_UTF8_ENCODER`       | Build with UTF8 encoding support                                                                                            | `Yes`                         |
| `FLB_WASM`               | Build with Wasm runtime support                                                                                             | `Yes`                         |
| `FLB_WASM_STACK_PROTECT` | Build with WASM runtime with strong stack protector flags                                                                   | `No`                          |
| `FLB_WAMRC`              | Build with Wasm AOT compiler executable                                                                                     | `No`                          |
| `FLB_WINDOWS_DEFAULTS`   | Build with predefined Windows settings                                                                                      | `Yes`                         |
| `FLB_ZIG`                | Enable zig integration                                                                                                      | `Yes`                         |

### Development options

| Option                    | Description                  | Default |
|:--------------------------|:-----------------------------|:--------|
| `FLB_BACKTRACE`           | Enable stacktrace support    | `Yes`   |
| `FLB_DEBUG`               | Build with debug mode (`-g`) | `No`    |
| `FLB_SMALL`               | Optimize for small size      | `No`    |
| `FLB_TESTS_INTERNAL`      | Enable internal tests        | `No`    |
| `FLB_TESTS_INTERNAL_FUZZ` | Enable internal fuzz tests   | `No`    |
| `FLB_TESTS_OSSFUZZ`       | Enable OSS-Fuzz build        | `No`    |
| `FLB_TESTS_RUNTIME`       | Enable runtime tests         | `No`    |
| `FLB_TRACE`               | Enable trace mode            | `No`    |
| `FLB_VALGRIND`            | Enable Valgrind support      | `No`    |

### Optimization options

| Option                                    | Description                                                                                              | Default |
|:------------------------------------------|:---------------------------------------------------------------------------------------------------------|:--------|
| `FLB_MSGPACK_TO_JSON_INIT_BUFFER_SIZE`    | Determine initial buffer size for `msgpack` to `json` conversion in terms of memory used by payload.     | `2.0`   |
| `FLB_MSGPACK_TO_JSON_REALLOC_BUFFER_SIZE` | Determine percentage of reallocation size when `msgpack` to `json` conversion buffer runs out of memory. | `0.1`   |

### Input plugins

Input plugins gather information from a specific source type like network interfaces, some built-in metrics, or through a specific input device. 

The following input plugins are available:

| Option                                                                                      | Description                                                               | Default |
|:--------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------|:--------|
| [`FLB_IN_BLOB`](../../../pipeline/inputs/blob.md)                                           | Enable Blob input plugin                                                  | `On`    |
| [`FLB_IN_COLLECTD`](../../../pipeline/inputs/collectd.md)                                   | Enable Collectd input plugin                                              | `On`    |
| [`FLB_IN_CPU`](../../../pipeline/inputs/cpu-metrics.md)                                     | Enable CPU input plugin                                                   | `On`    |
| [`FLB_IN_DISK`](../../../pipeline/inputs/disk-io-metrics.md)                                | Enable Disk I/O Metrics input plugin                                      | `On`    |
| [`FLB_IN_DOCKER`](../../../pipeline/inputs/docker-metrics.md)                               | Enable Docker input plugin                                                | `On`    |
| [`FLB_IN_DOCKER_EVENTS`](../../../pipeline/inputs/docker-events.md)                         | Enable Docker events input plugin                                         | `On`    |
| [`FLB_IN_DUMMY`](../../../pipeline/inputs/dummy.md)                                         | Enable Dummy input plugin                                                 | `On`    |
| [`FLB_IN_EBPF`](../../../pipeline/inputs/ebpf.md)                                           | Enable Linux eBPF input plugin                                            | `Off`   |
| [`FLB_IN_ELASTICSEARCH`](../../../pipeline/inputs/elasticsearch.md)                         | Enable Elasticsearch (Bulk API) input plugin                              | `On`    |
| [`FLB_IN_EXEC`](../../../pipeline/inputs/exec.md)                                           | Enable Exec input plugin                                                  | `On`    |
| [`FLB_IN_EXEC_WASI`](../../../pipeline/inputs/exec-wasi.md)                                 | Enable Exec WASI input plugin                                             | `On`    |
| [`FLB_IN_FLUENTBIT_METRICS`](../../../pipeline/inputs/fluentbit-metrics.md)                 | Enable Fluent Bit metrics input plugin                                    | `On`    |
| [`FLB_IN_FORWARD`](../../../pipeline/inputs/forward.md)                                     | Enable Forward input plugin                                               | `On`    |
| [`FLB_IN_GPU_METRICS`](../../../pipeline/inputs/gpu-metrics.md)                             | Enable GPU metrics input plugin                                           | `On`    |
| [`FLB_IN_HEAD`](../../../pipeline/inputs/head.md)                                           | Enable Head input plugin                                                  | `On`    |
| [`FLB_IN_HEALTH`](../../../pipeline/inputs/health.md)                                       | Enable Health input plugin                                                | `On`    |
| [`FLB_IN_HTTP`](../../../pipeline/inputs/http.md)                                           | Enable HTTP input plugin                                                  | `On`    |
| [`FLB_IN_KAFKA`](../../../pipeline/inputs/kafka.md)                                         | Enable Kafka input plugin                                                 | `On`    |
| [`FLB_IN_KMSG`](../../../pipeline/inputs/kernel-logs.md)                                    | Enable Kernel log input plugin                                            | `On`    |
| [`FLB_IN_KUBERNETES_EVENTS`](../../../pipeline/inputs/kubernetes-events.md)                 | Enable Kubernetes Events input plugin                                     | `On`    |
| [`FLB_IN_MEM`](../../../pipeline/inputs/memory-metrics.md)                                  | Enable Memory input plugin                                                | `On`    |
| [`FLB_IN_MQTT`](../../../pipeline/inputs/mqtt.md)                                           | Enable MQTT Broker input plugin                                           | `On`    |
| [`FLB_IN_NETIF`](../../../pipeline/inputs/network-io-metrics.md)                            | Enable Network I/O metrics input plugin                                   | `On`    |
| [`FLB_IN_NGINX_EXPORTER_METRICS`](../../../pipeline/inputs/nginx.md)                        | Enable NGINX metrics input plugin                                         | `On`    |
| [`FLB_IN_NODE_EXPORTER_METRICS`](../../../pipeline/inputs/node-exporter-metrics.md)         | Enable Node exporter metrics input plugin                                 | `On`    |
| [`FLB_IN_OPENTELEMETRY`](../../../pipeline/inputs/opentelemetry.md)                         | Enable OpenTelemetry input plugin                                         | `On`    |
| [`FLB_IN_NODE_EXPORTER_METRICS`](../../../pipeline/inputs/node-exporter-metrics.md)         | Enable Node exporter metrics input plugin                                 | `On`    |
| [`FLB_IN_PODMAN_METRICS`](../../../pipeline/inputs/podman-metrics.md)                       | Enable Podman metrics input plugin                                        | `On`    |
| [`FLB_IN_PROC`](../../../pipeline/inputs/process.md)                                        | Enable Process input plugin                                               | `On`    |
| [`FLB_IN_PROCESS_EXPORTER_METRICS`](../../../pipeline/inputs/process-exporter-metrics.md)   | Enable Process exporter metrics input plugin                              | `On`    |
| [`FLB_IN_PROMETHEUS_REMOTE_WRITE`](../../../pipeline/inputs/prometheus-remote-write.md)     | Enable Prometheus remote write input plugin                               | `On`    |
| [`FLB_IN_PROMETHEUS_SCRAPE_METRICS`](../../../pipeline/inputs/prometheus-scrape-metrics.md) | Enable Prometheus scrape metrics input plugin                             | `On`    |
| [`FLB_IN_PROMETHEUS_REMOTE_WRITE`](../../../pipeline/inputs/prometheus-textfile.md)         | Enable Prometheus textfile input plugin                                   | `On`    |
| [`FLB_IN_RANDOM`](../../../pipeline/inputs/random.md)                                       | Enable Random input plugin                                                | `On`    |
| [`FLB_IN_SERIAL`](../../../pipeline/inputs/serial-interface.md)                             | Enable Serial input plugin                                                | `On`    |
| [`FLB_IN_SPLUNK`](../../../pipeline/inputs/splunk.md)                                       | Enable Serial input plugin                                                | `On`    |
| [`FLB_IN_STATSD`](../../../pipeline/inputs/statsd.md)                                       | Enable Statsd input plugin                                                | `On`    |
| [`FLB_IN_STDIN`](../../../pipeline/inputs/standard-input.md)                                | Enable Standard input plugin                                              | `On`    |
| [`FLB_IN_SYSLOG`](../../../pipeline/inputs/syslog.md)                                       | Enable Syslog input plugin                                                | `On`    |
| [`FLB_IN_SYSTEMD`](../../../pipeline/inputs/systemd.md)                                     | Enable Systemd input plugin                                               | `On`    |
| [`FLB_IN_TAIL`](../../../pipeline/inputs/tail.md)                                           | Enable Tail input plugin                                                  | `On`    |
| [`FLB_IN_TCP`](../../../pipeline/inputs/tcp.md)                                             | Enable TCP input plugin                                                   | `On`    |
| [`FLB_IN_THERMAL`](../../../pipeline/inputs/thermal.md)                                     | Enable Thermal input plugin                                               | `On`    |
| [`FLB_IN_UDP`](../../../pipeline/inputs/udp.md)                                             | Enable UDP input plugin                                                   | `On`    |
| [`FLB_IN_WINLOG`](../../../pipeline/inputs/windows-event-log.md)                            | Enable Windows Event Log input plugin (Windows Only)                      | `Off`   |
| [`FLB_IN_WINEVTLOG`](../../../pipeline/inputs/windows-event-log-winevtlog.md)               | Enable Windows Event Log input plugin using `winevt.h` API (Windows Only) | `Off`   |
| [`FLB_IN_WINDOWS_EXPORTER_METRICS`](../../../pipeline/inputs/windows-exporter-metrics.md)   | Enable Windows exporter metrics input plugin                              | `On`    |
| [`FLB_IN_WINSTAT`](../../../pipeline/inputs/windows-system-statistics.md)                   | Enable Windows system statistics input plugin                             | `Off`   |


### Processor plugins

Processor plugins handle the events within the processor pipelines to allow modifying, enriching, or dropping events.

The following table describes the processors available:

| Option                                                                                           | Description                                 | Default |
|:-------------------------------------------------------------------------------------------------|:--------------------------------------------|:--------|
| [`FLB_PROCESSOR_CONTENT_MODIFIER`](../../../pipeline/processors/content-modifier.md)             | Enable content modifier processor           | `On`    |
| [`FLB_PROCESSOR_LABELS`](../../../pipeline/processors/labels.md)                                 | Enable metrics label manipulation processor | `On`    |
| [`FLB_PROCESSOR_METRICS_SELECTOR`](../../../pipeline/processors/metrics-selector.md)             | Enable metrics selector processor           | `On`    |
| [`FLB_PROCESSOR_OPENTELEMETRY_ENVELOPE`](../../../pipeline/processors/opentelemetry-envelope.md) | Enable OpenTelemetry envelope processor     | `On`    |
| [`FLB_PROCESSOR_SAMPLING`](../../../pipeline/processors/sampling.md)                             | Enable sampling processor                   | `On`    |
| [`FLB_PROCESSOR_SQl`](../../../pipeline/processors/sql.md)                                       | Enable SQL processor                        | `On`    |

### Filter plugins

Filter plugins let you modify, enrich or drop records. 

The following table describes the filters available on this version:

| Option                                                                       | Description                        | Default |
|:-----------------------------------------------------------------------------|:-----------------------------------|:--------|
| [`FLB_FILTER_AWS`](../../../pipeline/filters/aws-metadata.md)                | Enable AWS metadata filter         | `On`    |
| [`FLB_FILTER_CHECKLIST`](../../../pipeline/filters/checklist.md)             | Enable Checklist filter            | `On`    |
| [`FLB_FILTER_ECS`](../../../pipeline/filters/ecs-metadata.md)                | Enable AWS ECS metadata filter     | `On`    |
| [`FLB_FILTER_EXPECT`](../../../pipeline/filters/expect.md)                   | Enable Expect data test filter     | `On`    |
| [`FLB_FILTER_GIOIP2`](../../../pipeline/filters/geoip2-filter.md)            | Enable Geoip2 filter               | `On`    |
| [`FLB_FILTER_GREP`](../../../pipeline/filters/grep.md)                       | Enable Grep filter                 | `On`    |
| [`FLB_FILTER_KUBERNETES`](../../../pipeline/filters/kubernetes.md)           | Enable Kubernetes metadata filter  | `On`    |
| [`FLB_FILTER_LOG_TO_METRICS`](../../../pipeline/filters/log_to_metrics.md)   | Enable Log derived metrics filter  | `On`    |
| [`FLB_FILTER_LUA`](../../../pipeline/filters/lua.md)                         | Enable Lua scripting filter        | `On`    |
| [`FLB_FILTER_MODIFY`](../../../pipeline/filters/modify.md)                   | Enable Modify filter               | `On`    |
| [`FLB_FILTER_MULTILINE`](../../../pipeline/filters/multiline-stacktrace.md)  | Enable Multiline stacktrace filter | `On`    |
| [`FLB_FILTER_NEST`](../../../pipeline/filters/nest.md)                       | Enable Nest filter                 | `On`    |
| [`FLB_FILTER_NIGHTFALL`](../../../pipeline/filters/nightfall.md)             | Enable Nightfall filter            | `On`    |
| [`FLB_FILTER_PARSER`](../../../pipeline/filters/parser.md)                   | Enable Parser filter               | `On`    |
| [`FLB_FILTER_RECORD_MODIFIER`](../../../pipeline/filters/record-modifier.md) | Enable Record Modifier filter      | `On`    |
| [`FLB_FILTER_REWRITE_TAG`](../../../pipeline/filters/rewrite-tag.md)         | Enable Rewrite Tag filter          | `On`    |
| [`FLB_FILTER_STDOUT`](../../../pipeline/filters/standard-output.md)          | Enable Stdout filter               | `On`    |
| [`FLB_FILTER_SYSINFO`](../../../pipeline/filters/sysinfo.md)                 | Enable Sysinfo filter              | `On`    |
| [`FLB_FILTER_TYPE_TENSORFLOW`](../../../pipeline/filters/tensorflow.md)      | Enable Tensorflow filter           | `Off`   |
| [`FLB_FILTER_THROTTLE`](../../../pipeline/filters/throttle.md)               | Enable Throttle filter             | `On`    |
| [`FLB_FILTER_TYPE_CONVERTER`](../../../pipeline/filters/type-converter.md)   | Enable Type Converter filter       | `On`    |
| [`FLB_FILTER_WASM`](../../../pipeline/filters/wasm.md)                       | Enable Wasm filter                 | `On`    |

### Output plugins

Output plugins let you flush the information to some external interface, service, or terminal. 

The following table describes the output plugins available:

| Option                                                                                   | Description                                              | Default |
|:-----------------------------------------------------------------------------------------|:---------------------------------------------------------|:--------|
| [`FLB_OUT_AZURE`](../../../pipeline/outputs/azure.md)                                    | Enable Microsoft Azure output plugin                     | `On`    |
| [`FLB_OUT_AZURE_BLOB`](../../../pipeline/outputs/azure_blob.md)                          | Enable Microsoft Azure storage blob output plugin        | `On`    |
| [`FLB_OUT_AZURE_KUSTO`](../../../pipeline/outputs/azure_kusto.md)                        | Enable Azure Data Explorer (Kusto) output plugin         | `On`    |
| [`FLB_OUT_AZURE_LOGS_INGESTION`](../../../pipeline/outputs/azure_logs_ingestion.md)      | Enable Azure Log Ingestion output plugin                 | `On`    |
| [`FLB_OUT_BIGQUERY`](../../../pipeline/outputs/bigquery.md)                              | Enable Google BigQuery output plugin                     | `On`    |
| [`FLB_OUT_CHRONICLE`](../../../pipeline/outputs/chronicle.md)                            | Enable Google Chronicle output plugin                    | `On`    |
| [`FLB_OUT_CLOUDWATCH_LOGS`](../../../pipeline/outputs/cloudwatch.md)                     | Enable Amazon CloudWatch output plugin                   | `On`    |
| [`FLB_OUT_COUNTER`](../../../pipeline/outputs/counter.md)                                | Enable Counter output plugin                             | `On`    |
| [`FLB_OUT_DATADOG`](../../../pipeline/outputs/datadog.md)                                | Enable Datadog output plugin                             | `On`    |
| [`FLB_OUT_ES`](../../../pipeline/outputs/elasticsearch.md)                               | Enable Elastic Search output plugin                      | `On`    |
| [`FLB_OUT_EXIT`](../../../pipeline/outputs/exit.md)                                      | Enable Exit output plugin                                | `On`    |
| [`FLB_OUT_FILE`](../../../pipeline/outputs/file.md)                                      | Enable File output plugin                                | `On`    |
| [`FLB_OUT_FLOWCOUNTER`](../../../pipeline/outputs/flowcounter.md)                        | Enable Flow counter output plugin                        | `On`    |
| [`FLB_OUT_FORWARD`](../../../pipeline/outputs/forward.md)                                | Enable [Fluentd](http://www.fluentd.org) output plugin   | `On`    |
| [`FLB_OUT_GELF`](../../../pipeline/outputs/gelf.md)                                      | Enable GELF output plugin                                | `On`    |
| [`FLB_OUT_HTTP`](../../../pipeline/outputs/http.md)                                      | Enable HTTP output plugin                                | `On`    |
| [`FLB_OUT_INFLUXDB`](../../../pipeline/outputs/influxdb.md)                              | Enable InfluxDB output plugin                            | `On`    |
| [`FLB_OUT_KAFKA`](../../../pipeline/outputs/kafka.md)                                    | Enable Kafka output                                      | `On`    |
| [`FLB_OUT_KAFKA_REST`](../../../pipeline/outputs/kafka-rest-proxy.md)                    | Enable Kafka REST Proxy output plugin                    | `On`    |
| [`FLB_OUT_KINESIS_FIREHOSE`](../../../pipeline/outputs/firehose.md)                      | Enable Amazon Kinesis Data Firehose output plugin        | `On`    |
| [`FLB_OUT_KINESIS_STREAMS`](../../../pipeline/outputs/kinesis.md)                        | Enable Amazon Kinesis Data Streams output plugin         | `On`    |
| [`FLB_OUT_LIB`](../../../pipeline/outputs/library.md)                                    | Enable Library output plugin                             | `On`    |
| [`FLB_OUT_LOGDNA`](../../../pipeline/outputs/logdna.md)                                  | Enable LogDNA output plugin                              | `On`    |
| [`FLB_OUT_LOKI`](../../../pipeline/outputs/loki.md)                                      | Enable Loki output plugin                                | `On`    |
| [`FLB_OUT_NATS`](../../../pipeline/outputs/nats.md)                                      | Enable NATS output plugin                                | `On`    |
| [`FLB_OUT_NRLOGS`](../../../pipeline/outputs/new-relic.md)                               | Enable New Relic output plugin                           | `On`    |
| [`FLB_OUT_NULL`](../../../pipeline/outputs/null.md)                                      | Enable `NULL` output plugin                                | `On`    |
| [`FLB_OUT_OPENSEARCH`](../../../pipeline/outputs/opensearch.md)                          | Enable OpenSearch output plugin                          | `On`    |
| [`FLB_OUT_OPENTELEMETRY`](../../../pipeline/outputs/opentelemetry.md)                    | Enable OpenTelemetry output plugin                       | `On`    |
| [`FLB_OUT_ORACLE_LOG_ANALYTICS`](../../../pipeline/outputs/oci-logging-analytics.md)     | Enable Oracle Cloud Infrastructure Logging output plugin | `On`    |
| [`FLB_OUT_PGSQL`](../../../pipeline/outputs/postgresql.md)                               | Enable PostgreSQL output plugin                          | `Off`   |
| [`FLB_OUT_PLOT`](../../../pipeline/outputs/plot.md)                                      | Enable Plot output plugin                                | `On`    |
| [`FLB_OUT_PROMETHEUS_EXPORTER`](../../../pipeline/inputs/prometheus-exporter.md)         | Enable Prometheus exporter output plugin                 | `On`    |
| [`FLB_OUT_PROMETHEUS_REMOTE_WRITE`](../../../pipeline/inputs/prometheus-remote-write.md) | Enable Prometheus remote write output plugin             | `On`    |
| [`FLB_OUT_S3`](../../../pipeline/outputs/s3.md)                                          | Enable Amazon S3 output plugin                           | `On`    |
| [`FLB_OUT_SKYWALKING`](../../../pipeline/outputs/skywalking.md)                          | Enable Apache Skywalking output plugin                   | `On`    |
| [`FLB_OUT_SLACK`](../../../pipeline/outputs/slack.md)                                    | Enable Slack output plugin                               | `On`    |
| [`FLB_OUT_SPLUNK`](../../../pipeline/outputs/splunk.md)                                  | Enable Splunk output plugin                              | `On`    |
| [`FLB_OUT_STACKDRIVER`](../../../pipeline/outputs/stackdriver.md)                        | Enable Stackdriver output plugin                         | `On`    |
| [`FLB_OUT_STDOUT`](../../../pipeline/outputs/standard-output.md)                         | Enable STDOUT output plugin                              | `On`    |
| [`FLB_OUT_SYSLOG`](../../../pipeline/outputs/syslog.md)                                  | Enable Syslog output plugin                              | `On`    |
| [`FLB_OUT_TD`](../../../pipeline/outputs/treasure-data.md)                               | Enable Treasure Data output plugin                       | `On`    |
| [`FLB_OUT_TCP`](../../../pipeline/outputs/tcp-and-tls.md)                                | Enable TCP/TLS output plugin                             | `On`    |
| [`FLB_OUT_UDP`](../../../pipeline/outputs/udp.md)                                        | Enable UDP output plugin                                 | `On`    |
| [`FLB_OUT_VIVO_EXPORTER`](../../../pipeline/outputs/vivo-exporter.md)                    | Enable Vivo exporter output plugin                       | `On`    |
| [`FLB_OUT_WEBSOCKET`](../../../pipeline/outputs/udp.md)                                  | Enable UDP output plugin                                 | `On`    |
