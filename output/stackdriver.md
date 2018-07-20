# Stackdriver Logging

Stackdriver output plugin allows to ingest your records into [Google Cloud Stackdriver Logging](https://cloud.google.com/logging/) service.

Before to get started with the plugin configuration, make sure to obtain the proper credentials to get access to the service. We strongly recommend to use a common JSON credentials file, reference link:

- [Creating a Google Service Account for Stackdriver](https://cloud.google.com/logging/docs/agent/authorization#create-service-account)

> Your goal is to obtain a credentials JSON file that will be used later by Fluent Bit Stackdriver output plugin.

## Configuration Parameters

| Key                        | Description                                                      | default   |
| -------------------------- | -----------------------------------------------------------------| --------- |
| google_service_credentials | Absolute path to a Google Cloud credentials JSON file  | Value of environment variable _$GOOGLE_SERVICE_CREDENTIALS_ |
| service_account_email      | Account email associated to the service. Only available if __no credentials file__ has been provided. | Value of environment variable _$SERVICE_ACCOUNT_EMAIL_ |
| service_account_secret     | Private key content associated with the service account. Only available if __no credentials file__ has been provided. | Value of environment variable _$SERVICE_ACCOUNT_SECRET_ |
| resource                   | Set resource type of data. Only _global_ is supported. | global |

### Configuration File

If you are using a _Google Cloud Credentials File_, the following configuration is enough to get started:

```
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name        stackdriver
    Match       *
```
