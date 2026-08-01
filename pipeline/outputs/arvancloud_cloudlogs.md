---
description: Send logs to ArvanCloud CloudLogs
---

# ArvanCloud CloudLogs

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _ArvanCloud CloudLogs_ output plugin sends log records to the [ArvanCloud CloudLogs](https://www.arvancloud.ir/en/products/cloud-logs) ingestion API over HTTPS.

Fluent Bit posts a JSON body to the fixed endpoint `https://napi.arvancloud.ir/logging/v1/entries/write`. Each Fluent Bit record is wrapped in the CloudLogs entry schema. Authentication uses an API key sent in the `Authorization` header as `apikey <value>`.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `apikey` | Required. API key used for authorization. Fluent Bit sends it as `Authorization: apikey <value>`. | _none_ |
| `gzip` | Enable gzip compression of the HTTP request body. If compression fails, Fluent Bit sends the uncompressed payload. | `false` |
| `include_tag_key` | When enabled, include the original Fluent Bit tag as an extra field on each CloudLogs entry. | `false` |
| `log_type` | Static `logType` value used when `log_type_key` isn't set, or when the record field referenced by `log_type_key` is missing or empty. | `fluentbit` |
| `log_type_key` | Optional [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) that selects a field from the record to use as `logType`. When the field exists and isn't empty, it takes priority over `log_type`. | _none_ |
| `tag_key` | Field name used for the Fluent Bit tag when `include_tag_key` is enabled. | `tag` |
| `timestamp_format` | Optional `strptime`-style format used to parse the value selected by `timestamp_key`. When set, Fluent Bit parses the field and rewrites it as UTC RFC3339 with microseconds. When omitted, the `timestamp_key` value is forwarded as-is. | _none_ |
| `timestamp_key` | Optional [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) that selects a record field to use as the CloudLogs `timestamp`. If unset, missing, empty, or unparseable, Fluent Bit uses the event timestamp. | _none_ |

The plugin hardcodes the destination host (`napi.arvancloud.ir`), port (`443`), URI (`/logging/v1/entries/write`), and HTTPS. Host, port, and URI aren't configurable.

## Request payload

Fluent Bit builds one JSON object per flush:

```json
{
  "logs": [
    {
      "logType": "fluentbit",
      "timestamp": "2024-01-15T10:30:45.000000Z",
      "severity": "INFO",
      "resource": {
        "type": "general"
      },
      "payload": {
        "key": "value"
      }
    }
  ]
}
```

Behavior notes:

- `payload` contains the original record map unchanged.
- `severity` is always set to `INFO`.
- `resource` is always set to `{"type":"general"}`.
- When `include_tag_key` is enabled, the tag is added as a sibling field of `payload` using `tag_key`.
- `logType` resolution order is `log_type_key` (when present and non-empty), then `log_type`.
- Timestamp resolution:
  1. If `timestamp_key` and `timestamp_format` are set, parse the field and emit UTC RFC3339 with microseconds (for example `2024-01-15T10:30:45.000000Z`).
  2. If `timestamp_key` is set without `timestamp_format`, forward the field value as-is.
  3. Otherwise, or if extraction or parsing fails, use the Fluent Bit event timestamp formatted as UTC RFC3339 with microseconds.

## HTTP response handling

| Status | Result |
| :--- | :--- |
| `200`-`205` | Success (`FLB_OK`) |
| `400`, `401`, `403` | Failure without retry (`FLB_ERROR`) |
| `429` | Retry (`FLB_RETRY`) |
| `500` and above | Retry (`FLB_RETRY`) |
| Other HTTP client errors | Failure without retry (`FLB_ERROR`) |
| Connection or transport failure | Retry (`FLB_RETRY`) |

## Get started

### Minimal configuration

`apikey` is the only required option:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: app.logs

  outputs:
    - name: arvancloud_cloudlogs
      match: '*'
      apikey: YOUR_API_KEY_HERE
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  dummy
  Tag   app.logs

[OUTPUT]
  Name    arvancloud_cloudlogs
  Match   *
  apikey  YOUR_API_KEY_HERE
```

{% endtab %}
{% endtabs %}

### Full configuration example

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: app.logs
      dummy: '{"message":"hello","category":"security","ts":"2024-01-15T10:30:45Z"}'

  outputs:
    - name: arvancloud_cloudlogs
      match: '*'
      apikey: YOUR_API_KEY_HERE
      log_type: myapp
      log_type_key: $category
      timestamp_key: $ts
      timestamp_format: '%Y-%m-%dT%H:%M:%SZ'
      gzip: true
      include_tag_key: true
      tag_key: fluentbit_tag
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   dummy
  Tag    app.logs
  Dummy  {"message":"hello","category":"security","ts":"2024-01-15T10:30:45Z"}

[OUTPUT]
  Name              arvancloud_cloudlogs
  Match             *
  apikey            YOUR_API_KEY_HERE
  log_type          myapp
  log_type_key      $category
  timestamp_key     $ts
  timestamp_format  %Y-%m-%dT%H:%M:%SZ
  gzip              true
  include_tag_key   true
  tag_key           fluentbit_tag
```

{% endtab %}
{% endtabs %}

With that example, Fluent Bit derives `logType` from `$category` (`security`), normalizes `$ts` to `2024-01-15T10:30:45.000000Z`, compresses the request body with gzip when possible, and includes the tag under `fluentbit_tag`.

## References

- [ArvanCloud CloudLogs](https://www.arvancloud.ir/en/products/cloud-logs)
