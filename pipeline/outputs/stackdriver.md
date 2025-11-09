# Stackdriver

The _Stackdriver_ output plugin lets you ingest your records into the [Google Cloud Stackdriver Logging](https://cloud.google.com/logging/) service.

Before getting started with the plugin configuration, be sure to obtain the [proper credentials](https://cloud.google.com/logging/docs/agent/logging/authorization#create-service-account) to get access to the service. For best results, use a common JSON credentials file that can be referenced by the Stackdriver plugin.

## Configuration parameters

This plugin uses the following configuration parameters. For more details about Stackdriver-specific parameters, see the [Google Cloud `LogEntry` API documentation](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry).

| Key | Description | Default |
| --- | ----------- | ------- |
| `google_service_credentials` | Absolute path to a Google Cloud credentials JSON file. | Value of environment variable `$GOOGLE_APPLICATION_CREDENTIALS` |
| `service_account_email` | Account email associated with the service. Only available if no credentials file has been provided. | Value of environment variable `$SERVICE_ACCOUNT_EMAIL` |
| `service_account_secret` | Private key content associated with the service account. Only available if no credentials file has been provided. | Value of environment variable `$SERVICE_ACCOUNT_SECRET` |
| `metadata_server` | Prefix for a metadata server. | Value of environment variable `$METADATA_SERVER`, or `http://metadata.google.internal` if unset. |
| `location` | The GCP or AWS region in which to store data about the resource. If the resource type is either `generic_node` or `generic_task`, this field is required. | _none_ |
| `namespace` | A namespace identifier, such as a cluster name or environment. If the resource type is either `generic_node` or `generic_task`, this field is required. | _none_ |
| `node_id` | A unique identifier for the node within the namespace, such as a hostname or IP address. If the resource type is `generic_node`, this field is required. | _none_ |
| `job` | An identifier for a grouping of related task, such as the name of a microservice or distributed batch. If the resource type is `generic_task`, this field is required. | _none_ |
| `task_id` | A unique identifier for the task within the namespace and job, such as a replica index identifying the task within the job. If the resource type is `generic_task`, this field is required. | _none_ |
| `export_to_project_id` | The GCP project that should receive these logs. | The `project_id` in the `google_service_credentials` file, or the `project_id` from Google's `metadata.google.internal` server. |
| `resource` | Set resource type of data. Supported resource types: `k8s_container`, `k8s_node`, `k8s_pod`, `global`, `generic_node`, `generic_task`, and `gce_instance`. | `global`, `gce_instance` |
| `k8s_cluster_name` | The name of the cluster that the container (node or pod based on the resource type) is running in. If the resource type is `k8s_container`, `k8s_node`, or `k8s_pod`, this field is required. | _none_ |
| `k8s_cluster_location` | The physical location of the cluster that contains (node or pod based on the resource type) the container. If the resource type is `k8s_container`, `k8s_node`, or `k8s_pod`, this field is required. | _none_ |
| `labels_key` | The name of the key from the original record that contains the LogEntry's `labels`. | `logging.googleapis.com/labels` |
| `labels` | Optional list of comma-separated of strings specifying `key=value` pairs. The resulting labels will be combined with the elements obtained from `labels_key` to set the LogEntry Labels. Elements from `labels` will override duplicate values from `labels_key`. | _none_ |
| `log_name_key` | The name of the key from the original record that contains the `logName` value. | `logging.googleapis.com/logName` |
| `tag_prefix` | Set the `tag_prefix` used to validate the tag of logs with Kubernetes resource type. Without this option, the tag of the log must be in format of `k8s_container(pod/node).*` to use the `k8s_container` resource type. Now the tag prefix is configurable by this option (note the ending dot). | `k8s_container.`, `k8s_pod.`, `k8s_node.` |
| `severity_key` | The name of the key from the original record that contains the severity. | `logging.googleapis.com/severity` |
| `project_id_key` | The value of this field is used by the Stackdriver output plugin to find the GCP `projectID` from `jsonPayload` and then extract the value of it to set the `PROJECT_ID` within LogEntry `logName`, which controls the GCP project that should receive these logs. | `logging.googleapis.com/projectId`. See [Stackdriver Special Fields](https://github.com/fluent/fluent-bit-docs/blob/master/pipeline/outputs/stackdriver_special_fields.md#log-entry-fields) for more info. |
| `autoformat_stackdriver_trace` | Rewrite the _trace_ field to include the `projectID` and format it for use with Cloud Trace. When this flag is enabled, the user can get the correct result by printing only the `traceID` (usually 32 characters). | `false` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |
| `custom_k8s_regex` | Set a custom regular expression to extract field like `pod_name`, `namespace_name`, `container_name`, and `docker_id` from the `local_resource_id` in logs. This is helpful if the value of pod or node name contains dots. | `(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$` |
| `resource_labels` | An optional list of comma-separated strings specifying resource label plain text assignments (`new=value`) and mappings from an original field in the log entry to a destination field (`destination=$original`). Nested fields and environment variables are also supported using the [record accessor syntax](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor). If configured, all resource labels will be assigned using this API only, with the exception of `project_id`. See [Resource Labels](#resource-labels) for more details. | _none_ |
| `http_request_key` | The name of the key from the original record that contains the LogEntry's `httpRequest`. Be aware that the default value erroneously uses an underscore; users will likely need to set this to `logging.googleapis.com/httpRequest`. | `logging.googleapis.com/http_request` |
| `compress` | Set payload compression mechanism. The only available option is `gzip`. If no value is specified, no compression is applied. | _none_ |
| `cloud_logging_base_url` | Set the base Cloud Logging API URL to use for the `/v2/entries:write` API request. | `https://logging.googleapis.com` |

## Configuration file

If you are using a Google Cloud Credentials File, the following configuration is enough to get started:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: stackdriver
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  cpu
  Tag   cpu

[OUTPUT]
  Name        stackdriver
  Match       *
```

{% endtab %}
{% endtabs %}

### Example configuration file for Kubernetes resource types

The `local_resource_id` value is used by the Stackdriver output plugin to set the labels field for different Kubernetes resource types. Stackdriver plugin will try to find the `local_resource_id` field in the log entry. If there is no field `logging.googleapis.com/local_resource_id` in the log, the plugin will then construct it by using the tag value of the log.

The `local_resource_id` should be in format:

- `k8s_container.<namespace_name>.<pod_name>.<container_name>`
- `k8s_node.<node_name>`
- `k8s_pod.<namespace_name>.<pod_name>`

This implies that if there is no `local_resource_id` in the log entry then the tag of logs should match this format. Be aware that there is a `tag_prefix` option, so it's not mandatory to use `k8s_container(node/pod)` as the prefix for tag.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag_regex: 'var.log.containers.(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$'
      tag: custom_tag.<namespace_name>.<pod_name>.<container_name>
      path: /var/log/containers/*.log
      parser: docker
      db: /var/log/fluent-bit-k8s-container.db

  outputs:
    - name: stackdriver
      match: 'custom_tag.*'
      resource: k8s_container
      k8s_cluster_name: test_cluster_name
      k8s_cluster_location: test_cluster_location
      tag_prefix: 'custom_tag.'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name               tail
  Tag_Regex          var.log.containers.(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$
  Tag                custom_tag.<namespace_name>.<pod_name>.<container_name>
  Path               /var/log/containers/*.log
  Parser             docker
  DB                 /var/log/fluent-bit-k8s-container.db

[OUTPUT]
  Name                  stackdriver
  Match                 custom_tag.*
  Resource              k8s_container
  k8s_cluster_name      test_cluster_name
  k8s_cluster_location  test_cluster_location
  tag_prefix            custom_tag.
```

{% endtab %}
{% endtabs %}

## Resource labels

Fluent Bit uses the following methods to assign fields to the resource/labels section:

1. Resource Labels API
2. Monitored Resource API
3. Local Resource ID
4. Credentials / Config Parameters

If `resource_labels` is correctly configured, then Fluent Bit will attempt to populate all resource labels using the entries specified. Otherwise, Fluent Bit will attempt to use the monitored resource API. Similarly, if the monitored resource API can't be used, then Fluent Bit will attempt to populate resource/labels using configuration parameters and credentials specific to the resource type. As mentioned in the [configuration file](#configuration-file) section, Fluent Bit will attempt to use or construct a local resource ID for a Kubernetes resource type that doesn't use the resource labels or monitored resource API.

{% hint style="info" %}

The `project_id` resource label will always be set from the service credentials or fetched from the metadata server. It can't be overridden.

{% endhint %}

### Use the `resource_labels` parameter

The `resource_labels` configuration parameter offers an alternative API for assigning the resource labels. To use, input a list of comma-separated strings specifying resource labels plain text assignments (`new=value`), mappings from an original field in the log entry to a destination field (`destination=$original`) and environment variable assignments (`new=${var}`).

For instance, consider the following log entry:

```json
{
  "keyA": "valA",
  "toplevel": {
    "keyB": "valB"
  }
}
```

Combined with the following Fluent Bit Stackdriver output plugin configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: stackdriver
      match: '*'
      resource_labels: keyC=$keyA,keyD=$toplevel['keyB'],keyE=valC
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name             stackdriver
  Match            *
  Resource_Labels  keyC=$keyA,keyD=$toplevel['keyB'],keyE=valC
```

{% endtab %}
{% endtabs %}

This will produce the following log:

```json
{
  "resource": {
    "type": "global",
    "labels": {
      "project_id": "fluent-bit",
      "keyC": "valA",
      "keyD": "valB",
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
      }
    }
  ]
}
```

This makes the `resource_labels` API the recommended choice for supporting new or existing resource types that have all resource labels known before runtime or available on the payload during runtime.

For instance, for a Kubernetes resource type, `resource_labels` can be used in tandem with the [Kubernetes filter](https://docs.fluentbit.io/manual/pipeline/filters/kubernetes) to pack all six resource labels. The following example shows what this could look like for a `k8s_container` resource:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: stackdriver
      match: '*'
      resource: k8s_container
      resource_labels: cluster_name=my-cluster,location=us-central1-c,container_name=$kubernetes['container_name'],namespace_name=$kubernetes['namespace_name'],pod_name=$kubernetes['pod_name']
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name            stackdriver
  Match           *
  Resource        k8s_container
  Resource_Labels cluster_name=my-cluster,location=us-central1-c,container_name=$kubernetes['container_name'],namespace_name=$kubernetes['namespace_name'],pod_name=$kubernetes['pod_name']
```

{% endtab %}
{% endtabs %}

The `resource_labels` parameter also supports validation for required labels based on the input resource type. This allows Fluent Bit to check if all specified labels are present for a given configuration before runtime. If validation isn't supported for a resource type that you want to use this API with, open a pull request for it. Adding validation for a new resource type involves specifying the resources associated with the type alongside the [required labels](https://github.com/fluent/fluent-bit/blob/master/plugins/out_stackdriver/stackdriver_resource_types.c#L27).

## Log names

By default, the plugin will write to the following log name:

```text
/projects/<project ID>/logs/<log tag>
```

You might be in a scenario where being more specific about the log name is important (for example, [integration with Log Router rules](https://cloud.google.com/logging/docs/routing/overview) or [controlling cardinality of log based metrics](https://cloud.google.com/logging/docs/logs-based-metrics/troubleshooting#too-many-time-series)). You can control the log name directly on a per-log basis by using the [`logging.googleapis.com/logName` special field](https://github.com/fluent/fluent-bit-docs/blob/master/pipeline/outputs/stackdriver_special_fields.md#log-entry-fields). You can configure a `log_name_key` if you'd like to use something different from `logging.googleapis.com/logName`. For example, if the `log_name_key` is set to `mylognamefield` will extract the log name from `mylognamefield` in the log.

## Troubleshooting

### Upstream connection error

An upstream connection error means Fluent Bit wasn't able to reach Google services. In that case, the error message looks like this:

```text
[2019/01/07 23:24:09] [error] [oauth2] could not get an upstream connection
```

This is due to a network issue in the environment where Fluent Bit is running. Make sure that the Host, Container or Pod can reach the following Google endpoints:

- [https://www.googleapis.com](https://www.googleapis.com)
- [https://logging.googleapis.com](https://logging.googleapis.com)

{% hint style="warning" %}

For more details, see GitHub reference: [#761](https://github.com/fluent/fluent-bit/issues/761)

{% endhint %}

### Fail to process `local_resource_id`

The error looks like this:

```text
[2020/08/04 14:43:03] [error] [output:stackdriver:stackdriver.0] fail to process local_resource_id from log entry for k8s_container
```

Check the following:

- If the log entry doesn't contain the `local_resource_id` field, does the tag of the log match for format?
- If `tag_prefix` is configured, does the prefix of tag specified in the input plugin match the `tag_prefix`?

## Other Implementations

Stackdriver officially supports a [logging agent based on Fluentd](https://cloud.google.com/logging/docs/agent).

Fluent Bit plans to support some [special fields in structured payloads](https://cloud.google.com/logging/docs/agent/configuration#special-fields). For more information, see the documentation about [Stackdriver Special Fields](./stackdriver_special_fields.md#log-entry-fields).
