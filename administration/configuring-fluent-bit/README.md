# Configure Fluent Bit

Fluent Bit supports two configuration formats:

- [YAML](yaml/README.md): Standard configuration format as of v3.2.
- [Classic mode](classic-mode/README.md): To be deprecated at the end of 2026.

## Command line interface

Fluent Bit exposes most of it features through the command line interface. Running the `-h` option you can get a list of the options available:

```shell
$ docker run --rm -it fluent/fluent-bit --help
Usage: /fluent-bit/bin/fluent-bit [OPTION]

Available Options
  -b  --storage_path=PATH specify a storage buffering path
  -c  --config=FILE       specify an optional configuration file
  -d, --daemon            run Fluent Bit in background mode
  -D, --dry-run           dry run
  -f, --flush=SECONDS     flush timeout in seconds (default: 1)
  -C, --custom=CUSTOM     enable a custom plugin
  -i, --input=INPUT       set an input
  -F  --filter=FILTER     set a filter
  -m, --match=MATCH       set plugin match, same as '-p match=abc'
  -o, --output=OUTPUT     set an output
  -p, --prop="A=B"        set plugin configuration property
  -R, --parser=FILE       specify a parser configuration file
  -e, --plugin=FILE       load an external plugin (shared lib)
  -l, --log_file=FILE     write log info to a file
  -t, --tag=TAG           set plugin tag, same as '-p tag=abc'
  -T, --sp-task=SQL       define a stream processor task
  -v, --verbose           increase logging verbosity (default: info)
  -Z, --enable-chunk-traceenable chunk tracing, it can be activated either through the http api or the command line
  --trace-input           input to start tracing on startup.
  --trace-output          output to use for tracing on startup.
  --trace-output-property set a property for output tracing on startup.
  --trace                 setup a trace pipeline on startup. Uses a single line, ie: "input=dummy.0 output=stdout output.format='json'"
  -w, --workdir           set the working directory
  -H, --http              enable monitoring HTTP server
  -P, --port              set HTTP server TCP port (default: 2020)
  -s, --coro_stack_size   set coroutines stack size in bytes (default: 196608)
  -q, --quiet             quiet mode
  -S, --sosreport         support report for Enterprise customers
  -Y, --enable-hot-reload enable for hot reloading
  -W, --disable-thread-safety-on-hot-reloadingdisable thread safety on hot reloading
  -V, --version           show version number
  -h, --help              print this help

Inputs
  blob                    Blob (binary) files
  cpu                     CPU Usage
  mem                     Memory Usage
  thermal                 Thermal
  kmsg                    Kernel Log Buffer
  proc                    Check Process health
  disk                    Diskstats
  systemd                 Systemd (Journal) reader
  netif                   Network Interface Usage
  docker                  Docker containers metrics
  docker_events           Docker events
  podman_metrics          Podman metrics
  process_exporter_metricsProcess Exporter Metrics (Prometheus Compatible)
  node_exporter_metrics   Node Exporter Metrics (Prometheus Compatible)
  kubernetes_events       Kubernetes Events
  kafka                   Kafka consumer input plugin
  fluentbit_metrics       Fluent Bit internal metrics
  prometheus_scrape       Scrape metrics from Prometheus Endpoint
  prometheus_textfile     Read Prometheus metrics from text files
  tail                    Tail files
  dummy                   Generate dummy data
  head                    Head Input
  health                  Check TCP server health
  http                    HTTP
  collectd                collectd input plugin
  statsd                  StatsD input plugin
  opentelemetry           OpenTelemetry
  elasticsearch           HTTP Endpoints for Elasticsearch (Bulk API)
  splunk                  Input plugin for Splunk HEC payloads
  prometheus_remote_write Prometheus Remote Write input
  event_type              Event tests for input plugins
  nginx_metrics           Nginx status metrics
  serial                  Serial input
  stdin                   Standard Input
  syslog                  Syslog
  udp                     UDP
  exec_wasi               Exec WASI Input
  tcp                     TCP
  mqtt                    MQTT, listen for Publish messages
  forward                 Fluentd in-forward
  random                  Random

Processors
  content_modifier        Modify the content of Logs, Metrics and Traces
  labels                  Modifies metrics labels
  metrics_selector        select metrics by specified name
  opentelemetry_envelope  Package log records inside an OpenTelemetry Logs schema
  sampling                Sampling
  sql                     SQL processor

Filters
  alter_size              Alter incoming chunk size
  aws                     Add AWS Metadata
  checklist               Check records and flag them
  ecs                     Add AWS ECS Metadata
  record_modifier         modify record
  sysinfo                 Filter for system info
  throttle                Throttle messages using sliding window algorithm
  type_converter          Data type converter
  kubernetes              Filter to append Kubernetes metadata
  modify                  modify records by applying rules
  multiline               Concatenate multiline messages
  nest                    nest events by specified field values
  parser                  Parse events
  expect                  Validate expected keys and values
  grep                    grep events by specified field values
  rewrite_tag             Rewrite records tags
  log_to_metrics          generate log derived metrics
  lua                     Lua Scripting Filter
  stdout                  Filter events to STDOUT
  geoip2                  add geoip information to records
  nightfall               scans records for sensitive content
  wasm                    WASM program filter

Outputs
  azure                   Send events to Azure HTTP Event Collector
  azure_blob              Azure Blob Storage
  azure_logs_ingestion    Send logs to Log Analytics with Log Ingestion API
  azure_kusto             Send events to Kusto (Azure Data Explorer)
  bigquery                Send events to BigQuery via streaming insert
  counter                 Records counter
  datadog                 Send events to DataDog HTTP Event Collector
  es                      Elasticsearch
  exit                    Exit after a number of flushes (test purposes)
  file                    Generate log file
  forward                 Forward (Fluentd protocol)
  http                    HTTP Output
  influxdb                InfluxDB Time Series
  logdna                  LogDNA
  loki                    Loki
  kafka                   Kafka
  kafka-rest              Kafka REST Proxy
  nats                    NATS Server
  nrlogs                  New Relic
  null                    Throws away events
  opensearch              OpenSearch
  oracle_log_analytics    Oracle log analytics
  plot                    Generate data file for GNU Plot
  pgsql                   PostgreSQL
  skywalking              Send logs into log collector on SkyWalking OAP
  slack                   Send events to a Slack channel
  splunk                  Send events to Splunk HTTP Event Collector
  stackdriver             Send events to Google Stackdriver Logging
  stdout                  Prints events to STDOUT
  syslog                  Syslog
  tcp                     TCP Output
  udp                     UDP Output
  td                      Treasure Data
  flowcounter             FlowCounter
  gelf                    GELF Output
  websocket               Websocket
  cloudwatch_logs         Send logs to Amazon CloudWatch
  kinesis_firehose        Send logs to Amazon Kinesis Firehose
  kinesis_streams         Send logs to Amazon Kinesis Streams
  opentelemetry           OpenTelemetry
  prometheus_exporter     Prometheus Exporter
  prometheus_remote_write Prometheus remote write
  s3                      Send to S3
  vivo_exporter           Vivo Exporter
  chronicle               Send logs to Google Chronicle as unstructured log

Internal
 Event Loop  = epoll
 Build Flags = FLB_HAVE_SYS_WAIT_H FLB_HAVE_SIMD FLB_HAVE_IN_STORAGE_BACKLOG FLB_HAVE_CHUNK_TRACE FLB_HAVE_PARSER FLB_HAVE_RECORD_ACCESSOR FLB_HAVE_STREAM_PROCESSOR FLB_HAVE_UNICODE_ENCODER NGHTTP2_STATICLIB JSMN_PARENT_LINKS JSMN_STRICT FLB_EVENT_LOOP_AUTO_DISCOVERY FLB_HAVE_TLS FLB_HAVE_OPENSSL FLB_HAVE_METRICS FLB_HAVE_PROFILES FLB_HAVE_WASM FLB_HAVE_KAFKA_SASL FLB_HAVE_KAFKA_OAUTHBEARER FLB_HAVE_AWS_MSK_IAM FLB_HAVE_AWS FLB_HAVE_AWS_CREDENTIAL_PROCESS FLB_HAVE_SIGNV4 FLB_HAVE_SQLDB FLB_LOG_NO_CONTROL_CHARS FLB_HAVE_METRICS FLB_HAVE_HTTP_SERVER FLB_HAVE_SYSTEMD FLB_HAVE_SYSTEMD_SDBUS FLB_HAVE_FORK FLB_HAVE_TIMESPEC_GET FLB_HAVE_GMTOFF FLB_HAVE_TIME_ZONE FLB_HAVE_UNIX_SOCKET FLB_HAVE_LITTLE_ENDIAN_SYSTEM FLB_HAVE_LIBYAML FLB_HAVE_ATTRIBUTE_ALLOC_SIZE FLB_HAVE_PROXY_GO JEMALLOC_MANGLE FLB_HAVE_JEMALLOC FLB_HAVE_LIBBACKTRACE FLB_HAVE_REGEX FLB_HAVE_UTF8_ENCODER FLB_HAVE_LUAJIT FLB_HAVE_C_TLS FLB_HAVE_ACCEPT4 FLB_HAVE_INOTIFY FLB_HAVE_GETENTROPY FLB_HAVE_GETENTROPY_SYS_RANDOM
```
