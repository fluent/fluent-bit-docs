# Observe

Use the [HTTP output plugin](./http.md) to flush your records [into Observe](https://docs.observeinc.com/en/latest/content/data-ingestion/forwarders/fluentbit.html). It issues a POST request with the data records in [MessagePack](http://msgpack.org) (or JSON) format.

## Configuration parameters

The following HTTP configuration parameters are relevant to Observe:

| Key | Description | Default |
| --- | ----------- | ------- |
| `host` | IP address or hostname of the Observe data collection endpoint. Replace `$(OBSERVE_CUSTOMER)` with your [Customer ID](https://docs.observeinc.com/en/latest/content/hints/CustomerId.html). | `OBSERVE_CUSTOMER.collect.observeinc.com` |
| `port` | TCP port to use when sending data to Observe. | `443` |
| `tls` | Specifies whether to use TLS. | `on` |
| `uri` | Specifies the HTTP URI for Observe. | `/v1/http/fluentbit` |
| `format` | The data format to be used in the HTTP request body. | `msgpack` |
| `header` | The specific header that provides the Observe token needed to authorize sending data [into a data stream](https://docs.observeinc.com/en/latest/content/data-ingestion/datastreams.html?highlight=ingest%20token#create-a-datastream). | 'Authorization     Bearer ${OBSERVE_TOKEN}' |
| `header` | The specific header that instructs Observe how to decode incoming payloads. | `X-Observe-Decoder fluent` |
| `compress` | Sets the payload compression mechanism. Possible values: `gzip`, `false`. | `gzip` |
| `tls.ca_file` | For Windows only: the path to the root cert. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: http
      match: '*'
      host: my-observe-customer-id.collect.observeinc.com
      port: 443
      tls: on
      uri: /v1/http/fluentbit
      format: msgpack
      header:
        - 'Authorization     Bearer ${OBSERVE_TOKEN}'
        - 'X-Observe-Decoder fluent'
      compress: gzip
      # For Windows: provide path to root cert
      #tls.ca_file  C:\fluent-bit\isrgrootx1.pem
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
    name         http
    match        *
    host         my-observe-customer-id.collect.observeinc.com
    port         443
    tls          on

    uri          /v1/http/fluentbit

    format       msgpack
    header       Authorization     Bearer ${OBSERVE_TOKEN}
    header       X-Observe-Decoder fluent
    compress     gzip

    # For Windows: provide path to root cert
    #tls.ca_file  C:\fluent-bit\isrgrootx1.pem
```

{% endtab %}
{% endtabs %}
