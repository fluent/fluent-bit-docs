# Apache SkyWalking

The **Apache SkyWalking** output plugin, allows to flush your records to a [Apache SkyWalking](https://skywalking.apache.org/) OAP. The following instructions assumes that you have a fully operational Apache SkyWalking OAP in place.

## Configuration Parameters

| parameter | description | default |
| :--- | :--- | :--- |
| host | Hostname of Apache SkyWalking OAP | 127.0.0.1 |
| port | TCP port of the Apache SkyWalking OAP | 12800 |
| auth_token | Authentication token if needed for Apache SkyWalking OAP | None |
| svc_name | Service name that fluent-bit belongs to | sw-service |
| svc_inst_name | Service instance name of fluent-bit | fluent-bit |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The Apache SkyWalking output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Getting Started

In order to start inserting records into an Apache SkyWalking service, you can run the plugin through the configuration file:

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name cpu

[OUTPUT]
    Name skywalking
    svc_name dummy-service
    svc_inst_name dummy-service-fluentbit
```

## Output Format

The format of the plugin output follows the [data collect protocol](https://github.com/apache/skywalking-data-collect-protocol/blob/743f33119dc5621ae98b596eb8b131dd443445c7/logging/Logging.proto).

For example, if we get log as follows,

```text
{
   "log": "This is the original log message"
}
```

This message is packed into the following protocol format and written to the OAP via the REST API.

```text
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
