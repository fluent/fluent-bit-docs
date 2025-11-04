# Configure Fluent Bit

Fluent Bit supports two configuration formats:

- [YAML](./configuring-fluent-bit/yaml.md): Standard configuration format as of v3.2.
- [Classic mode](./configuring-fluent-bit/classic-mode.md): To be deprecated at the end of 2026.

## Command line interface

Fluent Bit exposes most of it features through the command line interface. Running the `-h` option you can get a list of the options available:

```shell
# Podman container tooling.
podman run -rm -ti fluent/fluent-bit --help

# Docker container tooling.
docker run --rm -it fluent/fluent-bit --help
```

Which returns the following help text:

```text
Usage: /fluent-bit/bin/fluent-bit [OPTION]

Available Options
  -b  --storage_path=PATH specify a storage buffering path
  -c  --config=FILE       specify an optional configuration file
  -d, --daemon            run Fluent Bit in background mode
      --supervisor        run under a supervising parent process, uses "fork()" to execute child processes
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
  -s, --coro_stack_size   set coroutines stack size in bytes (default: 24576)
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
  gpu_metrics             GPU Metrics
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
```
