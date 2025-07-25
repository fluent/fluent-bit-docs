
# TLS

Fluent Bit provides integrated support for Transport Layer Security (TLS) and its predecessor Secure Sockets Layer (SSL). This section refers only to TLS for both implementations.

Both input and output plugins that perform Network I/O can optionally enable TLS and configure the behavior. The following table describes the properties available:

| Property | Description | Default |
| :--- | :--- | :--- |
| `tls` | Enable or disable TLS support. | `Off` |
| `tls.verify` | Force certificate validation. | `On` |
| `tls.verify_hostname` | Force TLS verification of host names. | `Off` |
| `tls.debug` | Set TLS debug verbosity level. Accepted values: `0` (No debug), `1` (Error), `2` (State change), `3` (Informational) and `4`. (Verbose) | `1` |
| `tls.ca_file` | Absolute path to CA certificate file. | _none_ |
| `tls.ca_path` | Absolute path to scan for certificate files. | _none_ |
| `tls.crt_file` | Absolute path to Certificate file. | _none_ |
| `tls.key_file` | Absolute path to private Key file. | _none_ |
| `tls.key_passwd` | Optional password for `tls.key_file` file. | _none_ |
| `tls.vhost` | Hostname to be used for TLS SNI extension. | _none_ |

To use TLS on input plugins, you must provide both a certificate and a private key.

The listed properties can be enabled in the configuration file, specifically in each output plugin section or directly through the command line.

The following **output** plugins can take advantage of the TLS feature:

- [Amazon S3](../pipeline/outputs/s3.md)
- [Apache SkyWalking](../pipeline/outputs/skywalking.md)
- [Azure](../pipeline/outputs/azure.md)
- [Azure Blob](../pipeline/outputs/azure_blob.md)
- [Azure Data Explorer (Kusto)](../pipeline/outputs/azure_kusto.md)
- [Azure Logs Ingestion API](../pipeline/outputs/azure_logs_ingestion.md)
- [BigQuery](../pipeline/outputs/bigquery.md)
- [Dash0](../pipeline/outputs/dash0.md)
- [Datadog](../pipeline/outputs/datadog.md)
- [Elasticsearch](../pipeline/outputs/elasticsearch.md)
- [Forward](../pipeline/outputs/forward.md)
- [GELF](../pipeline/outputs/gelf.md)
- [Google Chronicle](../pipeline/outputs/chronicle.md)
- [HTTP](../pipeline/outputs/http.md)
- [InfluxDB](../pipeline/outputs/influxdb.md)
- [Kafka REST Proxy](../pipeline/outputs/kafka-rest-proxy.md)
- [LogDNA](../pipeline/outputs/logdna.md)
- [Loki](../pipeline/outputs/loki.md)
- [New Relic](../pipeline/outputs/new-relic.md)
- [OpenSearch](../pipeline/outputs/opensearch.md)
- [OpenTelemetry](../pipeline/outputs/opentelemetry.md)
- [Oracle Cloud Infrastructure Logging Analytics](../pipeline/outputs/oci-logging-analytics.md)
- [Prometheus Remote Write](../pipeline/outputs/prometheus-remote-write.md)
- [Slack](../pipeline/outputs/slack.md)
- [Splunk](../pipeline/outputs/splunk.md)
- [Stackdriver](../pipeline/outputs/stackdriver.md)
- [Syslog](../pipeline/outputs/syslog.md)
- [TCO and TLS](../pipeline/outputs/tcp-and-tls.md)
- [Treasure Data](../pipeline/outputs/treasure-data.md)
- [WebSocket](../pipeline/outputs/websocket.md)

The following **input** plugins can take advantage of the TLS feature:

- [Docker Events](../pipeline/inputs/docker-events.md)
- [Elasticsearch (Bulk API)](../pipeline/inputs/elasticsearch.md)
- [Forward](../pipeline/inputs/forward.md)
- [Health](../pipeline/inputs/health.md)
- [HTTP](../pipeline/inputs/http.md)
- [Kubernetes Events](../pipeline/inputs/kubernetes-events.md)
- [MQTT](../pipeline/inputs/mqtt.md)
- [NGINX Exporter Metrics](../pipeline/inputs/nginx.md)
- [OpenTelemetry](../pipeline/inputs/opentelemetry.md)
- [Prometheus Scrape Metrics](../pipeline/inputs/prometheus-scrape-metrics.md)
- [Prometheus Remote Write](../pipeline/inputs/prometheus-remote-write.md)
- [Splunk (HTTP HEC)](../pipeline/inputs/splunk.md)
- [Syslog](../pipeline/inputs/syslog.md)
- [TCP](../pipeline/inputs/tcp.md)

In addition, other plugins implement a subset of TLS support, with restricted configuration:

- [Kubernetes Filter](../pipeline/filters/kubernetes.md)

## Example: enable TLS on HTTP input

By default, the HTTP input plugin uses plain TCP. Run the following command to enable TLS:

```bash
./bin/fluent-bit -i http \
           -p port=9999 \
           -p tls=on \
           -p tls.verify=off \
           -p tls.crt_file=self_signed.crt \
           -p tls.key_file=self_signed.key \
           -o stdout \
           -m '*'
```

{% hint style="info" %}
See the Tips and Tricks section below for details on generating `self_signed.crt` and `self_signed.key` files shown in these examples.
{% endhint %}

In the previous command, the two properties `tls` and `tls.verify` are set for demonstration purposes. Always enable verification in production environments.

The same behavior can be accomplished using a configuration file:

{% tabs %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
      - name: http
        port: 9999
        tls: on
        tls.verify: off
        tls.cert_file: self_signed.crt
        tls.key_file: self_signed.key

    outputs:
      - name: stdout
        match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    name http
    port 9999
    tls on
    tls.verify off
    tls.crt_file self_signed.crt
    tls.key_file self_signed.key

[OUTPUT]
    Name       stdout
    Match      *
```

{% endtab %}
{% endtabs %}

## Example: enable TLS on HTTP output

By default, the HTTP output plugin uses plain TCP. Run the following command to enable TLS:

```bash
fluent-bit -i cpu -t cpu -o http://192.168.2.3:80/something \
    -p tls=on         \
    -p tls.verify=off \
    -m '*'
```

In the previous command, the properties `tls` and `tls.verify` are enabled for demonstration purposes. Always enable verification in production environments.

The same behavior can be accomplished using a configuration file:

{% tabs %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
      - name: cpu
        tag: cpu

    outputs:
      - name: http
        match: '*'
        host: 192.168.2.3
        port: 80
        uri: /something
        tls: on
        tls.verify: off
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

## Tips and Tricks

### Generate a self signed certificates for testing purposes

The following command generates a 4096 bit RSA key pair and a certificate that's signed using `SHA-256` with the expiration date set to 30 days in the future. In this example, `test.host.net` is set as the common name. This example opts out of `DES`, so the private key is stored in plain text.

```bash
openssl req -x509 \
            -newkey rsa:4096 \
            -sha256 \
            -nodes \
            -keyout self_signed.key \
            -out self_signed.crt \
            -subj "/CN=test.host.net"
```

### Connect to virtual servers using TLS

Fluent Bit supports [TLS server name indication](https://en.wikipedia.org/wiki/Server_Name_Indication). If you are serving multiple host names on a single IP address (for example, using virtual hosting), you can make use of `tls.vhost` to connect to a specific hostname.

{% tabs %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
      - name: cpu
        tag: cpu

    outputs:
      - name: forward
        match: '*'
        host: 192.168.10.100
        port: 24224
        tls: on
        tls.verify: off
        tls.ca_file: '/etc/certs/fluent.crt'
        tls.vhost: 'fluent.example.com'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

### Verify `subjectAltName`

By default, TLS verification of host names isn't done automatically. As an example, you can extract the X509v3 Subject Alternative Name from a certificate:

```text
X509v3 Subject Alternative Name:
    DNS:my.fluent-aggregator.net
```

This certificate covers only `my.fluent-aggregator.net` so if you use a different hostname it should fail.

To fully verify the alternative name and demonstrate the failure, enable `tls.verify_hostname`:

{% tabs %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
      - name: cpu
        tag: cpu

    outputs:
      - name: forward
        match: '*'
        host: other.fluent-aggregator.net
        port: 24224
        tls: on
        tls.verify: on
        tls.verify_hostname: on
        tls.ca_file: '/path/to/fluent-x509v3-alt-name.crt'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name                forward
    Match               *
    Host                other.fluent-aggregator.net
    Port                24224
    tls                 On
    tls.verify          On
    tls.verify_hostname on
    tls.ca_file         /path/to/fluent-x509v3-alt-name.crt
```

{% endtab %}
{% endtabs %}

This outgoing connect will fail and disconnect:

```text
[2024/06/17 16:51:31] [error] [tls] error: unexpected EOF with reason: certificate verify failed
[2024/06/17 16:51:31] [debug] [upstream] connection #50 failed to other.fluent-aggregator.net:24224
[2024/06/17 16:51:31] [error] [output:forward:forward.0] no upstream connections available
```
