# Security

Fluent Bit provides integrated support for _Transport Layer Security_ \(TLS\) and it predecessor _Secure Sockets Layer_ \(SSL\) respectively. In this section we will refer as TLS only for both implementations.

Each output plugin that requires to perform Network I/O can optionally enable TLS and configure the behavior. The following table describes the properties available:

| Property | Description | Default |
| :--- | :--- | :--- |
| tls | enable or disable TLS support | Off |
| tls.verify | force certificate validation | On |
| tls.debug | Set TLS debug verbosity level. It accept the following values: 0 \(No debug\), 1 \(Error\), 2 \(State change\), 3 \(Informational\) and 4 Verbose | 1 |
| tls.ca\_file | absolute path to CA certificate file |  |
| tls.ca\_path | absolute path to scan for certificate files |  |
| tls.crt\_file | absolute path to Certificate file |  |
| tls.key\_file | absolute path to private Key file |  |
| tls.key\_passwd | optional password for tls.key\_file file |  |
| tls.vhost | hostname to be used for TLS SNI extension |  |

The listed properties can be enabled in the configuration file, specifically on each output plugin section or directly through the command line.

The following **output** plugins can take advantage of the TLS feature:

* [Amazon CloudWatch](../pipeline/outputs/cloudwatch.md)
* [Amazon Kinesis Data Firehose](../pipeline/outputs/firehose.md)
* [Amazon Kinesis Data Streams](../pipeline/outputs/kinesis.md)
* [Amazon S3](../pipeline/outputs/s3.md)
* [Azure](../pipeline/outputs/azure.md)
* [BigQuery](../pipeline/outputs/bigquery.md)
* [Datadog](../pipeline/outputs/datadog.md)
* [Elasticsearch](../pipeline/outputs/elasticsearch.md)
* [Forward](../pipeline/outputs/forward.md)
* [GELF](../pipeline/outputs/gelf.md)
* [HTTP](../pipeline/outputs/http.md)
* [InfluxDB](../pipeline/outputs/influxdb.md)
* [Kafka REST Proxy](../pipeline/outputs/kafka-rest-proxy.md)
* [Slack](../pipeline/outputs/slack.md)
* [Splunk](../pipeline/outputs/splunk.md)
* [Stackdriver](../pipeline/outputs/stackdriver.md)
* [TCP & TLS](../pipeline/outputs/tcp-and-tls.md)
* [Treasure Data](../pipeline/outputs/treasure-data.md)

In addition, other plugins implements a sub-set of TLS support, meaning, with restricted configuration:

* [Kubernetes Filter](../pipeline/filters/kubernetes.md)

## Example: enable TLS on HTTP output

By default HTTP output plugin uses plain TCP, enabling TLS from the command line can be done with:

```text
$ fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something \
    -p tls=on         \
    -p tls.verify=off \
    -m '*'
```

In the command line above, the two properties _tls_ and _tls.verify_ where enabled for demonstration purposes \(we strongly suggest always keep verification ON\).

The same behavior can be accomplished using a configuration file:

```text
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name       http
    Match      *
    Host       192.168.2.3
    Port       80
    URI        /something
    tls        On
    tls.verify Off
```

## Tips and Tricks

### Connect to virtual servers using TLS

Fluent Bit supports [TLS server name indication](https://en.wikipedia.org/wiki/Server_Name_Indication). If you are serving multiple hostnames on a single IP address \(a.k.a. virtual hosting\), you can make use of `tls.vhost` to connect to a specific hostname.

```text
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name        forward
    Match       *
    Host        192.168.10.100
    Port        24224
    tls         On
    tls.verify  On
    tls.ca_file /etc/certs/fluent.crt
    tls.vhost   fluent.example.com
```

