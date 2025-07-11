---
description: Send logs to Datadog
---

# Datadog

The Datadog output plugin allows to ingest your logs into [Datadog](https://app.datadoghq.com/signup).

Before you begin, you need a [Datadog account](https://app.datadoghq.com/signup), a [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/), and you need to [activate Datadog Logs Management](https://app.datadoghq.com/logs/activation).

## Configuration Parameters

| Key             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                | Default                          |
| --------------- | -----------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                          | -------------------------------- |
| Host            | _Required_ - The Datadog server where you are sending your logs.                                                                                                                                                                                                                                                                                                                                                                           | `http-intake.logs.datadoghq.com` |
| TLS             | _Required_ - End-to-end security communications security protocol. Datadog recommends setting this to `on`.                                                                                                                                                                                                                                                                                                                                | `off`                            |
| compress        | _Recommended_ - compresses the payload in GZIP format, Datadog supports and recommends setting this to `gzip`.                                                                                                                                                                                                                                                                                                                             |                                  |
| apikey          | _Required_ - Your [Datadog API key](https://app.datadoghq.com/account/settings#api).                                                                                                                                                                                                                                                                                                                                                       |                                  |
| Proxy           | _Optional_ - Specify an HTTP Proxy. The expected format of this value is [http://host:port](http://host/:port). Note that _https_ is **not** supported yet.                                                                                                                                                                                                                                                                                |                                  |
| provider        | To activate the remapping, specify configuration flag provider with value `ecs`.                                                                                                                                                                                                                                                                                                                                                           |                                  |
| json_date_key   | Date key name for output.                                                                                                                                                                                                                                                                                                                                                                                                                  | `timestamp`                      |
| include_tag_key | If enabled, a tag is appended to output. The key name is used `tag_key` property.                                                                                                                                                                                                                                                                                                                                                          | `false`                          |
| tag_key         | The key name of tag. If `include_tag_key` is false, This property is ignored.                                                                                                                                                                                                                                                                                                                                                              | `tagkey`                         |
| dd_service      | _Recommended_ - The human readable name for your service generating the logs (e.g. the name of your application or database). If unset, Datadog will look for the service using [Service Remapper](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=service#service-attribute)." |                                  |
| dd_source       | _Recommended_ - A human readable name for the underlying technology of your service (e.g. `postgres` or `nginx`). If unset, Datadog will look for the source in the [`ddsource` attribute](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=source#source-attribute).                                                                                                                                                                                                                                                                                                                   |                                  |
| dd_tags         | _Optional_ - The [tags](https://docs.datadoghq.com/tagging/) you want to assign to your logs in Datadog. If unset, Datadog will look for the tags in the [`ddtags` attribute](https://docs.datadoghq.com/api/latest/logs/#send-logs).                                                                                                                                                                                                                                                                                                                                   |                                  |
| dd_message_key  | By default, the plugin searches for the key 'log' and remap the value to the key 'message'. If the property is set, the plugin will search the property name key.                                                                                                                                                                                                                                                                          |                                  |
| dd_hostname     | The host the emitted logs should be associated with. If unset, Datadog expects the host to be set with `host`, `hostname`, or `syslog.hostname` attributes. See [Datadog Logs preprocessor documentation](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=host#preprocessing) for recognized attributes. | _none_ |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| header | Add additional arbitrary HTTP header key/value pair. Multiple headers can be set. | _none_ |

### Configuration File

Get started quickly with this configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
          
    outputs:
        - name: datadog
          match: '*'
          host: http-intake.logs.datadoghq.com
          tls: on
          compress: gzip
          apikey: <my-datadog-api-key>
          dd_service: <my-app-service>
          dd_source: <my-app-source>
          dd_tags: team:logs,foo:bar
          dd_hostname: myhost
      
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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
    dd_hostname myhost
```

{% endtab %}
{% endtabs %}

## Troubleshooting

### 403 Forbidden

If you get a `403 Forbidden` error response, double check that you have a valid [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/) and that you have [activated Datadog Logs Management](https://app.datadoghq.com/logs/activation).