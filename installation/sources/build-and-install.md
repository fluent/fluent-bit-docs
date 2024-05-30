# Build and Install

[Fluent Bit](http://fluentbit.io) uses [CMake](http://cmake.org) as its build system. The suggested procedure to prepare the build system consists of the following steps:

## Requirements

- CMake >= 3.12
- Flex
- Bison >= 3
- YAML headers
- OpenSSL headers

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

Fluent Bit provides options to CMake that you can enable or disable when configuring.
Refer to the following tables in the **General Options**, **Development Options**,
**Input Plugins** and **Output Plugins** sections.

### General Options

| option | description | default |
| :--- | :--- | :--- |
| FLB_ALL | Enable all features available | No |
| FLB_ARROW | Build with Apache Arrow support | No |
| FLB_AVRO_ENCODER | Build with Avro encoding support | No |
| FLB_AWS | Enable AWS support | Yes |
| FLB_AWS_ERROR_REPORTER | Build with aws error reporting support | No |
| FLB_BINARY | Build executable | Yes |
| FLB_CONFIG_YAML | Enable YAML configuration support | Yes |
| FLB_CUSTOM_CALYPTIA | Enable Calyptia Support | Yes |
| FLB_EXAMPLES | Build examples | Yes |
| FLB_HTTP_SERVER | Enable HTTP Server | No |
| FLB_INOTIFY | Enable Inotify support | Yes |
| FLB_JEMALLOC | Use Jemalloc as default memory allocator | No |
| FLB_LUAJIT | Enable Lua scripting support | Yes |
| FLB_METRICS | Enable metrics support | Yes |
| FLB_MTRACE | Enable mtrace support | No |
| FLB_PARSER | Build with Parser support | Yes |
| FLB_POSIX_TLS | Force POSIX thread storage | No |
| FLB_PROXY_GO | Enable Go plugins support | Yes |
| FLB_RECORD_ACCESSOR | Enable record accessor | Yes |
| FLB_REGEX | Build with Regex support | Yes |
| FLB_RELEASE | Build with release mode (-O2 -g -DNDEBUG) | No |
| FLB_RUN_LDCONFIG | Enable execution of ldconfig after installation | No |
| FLB_SHARED_LIB | Build shared library | Yes |
| FLB_SIGNV4 | Enable AWS Signv4 support | Yes |
| FLB_SQLDB | Enable SQL embedded database support | No |
| FLB_STATIC_CONF | Build binary using static configuration files. The value of this option must be a directory containing configuration files. |  |
| FLB_STREAM_PROCESSOR | Enable Stream Processor | Yes |
| FLB_TLS | Build with SSL/TLS support | Yes |
| FLB_UTF8_ENCODER | Build with UTF8 encoding support | Yes |
| FLB_WASM | Build with WASM runtime support | Yes |
| FLB_WASM_STACK_PROTECT | Build with WASM runtime with strong stack protector flags | No |
| FLB_WAMRC | Build with WASM AOT compiler executable | No |
| FLB_WINDOWS_DEFAULTS | Build with predefined Windows settings | Yes |

### Development Options

| option | description | default |
| :--- | :--- | :--- |
| FLB_BACKTRACE | Enable backtrace/stacktrace support | Yes |
| FLB_CHUNK_TRACE | Enable chunk traces | Yes |
| FLB_CORO_STACK_SIZE | Set coroutine stack size | |
| FLB_COVERAGE | Build with code-coverage | No |
| FLB_DEBUG | Build binaries with debug symbols | No |
| FLB_HTTP_CLIENT_DEBUG | Enable HTTP Client debug callbacks | No |
| FLB_SMALL | Minimise binary size | No |
| FLB_TESTS | Enable tests | No |
| FLB_TESTS_RUNTIME | Enable runtime tests | No |
| FLB_TESTS_INTERNAL | Enable internal tests | No |
| FLB_TESTS_INTERNAL_FUZZ | Enable internal fuzz tests | No |
| FLB_TESTS_OSSFUZZ | Enable OSS-Fuzz build | No |
| FLB_TRACE | Enable trace mode | No |
| FLB_VALGRIND | Enable Valgrind support | No |

### Optimization Options

| option | description | default |
| :--- | :--- | :--- |
| FLB_MSGPACK_TO_JSON_INIT_BUFFER_SIZE | Determine initial buffer size for msgpack to json conversion in terms of memory used by payload. | 2.0 |
| FLB_MSGPACK_TO_JSON_REALLOC_BUFFER_SIZE | Determine percentage of reallocation size when msgpack to json conversion buffer runs out of memory. | 0.1 |

### Input Plugins

The _input plugins_ provides certain features to gather information from a specific source type which can be a network interface, some built-in metric or through a specific input device, the following input plugins are available:

| option | description | default |
| :--- | :--- | :--- |
| FLB_IN_CALYPTIA_FLEET | Enable Calyptia Fleet input plugin | Yes |
| [FLB_IN_COLLECTD](../../pipeline/inputs/collectd.md) | Enable Collectd input plugin | On |
| [FLB_IN_CPU](../../pipeline/inputs/cpu-metrics.md) | Enable CPU input plugin | On |
| [FLB_IN_DISK](../../pipeline/inputs/disk-io-metrics.md) | Enable Disk I/O Metrics input plugin | On |
| [FLB_IN_DOCKER](../../pipeline/inputs/docker-metrics.md) | Enable Docker metrics input plugin | On |
| [FLB_IN_DOCKER_EVENTS](../../pipeline/inputs/docker-events.md) | Enable Docker events input plugin | Yes |
| [FLB_IN_DUMMY](../../pipeline/inputs/dummy.md) | Enable Dummy input plugin | Yes |
| [FLB_IN_ELASTICSEARCH](../../pipeline/inputs/elasticsearch.md) | Enable Elasticsearch (Bulk API) input plugin | Yes |
| FLB_IN_EMITTER | Enable emitter input plugin | Yes |
| FLB_IN_EVENT_TEST | Enable event test plugin | No |
| FLB_IN_EVENT_TYPE | Enable event type plugin | Yes |
| [FLB_IN_EXEC](../../pipeline/inputs/exec.md) | Enable Exec input plugin | On |
| [FLB_IN_EXEC_WASI](../../pipeline/inputs/exec-wasi.md) | Enable Exec WASI input plugin | On |
| [FLB_IN_FLUENTBIT_METRICS](../../pipeline/inputs/fluentbit-metrics.md) | Enable Fluent Bit metrics input plugin | On |
| [FLB_IN_ELASTICSEARCH](../../pipeline/inputs/elasticsearch.md) | Enable Elasticsearch/OpenSearch Bulk input plugin | On |
| [FLB_IN_FORWARD](../../pipeline/inputs/forward.md) | Enable Forward input plugin | On |
| [FLB_IN_HEAD](../../pipeline/inputs/head.md) | Enable Head input plugin | On |
| [FLB_IN_HEALTH](../../pipeline/inputs/health.md) | Enable Health input plugin | On |
| [FLB_IN_HTTP](../../pipeline/inputs/http.md) | Enable HTTP input plugin | Yes |
| [FLB_IN_KAFKA](../../pipeline/inputs/kafka.md) | Enable Kafka input plugin | Yes |
| [FLB_IN_KMSG](../../pipeline/inputs/kernel-logs.md) | Enable Kernel log input plugin | On |
| [FLB_IN_KUBERNETES_EVENTS](../../pipeline/inputs/kubernetes-events.md) | Enable Kubernetes Events plugin | Yes |
| FLB_IN_LIB | Enable library mode input plugin | Yes |
| [FLB_IN_MEM](../../pipeline/inputs/memory-metrics.md) | Enable Memory input plugin | On |
| [FLB_IN_MQTT](../../pipeline/inputs/mqtt.md) | Enable MQTT Server input plugin | On |
| [FLB_IN_NETIF](../../pipeline/inputs/network-io-metrics.md) | Enable Network I/O metrics input plugin | On |
| [FLB_IN_NGINX_EXPORTER_METRICS](../../pipeline/inputs/nginx.md) | Enable Nginx Metrics input plugin | Yes |
| [FLB_IN_NODE_EXPORTER_METRICS](../../pipeline/inputs/node-export-metrics.md) | Enable node exporter metrics input plugin | Yes |
| [FLB_IN_OPENTELEMETRY](../../pipeline/inputs/opentelemetry.md) | Enable OpenTelemetry input plugin | Yes |
| [FLB_IN_PODMAN_METRICS](../../pipeline/inputs/podman-metrics.md) | Enable Podman Metrics input plugin | Yes |
| [FLB_IN_PROC](../../pipeline/inputs/process.md) | Enable Process monitoring input plugin | On |
| [FLB_IN_PROCESS_EXPORTER_METRICS](../../pipeline/inputs/prometheus-exporter-metrics.md) | Enable process exporter metrics input plugin | Yes |
| [FLB_IN_PROMETHEUS_REMOTE_WRITE](../../pipeline/inputs/prometheus-remote-write.md) | Enable prometheus remote write input plugin | Yes |
| [FLB_IN_PROMETHEUS_SCRAPE](../../pipeline/inputs/prometheus-scrape-metrics.md) | Enable Promeheus Scrape input plugin | Yes |
| [FLB_IN_RANDOM](../../pipeline/inputs/random.md) | Enable Random input plugin | On |
| [FLB_IN_SERIAL](../../pipeline/inputs/serial-interface.md) | Enable Serial input plugin | On |
| [FLB_IN_SPLUNK](../../pipeline/inputs/splunk.md) | Enable Splunk HTTP HEC input plugin | Yes |
| [FLB_IN_STATSD](../../pipeline/inputs/statds.md) | Enable StatsD input plugin | Yes |
| [FLB_IN_STDIN](../../pipeline/inputs/standard-input.md) | Enable Standard input plugin | On |
| FLB_IN_STORAGE_BACKLOG | Enable storage backlog input plugin | Yes |
| [FLB_IN_SYSLOG](../../pipeline/inputs/syslog.md) | Enable Syslog input plugin | On |
| [FLB_IN_SYSTEMD](../../pipeline/inputs/systemd.md) | Enable Systemd / Journald input plugin | On |
| [FLB_IN_TAIL](../../pipeline/inputs/tail.md) | Enable Tail \(follow files\) input plugin | On |
| [FLB_IN_TCP](../../pipeline/inputs/tcp.md) | Enable TCP input plugin | On |
| [FLB_IN_THERMAL](../../pipeline/inputs/thermal.md) | Enable system temperature\(s\) input plugin | On |
| [FLB_IN_UDP](../../pipeline/inputs/udp.md) | Enable UDP input plugin | On |
| FLB_IN_UNIX_SOCKET | Enable Unix socket input plugin | No |
| [FLB_IN_WINDOWS_EXPORTER_METRICS](../../pipeline/inputs/windows-exporter-metrics.md) | Enable windows exporter metrics input plugin | Yes |
| [FLB_IN_WINLOG](../../pipeline/inputs/windows-event-log.md) | Enable Windows Event Log input plugin \(Windows Only\) | On |
| [FLB_IN_WINEVTLOG](../../pipeline/inputs/windows-event-log-winevtlog.md) | Enable Windows Event Log input plugin using winevt.h API \(Windows Only\) | On |
| FLB_IN_WINSTAT | Enable Windows Stat input plugin | No |

### Filter Plugins

The _filter plugins_ allows to modify, enrich or drop records. The following table describes the filters available on this version:

| option | description | default |
| :--- | :--- | :--- |
| [FLB_FILTER_AWS](../../pipeline/filters/aws-metadata.md) | Enable AWS metadata filter | On |
| [FLB_FILTER_CHECKLIST](../../pipeline/filters/checklist.md) | Enable checklist filter | On |
| [FLB_FILTER_ECS](../../pipeline/filters/ecs-metadata.md) | Enable AWS metadata filter | On |
| [FLB_FILTER_EXPECT](../../pipeline/filters/expect.md) | Enable Expect data test filter | On |
| [FLB_FILTER_GEOIP2](../../pipeline/filters/geoip2-filter.md) | Enable geoip2 filter | Yes |
| [FLB_FILTER_GREP](../../pipeline/filters/grep.md) | Enable Grep filter | On |
| [FLB_FILTER_KUBERNETES](../../pipeline/filters/kubernetes.md) | Enable Kubernetes metadata filter | On |
| [FLB_FILTER_LOG_TO_METRICS](../../pipeline/filters/log_to_metrics.md) | Enable log-derived metrics filter | Yes |
| [FLB_FILTER_LUA](../../pipeline/filters/lua.md) | Enable Lua scripting filter | On |
| [FLB_FILTER_MODIFY](../../pipeline/filters/modify.md) | Enable Modify filter | On |
| [FLB_FILTER_MULTILINE](../../pipeline/filters/multiline-stacktrace.md) | Enable multiline filter | Yes |
| [FLB_FILTER_NEST](../../pipeline/filters/nest.md) | Enable Nest filter | On |
| [FLB_FILTER_NIGHTFALL](../../pipeline/filters/nightfall.md) | Enable Nightfall filter | Yes |
| [FLB_FILTER_PARSER](../../pipeline/filters/parser.md) | Enable Parser filter | On |
| [FLB_FILTER_RECORD_MODIFIER](../../pipeline/filters/record-modifier.md) | Enable Record Modifier filter | On |
| [FLB_FILTER_REWRITE_TAG](../../pipeline/filters/rewrite-tag.md) | Enable Rewrite Tag filter | On |
| [FLB_FILTER_STDOUT](../../pipeline/filters/standard-output.md) | Enable Stdout filter | On |
| [FLB_FILTER_SYSINFO](../../pipeline/filters/sysinfo.md) | Enable Sysinfo filter | On |
| [FLB_FILTER_TENSORFLOW](../../pipeline/filters/tensorflow.md) | Enable tensorflow filter | No |
| [FLB_FILTER_THROTTLE](../../pipeline/filters/throttle.md) | Enable Throttle filter | On |
| [FLB_FILTER_TYPE_CONVERTER](../../pipeline/filters/type-converter.md) | Enable Type Converter filter | On |
| [FLB_FILTER_WASM](../../pipeline/filters/wasm.md) | Enable WASM filter | On |

### Output Plugins

The _output plugins_ gives the capacity to flush the information to some external interface, service or terminal, the following table describes the output plugins available as of this version:

| option | description | default |
| :--- | :--- | :--- |
| [FLB_OUT_AZURE](../../pipeline/outputs/azure.md) | Enable Microsoft Azure output plugin | On |
| [FLB_OUT_AZURE_BLOB](../../pipeline/outputs/azure_blob.md) | Enable Azure output plugin | Yes |
| [FLB_OUT_AZURE_KUSTO](../../pipeline/outputs/azure_kusto.md) | Enable Azure Kusto output plugin | On |
| [FLB_OUT_AZURE_LOGS_INGESTION](../../pipeline/outputs/azure_logs_ingestion.md) | Enable Azure Logs Ingestion output plugin | Yes |
| [FLB_OUT_BIGQUERY](../../pipeline/outputs/bigquery.md) | Enable Google BigQuery output plugin | On |
| FLB_OUT_CALYPTIA | Enable Calyptia monitoring plugin | Yes |
| [FLB_OUT_CHRONICLE](../../pipeline/outputs/chronicle.md) | Enable Google Chronicle output plugin | Yes |
| [FLB_OUT_CLOUDWATCH_LOGS](../../pipeline/outputs/cloudwatch.md) | Enable Amazon CloudWatch output plugin | On |
| [FLB_OUT_COUNTER](../../pipeline/outputs/counter.md) | Enable Counter output plugin | On |
| [FLB_OUT_DATADOG](../../pipeline/outputs/datadog.md) | Enable Datadog output plugin | On |
| [FLB_OUT_ES](../../pipeline/outputs/elasticsearch.md) | Enable [Elastic Search](http://www.elastic.co) output plugin | On |
| FLB_OUT_EXIT | Enable Exit output plugin | Yes |
| [FLB_OUT_FILE](../../pipeline/outputs/file.md) | Enable File output plugin | On |
| [FLB_OUT_FLOWCOUNTER](../../pipeline/outputs/flowcounter.md) | Enable Flowcounter output plugin | On |
| [FLB_OUT_FORWARD](../../pipeline/outputs/forward.md) | Enable [Fluentd](http://www.fluentd.org) output plugin | On |
| [FLB_OUT_GELF](../../pipeline/outputs/gelf.md) | Enable Gelf output plugin | On |
| [FLB_OUT_HTTP](../../pipeline/outputs/http.md) | Enable HTTP output plugin | On |
| [FLB_OUT_INFLUXDB](../../pipeline/outputs/influxdb.md) | Enable InfluxDB output plugin | On |
| [FLB_OUT_KAFKA](../../pipeline/outputs/kafka.md) | Enable Kafka output | Off |
| [FLB_OUT_KAFKA_REST](../../pipeline/outputs/kafka-rest-proxy.md) | Enable Kafka REST Proxy output plugin | On |
| [FLB_OUT_KINESIS_FIREHOSE](../../pipeline/outputs/firehose.md) | Enable Amazon Kinesis Data Firehose output plugin | On |
| [FLB_OUT_KINESIS_STREAMS](../../pipeline/outputs/kinesis.md) | Enable Amazon Kinesis Data Streams output plugin | On |
| FLB_OUT_LIB | Enable Lib output plugin | On |
| [FLB_OUT_LOGDNA](../../pipeline/outputs/logdna.md) | Enable LogDNA output plugin | Yes |
| [FLB_OUT_LOKI](../../pipeline/outputs/loki.md) | Enable Loki output plugin | Yes |
| [FLB_OUT_NATS](../../pipeline/outputs/nats.md) | Enable [NATS](http://www.nats.io) output plugin | On |
| [FLB_OUT_NRLOGS](../../pipeline/outputs/new-relic.md) | Enable New Relic output plugin | Yes |
| FLB_OUT_NULL | Enable NULL output plugin | On |
| [FLB_OUT_OPENSEARCH](../../pipeline/outputs/opensearch.md) | Enable OpenSearch output plugin | Yes |
| [FLB_OUT_OPENTELEMETRY](../../pipeline/outputs/opentelemetry.md) | Enable OpenTelemetry plugin | Yes |
| [FLB_OUT_ORACLE_LOG_ANALYTICS](../../pipeline/outputs/oci-logging-analytics.md) | Enable Oracle Cloud Infrastructure Logging analytics plugin | Yes |
| [FLB_OUT_PGSQL](../../pipeline/outputs/postgresql.md) | Enable PostgreSQL output plugin | No |
| FLB_OUT_PLOT | Enable Plot output plugin | Yes |
| [FLB_OUT_PROMETHEUS_EXPORTER](../../pipeline/outputs/prometheus-exporter.md) | Enable Prometheus exporter plugin | Yes |
| [FLB_OUT_PROMETHEUS_REMOTE_WRITE](../../pipeline/outputs/prometheus-remote-write.md) | Enable Prometheus remote write plugin | Yes |
| FLB_OUT_RETRY | Enable Retry test output plugin | No |
| [FLB_OUT_S3](../../pipeline/outputs/s3.md) | Enable Amazon S3 output plugin | On |
| [FLB_OUT_SKYWALKING](../../pipeline/outputs/skywalking.md) | Enable Apache SkyWalking output plugin | Yes |
| [FLB_OUT_SLACK](../../pipeline/outputs/slack.md) | Enable Slack output plugin | On |
| [FLB_OUT_SPLUNK](../../pipeline/outputs/splunk.md) | Enable Splunk output plugin | On |
| [FLB_OUT_STACKDRIVER](../../pipeline/outputs/stackdriver.md) | Enable Google Stackdriver output plugin | On |
| [FLB_OUT_STDOUT](../../pipeline/outputs/standard-output.md) | Enable STDOUT output plugin | On |
| [FLB_OUT_SYSLOG](../../pipeline/outputs/syslog.md) | Enable Syslog output plugin | Yes |
| [FLB_OUT_TCP](../../pipeline/outputs/tcp-and-tls.md) | Enable TCP/TLS output plugin | On |
| [FLB_OUT_TD](../../pipeline/outputs/treasure-data.md) | Enable [Treasure Data](http://www.treasuredata.com) output plugin | On |
| FLB_OUT_UDP | Enable UDP output plugin | Yes |
| [FLB_OUT_VIVO_EXPORTER](../../pipeline/outputs/vivo-exporter.md) | Enabel Vivo exporter output plugin | Yes |
| [FLB_OUT_WEBSOCKET](../../pipeline/outputs/websocket.md) | Enable Websocket output plugin | Yes |

### Processor Plugins

The _processor plugins_ provide the capability to handle the events within the processor pipelines to allow modifying, enrich or drop events. 
The following table describes the processors available on this version:

| option | description | default |
| :--- | :--- | :--- |
| [FLB_PROCESSOR_CONTENT_MODIFIER](../../pipeline/inputs/content-modifier.md) | Enable content modifier processor | Yes |
| FLB_PROCESSOR_LABELS | Enable metrics label manipulation processor | Yes |
| [FLB_PROCESSOR_METRICS_SELECTOR](../../pipeline/processors/metrics-selector.md) | Enable metrics selector processor | On |
| [FLB_PROCESSOR_SQL](../../pipeline/inputs/sql.md) | Enable SQL processor | Yes |
