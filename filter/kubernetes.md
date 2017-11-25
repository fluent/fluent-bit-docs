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
| Kube\_URL       | API Server end-point  | https://kubernetes.default.svc:443 |
| Kube\_CA\_File | CA certificate file   | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt|
| Kube\_Token\_File | Token file | /var/run/secrets/kubernetes.io/serviceaccount/token |
| Merge\_JSON\_Log | When enabled, it checks if the _log_ field content is a JSON string map, if so, it append the map fields as part of the log structure. | Off |
| Annotations | Include Kubernetes Pod annotations in the record | On |
