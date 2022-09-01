# Observe

Observe employs the **http** output plugin, allowing you to flush your records [into Observe](https://docs.observeinc.com/en/latest/content/data-ingestion/forwarders/fluentbit.html).

For now the functionality is pretty basic and it issues a POST request with the data records in [MessagePack](http://msgpack.org) (or JSON) format.  

The following are the specfic HTTP parameters to employ:

## Configuration Parameters

| Key                        | Description                                                                                                                                                                                                                                                                                                                        | default   |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| host                       | IP address or hostname of Observe's data collection endpoint                                                                                                                                                                                                                                                                       | collect.observeinc.com |
| port                       | TCP port of to employ when sending to Observe                                                                                                                                                                                                                                                                                      | 443      |
| tls                        | Specify to use tls                                                                                                                                                                                                                                                                                                                 | on       |
| http_user                  | Basic Auth Username                                                                                                                                                                                                                                                                                                                | ${OBSERVE_CUSTOMER} |
| http_passwd                | Basic Auth Password. Requires http\_user to be set                                                                                                                                                                                                                                                                                 | ${OBSERVE_TOKEN} |
| uri                        | Specify the HTTP URI for the Observe's data ingest                                                                                                                                                                                                                                                                                 | /v1/http/fluentbit |
| format                     | The data format to be used in the HTTP request body                                                                                                                                                                                                                                                                                | msgpack   |
| header                     | The specific header to instructs Observe how to decode incoming payloads                                                                                                                                                                                                                                                           | X-Observe-Decoder fluent |
| compress                   | Set payload compression mechanism. Option available is 'gzip'                                                                                                                                                                                                                                                                      | gzip      |
| tls.ca_file                | **For use with Windows**: provide path to root cert                                                                                                                                                                                                                                                                                |           |

### Configuration File

In your main configuration file, append the following _Input_ & _Output_ sections:

```text
[OUTPUT]
    name         http
    match        *
    host         collect.observeinc.com
    port         443
    tls          on

    # For Windows: provide path to root cert
    #tls.ca_file  C:\td-agent-bit\isrgrootx1.pem

    http_user    ${OBSERVE_CUSTOMER}
    http_passwd  ${OBSERVE_TOKEN}
    uri          /v1/http/fluentbit

    format       msgpack
    header       X-Observe-Decoder fluent
    compress     gzip
```
