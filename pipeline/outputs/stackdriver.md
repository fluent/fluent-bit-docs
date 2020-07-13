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
| resource | Set resource type of data. Supported resource types: _k8s\_container_, _k8s\_node_, _k8s\_pod_, _global_ and _gce\_instance_. | global, gce\_instance |
| k8s\_cluster\_name | The name of the cluster that the container \(node or pod based on the resource type\) is running in. If the resource type is one of the _k8s\_container_, _k8s\_node_ or _k8s\_pod_, then this field is required. |  |
| k8s\_cluster\_location | The physical location of the cluster that contains \(node or pod based on the resource type\) the container. If the resource type is one of the _k8s\_container_, _k8s\_node_ or _k8s\_pod_, then this field is required. |  |
| labels\_key | The value of this field is used by the Stackdriver output plugin to find the related labels from jsonPayload and then extract the value of it to set the LogEntry Labels. | logging.googleapis.com/labels |

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

## Troubleshooting Notes

### Upstream connection error

> Github reference: [\#761](https://github.com/fluent/fluent-bit/issues/761)

An upstream connection error means Fluent Bit was not able to reach Google services, the error looks like this:

```text
[2019/01/07 23:24:09] [error] [oauth2] could not get an upstream connection
```

This belongs to a network issue by the environment where Fluent Bit is running, make sure that from the Host, Container or Pod you can reach the following Google end-points:

* [https://www.googleapis.com](https://www.googleapis.com/)
* [https://logging.googleapis.com](https://logging.googleapis.com/)

## Other implementations

Stackdriver officially supports a [logging agent based on Fluentd](https://cloud.google.com/logging/docs/agent).

We plan te support some [special fields in structured payloads](https://cloud.google.com/logging/docs/agent/configuration#special-fields).

Currently, we have supported [operation](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logentryoperation). See some use cases of operation [here](https://github.com/fluent/fluent-bit-docs/tree/821f28830510947b6ec4b23406cfdfbfea6fdf31/pipeline/outputs/stackdriver_special_fields.md).

