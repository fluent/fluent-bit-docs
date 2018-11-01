# Stackdriver

Stackdriver output plugin allows to ingest your records into [Google Cloud Stackdriver Logging](https://cloud.google.com/logging/) service.

Before to get started with the plugin configuration, make sure to obtain the proper credentials to get access to the service. We strongly recommend to use a common JSON credentials file, reference link:

* [Creating a Google Service Account for Stackdriver](https://cloud.google.com/logging/docs/agent/authorization#create-service-account)

> Your goal is to obtain a credentials JSON file that will be used later by Fluent Bit Stackdriver output plugin.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| google\_service\_credentials | Absolute path to a Google Cloud credentials JSON file | Value of environment variable _$GOOGLE\_SERVICE\_CREDENTIALS_ |
| service\_account\_email | Account email associated to the service. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_EMAIL_ |
| service\_account\_secret | Private key content associated with the service account. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_SECRET_ |
| resource | Set resource type of data. Only _global_ is supported. | global |

### Configuration File

If you are using a _Google Cloud Credentials File_, the following configuration is enough to get started:

```text
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name        stackdriver
    Match       *
```

## Other implementations

Stackdriver officially supports a [logging agent based on Fluentd](https://cloud.google.com/logging/docs/agent).
