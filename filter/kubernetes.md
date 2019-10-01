# Kubernetes

The _Kubernetes Filter_ allows to enrich your log files with Kubernetes metadata.

When Fluent Bit is deployed in Kubernetes as a DaemonSet and configured to read the log files from the containers \(using tail plugin\), this filter aims to perform the following operations:

* Analyze the Tag and extract the following metadata:
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
| Buffer\_Size | Set the buffer size for HTTP client when reading responses from Kubernetes API server. The value must be according to the [Unit Size](../configuration/unit_sizes.md) specification. | 32k |
| Kube\_URL | API Server end-point | [https://kubernetes.default.svc.cluster.local:443](https://kubernetes.default.svc.cluster.local:443) |
| Kube\_CA\_File | CA certificate file | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |
| Kube\_CA\_Path | CA path |  |
| Kube\_Token\_File | Token file | /var/run/secrets/kubernetes.io/serviceaccount/token |
| Merge\_Log | When enabled, it checks if the `log` field content is a JSON string map, if so, it append the map fields as part of the log structure. | Off |
| tls.debug | Debug level between 0 \(nothing\) and 4 \(every detail\). | -1 |
| tls.verify | When enabled, turns on certificate validation when connecting to the Kubernetes API server. | On |
| Use\_Journal | When enabled, the filter reads logs coming in Journald format. | Off |
| Regex\_Parser | Set an alternative Parser to process record Tag and extract pod\_name, namespace\_name, container\_name and docker\_id. The parser must be registered in a [parsers file](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf) \(refer to parser _filter-kube-test_ as an example\). |  |
| Annotations | Include Kubernetes resource annotations in the extra metadata. | On |
| Dummy\_Meta | If set, use dummy-meta data \(for test/dev purposes\) | Off |

