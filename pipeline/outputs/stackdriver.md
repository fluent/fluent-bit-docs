# Stackdriver

Stackdriver output plugin allows to ingest your records into [Google Cloud Stackdriver Logging](https://cloud.google.com/logging/) service.

Before to get started with the plugin configuration, make sure to obtain the proper credentials to get access to the service. We strongly recommend to use a common JSON credentials file, reference link:

* [Creating a Google Service Account for Stackdriver](https://cloud.google.com/logging/docs/agent/authorization#create-service-account)

> Your goal is to obtain a credentials JSON file that will be used later by Fluent Bit Stackdriver output plugin.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| google\_service\_credentials | Absolute path to a Google Cloud credentials JSON file | Value of environment variable _$GOOGLE\_APPLICATION\_CREDENTIALS_ |
| service\_account\_email | Account email associated to the service. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_EMAIL_ |
| service\_account\_secret | Private key content associated with the service account. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_SECRET_ |
| metadata\_server | Prefix for a metadata server. Can also set environment variable _$METADATA\_SERVER_. | [http://metadata.google.internal](http://metadata.google.internal) |
| location | The GCP or AWS region in which to store data about the resource. If the resource type is one of the _generic\_node_ or _generic\_task_, then this field is required. |  |
| namespace | A namespace identifier, such as a cluster name or environment. If the resource type is one of the _generic\_node_ or _generic\_task_, then this field is required. |  |
| node\_id | A unique identifier for the node within the namespace, such as hostname or IP address. If the resource type is _generic\_node_, then this field is required. |  |
| job | An identifier for a grouping of related task, such as the name of a microservice or distributed batch. If the resource type is _generic\_task_, then this field is required. |  |
| task\_id | A unique identifier for the task within the namespace and job, such as a replica index identifying the task within the job. If the resource type is _generic\_task_, then this field is required. |  |
| export\_to\_project\_id | The GCP project that should receive these logs. | Defaults to the project ID of the google\_service\_credentials file, or the project\_id from Google's metadata.google.internal server. |
| resource | Set resource type of data. Supported resource types: _k8s\_container_, _k8s\_node_, _k8s\_pod_, _global_, _generic\_node_, _generic\_task_, and _gce\_instance_. | global, gce\_instance |
| k8s\_cluster\_name | The name of the cluster that the container \(node or pod based on the resource type\) is running in. If the resource type is one of the _k8s\_container_, _k8s\_node_ or _k8s\_pod_, then this field is required. |  |
| k8s\_cluster\_location | The physical location of the cluster that contains \(node or pod based on the resource type\) the container. If the resource type is one of the _k8s\_container_, _k8s\_node_ or _k8s\_pod_, then this field is required. |  |
| labels\_key | The value of this field is used by the Stackdriver output plugin to find the related labels from jsonPayload and then extract the value of it to set the LogEntry Labels. | logging.googleapis.com/labels |
| labels | Optional list of comma separated of strings specifying `key=value` pairs. The resulting `labels` will be combined with the elements in obtained from `labels\_key` to set the LogEntry Labels. Elements from `labels` will override duplicate values from `labels\_key`.|  |
| log\_name\_key | The value of this field is used by the Stackdriver output plugin to extract logName from jsonPayload and set the logName field. | logging.googleapis.com/logName |
| tag\_prefix | Set the tag\_prefix used to validate the tag of logs with k8s resource type. Without this option, the tag of the log must be in format of k8s\_container\(pod/node\).\* in order to use the k8s\_container resource type. Now the tag prefix is configurable by this option \(note the ending dot\). | k8s\_container., k8s\_pod., k8s\_node. |
| severity\_key | Specify the name of the key from the original record that contains the severity information. |  |
| autoformat\_stackdriver\_trace | Rewrite the _trace_ field to include the projectID and format it for use with Cloud Trace. When this flag is enabled, the user can get the correct result by printing only the traceID (usually 32 characters). | false |
| Workers | Enables dedicated thread(s) for this output. Default value is set since version 1.8.13. For previous versions is 0. | 2 |
| custom\_k8s\_regex | Set a custom regex to extract field like pod\_name, namespace\_name, container\_name and docker\_id from the local\_resource\_id in logs. This is helpful if the value of pod or node name contains dots. | `(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$` |
| resource_labels | An optional list of comma separated strings specifying resource labels plaintext assignments (`new=value`) and/or mappings from an original field in the log entry to a destination field (`destination=$original`). Nested fields and environment variables are also supported using the [record accessor syntax](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor). If configured, *all* resource labels will be assigned using this API only, with the exception of `project_id`. See [Resource Labels](#resource-labels) for more details. | |

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

Example configuration file for k8s resource type:

local_resource_id is used by stackdriver output plugin to set the labels field for different k8s resource types. Stackdriver plugin will try to find the local_resource_id field in the log entry. If there is no field logging.googleapis.com/local_resource_id in the log, the plugin will then construct it by using the tag value of the log.

The local_resource_id should be in format:

* `k8s_container.<namespace_name>.<pod_name>.<container_name>`
* `k8s_node.<node_name>`
* `k8s_pod.<namespace_name>.<pod_name>`

This implies that if there is no local_resource_id in the log entry then the tag of logs should match this format. Note that we have an option tag_prefix so it is not mandatory to use k8s_container(node/pod) as the prefix for tag.

```
[INPUT]
    Name               tail
    Tag_Regex          var.log.containers.(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$
    Tag                custom_tag.<namespace_name>.<pod_name>.<container_name>
    Path               /var/log/containers/*.log
    Parser             docker
    DB                 /var/log/fluent-bit-k8s-container.db

[OUTPUT]
    Name        stackdriver
    Match       custom_tag.*
    Resource    k8s_container
    k8s_cluster_name test_cluster_name
    k8s_cluster_location  test_cluster_location
    tag_prefix  custom_tag.
```

## Resource Labels

Currently, there are four ways which fluent-bit uses to assign fields into the resource/labels section.

1. Resource Labels API
2. Monitored Resource API
3. Local Resource Id
4. Credentials / Config Parameters

If `resource_labels` is correctly configured, then fluent-bit will attempt to populate all resource/labels using the entries specified. Otherwise, fluent-bit will attempt to use the monitored resource API. Similarly, if the monitored resource API cannot be used, then fluent-bit will attempt to populate resource/labels using configuration parameters and/or credentials specific to the resource type. As mentioned in the [Configuration File](#configuration-file) section, fluent-bit will attempt to use or construct a local resource ID for a K8s resource type which does not use the resource labels or monitored resource API.

Note that the `project_id` resource label will always be set from the service credentials or fetched from the metadata server and cannot be overridden.

### Using the resource_labels parameter

The `resource_labels` configuration parameter offers an alternative API for assigning the resource labels. To use, input a list of comma separated strings specifying resource labels plaintext assignments (`new=value`), mappings from an original field in the log entry to a destination field (`destination=$original`) and/or environment variable assignments (`new=${var}`).

For instance, consider the following log entry:
```
{
  "keyA": "valA",
  "toplevel": {
    "keyB": "valB"
  }
}
```

Combined with the following Stackdriver configuration:
```
[OUTPUT]
    Name stackdriver
    Match *
    Resource_Labels  keyC=$keyA,keyD=$toplevel['keyB'],keyE=valC
```

This will produce the following log:
```
{
  "resource": {
    "type": "global",
    "labels": {
      "project_id": "fluent-bit",
      "keyC": "valA",
      "keyD": "valB"
      "keyE": "valC"
    }
  },
  "entries": [
    {
      "jsonPayload": {
        "keyA": "valA",
        "toplevel": {
           "keyB": "valB"
        }
      },
    }
  ]
}
```

This makes the `resource_labels` API the recommended choice for supporting new or existing resource types that have all resource labels known before runtime or available on the payload during runtime. 

For instance, for a K8s resource type, `resource_labels` can be used in tandem with the [Kubernetes filter](https://docs.fluentbit.io/manual/pipeline/filters/kubernetes) to pack all six resource labels. Below is an example of what this could look like for a `k8s_container` resource:


```
[OUTPUT]
    Name            stackdriver
    Match           *
    Resource        k8s_container
    Resource_Labels cluster_name=my-cluster,location=us-central1-c,container_name=$kubernetes['container_name'],namespace_name=$kubernetes['namespace_name'],pod_name=$kubernetes['pod_name']
```

`resource_labels` also supports validation for required labels based on the input resource type. This allows fluent-bit to check if all specified labels are present for a given configuration before runtime. If validation is not currently supported for a resource type that you would like to use this API with, we encourage you to open a pull request for it. Adding validation for a new resource type is simple - all that is needed is to specify the resources associated with the type alongside the required labels [here](https://github.com/fluent/fluent-bit/blob/master/plugins/out_stackdriver/stackdriver_resource_types.c#L27).
## Troubleshooting Notes

### Upstream connection error

> Github reference: [#761](https://github.com/fluent/fluent-bit/issues/761)

An upstream connection error means Fluent Bit was not able to reach Google services, the error looks like this:

```
[2019/01/07 23:24:09] [error] [oauth2] could not get an upstream connection
```

This belongs to a network issue by the environment where Fluent Bit is running, make sure that from the Host, Container or Pod you can reach the following Google end-points:

* [https://www.googleapis.com](https://www.googleapis.com)
* [https://logging.googleapis.com](https://logging.googleapis.com)

### Fail to process local_resource_id

The error looks like this:

```
[2020/08/04 14:43:03] [error] [output:stackdriver:stackdriver.0] fail to process local_resource_id from log entry for k8s_container
```

Do following check:

* If the log entry does not contain the local_resource_id field, does the tag of the log match for format?
*   If tag_prefix is configured, does the prefix of tag specified in the input plugin match the tag_prefix?

    **Other implementations**

Stackdriver officially supports a [logging agent based on Fluentd](https://cloud.google.com/logging/docs/agent).

We plan to support some [special fields in structured payloads](https://cloud.google.com/logging/docs/agent/configuration#special-fields). Use cases of special fields is [here](./stackdriver_special_fields.md).
