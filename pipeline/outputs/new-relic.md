# New Relic

[New Relic](https://newrelic.com/) is a data management platform that gives you real-time insights of your data for developers, operations and management teams.

The Fluent Bit `nrlogs` output plugin allows you to send your logs to New Relic service.

Before to get started with the plugin configuration, make sure to obtain the proper account to get access to the service. You can register and start with a free trial in the following link:

* [New Relic Sign Up](https://newrelic.com/signup)

## Configuration Parameters

| Key         | Description                                                                                                                                                                                                                                                                                                                                                                                                            | Default                                                                               |
|:------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------|
| base_uri    | Full address of New Relic API end-point. By default the value points to the US end-point. If you want to use the EU end-point you can set this key to the following value:<br> - <a href="https://log-api.eu.newrelic.com/log/v1">https://log-api.eu.newrelic.com/log/v1</a>                                                                                                                                           | <a href="https://log-api.newrelic.com/log/v1">https://log-api.newrelic.com/log/v1</a> |
| api_key     | Your key for data ingestion. The API key is also called the ingestion key, you can get more details on how to generated in the official documentation <a href="https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#event-insert-key">here</a>. From a configuration perspective either an `api_key` or a `license_key` is required. New Relic suggests to use primarily the `api_key`. |                                                                                       |
| license_key | Optional authentication parameter for data ingestion. Note that New Relic suggest to use the `api_key` instead. You can read more about the License Key <a href="https://docs.newrelic.com/docs/accounts/install-new-relic/account-setup/license-key">here</a>.                                                                                                                                                        |                                                                                       |
| compress    | Set the compression mechanism for the payload. This option allows two values: `gzip` \(enabled by default\) or `false` to disable compression.                                                                                                                                                                                                                                                                         | gzip                                                                                  |
| workers     | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output.                                                                                                                                                                                                                                                                                                   | 0                                                                                     |

The following configuration example, will emit a dummy example record and ingest it on New Relic. In your main configuration file append the following:


{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
  
pipeline:
  inputs:
    - name: dummy 
      dummy: '{"message":"a simple message", "temp": "0.74", "extra": "false"}'
      samples: 1
      
  outputs:
    - name: nrlogs
      match: '*'
      api_key: YOUR_API_KEY_HERE
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush     1
  log_level info

[INPUT]
  name      dummy
  dummy     {"message":"a simple message", "temp": "0.74", "extra": "false"}
  samples   1

[OUTPUT]
  name      nrlogs
  match     *
  api_key   YOUR_API_KEY_HERE
```

{% endtab %}
{% endtabs %}

Run Fluent Bit with the new configuration file:

```shell
# For YAML configuration.
fluent-bit --config fluent-bit.yaml

# For classic configuration
fluent-bit --config fluent-bit.conf
```

Fluent Bit output:

```text
...
[2020/04/10 10:58:35] [ info] [output:nrlogs:nrlogs.0] log-api.newrelic.com:443, HTTP status=202
{"requestId":"feb312fe-004e-b000-0000-0171650764ac"}
...
```