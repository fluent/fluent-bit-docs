---
description: Send logs to Databricks via ZeroBus
---

# ZeroBus

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _ZeroBus_ output plugin lets you ingest log records into a [Databricks](https://www.databricks.com/) table through the ZeroBus streaming ingestion interface. Records are converted to JSON and sent via the ZeroBus SDK using gRPC.

Before you begin, you need a Databricks workspace with a Unity Catalog table configured for ZeroBus ingestion, and an OAuth2 service principal (client ID and client secret) with appropriate permissions.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `endpoint` | ZeroBus gRPC endpoint URL. If no scheme is provided, `https://` is automatically prepended. | _none_ |
| `workspace_url` | Databricks workspace URL. If no scheme is provided, `https://` is automatically prepended. | _none_ |
| `table_name` | Fully qualified Unity Catalog table name in `catalog.schema.table` format. | _none_ |
| `client_id` | OAuth2 client ID for authentication. | _none_ |
| `client_secret` | OAuth2 client secret for authentication. | _none_ |
| `add_tag` | If enabled, the Fluent Bit tag is added as a `_tag` field in each record. | `true` |
| `time_key` | Key name for the injected timestamp. The timestamp is formatted as RFC 3339 with nanosecond precision. Set to an empty string to disable timestamp injection. | `_time` |
| `log_key` | Comma-separated list of record keys to include in the output. When unset, all keys are included. | _none_ |
| `raw_log_key` | If set, the full original record (before filtering by `log_key`) is stored as a JSON string under this key name. | _none_ |

## Get started

To send log records to Databricks via ZeroBus, configure the plugin with your ZeroBus endpoint, workspace URL, table name, and OAuth2 credentials.

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: app.logs
      path: /var/log/app/*.log

  outputs:
    - name: zerobus
      match: '*'
      endpoint: https://<workspace-id>.zerobus.<region>.cloud.databricks.com
      workspace_url: https://<instance-name>.cloud.databricks.com
      table_name: catalog.schema.logs
      client_id: <your-client-id>
      client_secret: <your-client-secret>
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name  tail
    Tag   app.logs
    Path  /var/log/app/*.log

[OUTPUT]
    Name           zerobus
    Match          *
    Endpoint       https://<workspace-id>.zerobus.<region>.cloud.databricks.com
    Workspace_Url  https://<instance-name>.cloud.databricks.com
    Table_Name     catalog.schema.logs
    Client_Id      <your-client-id>
    Client_Secret  <your-client-secret>
```

{% endtab %}
{% endtabs %}

### Record format

Each log record is converted to a JSON object before ingestion. The plugin applies the following transformations in order:

1. If `raw_log_key` is set, the full original record is captured as a JSON string before any filtering.
2. If `log_key` is set, only the specified keys are included in the output record.
3. If `raw_log_key` is set, the captured JSON string is injected under the configured key (unless a key with that name already exists).
4. If `time_key` is set, a timestamp in RFC 3339 format with nanosecond precision (for example, `2024-01-15T10:30:00.123456789Z`) is injected (unless a key with that name already exists).
5. If `add_tag` is enabled, the Fluent Bit tag is injected as `_tag` (unless a key with that name already exists).

For example, given the following input record:

```json
{"level": "info", "message": "request completed", "status": 200}
```

The default configuration produces:

```json
{
  "level": "info",
  "message": "request completed",
  "status": 200,
  "_time": "2024-01-15T10:30:00.123456789Z",
  "_tag": "app.logs"
}
```

### Filtering keys

Use `log_key` to select specific fields from the record. Combined with `raw_log_key`, you can send a filtered record while preserving the original data:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  outputs:
    - name: zerobus
      match: '*'
      endpoint: https://<workspace-id>.zerobus.<region>.cloud.databricks.com
      workspace_url: https://<instance-name>.cloud.databricks.com
      table_name: catalog.schema.logs
      client_id: <your-client-id>
      client_secret: <your-client-secret>
      log_key: level,message
      raw_log_key: _raw
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
    Name           zerobus
    Match          *
    Endpoint       https://<workspace-id>.zerobus.<region>.cloud.databricks.com
    Workspace_Url  https://<instance-name>.cloud.databricks.com
    Table_Name     catalog.schema.logs
    Client_Id      <your-client-id>
    Client_Secret  <your-client-secret>
    Log_Key        level,message
    Raw_Log_Key    _raw
```

{% endtab %}
{% endtabs %}

This produces:

```json
{
  "level": "info",
  "message": "request completed",
  "_raw": "{\"level\":\"info\",\"message\":\"request completed\",\"status\":200}",
  "_time": "2024-01-15T10:30:00.123456789Z",
  "_tag": "app.logs"
}
```
