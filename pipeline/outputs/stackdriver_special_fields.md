# Stackdriver special fields

When the [google-logging-agent](https://cloud.google.com/logging/docs/agent) receives a structured log record, it treats [some fields](https://cloud.google.com/logging/docs/agent/configuration#special-fields) specially, allowing users to set specific fields in the LogEntry object that get written to the Logging API.

## LogEntry fields

Fluent Bit support some special fields for setting fields on the LogEntry object:

| JSON log field | [LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) field | Type | Description |
| :--- | :--- | :--- | :--- |
| `logging.googleapis.com/logName` | `logName` | `string` | The log name to write this log to. |
| `logging.googleapis.com/labels` | `labels` | `object<string, string>` | The labels for this log. |
| `logging.googleapis.com/severity` | `severity` | [`LogSeverity` Enum](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogSeverity) | The severity of this log. |
| `logging.googleapis.com/monitored_resource` | `resource` | [`MonitoredResource`](https://cloud.google.com/logging/docs/reference/v2/rest/v2/MonitoredResource) (without `type`) | Resource labels for this log. |
| `logging.googleapis.com/operation` | `operation` | [`LogEntryOperation`](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntryOperation) | Additional information about a potentially long-running operation. |
| `logging.googleapis.com/insertId` | `insertId` | `string` | A unique identifier for the log entry. It's used to order `logEntries`. |
| `logging.googleapis.com/sourceLocation` | `sourceLocation` | [`LogEntrySourceLocation`](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntrySourceLocation) | Additional information about the source code location that produced the log entry. |
| `logging.googleapis.com/http_request` | `httpRequest` | [`HttpRequest`](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#HttpRequest) | A common proto for logging HTTP requests. |
| `logging.googleapis.com/trace` | `trace` | `string` | Resource name of the trace associated with the log entry. |
| `logging.googleapis.com/traceSampled` | `traceSampled` | boolean | The sampling decision associated with this log entry. |
| `logging.googleapis.com/spanId` | `spanId` | `string` | The ID of the trace span associated with this log entry. |
| `timestamp` | `timestamp` | `object` ([protobuf `Timestamp` object format](https://protobuf.dev/reference/protobuf/google.protobuf/#timestamp)) | An object including the seconds and nanoseconds fields that represent the time. |
| `timestampSecond` and `timestampNanos` | `timestamp` | `int` | The seconds and nanoseconds that represent the time. |

## Other special fields

| JSON log field | Description |
|:---------------|:------------|
| `logging.googleapis.com/projectId` | Changes the project ID that this log will be written to. Ensure that you are authenticated to write logs to this project. |
| `logging.googleapis.com/local_resource_id` | Overrides the [configured `local_resource_id`](./stackdriver.md#resource-labels).   |

## Use special fields

To use a special field, you must add a field with the right name and value to your log. Given an example structured log (internally in MessagePack but shown in JSON for demonstration):

```json
{
  "log": "Hello world!"
}
```

To use the `logging.googleapis.com/logName` special field, add it to your structured log as follows:

```json
{
  "log": "Hello world!",
  "logging.googleapis.com/logName": "my_log"
}
```

For the special fields that map to `LogEntry` prototypes, add them as objects with field names that match the proto. For example, to use the `logging.googleapis.com/operation`:

```json
{
  "log": "Hello world!",
  "logging.googleapis.com/operation": {
    "id": "test_id",
    "producer": "test_producer",
    "first": true,
    "last": true
  }
}
```

Adding special fields to logs is best done through the [`modify` filter](https://docs.fluentbit.io/manual/pipeline/filters/modify) for basic fields, or [a Lua script using the `lua` filter](https://docs.fluentbit.io/manual/pipeline/filters/lua) for more complex fields.

## Basic type special fields

Special fields with basic types (except for the [`logging.googleapis.com/insertId` field](#insert-id)) will follow this pattern (demonstrated with the `logging.googleapis.com/logName` field):

1. If the special field matches the type, it will be moved to the corresponding LogEntry field. For example:

   ```text
   {
     ...
     "logging.googleapis.com/logName": "my_log"
     ...
   }
   ```

   the `logEntry` will be:

   ```text
   {
     "jsonPayload": {
       ...
     }
     "logName": "my_log"
     ...
   }
   ```

1. If the field is non-empty but an invalid, it will be left in the `jsonPayload`. For example:

   ```text
   {
     ...
     "logging.googleapis.com/logName": 12345
     ...
   }
   ```

  the `logEntry` will be:

   ```text
   {
     "jsonPayload": {
       "logging.googleapis.com/logName": 12345
       ...
     }
   }
   ```

### Exceptions [#exceptions-basic]

#### Insert ID

If the `logging.googleapis.com/insertId` field has an invalid type, the log will be rejected by the plugin and not sent to Cloud Logging.

#### Trace sampled

If the`autoformat_stackdriver_trace` is set to `true`, the value provided in the `trace` field will be formatted into the format that Cloud Logging expects along with the detected Project ID (from the Google Metadata server, configured in the plugin, or provided using a special field).

For example, if `autoformat_stackdriver_trace` is enabled, this:

```text
{
  ...
  "logging.googleapis.com/projectId": "my-project-id",
  "logging.googleapis.com/trace": "12345"
  ...
}
```

Will become this:

```text
{
  "jsonPayload": {
    ...
  },
  "projectId": "my-project-id",
  "trace": "/projects/my-project-id/traces/12345"
  ...
}
```

#### `timestampSecond` and `timestampNano`

The `timestampSecond` and `timestampNano` fields don't map directly to the `timestamp` field in `LogEntry` so the parsing behaviour deviates from other special fields. Read more in the [Timestamp section](#timestamp).

## Proto special fields

For special fields that expect the format of a prototype from the `LogEntry` (except for the `logging.googleapis.com/monitored_resource` field) will follow this pattern (demonstrated with the `logging.googleapis.com/operation` field):

If any sub-fields of the proto are empty or in incorrect type, the plugin will set these sub-fields empty. For example:

```text
{
  "logging.googleapis.com/operation": {
    "id": 123, #incorrect type
    # no producer here
    "first": true,
    "last": true
  }
  ...
}
```

the `logEntry` will be:

```text
{
  "jsonPayload": {
    ...
  }
  "operation": {
    "first": true,
    "last": true
  }
  ...
}
```

If the field itself isn't a map, the plugin will leave this field untouched. For example:

```text
{
  ...
  "logging.googleapis.com/operation": "some string",
  ...
}
```

the `logEntry` will be:

```text
{
  "jsonPayload": {
    "logging.googleapis.com/operation": "some string",
    ...
  }
  ...
}
```

If there are extra sub-fields, the plugin will add the recognized fields to the corresponding field in the LogEntry, and preserve the extra sub-fields in `jsonPayload`. For example:

```text
{
  ...
  "logging.googleapis.com/operation": {
    "id": "test_id",
    "producer": "test_producer",
    "first": true,
    "last": true,
    "extra1": "some string",
    "extra2": 123,
    "extra3": true
  }
  ...
}
```

the `logEntry will be:

```text
{
  "jsonPayload": {
    "logging.googleapis.com/operation": {
      "extra1": "some string",
      "extra2": 123,
      "extra3": true
    }
    ...
  }
  "operation": {
    "id": "test_id",
    "producer": "test_producer",
    "first": true,
    "last": true
  }
  ...
}
```

### Exceptions [#exceptions-proto]

#### `MonitoredResource` ID

The `logging.googleapis.com/monitored_resource` field is parsed in a special way, meaning it has some important exceptions:

The `type` field from the `MonitoredResource` proto isn't parsed out of the special field. It's read from the [`resource` plugin configuration option](https://docs.fluentbit.io/manual/pipeline/outputs/stackdriver#configuration-parameters). If it's supplied in the `logging.googleapis.com/monitored_resource` special field, it won't be recognized.

The `labels` field is expected to be an `object<string, string>`. If any fields have a value that's not a string, the value is ignored and not preserved. The plugin logs an error and drops the field.

If no valid `labels` field is found, or if all entries in the `labels` object provided are invalid, the `logging.googleapis.com/monitored_resource` field is dropped in favour of automatically setting resource labels using other available information based on the configured `resource` type.

## Timestamp

Fluent Bit supports the following formats of time-related fields:

- `timestamp`

  Log body contains a `timestamp` field that includes the seconds and nanoseconds fields.

  ```text
  {
    "timestamp": {
      "seconds": CURRENT_SECONDS,
      "nanos": CURRENT_NANOS
    }
  }
  ```

- `timestampSeconds`/`timestampNanos`

  Log body contains both the `timestampSeconds` and `timestampNanos` fields.

  ```text
  {
    "timestampSeconds": CURRENT_SECONDS,
    "timestampNanos": CURRENT_NANOS
  }
  ```

If one of the following JSON timestamp representations is present in a structured record, the plugin collapses them into a single representation in the timestamp field in the `LogEntry` object.

Without time-related fields, the plugin will set the current time as timestamp.

### Format 1

Set the input log as follows:

```text
{
  "timestamp": {
    "seconds": 1596149787,
    "nanos": 12345
  }
  ...
}
```

the `logEntry` will be:

```text
{
  "jsonPayload": {
    ...
  }
  "timestamp": "2020-07-30T22:56:27.000012345Z"
  ...
}
```

### Format 2

Set the input log as follows:

```text
{
  "timestampSeconds":1596149787,
  "timestampNanos": 12345
  ...
}
```

the `logEntry` will be:

```text
{
  "jsonPayload": {
    ...
  }
  "timestamp": "2020-07-30T22:56:27.000012345Z"
  ...
}
```

If the `timestamp` object or the `timestampSeconds` and `timestampNanos` fields end up being invalid, they will remain in the `jsonPayload` untouched.
