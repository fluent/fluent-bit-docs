# Apache SkyWalking

The _Apache SkyWalking_ output plugin lets you flush your records to an [Apache SkyWalking](https://skywalking.apache.org/) OAP. The following instructions assume that you have an operational Apache SkyWalking OAP in place.

## Configuration parameters

This plugin supports the following parameters:

| Parameter | Description | Default    |
|:--------- |:----------- |:-----------|
| `host` | Hostname of Apache SkyWalking OAP. |` 127.0.0.1` |
| `port` | TCP port of the Apache SkyWalking OAP. | `12800` |
| `auth_token` | Authentication token if needed for Apache SkyWalking OAP. | _none_ |
| `svc_name` | Service name that Fluent Bit belongs to. | `sw-service` |
| `svc_inst_name` | Service instance name of Fluent Bit. | `fluent-bit` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The Apache SkyWalking output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To start inserting records into an Apache SkyWalking service, you can run the plugin through the configuration file.

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu

  outputs:
    - name: skywalking
      svc_name: dummy-service
      svc_inst_name: dummy-service-fluentbit
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name cpu

[OUTPUT]
  Name          skywalking
  svc_name      dummy-service
  svc_inst_name dummy-service-fluentbit
```

{% endtab %}
{% endtabs %}

## Output format

The format of the plugin output follows the [data collect protocol](https://github.com/apache/skywalking-data-collect-protocol/blob/743f33119dc5621ae98b596eb8b131dd443445c7/logging/Logging.proto).

For example, if the log is as follows:

```json
{
  "log": "This is the original log message"
}
```

This message is packed into the following protocol format and written to the OAP using the REST API.

```json
[{
  "timestamp": 123456789,
  "service": "dummy-service",
  "serviceInstance": "dummy-service-fluentbit",
  "body": {
    "json": {
      "json": "{\"log\": \"This is the original log message\"}"
    }
  }
}]
```
