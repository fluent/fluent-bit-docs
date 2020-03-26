---
description: Kubernetes Production Grade
---

# Kubernetes

![](../.gitbook/assets/fluentbit_kube_logging%20%281%29.png)

[Fluent Bit](http://fluentbit.io) is a lightweight and extensible **Log Processor** that comes with full support for Kubernetes:

* Process Kubernetes containers logs from the file system or Systemd/Journald.
* Enrich logs with Kubernetes Metadata.
* Centralize your logs in third party storage services like Elasticsearch, InfluxDB, HTTP, etc.

## Concepts <a id="concepts"></a>

Before getting started it is important to understand how Fluent Bit will be deployed. Kubernetes manages a cluster of _nodes_, so our log agent tool will need to run on every node to collect logs from every _POD_, hence Fluent Bit is deployed as a DaemonSet \(a POD that runs on every _node_ of the cluster\).

When Fluent Bit runs, it will read, parse and filter the logs of every POD and will enrich each entry with the following information \(metadata\):

* Pod Name
* Pod ID
* Container Name
* Container ID
* Labels
* Annotations

To obtain these information, a built-in filter plugin called _kubernetes_ talks to the Kubernetes API Server to retrieve relevant information such as the _pod\_id_, _labels_ and _annotations_, other fields such as _pod\_name_, _container\_id_ and _container\_name_ are retrieved locally from the log file names. All of this is handled automatically, no intervention is required from a configuration aspect.

> Our Kubernetes Filter plugin is fully inspired on the [Fluentd Kubernetes Metadata Filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) written by [Jimmi Dyson](https://github.com/jimmidyson).

## Installation <a id="installation"></a>

[Fluent Bit](http://fluentbit.io) must be deployed as a DaemonSet, so on that way it will be available on every node of your Kubernetes cluster. To get started run the following commands to create the namespace, service account and role setup:

```text
$ kubectl create namespace logging
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
```

The next step is to create a ConfigMap that will be used by our Fluent Bit DaemonSet:

```text
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/elasticsearch/fluent-bit-configmap.yaml
```

### Note for Kubernetes v1.16

Starting from Kubernetes v1.16, DaemonSet resources are not longer served from `extensions/v1beta` . Our current Daemonset Yaml files uses the old `apiVersion`.

If you are using Kubernetes v1.16, grab manually a copy of your Daemonset Yaml file and replace the value of `apiVersion` from:

```yaml
apiVersion: extensions/v1beta1
```

to

```yaml
apiVersion: apps/v1
```

You can read more about this deprecation on Kubernetes v1.14 Changelog here:

[https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md\#deprecations](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#deprecations)

### Fluent Bit to Elasticsearch

Fluent Bit DaemonSet ready to be used with Elasticsearch on a normal Kubernetes Cluster:

```text
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/elasticsearch/fluent-bit-ds.yaml
```

### Fluent Bit to Elasticsearch on Minikube

If you are using Minikube for testing purposes, use the following alternative DaemonSet manifest:

```text
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/elasticsearch/fluent-bit-ds-minikube.yaml
```

## Details

The default configuration of Fluent Bit makes sure of the following:

* Consume all containers logs from the running Node.
* The [Tail input plugin](https://docs.fluentbit.io/manual/v/1.0/input/tail) will not append more than **5MB**  into the engine until they are flushed to the Elasticsearch backend. This limit aims to provide a workaround for [backpressure](https://docs.fluentbit.io/manual/v/1.0/configuration/backpressure) scenarios.
* The Kubernetes filter will enrich the logs with Kubernetes metadata, specifically _labels_ and _annotations_. The filter only goes to the API Server when it cannot find the cached info, otherwise it uses the cache.
* The default backend in the configuration is Elasticsearch set by the [Elasticsearch Ouput Plugin](https://docs.fluentbit.io/manual/v/1.0/output/elasticsearch). It uses the Logstash format to ingest the logs. If you need a different Index and Type, please refer to the plugin option and do your own adjustments.
* There is an option called **Retry\_Limit** set to False, that means if Fluent Bit cannot flush the records to Elasticsearch it will re-try indefinitely until it succeed.

