# Datadog

The Datadog output plugin allows to ingest your Logs into [Datadog](https://docs.datadoghq.com/).

Before you begin, you need a [Datadog API key](https://docs.datadoghq.com/account_management/api-app-keys/).

## Configuration Parameters

| Key | Description | Default |
|------------|---------------------------------------------------------------------------------------------|----------------------------------|
| Host | The Datadog server where you are sending your logs.  | `http-intake.logs.datadoghq.com` |
| TLS | End-to-end security communications security protocol. Datadog recommends leaving this `on`. | `on` |
| apikey | )Your [Datadog API key](https://app.datadoghq.com/account/settings#api). |  |
| dd_service | The name of your applications service. |  |
| dd_source | The name of your application source. |  |
| dd_tags | )The [tags](https://docs.datadoghq.com/tagging/) you want to assign to your logs in Datadog. |  |

### Configuration File

Get started quickly with this configuration file:

```text
[OUTPUT]
    Name        datadog
    Match       *
    Host        http-intake.logs.datadoghq.com
    TLS         on
    apikey      <my-datadog-api-key>
    dd_service  my-app-service
    dd_source   my-app
    dd_tags     team:logs,foo:bar
```

## Troubleshooting

Anything we want to add here yet?
