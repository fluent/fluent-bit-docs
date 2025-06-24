# Observe

Observe employs the **http** output plugin, allowing you to flush your records [into Observe](https://docs.observeinc.com/en/latest/content/data-ingestion/forwarders/fluentbit.html).

For now the functionality is pretty basic and it issues a POST request with the data records in [MessagePack](http://msgpack.org) (or JSON) format.

The following are the specific HTTP parameters to employ:

## Configuration Parameters

| Key                        | Description                                                                                                                                                                                                                                                                                                                        | default   |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| host                       | IP address or hostname of Observe's data collection endpoint.  $(OBSERVE_CUSTOMER) is your [Customer ID](https://docs.observeinc.com/en/latest/content/common-topics/HelpfulHints.html?highlight=customer%20id#customer-id)                                                                                                                                                                                                                                                                      | OBSERVE_CUSTOMER.collect.observeinc.com |
| port                       | TCP port of to employ when sending to Observe                                                                                                                                                                                                                                                                                      | 443      |
| tls                        | Specify to use tls                                                                                                                                                                                                                                                                                                                 | on       |
| uri                        | Specify the HTTP URI for the Observe's data ingest                                                                                                                                                                                                                                                                                 | /v1/http/fluentbit |
| format                     | The data format to be used in the HTTP request body                                                                                                                                                                                                                                                                                | msgpack   |
| header                     | The specific header that provides the Observe token needed to authorize sending data [into a datastream](https://docs.observeinc.com/en/latest/content/data-ingestion/datastreams.html?highlight=ingest%20token#create-a-datastream).                                                                                                                                                                                                                                                              | Authorization     Bearer ${OBSERVE_TOKEN} |
| header                     | The specific header to instructs Observe how to decode incoming payloads                                                                                                                                                                                                                                                           | X-Observe-Decoder fluent |
| compress                   | Set payload compression mechanism. Option available is 'gzip'                                                                                                                                                                                                                                                                      | gzip      |
| tls.ca_file                | **For use with Windows**: provide path to root cert                                                                                                                                                                                                                                                                                |           |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### Configuration File

In your main configuration file, append the following _Input_ & _Output_ sections:

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
