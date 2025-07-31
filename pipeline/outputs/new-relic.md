# New Relic

The _New Relic_ output plugin lets you send logs to New Relic.

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `base_uri` | The New Relic API endpoint. | `https://log-api.newrelic.com/log/v1`|
| `api_key` | Your [New Relic API key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/). Either an `api_key` or `license_key` is required.| _none_ |
| `license_key` | Your [New Relic license key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/). Either an `api_key` or `license_key` is required. | _none_ |
| `compress` | Sets the compression mechanism for the payload. Possible values: `gzip` or `false`. | `gzip` |
| `workers` | Sets the number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Example configuration

The following example configuration uses a `dummy` input plugin and a `nrlogs` output plugin.

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
