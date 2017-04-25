# Kubernetes

![](/imgs/flb_kubernetes.png)

Fluent Bit as a log forwarder is a perfect fit for Kubernetes use case. The following document describes how to deploy Fluent Bit for your log collection needs.

## Concepts

Before to get started is important to understand how Fluent Bit will be deployed. Kubernetes manage a cluster of _nodes_, so our log agent tool will need to run on every node to collect logs from every _POD_, for hence Fluent Bit is deployed as a DaemonSet (a POD that runs on every _node_ of the cluster).

When Fluent Bit runs, it will read, parse and filter the logs of every POD and will enrich each entry with the following information (metadata):

- POD Name
- POD ID
- Container Name
- Container ID
- Labels
- Annotations

To obtain these information, a built-in filter plugin called _kubernetes_ talks to the Kubernetes API Server to retrieve relevant information such as the _pod\_id_, _labels_ and _annotations_, other fields such as _pod\_name_, _container\_id_ and _container\_name_ are retrieved locally from the log file names. All of this is handled automatically, no intervention is required from a configuration aspect.

> Our Kubernetes Filter plugin is fully inspired on the [Fluentd Kubernetes Metadata Filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) written by [Jimmi Dyson](https://github.com/jimmidyson).

## Getting Started

The following steps assumes that you have a Kubernetes cluster running with an Elasticsearch database on it. Our default configuration assumes that your database can be reached through the DNS name _elasticsearch-logging_.

Please download the Fluent Bit DaemonSet for Elasticsearch from here:

- [fluent-bit-daemonset-elasticsearch.yaml](https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-daemonset/master/fluent-bit-daemonset-elasticsearch.yaml)

Now your master node deploy the daemonset with:

```
$ kubectl apply -f ./fluent-bit-daemonset-elasticsearch.yaml
```

After a few seconds Fluent Bit will be running and ingesting your logs into your Elasticsearch database. If you database have a different DNS name than _elasticsearch-logging_, make sure to perform the proper adjustments to the Yaml file.
