# Monitoring

Fluent Bit comes with a built-in HTTP Server that can be used to query internal information and monitor metrics of each running plugin.

Content:

* [Getting Started](monitoring.md#getting_started)
* [REST API Interface](monitoring.md#rest_api)
* [Examples](monitoring.md#examples)

## Getting Started {#getting_started}

To get started, the first step is to enable the HTTP Server from the configuration file:

```text
[SERVICE]
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_PORT    2020

[INPUT]
    Name cpu

[OUTPUT]
    Name  stdout
    Match *
```

the above configuration snippet will instruct Fluent Bit to start it HTTP Server on TCP Port 2020 and listening on all network interfaces:

```text
$ bin/fluent-bit -c fluent-bit.conf
Fluent-Bit v0.13.0
Copyright (C) Treasure Data

[2017/10/27 19:08:24] [ info] [engine] started
[2017/10/27 19:08:24] [ info] [http_server] listen iface=0.0.0.0 tcp_port=2020
```

now with a simple **curl** command is enough to gather some information:

```text
$ curl -s http://127.0.0.1:2020 | jq
{
  "fluent-bit": {
    "version": "0.13.0",
    "edition": "Community",
    "flags": [
      "FLB_HAVE_TLS",
      "FLB_HAVE_METRICS",
      "FLB_HAVE_SQLDB",
      "FLB_HAVE_TRACE",
      "FLB_HAVE_HTTP_SERVER",
      "FLB_HAVE_FLUSH_LIBCO",
      "FLB_HAVE_SYSTEMD",
      "FLB_HAVE_VALGRIND",
      "FLB_HAVE_FORK",
      "FLB_HAVE_PROXY_GO",
      "FLB_HAVE_REGEX",
      "FLB_HAVE_C_TLS",
      "FLB_HAVE_SETJMP",
      "FLB_HAVE_ACCEPT4",
      "FLB_HAVE_INOTIFY"
    ]
  }
}
```

Note that we are sending the _curl_ command output to the _jq_ program which helps to make the JSON data easy to read from the terminal. Fluent Bit don't aim to do JSON pretty-printing.

## REST API Interface {#rest_api}

Fluent Bit aims to expose useful interfaces for monitoring, as of Fluent Bit v0.13 the following end points are available:

| URI | Description | Data Format |
| :--- | :--- | :--- |
| / | Fluent Bit build information | JSON |
| /api/v1/metrics | Internal metrics per loaded plugin | JSON |
| /api/v1/metrics/prometheus | Internal metrics per loaded plugin ready to be consumed by a Prometheus Server | Prometheus Text 0.0.4 |

## Examples {#examples}

Query internal metrics in JSON format:

```text
$ curl -s http://127.0.0.1:2020/api/v1/metrics | jq
{
  "input": {
    "cpu.0": {
      "records": 8,
      "bytes": 2536
    }
  },
  "output": {
    "stdout.0": {
      "proc_records": 5,
      "proc_bytes": 1585,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

Query internal metrics in Prometheus Text 0.0.4 format:

```text
$ curl -s http://127.0.0.1:2020/api/v1/metrics/prometheus
fluentbit_input_records_total{name="cpu.0"} 57 1509150350542
fluentbit_input_bytes_total{name="cpu.0"} 18069 1509150350542
fluentbit_output_proc_records_total{name="stdout.0"} 54 1509150350542
fluentbit_output_proc_bytes_total{name="stdout.0"} 17118 1509150350542
fluentbit_output_errors_total{name="stdout.0"} 0 1509150350542
fluentbit_output_retries_total{name="stdout.0"} 0 1509150350542
fluentbit_output_retries_failed_total{name="stdout.0"} 0 1509150350542
```

