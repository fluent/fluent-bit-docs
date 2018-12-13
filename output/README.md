# Output Plugins

The _output plugins_ defines where [Fluent Bit](http://fluentbit.io) should flush the information it gather from the input. At the moment the available options are the following:

| name | title | description |
| :--- | :--- | :--- |
| [azure](azure.md) | Azure Log Analytics | Ingest records into Azure Log Analytics |
| [bigquery](bigquery.md) | BigQuery | Ingest records into Google BigQuery |
| [counter](counter.md) | Count Records | Simple records counter. |
| [es](elasticsearch.md) | Elasticsearch | flush records to a Elasticsearch server. |
| [file](file.md) | File | Flush records to a file. |
| [flowcounter](flowcounter.md) | FlowCounter | Count records. |
| [forward](forward.md) | Forward | Fluentd forward protocol. |
| [http](http.md) | HTTP | Flush records to an HTTP end point. |
| [influxdb](influxdb.md) | InfluxDB | Flush records to InfluxDB time series database. |
| [kafka](kafka.md) | Apache Kafka | Flush records to Apache Kafka |
| [kafka-rest](kafka-rest-proxy.md) | Kafka REST Proxy | Flush records to a Kafka REST Proxy server. |
| [stackdriver](stackdriver.md) | Google Stackdriver Logging | Flush records to Google Stackdriver Logging service. |
| [stdout](stdout.md) | Standard Output | Flush records to the standard output. |
| [splunk](splunk.md) | Splunk | Flush records to a Splunk Enterprise service |
| [td](td.md) | [Treasure Data](http://www.treasuredata.com) | Flush records to the [Treasure Data](http://www.treasuredata.com) cloud service for analytics. |
| [nats](nats.md) | NATS | flush records to a NATS server. |
| [null](null.md) | NULL | throw away events. |

