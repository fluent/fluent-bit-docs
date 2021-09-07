---
description: Send logs to Datadog
---

# Datadog

The Datadog output plugin allows to ingest your logs into [Datadog](https://app.datadoghq.com/signup).

Before you begin, you need a [Datadog account](https://app.datadoghq.com/signup), a [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/), and you need to [activate Datadog Logs Management](https://app.datadoghq.com/logs/activation).

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| Host | _Required_ - The Datadog server where you are sending your logs. | `http-intake.logs.datadoghq.com` |
| TLS | _Required_ - End-to-end security communications security protocol. Datadog recommends setting this to `on`. | `off` |
| compress | _Recommended_ - compresses the payload in GZIP format, Datadog supports and recommends setting this to `gzip`. |  |
| apikey | _Required_ - Your [Datadog API key](https://app.datadoghq.com/account/settings#api). |  |
| Proxy | _Optional_ - Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host:port). Note that _https_ is **not** supported yet. |  |
| provider | To activate the remapping, specify configuration flag provider with value `ecs`. |  |
| json\_date\_key | Date key name for output. | `timestamp` |
| include\_tag\_key | If enabled, a tag is appended to output. The key name is used `tag_key` property. | `false` |
| tag\_key | The key name of tag. If `include_tag_key` is false, This property is ignored. | `tagkey` |
| dd\_service | _Recommended_ - The human readable name for your service generating the logs - the name of your application or database. |  |
| dd\_source | _Recommended_ - A human readable name for the underlying technology of your service. For example, `postgres` or `nginx`. |  |
| dd\_tags | _Optional_ - The [tags](https://docs.datadoghq.com/tagging/) you want to assign to your logs in Datadog. |  |
| dd\_message\_key | By default, the plugin searches for the key 'log' and remap the value to the key 'message'. If the property is set, the plugin will search the property name key. |  |

### Configuration File

Get started quickly with this configuration file:

```text
[OUTPUT]
    Name        datadog
    Match       *
    Host        http-intake.logs.datadoghq.com
    TLS         on
    compress    gzip
    apikey      <my-datadog-api-key>
    dd_service  <my-app-service>
    dd_source   <my-app-source>
    dd_tags     team:logs,foo:bar
```

## Troubleshooting

### 403 Forbidden

If you get a `403 Forbidden` error response, double check that you have a valid [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/) and that you have [activated Datadog Logs Management](https://app.datadoghq.com/logs/activation).

