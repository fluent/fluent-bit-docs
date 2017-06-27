# Kubernetes Filter

The _Kubernetes Filter_ allows to enrich your log files with Kubernetes metadata.

When Fluent Bit is deployed in Kubernetes as a DaemonSet and configured to read the log files from the containers (using tail plugin), this filter aims to perform the following operations:

- Analize the Tag and extract the following metadata:
  - POD Name
  - Namespace
  - Container Name
  - Container ID
- Query Kubernetes API Server to obtain extra metadata for the POD in question:
  - POD ID
  - Labels
  - Annotations

The data is cached locally in memory and appended to each record.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         |  Description             | Default                            |
| ------------|--------------------------|------------------------------------|
| [Kube_URL](#config_kube_url) | API Server end-point  | https://kubernetes.default.svc:443 |
| [Kube_CA_File](#config_kube_ca_file) | CA certificate file   | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt|
| [Kube_Token_File](#config_kube_token_file) | Token file | /var/run/secrets/kubernetes.io/serviceaccount/token |
| [Merge_JSON_Log](#config_merge_json_log) | Interpret message _log_ field as a structured message | Off |
| [Merge_JSON_Key](#config_merge_json_key) | Set a new key name to append _log_ structured message |     |
| [Dummy_Meta](#config_dummy_meta) | Append dummy metadata | Off


### Kube_URL {#config_kube_url}

The filter aims to enrigh logs with Kubernetes metadata, this information comes from the Kubernetes API Server and the [Kube_URL](#config_kube_url) configuration property aims to specify the HTTP endpoint of the API Server. Different Kubernetes deployments might have a different end-points.

__Default__ https://kubernetes.default.svc:443

### Kube_CA_File {#config_kube_ca_file}

When accessing the API Server in secure mode (TLS), the [Kube_CA_File](#config_kube_ca_file) defines the absolute path for the root CA certificate. This certificate exists on every node of the cluster.

__Default__ /var/run/secrets/kubernetes.io/serviceaccount/ca.crt

### Kube_Token_File {#config_kube_token_file}

When accessing the API Server, the Kubernetes HTTP end-point requires an authorization token. The [Kube_Token_File](#config_kube_token_file) defines the absolute path of this token.

__Default__ /var/run/secrets/kubernetes.io/serviceaccount/token

### Merge_JSON_Log {#config_merge_json_log}

Applications might generate their logs in JSON format, if so the container engine (e.g: Docker) will threat that log line as a string leading to a nested JSON map. Enabling [Merge_JSON_Log](#config_merge_json_log) instruct Fluent Bit to parse and format that JSON-string as native structured fields.

__Default__ Off

### Merge_JSON_Key {#config_merge_json_key}

Specify an optional key name to append structured fields from the _log_ message when Merge\_JSON\_Log is enabled.

> this option has been introduced in Fluent Bit v0.11.11

### Dummy_Meta {#config_dummy_meta}

When enabled this option makes the filter to skip API Server and instead just insert a dummy metadata into each log line. This option is available only for testing and development purposes, do not use in production.

> this option has been introduced in Fluent Bit v0.11.11
