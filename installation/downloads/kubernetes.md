---
description: Kubernetes Production Grade Log Processor
---

# Kubernetes

[Fluent Bit](https://fluentbit.io) is a lightweight and extensible log processor with full support for Kubernetes:

- Process Kubernetes containers logs from the file system or Systemd/Journald.
- Enrich logs with Kubernetes Metadata.
- Centralize your logs in third party storage services like Elasticsearch, InfluxDB, HTTP, and so on.

## Concepts

Before getting started it's important to understand how Fluent Bit will be deployed. Kubernetes manages a cluster of nodes. The Fluent Bit log agent tool needs to run on every node to collect logs from every pod. Fluent Bit is deployed as a DaemonSet, which is a pod that runs on every node of the cluster.

When Fluent Bit runs, it reads, parses, and filters the logs of every pod. In addition, Fluent Bit adds metadata to each entry using the [Kubernetes](../../pipeline/filters/kubernetes) filter plugin.

The Kubernetes filter plugin talks to the Kubernetes API Server to retrieve relevant information such as the `pod_id`, `labels`, and `annotations`. Other fields, such as `pod_name`, `container_id`, and `container_name`, are retrieved locally from the log file names. All of this is handled automatically, and no intervention is required from a configuration aspect.

## Installation

Fluent Bit should be deployed as a DaemonSet, so it will be available on every node of your Kubernetes cluster.

The recommended way to deploy Fluent Bit for Kubernetes is with the official [Helm Chart](https://github.com/fluent/helm-charts).

### OpenShift

If you are using Red Hat OpenShift you must set up Security Context Constraints (SCC) using the relevant option in the helm chart.

### Installing with Helm chart

[Helm](https://helm.sh) is a package manager for Kubernetes and lets you deploy application packages into your running cluster. Fluent Bit is distributed using a Helm chart found in the [Fluent Helm Charts repository](https://github.com/fluent/helm-charts).

Use the following command to add the Fluent Helm charts repository

```shell
helm repo add fluent https://fluent.github.io/helm-charts
```

To validate that the repository was added, run `helm search repo fluent` to ensure the charts were added. The default chart can then be installed by running the following command:

```shell
helm upgrade --install fluent-bit fluent/fluent-bit
```

### Default values

The default chart values include configuration to read container logs. With Docker parsing, Systemd logs apply Kubernetes metadata enrichment, and output to an Elasticsearch cluster. You can modify the [included values file](https://github.com/fluent/helm-charts/blob/main/charts/fluent-bit/values.yaml) to specify additional outputs, health checks, monitoring endpoints, or other configuration options.

## Details

The default configuration of Fluent Bit ensures the following:

- Consume all containers logs from the running node and parse them with either the `docker` or `cri` multi-line parser.
- Persist how far it got into each file it's tailing so if a pod is restarted it picks up from where it left off.
- The Kubernetes filter adds Kubernetes metadata, specifically `labels` and `annotations`. The filter only contacts the API Server when it can't find the cached information, otherwise it uses the cache.
- The default backend in the configuration is Elasticsearch set by the [Elasticsearch Output Plugin](../../pipeline/outputs/elasticsearch.md). It uses the Logstash format to ingest the logs. If you need a different `Index` and `Type`, refer to the plugin option and update as needed.
- There is an option called `Retry_Limit`, which is set to `False`. If Fluent Bit can't flush the records to Elasticsearch, it will retry indefinitely until it succeeds.

## Windows deployment

Fluent Bit v1.5.0 and later supports deployment to Windows pods.

### Log files overview

When deploying Fluent Bit to Kubernetes, there are three log files that you need to pay attention to.

- `C:\k\kubelet.err.log`

  This is the error log file from kubelet daemon running on host. Retain this file for future troubleshooting, including debugging deployment failures.

- `C:\var\log\containers\<pod>_<namespace>_<container>-<docker>.log`

  This is the main log file you need to watch. Configure Fluent Bit to follow this file. It's a symlink to the Docker log file in `C:\ProgramData\`, with some additional metadata on the file's name.

- `C:\ProgramData\Docker\containers\<docker>\<docker>.log`

  This is the log file produced by Docker. Normally you don't directly read from this file, but you need to make sure that this file is visible from Fluent Bit.

Typically, your deployment YAML contains the following volume configuration.

```yaml
spec:
  containers:
  - name: fluent-bit
    image: my-repo/fluent-bit:1.8.4
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

Assuming the basic volume configuration described previously, you can apply one of the following configurations to start logging:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
    - name: docker
      format: json
      time_key: time
      time_format: '%Y-%m-%dT%H:%M:%S.%L'
      time_keep: true

pipeline:
    inputs:
        - name: tail
          tag: kube.*
          path: 'C:\\var\\log\\containers\\*.log'
          parser: docker
          db: 'C:\\fluent-bit\\tail_docker.db'
          mem_buf_limit: 7MB
          refresh_interval: 10

        - name: tail
          tag: kube.error
          path: 'C:\\k\\kubelet.err.log'
          db: 'C:\\fluent-bit\\tail_kubelet.db'

    filters:
        - name: kubernetes
          match: kube.*
          kube_url: 'https://kubernetes.default.svc.cluster.local:443'

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

### Mitigate unstable network on Windows pods

Windows pods often lack working DNS immediately after boot ([#78479](https://github.com/kubernetes/kubernetes/issues/78479)). To mitigate this issue, `filter_kubernetes` provides a built-in mechanism to wait until the network starts up:

- `DNS_Retries`: Retries N times until the network start working (6)
- `DNS_Wait_Time`: Lookup interval between network status checks (30)

By default, Fluent Bit waits for three minutes (30 seconds x 6 times). If it's not enough for you, update the configuration as follows:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
    filters:
        - name: kubernetes
          ...
          dns_retries: 10
          dns_wait_time: 30
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[filter]
    Name kubernetes
    ...
    DNS_Retries 10
    DNS_Wait_Time 30
```

% endtab %}
{% endtabs %}
