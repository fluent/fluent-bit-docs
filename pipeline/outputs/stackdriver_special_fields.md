# Stackdriver Special fields

When the [google-logging-agent](https://cloud.google.com/logging/docs/agent) receives a structured log record, it treats the [some fields](https://cloud.google.com/logging/docs/agent/configuration#special-fields) specially, allowing users to set specific fields in the LogEntry object that get written to the Logging API.

Currently, we also support some special fields in fluent-bit:
| JSON log field | [LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) field | Logging agent function |
| :--- | :--- | :--- |
| logging.googleapis.com/operation | operation | The value of this field is also used by the Logs Viewer to group related log entries |
| logging.googleapis.com/labels | labels | The value of this field should be a structured record |


## Operaiton
Operation field contains additional information about a potentially long-running operation with which a log entry is associated.

The JSON representation is as followed:
```text
{
  "id": string,
  "producer": string,
  "first": boolean,
  "last": boolean
}
```

For example, when the jsonPayload contains the subfield `logging.googleapis.com/operation`:
```text
jsonPayload {
    "logging.googleapis.com/operation": {
        "id": "test_id",
        "producer": "test_producer",
        "first": true,
        "last": true
    }
    ...
}
```
the stackdriver output plugin will extract the operation field and remove it from jsonPayload. LogEntry will be:
```text
{
    "jsonPayload": {
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

### Use Cases
**1. If the subfields are emtpy or in incorrect type, stackdriver output plugin will set these subfields empty.** For example:
```text
jsonPayload {
    "logging.googleapis.com/operation": {
        "id": 123, #incorrect type
        # no producer here
        "first": true,
        "last": true
    }
    ...
}
```
the logEntry will be:
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
**2. If the `logging.googleapis.com/operation` itself is not a map, stackdriver output plugin will leave this field untouched.** For example:
```text
jsonPayload {
    "logging.googleapis.com/operation": "some string",
    ...
}
```
the logEntry will be:
```text
{
    "jsonPayload": {
        "logging.googleapis.com/operation": "some string",
        ...
    }
    ...
}
```
**3. If there are extra subfields, stackdriver output plugin will add operation field to logEntry and preserve the extra subfields in jsonPayload.** For example:
```text
jsonPayload {
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
the logEntry will be:
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
## Labels
labels field contains specific labels in a structured entry that will be added to LogEntry labels.

For example, when the jsonPayload contains the subfield `logging.googleapis.com/labels`:
```text
jsonPayload {
    "logging.googleapis.com/labels": {
        "A": "valA",
        "B": "valB",
        "C": "valC"
    }
    ...
}
```
the stackdriver output plugin will extract labels from the subfield `logging.googleapis.com/labels` and move it up from jsonPayload to LogEntry Labels. LogEntry will be:
```text
{
    "jsonPayload": {
        ...
    }
    "labels": {
        "A": "valA",
        "B": "valB",
        "C": "valC"
    }
    ...
}
```
