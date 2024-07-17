# Loki

[Loki](https://grafana.com/oss/loki/) is multi-tenant log aggregation system inspired by Prometheus.
It is designed to be very cost effective and easy to operate.

The Fluent Bit `loki` built-in output plugin allows you to send your log or events to a Loki service.
It supports data enrichment with Kubernetes labels, custom label keys and Tenant ID within others.

Be aware there is a separate Golang output plugin provided by [Grafana](https://grafana.com/docs/loki/latest/clients/fluentbit/) with different configuration options.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| host | Loki hostname or IP address. Do not include the subpath, i.e. `loki/api/v1/push`, but just the base hostname/URL.  | 127.0.0.1 |
| uri | Specify a custom HTTP URI. It must start with forward slash.| /loki/api/v1/push |
| port | Loki TCP port | 3100 |
| tls | Use TLS authentication | off |
| http\_user | Set HTTP basic authentication user name |  |
| http\_passwd | Set HTTP basic authentication password |  |
| bearer\_token | Set bearer token authentication token value. |  |
| header | Add additional arbitrary HTTP header key/value pair. Multiple headers can be set. |  |
| tenant\_id | Tenant ID used by default to push logs to Loki. If omitted or empty it assumes Loki is running in single-tenant mode and no X-Scope-OrgID header is sent. |  |
| labels | Stream labels for API request. It can be multiple comma separated of strings specifying  `key=value` pairs. In addition to fixed parameters, it also allows to add custom record keys \(similar to `label_keys` property\). More details in the Labels section. | job=fluent-bit |
| label\_keys | Optional list of record keys that will be placed as stream labels. This configuration property is for records key only. More details in the Labels section. |  |
| label\_map\_path | Specify the label map file path. The file defines how to extract labels from each record. More details in the Labels section. | |
| structured\_metadata | Optional comma-separated list of `key=value` strings specifying structured metadata for the log line. Like the `labels` parameter, values can reference record keys using record accessors. See [Structured metadata](#structured-metadata) for more information. | |
| remove\_keys | Optional list of keys to remove. | |
| drop\_single\_key | If set to true and after extracting labels only a single key remains, the log line sent to Loki will be the value of that key in line\_format. | off |
| line\_format | Format to use when flattening the record to a log line. Valid values are `json` or `key_value`. If set to `json`,  the log line sent to Loki will be the Fluent Bit record dumped as JSON. If set to `key_value`, the log line will be each item in the record concatenated together \(separated by a single space\) in the format. | json |
| auto\_kubernetes\_labels | If set to true, it will add all Kubernetes labels to the Stream labels | off |
| tenant\_id\_key | Specify the name of the key from the original record that contains the Tenant ID. The value of the key is set as `X-Scope-OrgID` of HTTP header. It is useful to set Tenant ID dynamically. ||
| compress | Set payload compression mechanism. The only available option is gzip. Default = "", which means no compression. ||

## Labels

Loki store the record logs inside Streams, a stream is defined by a set of labels, at least one label is required.

Fluent Bit implements a flexible mechanism to set labels by using fixed key/value pairs of text but also allowing to set as labels certain keys that exists as part of the records that are being processed.
Consider the following JSON record \(pretty printed for readability\):

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

As you can see the label `job` has the value `fluentbit` and the second label is configured to access the nested map called `sub` targeting the value of the key `stream` .
Note that the second label name **must** starts with a `$`, that means that's a [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) pattern so it provide you the ability to retrieve values from nested maps by using the key names.

When processing above's configuration, internally the ending labels for the stream in question becomes:

```text
job="fluentbit", stream="stdout"
```

Another feature of Labels management is the ability to provide custom key names, using the same record accessor pattern we can specify the key name manually and let the value to be populated automatically at runtime, e.g:

```text
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, mystream=$sub['stream']
```

When processing that new configuration, the internal labels will be:

```text
job="fluentbit", mystream="stdout"
```

### Using the `label_keys` property

The additional configuration property called `label_keys` allow to specify multiple record keys that needs to be placed as part of the outgoing Stream Labels, yes, this is a similar feature than the one explained above in the `labels` property.
Consider this as another way to set a record key in the Stream, but with the limitation that you cannot use a custom name for the key value.

The following configuration examples generate the same Stream Labels:

```text
[OUTPUT]
    name       loki
    match      *
    labels     job=fluentbit
    label_keys $sub['stream']
```

the above configuration accomplish the same than this one:

```text
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, $sub['stream']
```

both will generate the following Streams label:

```text
job="fluentbit", stream="stdout"
```

### Using the `label_map_path` property

The configuration property `label_map_path` is to read a JSON file that defines how to extract labels from each record.

The file should contain a JSON object. Each keys define how to get label value from a nested record. Each values are used as label names.

The following configuration examples generate the same Stream Labels:

map.json:
```json
{
    "sub": {
           "stream": "stream"
    }
}
```

The following configuration examples generate the same Stream Labels:

```text
[OUTPUT]
    name   loki
    match  *
    label_map_path /path/to/map.json
```


the above configuration accomplish the same than this one:

```text
[OUTPUT]
    name   loki
    match  *
    labels job=fluentbit, $sub['stream']
```

both will generate the following Streams label:

```text
job="fluentbit", stream="stdout"
```

### Kubernetes & Labels

Note that if you are running in a Kubernetes environment, you might want to enable the option `auto_kubernetes_labels` which will auto-populate the streams with the Pod labels for you. Consider the following configuration:

```python
[OUTPUT]
    name                   loki
    match                  *
    labels                 job=fluentbit
    auto_kubernetes_labels on
```

Based in the JSON example provided above, the internal stream labels will be:

```text
job="fluentbit", team="Santiago Wanderers"
```

### Structured metadata

[Structured metadata](https://grafana.com/docs/loki/latest/get-started/labels/structured-metadata/)
lets you attach custom fields to individual log lines without embedding the
information in the content of the log line. This capability works well for high
cardinality data that isn't suited for using labels. While not a label, the
`structured_metadata` configuration parameter operates similarly to the `labels`
parameter. Both parameters are comma-delimited `key=value` lists, and both can use
record accessors to reference keys within the record being processed.

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

## Networking and TLS Configuration

This plugin inherit core Fluent Bit features to customize the network behavior and optionally enable TLS in the communication channel. For more details about the specific options available refer to the following articles:

* [Networking Setup](../../administration/networking.md): timeouts, keepalive and source address
* [Security & TLS](../../administration/transport-security.md): all about TLS configuration and certificates

Note that all options mentioned in the articles above must be enabled in the plugin configuration in question.

### Fluent Bit + Grafana Cloud

Fluent Bit supports sending logs (and metrics) to [Grafana Cloud](https://grafana.com/products/cloud/) by providing the appropriate URL and ensuring TLS is enabled.

An example configuration - make sure to set the credentials and ensure the host URL matches the correct one for your deployment:

```text
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

## Getting Started

The following configuration example, will emit a dummy example record and ingest it on Loki .
Copy and paste the following content into a file called `out_loki.conf`:

```text
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

run Fluent Bit with the new configuration file:

```text
$ fluent-bit -c out_loki.conf
```

Fluent Bit output:

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

