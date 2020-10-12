# Stackdriver Special fields

When the [google-logging-agent](https://cloud.google.com/logging/docs/agent) receives a structured log record, it treats the [some fields](https://cloud.google.com/logging/docs/agent/configuration#special-fields) specially, allowing users to set specific fields in the LogEntry object that get written to the Logging API.

Currently, we also support some special fields in fluent-bit:
| JSON log field | [LogEntry](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry) field | Logging agent function |
| :--- | :--- | :--- |
| logging.googleapis.com/operation | operation | Additional information about a potentially long-running operation |
| logging.googleapis.com/labels | labels | The value of this field should be a structured record |
| logging.googleapis.com/insertId | insertId | A unique identifier for the log entry. It is used to order logEntries |
| logging.googleapis.com/sourceLocation | sourceLocation | Additional information about the source code location that produced the log entry. |
| logging.googleapis.com/http_request | httpRequest | A common proto for logging HTTP requests. |
| timestamp | timestamp | An object including the seconds and nanos fields that represents the time |
| timestampSecond & timestampNanos | timestamp | The seconds and nanos that represents the time |

## Operation
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
**1. If the subfields are empty or in incorrect type, stackdriver output plugin will set these subfields empty.** For example:
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

## insertId
InsertId is a unique identifier for the log entry. It is used to order logEntries.

The JSON representation is as followed:
```text
"insertId": string
```

### Use Cases
**1. If the insertId is a non-empty string.** For example:
```text
jsonPayload {
    "logging.googleapis.com/insertId": "test_id"
    ...
}
```
the logEntry will be:
```text
{
    "jsonPayload": {
        ...
    }
    "insertId": "test_id"
    ...
}
```

**2. If the insertId is invalid (not non-empty string).** For example:
```text
jsonPayload {
    "logging.googleapis.com/insertId": 12345
    ...
}
```
The logging agent will log an error and reject the entry.

## SourceLocation
SourceLocation field contains additional information about the source code location that produced the log entry. The format.

The JSON representation is as followed:
```text
{
  "file": string,
  "line": string,
  "function": string
}
```

### Use Cases
Set the input log as followed:
```text
jsonPayload {
    "logging.googleapis.com/sourceLocation": {
        "file": "my_file",
        "line": 123,
        "function": "foo()"
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
    "sourceLocation": {
        "file": "my_file",
        "line": 123,
        "function": "foo()"
    }
    ...
}
```

## httpRequest
HttpRequest field is a common proto for logging HTTP requests. 

The JSON representation is as followed:
```text
{
  "requestMethod": string,
  "requestUrl": string,
  "requestSize": string,
  "status": integer,
  "responseSize": string,
  "userAgent": string,
  "remoteIp": string,
  "serverIp": string,
  "referer": string,
  "latency": string,
  "cacheLookup": boolean,
  "cacheHit": boolean,
  "cacheValidatedWithOriginServer": boolean,
  "cacheFillBytes": string,
  "protocol": string
}

```

### Use Cases
Set the input log as followed:
```text
jsonPayload {
    "logging.googleapis.com/http_request": {
        "requestMethod":"GET", 
        "requestUrl":"logging.googleapis.com", 
        "requestSize":"12", 
        "status":200, 
        "responseSize":"12", 
        "userAgent":"Mozilla", 
        "remoteIp":"255.0.0.1", 
        "serverIp":"255.0.0.1", 
        "referer":"referer", 
        "latency":"1s", 
        "cacheLookup":true, 
        "cacheHit":true, 
        "cacheValidatedWithOriginServer":true, 
        "cacheFillBytes":"12", 
        "protocol":"HTTP/1.2"
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
    "httpRequest": {
        "requestMethod":"GET", 
        "requestUrl":"logging.googleapis.com", 
        "requestSize":"12", 
        "status":200, 
        "responseSize":"12", 
        "userAgent":"Mozilla", 
        "remoteIp":"255.0.0.1", 
        "serverIp":"255.0.0.1", 
        "referer":"referer", 
        "latency":"1s", 
        "cacheLookup":true, 
        "cacheHit":true, 
        "cacheValidatedWithOriginServer":true, 
        "cacheFillBytes":"12", 
        "protocol":"HTTP/1.2"
    }
    ...
}
```

## Timestamp

We support two formats of time-related fields:

Format 1 - timestamp:
JsonPayload contains a timestamp field that includes the seconds and nanos fields.
```text
{
  "timestamp": {
    "seconds": CURRENT_SECONDS,
    "nanos": CURRENT_NANOS
  }
}
```
Format 2 - timestampSeconds/timestampNanos:
JsonPayload contains both the timestampSeconds and timestampNanos fields.
```text
{
   "timestampSeconds": CURRENT_SECONDS,
   "timestampNanos": CURRENT_NANOS
}

```

If one of the following JSON timestamp representations is present in a structured record, the Logging agent collapses them into a single representation in the timestamp field in the LogEntry object.

Without time-related fields, the logging agent will set the current time as timestamp. Supporting time-related fields enables users to get more information about the logEntry.


### Use Cases
**Format 1**
Set the input log as followed:
```text
jsonPayload {
    "timestamp": {
        "seconds": 1596149787,
        "nanos": 12345
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
    "timestamp": "2020-07-30T22:56:27.000012345Z"
    ...
}
```

**Format 2**
Set the input log as followed:
```text
jsonPayload {
    "timestampSeconds":1596149787,
    "timestampNanos": 12345
    ...
}
```
the logEntry will be:
```text
{
    "jsonPayload": {
        ...
    }
    "timestamp": "2020-07-30T22:56:27.000012345Z"
    ...
}
```
