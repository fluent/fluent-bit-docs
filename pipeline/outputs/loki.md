# Loki

[Loki](https://grafana.com/oss/loki/) is multi-tenant log aggregation system inspired by Prometheus.

The Fluent Bit _Loki_ built-in output plugin lets you send your log or events to a Loki service.
It supports data enrichment with Kubernetes labels, custom label keys, and Tenant ID, along with other information.

There is a separate Golang output plugin provided by [Grafana](https://grafana.com/docs/loki/latest/clients/fluentbit/) with different configuration options.

## Configuration parameters

| Key | Description | Default |
|:----|:------------|:--------|
| `host` | Loki base hostname or IP address. Don't include the sub-path, only the base hostname or URL.  | `127.0.0.1`         |
| `uri`  | Specify a custom HTTP URI. It must start with a forward slash (`/`).| `/loki/api/v1/push` |
| `port` | The Loki TCP port. | `3100` |
| `tls` | Use TLS authentication. | `off` |
| `http_user` | Set HTTP basic authentication user name. | _none_ |
| `http_passwd` | Set HTTP basic authentication password. | _none_ |
| `bearer_token` | Set bearer token authentication token value. | _none_ |
| `header` | Add additional arbitrary HTTP header key/value pair. Multiple headers can be set. | _none_ |
| `tenant_id` | Tenant ID used by default to push logs to Loki. If omitted or empty it assumes Loki is running in single-tenant mode and no `X-Scope-OrgID` header is sent. | _none_ |
| `labels` | Stream labels for API request. It can be multiple comma separated of strings specifying `key=value` pairs. Allows fixed parameters, or adding custom record keys (similar to the `label_keys` property). See the Labels section. | `job=fluent-bit` |
| `label_keys` | (Optional.) List of record keys that will be placed as stream labels. This configuration property is for records key only. See the Labels section. | _none_ |
| `label_map_path` | Specify the label map path. The file defines how to extract labels from each record. See the Labels section. | _none_ |
| `structured_metadata` | (Optional.) Comma-separated list of `key=value` strings specifying structured metadata for the log line. Like the `labels` parameter, values can reference record keys using record accessors. See [Structured metadata](#structured_metadata). | _none_ |
| `structured_metadata_map_keys` | (Optional.) Comma-separated list of record key strings specifying record values of type `map`, used to dynamically populate structured metadata for the log line. Values can only reference record keys using record accessors, which should reference map values. Each entry from the referenced map will be used to add an entry to the structured metadata. See [Structured metadata](#structured_metadata). | _none_ |
| `remove_keys` | (Optional.) List of keys to remove. | _none_ |
| `drop_single_key` | When set to `true` and after extracting labels only a single key remains, the log line sent to Loki will be the value of that key in `line_format`. If set to `raw` and the log line is a string, the log line will be sent unquoted. | `off` |
| `line_format` | Format to use when flattening the record to a log line. Valid values are `json` or `key_value`. If set to `json`, the log line sent to Loki will be the Fluent Bit record dumped as JSON. If set to `key_value`, the log line will be each item in the record concatenated together (separated by a single space) in the format. | `json` |
| `auto_kubernetes_labels` | If set to `true`, adds all Kubernetes labels to the Stream labels. | `off` |
| `tenant_id_key` | Specify the name of the key from the original record that contains the Tenant ID. The value of the key is set as `X-Scope-OrgID` of HTTP header. Use to set Tenant ID dynamically. | _none_ |
| `compress` | Set payload compression mechanism. The only available option is `gzip`. | `""` (no compression) |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

## Labels

Loki stores the record logs inside Streams. A _stream_ is defined by a set of labels, at least one label is required.

Fluent Bit implements a flexible mechanism to set labels by using fixed key/value pairs of text. It also allows setting as labels certain keys that exists as part of the records that are being processed.

Consider the following JSON record (pretty printed for readability):

```javascript
{
    "key": 1,
    "sub": {
        "stream": "stdout",
        "id": "some id"
    },
    "kubernetes": {
        "labels": {
            "team": "Santiago Wanderers"
        }
    }
}
```

If you decide that your Loki Stream will be composed by two labels called `job` and the value of the record key called `stream` , your `labels` configuration properties might look as follows:

```python
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, $sub['stream']
```

The label `job` has the value `fluentbit` and the second label is configured to access the nested map called `sub` targeting the value of the key `stream` .

The second label name must start with a dollar sign `$`, meaning it's a [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) pattern which provides the ability to retrieve values from nested maps by using the key names.

When processing the previous configuration, internally the ending labels for the stream in question becomes:

```text
job="fluentbit", stream="stdout"
```

Another feature of Labels management is the ability to provide custom key names. Using the same record accessor pattern you can specify the key name manually and let the value populate automatically at runtime:

```python
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, mystream=$sub['stream']
```

When processing that new configuration, the internal labels will be:

```text
job="fluentbit", mystream="stdout"
```

### Use `label_keys`

The `label_keys` configuration property lets you specify multiple record keys which need to be placed as part of the outgoing Stream Labels.
This is another way to set a record key in the Stream, but with the limitation that you can't use a custom name for the key value.

The following configuration examples generate the same Stream Labels:

```python
[OUTPUT]
    name       loki
    match      *
    labels     job=fluentbit
    label_keys $sub['stream']
```

The previous configuration accomplishes the same as this one:

```python
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, $sub['stream']
```

Both generate the following Streams label:

```text
job="fluentbit", stream="stdout"
```

### Use `label_map_path`

The `label_map_path` configuration property reads a JSON file that defines how to extract labels from each record.

The file should contain a JSON object. Each key defines how to get label value from a nested record. Each value is used as a label name.

The following configuration examples generate the same Stream Labels:

`map.json`:

```json
{
    "sub": {
           "stream": "stream"
    }
}
```

Add the JSON path to the plugin output configuration:

```python
[OUTPUT]
    name   loki
    match  *
    label_map_path /path/to/map.json
```

The previous configurations accomplish the same as this one:

```python
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, $sub['stream']
```

Both will generate the following Streams label:

```text
job="fluentbit", stream="stdout"
```

#### Kubernetes and labels

If you are running in a Kubernetes environment, consider enabling the `auto_kubernetes_labels` option, which auto-populates the streams with the Pod labels for you. Consider the following configuration:

```python
[OUTPUT]
    name                   loki
    match                  *
    labels                 job=fluentbit
    auto_kubernetes_labels on
```

Based on the JSON example provided, the internal stream labels will be:

```text
job="fluentbit", team="Santiago Wanderers"
```

## Use `drop_single_key`

If there is only one key remaining after removing keys, you can use the `drop_single_key` property to send its value to Loki, rather than a single `key=value` pair.

Consider this JSON example:

```json
{"key":"value"}
```

If the value is a string, `line_format` is `json`, and `drop_single_key` is `true`, it will be sent as a quoted string.

```python
[OUTPUT]
    name            loki
    match           *
    drop_single_key on
    line_format     json
```

The outputted line would show in Loki as:

```json
"value"
```

If `drop_single_key` is `raw`, or `line_format` is `key_value`, it will show in Loki as:

```text
value
```

If you want both structured JSON and plain text logs in Loki, you should set `drop_single_key` to `raw` and `line_format` to `json`.
Loki doesn't interpret a quoted string as valid JSON.T o remove the quotes without `drop_single_key` set to `raw`, you would need to use a query like this:

```C
{"job"="fluent-bit"} | regexp `^"?(?P<log>.*?)"?$` | line_format "{{.log}}"
```

If `drop_single_key` is `off`, it will show in Loki as:

```json
{"key":"value"}
```

You can get the same behavior this flag provides in Loki with `drop_single_key` set to `off` with this query:

```C
{"job"="fluent-bit"} | json | line_format "{{.log}}"
```

## Use `structured_metadata`

[Structured metadata](https://grafana.com/docs/loki/latest/get-started/labels/structured-metadata/) lets you attach custom fields to individual log lines without embedding the information in the content of the log line. This capability works well for high cardinality data that isn't suited for using labels. While not a label, the `structured_metadata` configuration parameter operates similarly to the `labels` parameter. Both parameters are comma-delimited `key=value` lists, and both can use record accessors to reference keys within the record being processed.

The following configuration:

- Defines fixed values for the cluster and region labels.
- Uses the record accessor pattern to set the namespace label to the namespace name as
  determined by the Kubernetes metadata filter (not shown).
- Uses a structured metadata field to hold the Kubernetes pod name.

```python
[OUTPUT]
    name                loki
    match               *
    labels              cluster=my-k8s-cluster, region=us-east-1, namespace=$kubernetes['namespace_name']
    structured_metadata pod=$kubernetes['pod_name']
```

Other common uses for structured metadata include trace and span IDs, process and thread IDs, and log levels.

Structured metadata is officially supported starting with Loki 3.0, and shouldn't be used
with Loki deployments prior to Loki 3.0.

### Structured metadata maps

In addition to the `structured_metadata` configuration parameter, a `structured_metadata_map_keys` is available, which can be used to dynamically populate structured metadata from map values in the log record. `structured_metadata_map_keys` can be set with a list of record accessors, where each one should reference map values in the log record. Record accessors which don't match a map value will be skipped.

The following configuration is similar to the previous example, except now all entries in the log record map value `$kubernetes` will be used as structured metadata entries.

{% tabs %}
{% tab title="fluent-bit.conf" %}

```python
[OUTPUT]
    name                         loki
    match                        *
    labels                       cluster=my-k8s-cluster, region=us-east-1
    structured_metadata_map_keys $kubernetes
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```yaml
  outputs:
    - name:                         loki
      match:                        *
      labels:                       cluster=my-k8s-cluster, region=us-east-1
      structured_metadata_map_keys: $kubernetes
```

{% endtab %}
{% endtabs %}

Assuming the value `$kubernetes` is a map containing two entries `namespace_name` and `pod_name`, the previous configuration is equivalent to:

{% tabs %}
{% tab title="fluent-bit.conf" %}

```python
[OUTPUT]
    name                loki
    match               *
    labels              cluster=my-k8s-cluster, region=us-east-1
    structured_metadata $kubernetes['namespace_name'],$kubernetes['pod_name']
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```yaml
  outputs:
    - name:                loki
      match:               *
      labels:              cluster=my-k8s-cluster, region=us-east-1
      structured_metadata: $kubernetes['namespace_name'], $kubernetes['pod_name']
```

{% endtab %}
{% endtabs %}

## Networking and TLS Configuration

This plugin inherits core Fluent Bit features to customize the network behavior and optionally enable TLS in the communication channel. For more details about the specific options available refer to the following articles:

- [Networking Setup](../../administration/networking.md): timeouts, keepalive and source address
- [Security and TLS](../../administration/transport-security.md): all about TLS configuration and certificates

All options mentioned in these articles must be enabled in the plugin configuration in question.

### Fluent Bit and Grafana Cloud

Fluent Bit supports sending logs and metrics to [Grafana Cloud](https://grafana.com/products/cloud/) by providing the appropriate URL and ensuring TLS is enabled.

An example configuration, set the credentials and ensure the host URL matches the correct one for your deployment:

```python
    [OUTPUT]
        Name        loki
        Match       *
        Host        logs-prod-eu-west-0.grafana.net
        port        443
        tls         on
        tls.verify  on
        http_user   XXX
        http_passwd XXX
```

## Get Started

The following configuration example emits a dummy example record and ingests it on Loki .
Copy and paste the following content into a file called `out_loki.conf`:

```python
[SERVICE]
    flush     1
    log_level info

[INPUT]
    name      dummy
    dummy     {"key": 1, "sub": {"stream": "stdout", "id": "some id"}, "kubernetes": {"labels": {"team": "Santiago Wanderers"}}}
    samples   1

[OUTPUT]
    name                   loki
    match                  *
    host                   127.0.0.1
    port                   3100
    labels                 job=fluentbit
    label_keys             $sub['stream']
    auto_kubernetes_labels on
```

Run Fluent Bit with the new configuration file:

```shell
fluent-bit -c out_loki.conf
```

Which returns output that similar to the following:

```text
Fluent Bit v1.7.0
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2020/10/14 20:57:45] [ info] [engine] started (pid=809736)
[2020/10/14 20:57:45] [ info] [storage] version=1.0.6, initializing...
[2020/10/14 20:57:45] [ info] [storage] in-memory
[2020/10/14 20:57:45] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2020/10/14 20:57:45] [ info] [output:loki:loki.0] configured, hostname=127.0.0.1:3100
[2020/10/14 20:57:45] [ info] [sp] stream processor started
[2020/10/14 20:57:46] [debug] [http] request payload (272 bytes)
[2020/10/14 20:57:46] [ info] [output:loki:loki.0] 127.0.0.1:3100, HTTP status=204
```
