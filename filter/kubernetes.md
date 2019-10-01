# Kubernetes

The _Kubernetes Filter_ allows to enrich your log files with Kubernetes metadata.

When Fluent Bit is deployed in Kubernetes as a DaemonSet and configured to read the log files from the containers \(using tail plugin\), this filter aims to perform the following operations:

* Analize the Tag and extract the following metadata:
  * POD Name
  * Namespace
  * Container Name
  * Container ID
* Query Kubernetes API Server to obtain extra metadata for the POD in question:
  * POD ID
  * Labels
  * Annotations

The data is cached locally in memory and appended to each record.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| [Kube\_URL](kubernetes.md#config_kube_url) | API Server end-point | [https://kubernetes.default.svc:443](https://kubernetes.default.svc:443) |
| [Kube\_CA\_File](kubernetes.md#config_kube_ca_file) | CA certificate file | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |
| [Kube\_Token\_File](kubernetes.md#config_kube_token_file) | Token file | /var/run/secrets/kubernetes.io/serviceaccount/token |
| [Merge\_JSON\_Log](kubernetes.md#config_merge_json_log) | Interpret message _log_ field as a structured message | Off |
| [Merge\_JSON\_Key](kubernetes.md#config_merge_json_key) | Set a new key name to append _log_ structured message |  |
| [Dummy\_Meta](kubernetes.md#config_dummy_meta) | Append dummy metadata | Off |

### Kube\_URL <a id="config_kube_url"></a>

The filter aims to enrigh logs with Kubernetes metadata, this information comes from the Kubernetes API Server and the [Kube\_URL](kubernetes.md#config_kube_url) configuration property aims to specify the HTTP endpoint of the API Server. Different Kubernetes deployments might have a different end-points.

**Default** [https://kubernetes.default.svc:443](https://kubernetes.default.svc:443)

### Kube\_CA\_File <a id="config_kube_ca_file"></a>

When accessing the API Server in secure mode \(TLS\), the [Kube\_CA\_File](kubernetes.md#config_kube_ca_file) defines the absolute path for the root CA certificate. This certificate exists on every node of the cluster.

**Default** /var/run/secrets/kubernetes.io/serviceaccount/ca.crt

### Kube\_Token\_File <a id="config_kube_token_file"></a>

When accessing the API Server, the Kubernetes HTTP end-point requires an authorization token. The [Kube\_Token\_File](kubernetes.md#config_kube_token_file) defines the absolute path of this token.

**Default** /var/run/secrets/kubernetes.io/serviceaccount/token

### Merge\_JSON\_Log <a id="config_merge_json_log"></a>

Applications might generate their logs in JSON format, if so the container engine \(e.g: Docker\) will threat that log line as a string leading to a nested JSON map. Enabling [Merge\_JSON\_Log](kubernetes.md#config_merge_json_log) instruct Fluent Bit to parse and format that JSON-string as native structured fields.

**Default** Off

### Merge\_JSON\_Key <a id="config_merge_json_key"></a>

Specify an optional key name to append structured fields from the _log_ message when Merge\_JSON\_Log is enabled.

> this option has been introduced in Fluent Bit v0.11.11

### Dummy\_Meta <a id="config_dummy_meta"></a>

When enabled this option makes the filter to skip API Server and instead just insert a dummy metadata into each log line. This option is available only for testing and development purposes, do not use in production.

> this option has been introduced in Fluent Bit v0.11.11

