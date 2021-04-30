---
description: Kubernetes Production Grade Log Processor
---

# Kubernetes

![](../.gitbook/assets/fluentbit_kube_logging%20%283%29.png)

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

To obtain this information, a built-in filter plugin called _kubernetes_ talks to the Kubernetes API Server to retrieve relevant information such as the _pod\_id_, _labels_ and _annotations_, other fields such as _pod\_name_, _container\_id_ and _container\_name_ are retrieved locally from the log file names. All of this is handled automatically, no intervention is required from a configuration aspect.

> Our Kubernetes Filter plugin is fully inspired by the [Fluentd Kubernetes Metadata Filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) written by [Jimmi Dyson](https://github.com/jimmidyson).

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

The default configmap assumes that dockershim is utilized for the cluster. If a CRI runtime, such as containerd or CRI-O, is being utilized, the [CRI parser](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf#L106-L112) should be utilized. More specifically, change the `Parser` described in `input-kubernetes.conf` from docker to cri.

### Note for Kubernetes &lt; v1.16

For Kubernetes versions older than v1.16, the DaemonSet resource is not available on `apps/v1` , the resource is available on `apiVersion: extensions/v1beta1` . Our current Daemonset Yaml files uses the new `apiVersion`.

If you are using and older Kubernetes version, manually grab a copy of your Daemonset Yaml file and replace the value of `apiVersion` from:

```yaml
apiVersion: apps/v1
```

to

```yaml
apiVersion: extensions/v1beta1
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

## Installing with Helm Chart

[Helm](https://helm.sh) is a package manager for Kubernetes and allows you to quickly deploy application packages into your running cluster. Fluent Bit is distributed via a helm chart found in the Fluent Helm Charts repo: [https://github.com/fluent/helm-charts](https://github.com/fluent/helm-charts).

To add the Fluent Helm Charts repo use the following command

```text
helm repo add fluent https://fluent.github.io/helm-charts
```

To validate that the repo was added you can run `helm search repo fluent` to ensure the charts were added. The default chart can then be installed by running the following

```text
helm install fluent-bit fluent/fluent-bit
```

### Default Values

The default chart values include configuration to read container logs, with Docker parsing, systemd logs apply Kubernetes metadata enrichment and finally output to an Elasticsearch cluster. You can modify the values file included [https://github.com/fluent/helm-charts/blob/master/charts/fluent-bit/values.yaml](https://github.com/fluent/helm-charts/blob/master/charts/fluent-bit/values.yaml) to specify additional outputs, health checks, monitoring endpoints, or other configuration options.

## Details

The default configuration of Fluent Bit makes sure of the following:

* Consume all containers logs from the running Node.
* The [Tail input plugin](https://docs.fluentbit.io/manual/v/1.0/input/tail) will not append more than **5MB**  into the engine until they are flushed to the Elasticsearch backend. This limit aims to provide a workaround for [backpressure](https://docs.fluentbit.io/manual/v/1.0/configuration/backpressure) scenarios.
* The Kubernetes filter will enrich the logs with Kubernetes metadata, specifically _labels_ and _annotations_. The filter only goes to the API Server when it cannot find the cached info, otherwise it uses the cache.
* The default backend in the configuration is Elasticsearch set by the [Elasticsearch Output Plugin](../pipeline/outputs/elasticsearch.md). It uses the Logstash format to ingest the logs. If you need a different Index and Type, please refer to the plugin option and do your own adjustments.
* There is an option called **Retry\_Limit** set to False, that means if Fluent Bit cannot flush the records to Elasticsearch it will re-try indefinitely until it succeed.

## Container Runtime Interface \(CRI\) parser

Fluent Bit by default assumes that logs are formatted by the Docker interface standard. However, when using CRI you can run into issues with malformed JSON if you do not modify the parser used. Fluent Bit includes a CRI log parser that can be used instead. An example of the parser is seen below:

```text
# CRI Parser
[PARSER]
    # http://rubular.com/r/tjUt3Awgg4
    Name cri
    Format regex
    Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<message>.*)$
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L%z
```

To use this parser change the Input section for your configuration from `docker` to `cri`

```text
[INPUT]
    Name tail
    Path /var/log/containers/*.log
    Parser cri
    Tag kube.*
    Mem_Buf_Limit 5MB
    Skip_Long_Lines On
```

## Windows Deployment

Since v1.5.0, Fluent Bit supports deployment to Windows pods.

### Log files overview

When deploying Fluent Bit to Kubernetes, there are three log files that you need to pay attention to.

`C:\k\kubelet.err.log`

* This is the error log file from kubelet daemon running on host.
* You will need to retain this file for future troubleshooting \(to debug deployment failures etc.\)

`C:\var\log\containers\<pod>_<namespace>_<container>-<docker>.log`

* This is the main log file you need to watch. Configure Fluent Bit to follow this file.
* It is actually a symlink to the Docker log file in `C:\ProgramData\`, with some additional metadata on its file name.

`C:\ProgramData\Docker\containers\<docker>\<docker>.log`

* This is the log file produced by Docker.
* Normally you don't directly read from this file, but you need to make sure that this file is visible from Fluent Bit.

Typically, your deployment yaml contains the following volume configuration.

```yaml
spec:
  containers:
  - name: fluent-bit
    image: my-repo/fluent-bit:1.5.0
    volumeMounts:
    - mountPath: C:\k
      name: k
    - mountPath: C:\var\log
      name: varlog
    - mountPath: C:\ProgramData
      name: progdata
  volumes:
  - name: k
    hostPath:
      path: C:\k
  - name: varlog
    hostPath:
      path: C:\var\log
  - name: progdata
    hostPath:
      path: C:\ProgramData
```

### Configure Fluent Bit

Assuming the basic volume configuration described above, you can apply the following config to start logging. You can visualize this configuration [here](https://link.calyptia.com/gzc)

```yaml
fluent-bit.conf: |
    [SERVICE]
      Parsers_File      C:\\fluent-bit\\parsers.conf

    [INPUT]
      Name              tail
      Tag               kube.*
      Path              C:\\var\\log\\containers\\*.log
      Parser            docker
      DB                C:\\fluent-bit\\tail_docker.db
      Mem_Buf_Limit     7MB
      Refresh_Interval  10

    [INPUT]
      Name              tail
      Tag               kubelet.err
      Path              C:\\k\\kubelet.err.log
      DB                C:\\fluent-bit\\tail_kubelet.db

    [FILTER]
      Name              kubernetes
      Match             kube.*
      Kube_URL          https://kubernetes.default.svc.cluster.local:443

    [OUTPUT]
      Name  stdout
      Match *

parsers.conf: |
    [PARSER]
        Name         docker
        Format       json
        Time_Key     time
        Time_Format  %Y-%m-%dT%H:%M:%S.%L
        Time_Keep    On
```

### Mitigate unstable network on Windows pods

Windows pods often lack working DNS immediately after boot \([\#78479](https://github.com/kubernetes/kubernetes/issues/78479)\). To mitigate this issue, `filter_kubernetes` provides a built-in mechanism to wait until the network starts up:

* `DNS_Retries` - Retries N times until the network start working \(6\)
* `DNS_Wait_Time` - Lookup interval between network status checks \(30\)

By default, Fluent Bit waits for 3 minutes \(30 seconds x 6 times\). If it's not enough for you, tweak the configuration as follows.

```text
[filter]
    Name kubernetes
    ...
    DNS_Retries 10
    DNS_Wait_Time 30
```

