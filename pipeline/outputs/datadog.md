---
description: Send logs to Datadog
---

# Datadog

The _Datadog_ output plugin lets you ingest your logs into [Datadog](https://app.datadoghq.com/signup).

Before you begin, you need a [Datadog account](https://app.datadoghq.com/signup), a [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/), and you need to [activate Datadog Logs Management](https://app.datadoghq.com/logs/activation).

## Configuration parameters

This plugin uses the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `Host` | The Datadog server where you are sending your logs. | `http-intake.logs.datadoghq.com` |
| `TLS` | End-to-end security communications security protocol. Datadog recommends setting this to `on`. | `off` |
| `compress` | Optional. Compresses the payload in GZIP format. Datadog supports and recommends setting this to `gzip`.  | _none_ |
| `apikey` | Your [Datadog API key](https://app.datadoghq.com/account/settings#api). | _none_ |
| `Proxy` | Optional. Specifies an HTTP proxy. The expected format of this value is `http://host:port`. HTTPS isn't supported. | _none_ |
| `provider` | To activate remapping, specify the configuration flag provider with the value `ecs`. | _none_ |
| `json_date_key` | Date key name for output. | `timestamp` |
| `include_tag_key` | If enabled, a tag is appended to the output. The key name is used `tag_key` property. | `false` |
| `tag_key` | The key name of tag. If `include_tag_key` is `false`, this property is ignored. | `tagkey` |
| `dd_service` | Recommended. The human readable name for your service generating the logs. For example, the name of your application or database. If not set, Datadog looks for the service using [service remapper](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=service#service-attribute). | _none_ |
| `dd_source` | Recommended. A human-readable name for the underlying technology of your service like `postgres` or `nginx`. If unset, Datadog looks for the source in the [`ddsource` attribute](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=source#source-attribute). | _none_ |
| `dd_tags` | Optional. The [tags](https://docs.datadoghq.com/tagging/) you want to assign to your logs in Datadog. If unset, Datadog will look for the tags in the [`ddtags` attribute](https://docs.datadoghq.com/api/latest/logs/#send-logs).  | _none_ |
| `dd_message_key` | By default, the plugin searches for the key `log` and remaps the value to the key `message`. If the property is set, the plugin will search the property name key. | _none_ |
| `dd_hostname` | The host the emitted logs should be associated with. If unset, Datadog expects the host to be set with `host`, `hostname`, or `syslog.hostname` attributes. See [Datadog Logs preprocessor documentation](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=host#preprocessing) for recognized attributes. | _none_ |
| `site` | Optional. The Datadog site to send logs to. Use `datadoghq.com` for US or `datadoghq.eu` for EU. If not specified, defaults to `datadoghq.com`. | `datadoghq.com` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| `header` | Add additional arbitrary HTTP header key/value pair. Multiple headers can be set. | _none_ |

### Configuration file

Get started with this configuration file:

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
      site: datadoghq.com
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
  site        datadoghq.com
  dd_service  <my-app-service>
  dd_source   <my-app-source>
  dd_tags     team:logs,foo:bar
  dd_hostname myhost
```

{% endtab %}
{% endtabs %}

## Troubleshooting

If you get a `403 Forbidden` error response, double check that you have a valid [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/) and that you have [activated Datadog Logs Management](https://app.datadoghq.com/logs/activation).
