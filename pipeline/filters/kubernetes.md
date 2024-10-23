# Kubernetes

Fluent Bit _Kubernetes Filter_ allows to enrich your log files with Kubernetes metadata.

When Fluent Bit is deployed in Kubernetes as a DaemonSet and configured to read the log files from the containers \(using tail or systemd input plugins\), this filter aims to perform the following operations:

* Analyze the Tag and extract the following metadata:
  * Pod Name
  * Namespace
  * Container Name
  * Container ID
* Query Kubernetes API Server to obtain extra metadata for the POD in question:
  * Pod ID
  * Labels
  * Annotations
  * Namespace Labels
  * Namespace Annotations

The data is cached locally in memory and appended to each record.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Buffer\_Size | Set the buffer size for HTTP client when reading responses from Kubernetes API server. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. A value of `0` results in no limit, and the buffer will expand as-needed. Note that if pod specifications exceed the buffer limit, the API response will be discarded when retrieving metadata, and some kubernetes metadata will fail to be injected to the logs. | 32k |
| Kube\_URL | API Server end-point | [https://kubernetes.default.svc:443](https://kubernetes.default.svc:443) |
| Kube\_CA\_File | CA certificate file | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |
| Kube\_CA\_Path | Absolute path to scan for certificate files |  |
| Kube\_Token\_File | Token file | /var/run/secrets/kubernetes.io/serviceaccount/token |
| Kube\_Tag\_Prefix | When the source records comes from Tail input plugin, this option allows to specify what's the prefix used in Tail configuration. | kube.var.log.containers. |
| Merge\_Log | When enabled, it checks if the `log` field content is a JSON string map, if so, it append the map fields as part of the log structure. | Off |
| Merge\_Log\_Key | When `Merge_Log` is enabled, the filter tries to assume the `log` field from the incoming message is a JSON string message and make a structured representation of it at the same level of the `log` field in the map. Now if `Merge_Log_Key` is set \(a string name\), all the new structured fields taken from the original `log` content are inserted under the new key. |  |
| Merge\_Log\_Trim | When `Merge_Log` is enabled, trim \(remove possible \n or \r\) field values. | On |
| Merge\_Parser | Optional parser name to specify how to parse the data contained in the _log_ key. Recommended use is for developers or testing only. |  |
| Keep\_Log | When `Keep_Log` is disabled, the `log` field is removed from the incoming message once it has been successfully merged \(`Merge_Log` must be enabled as well\). | On |
| tls.debug | Debug level between 0 \(nothing\) and 4 \(every detail\). | -1 |
| tls.verify | When enabled, turns on certificate validation when connecting to the Kubernetes API server. | On |
| tls.verify\_hostname | When enabled, turns on hostname validation for certificates | Off |
| Use\_Journal | When enabled, the filter reads logs coming in Journald format. | Off |
| Cache\_Use\_Docker\_Id | When enabled, metadata will be fetched from K8s when docker\_id is changed. | Off |
| Regex\_Parser | Set an alternative Parser to process record Tag and extract pod\_name, namespace\_name, container\_name and docker\_id. The parser must be registered in a [parsers file](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf) \(refer to parser _filter-kube-test_ as an example\). |  |
| K8S-Logging.Parser | Allow Kubernetes Pods to suggest a pre-defined Parser \(read more about it in Kubernetes Annotations section\) | Off |
| K8S-Logging.Exclude | Allow Kubernetes Pods to exclude their logs from the log processor \(read more about it in Kubernetes Annotations section\). | Off |
| Labels | Include Kubernetes pod resource labels in the extra metadata. | On |
| Annotations | Include Kubernetes pod resource annotations in the extra metadata. | On |
| Kube\_meta\_preload\_cache\_dir | If set, Kubernetes meta-data can be cached/pre-loaded from files in JSON format in this directory, named as namespace-pod.meta |  |
| Dummy\_Meta | If set, use dummy-meta data \(for test/dev purposes\) | Off |
| DNS\_Retries | DNS lookup retries N times until the network start working | 6 |
| DNS\_Wait\_Time | DNS lookup interval between network status checks | 30 |
| Use\_Kubelet | this is an optional feature flag to get metadata information from kubelet instead of calling Kube Server API to enhance the log. This could mitigate the [Kube API heavy traffic issue for large cluster](kubernetes.md#optional-feature-using-kubelet-to-get-metadata). If used when any [Kubernetes Namespace Meta](#kubernetes-namespace-meta) fields are enabled, Kubelet will be used to fetch pod data, but namespace meta will still be fetched using the `Kube_URL` settings.| Off |
| Kubelet\_Port | kubelet port using for HTTP request, this only works when `Use_Kubelet`  set to On. | 10250 |
| Kubelet\_Host | kubelet host using for HTTP request, this only works when `Use_Kubelet`  set to On. | 127.0.0.1 |
| Kube\_Meta\_Cache\_TTL | configurable TTL for K8s cached pod metadata. By default, it is set to 0 which means TTL for cache entries is disabled and cache entries are evicted at random when capacity is reached. In order to enable this option, you should set the number to a time interval. For example, set this value to 60 or 60s and cache entries which have been created more than 60s will be evicted. | 0 |
| Kube\_Token\_TTL | configurable 'time to live' for the K8s token. By default, it is set to 600 seconds. After this time, the token is reloaded from Kube_Token_File or the Kube_Token_Command.| 600 |
| Kube\_Token\_Command | Command to get Kubernetes authorization token. By default, it will be `NULL` and we will use token file to get token. If you want to manually choose a command to get it, you can set the command here. For example, run `aws-iam-authenticator -i your-cluster-name token --token-only` to set token. This option is currently Linux-only. |  |
| Kube\_Meta\_Namespace\_Cache\_TTL | configurable TTL for K8s cached namespace metadata. By default, it is set to 900 which means a 15min TTL for namespace cache entries. Setting this to 0 will mean entries are evicted at random once the cache is full. | 900 |
| Namespace\_Labels | Include Kubernetes namespace resource labels in the extra metadata. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| Off |
| Namespace\_Annotations | Include Kubernetes namespace resource annotations in the extra metadata. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| Off |
| Namespace\_Metadata\_Only | Include Kubernetes namespace metadata only and no pod metadata. If this is set, the values of `Labels` and `Annotations` are ignored. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| Off |

## Processing the 'log' value

Kubernetes Filter aims to provide several ways to process the data contained in the _log_ key. The following explanation of the workflow assumes that your original Docker parser defined in _parsers.conf_ is as follows:

```text
[PARSER]
    Name         docker
    Format       json
    Time_Key     time
    Time_Format  %Y-%m-%dT%H:%M:%S.%L
    Time_Keep    On
```

> Since Fluent Bit v1.2 we are not suggesting the use of decoders \(Decode\_Field\_As\) if you are using Elasticsearch database in the output to avoid data type conflicts.

To perform processing of the _log_ key, it's **mandatory to enable** the _Merge\_Log_ configuration property in this filter, then the following processing order will be done:

* If a Pod suggest a parser, the filter will use that parser to process the content of _log_.
* If the option _Merge\_Parser_ was set and the Pod did not suggest a parser, process the _log_ content using the suggested parser in the configuration.
* If no Pod was suggested and no _Merge\_Parser_ is set, try to handle the content as JSON.

If _log_ value processing fails, the value is untouched. The order above is not chained, meaning it's exclusive and the filter will try only one of the options above, **not** all of them.

## Kubernetes Namespace Meta

Namespace Meta can be enabled via the following settings:

* Namespace\_Labels
* Namespace\_Annotations

Using any Namespace Meta requires the use of the Kube API as it can not be fetched directly from Kubelet. If `Use_Kubelet On` has been set, the Kubelet api will only be used to fetch pod metadata, while namespace meta is fetched from the upstream Kubernetes API.

Namespace Meta if collected will be stored within a `kubernetes_namespace` record key.

> Namespace meta is not be guaranteed to be in sync as namespace labels & annotations can be adjusted after pod creation. Adjust `Kube_Meta_Namespace_Cache_TTL` to lower caching times to fit your use case.

* Namespace\_Metadata\_Only
  * Using this feature will instruct fluent-bit to only fetch namespace metadata and to not fetch POD metadata at all.
    POD basic metadata like container id, host, etc will be NOT be added and the Labels and Annotations configuration options which are used specifically for POD Metadata will be ignored.

## Kubernetes Pod Annotations

A flexible feature of Fluent Bit Kubernetes filter is that allow Kubernetes Pods to suggest certain behaviors for the log processor pipeline when processing the records. At the moment it support:

* Suggest a pre-defined parser
* Request to exclude logs

The following annotations are available:

| Annotation | Description | Default |
| :--- | :--- | :--- |
| fluentbit.io/parser\[\_stream\]\[-container\] | Suggest a pre-defined parser. The parser must be registered already by Fluent Bit. This option will only be processed if Fluent Bit configuration \(Kubernetes Filter\) have enabled the option _K8S-Logging.Parser_. If present, the stream \(stdout or stderr\) will restrict that specific stream. If present, the container can override a specific container in a Pod. |  |
| fluentbit.io/exclude\[\_stream\]\[-container\] | Request to Fluent Bit to exclude or not the logs generated by the Pod. This option will only be processed if Fluent Bit configuration \(Kubernetes Filter\) have enabled the option _K8S-Logging.Exclude_. | False |

### Annotation Examples in Pod definition

#### Suggest a parser

The following Pod definition runs a Pod that emits Apache logs to the standard output, in the Annotations it suggest that the data should be processed using the pre-defined parser called _apache_:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-logs
  labels:
    app: apache-logs
  annotations:
    fluentbit.io/parser: apache
spec:
  containers:
  - name: apache
    image: edsiper/apache_logs
```

#### Request to exclude logs

There are certain situations where the user would like to request that the log processor simply skip the logs from the Pod in question:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-logs
  labels:
    app: apache-logs
  annotations:
    fluentbit.io/exclude: "true"
spec:
  containers:
  - name: apache
    image: edsiper/apache_logs
```

Note that the annotation value is boolean which can take a _true_ or _false_ and **must** be quoted.

## Workflow of Tail + Kubernetes Filter

Kubernetes Filter depends on either [Tail](../inputs/tail.md) or [Systemd](../inputs/systemd.md) input plugins to process and enrich records with Kubernetes metadata. Here we will explain the workflow of Tail and how it configuration is correlated with Kubernetes filter. Consider the following configuration example \(just for demo purposes, not production\):

```text
[INPUT]
    Name    tail
    Tag     kube.*
    Path    /var/log/containers/*.log
    multiline.parser              docker, cri

[FILTER]
    Name             kubernetes
    Match            kube.*
    Kube_URL         https://kubernetes.default.svc:443
    Kube_CA_File     /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Kube_Token_File  /var/run/secrets/kubernetes.io/serviceaccount/token
    Kube_Tag_Prefix  kube.var.log.containers.
    Merge_Log        On
    Merge_Log_Key    log_processed
```

In the input section, the [Tail](../inputs/tail.md) plugin will monitor all files ending in _.log_ in path _/var/log/containers/_. For every file it will read every line and apply the docker parser. Then the records are emitted to the next step with an expanded tag.

Tail support Tags expansion, which means that if a tag have a star character \(\*\), it will replace the value with the absolute path of the monitored file, so if you file name and path is:

```text
/var/log/container/apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

then the Tag for every record of that file becomes:

```text
kube.var.log.containers.apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

> note that slashes are replaced with dots.

When [Kubernetes Filter](kubernetes.md) runs, it will try to match all records that starts with _kube._ \(note the ending dot\), so records from the file mentioned above will hit the matching rule and the filter will try to enrich the records

Kubernetes Filter do not care from where the logs comes from, but it cares about the absolute name of the monitored file, because that information contains the pod name and namespace name that are used to retrieve associated metadata to the running Pod from the Kubernetes Master/API Server.

> If you have large pod specifications \(can be caused by large numbers of environment variables, etc.\), be sure to increase the `Buffer_Size` parameter of the kubernetes filter. If object sizes exceed this buffer, some metadata will fail to be injected to the logs.

If the configuration property **Kube\_Tag\_Prefix** was configured \(available on Fluent Bit &gt;= 1.1.x\), it will use that value to remove the prefix that was appended to the Tag in the previous Input section. Note that the configuration property defaults to _kube.var.logs.containers._ , so the previous Tag content will be transformed from:

```text
kube.var.log.containers.apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

to:

```text
apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

> the transformation above do not modify the original Tag, just creates a new representation for the filter to perform metadata lookup.

that new value is used by the filter to lookup the pod name and namespace, for that purpose it uses an internal Regular expression:

```text
(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$
```

> If you want to know more details, check the source code of that definition [here](https://github.com/fluent/fluent-bit/blob/master/plugins/filter_kubernetes/kube_regex.h#L26>).

You can see on [Rublar.com](https://rubular.com/r/HZz3tYAahj6JCd) web site how this operation is performed, check the following demo link:

* [https://rubular.com/r/HZz3tYAahj6JCd](https://rubular.com/r/HZz3tYAahj6JCd)

### Custom Regex

Under certain and not common conditions, a user would want to alter that hard-coded regular expression, for that purpose the option **Regex\_Parser** can be used \(documented on top\).

#### Custom Tag For Enhanced Filtering

One such use case involves splitting logs by namespace, pods, containers or container id.
The tag is restructured within the tail input using match groups, this can simplify the filtering by those match groups later in the pipeline.
Since the tag no longer follows the original file name, a custom **Regex\_Parser** that matches the new tag structure is required:

```text
[PARSER]
    Name    custom-tag
    Format  regex
    Regex   ^(?<namespace_name>[^_]+)\.(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)\.(?<container_name>.+)\.(?<container_id>[a-z0-9]{64})

[INPUT]
    Name              tail
    Tag               kube.<namespace_name>.<pod_name>.<container_name>.<container_id>
    Path              /var/log/containers/*.log
    Tag_Regex         (?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<container_id>[a-z0-9]{64})\.log$
    Parser            cri

[FILTER]
    Name                kubernetes
    Match               kube.*
    Kube_Tag_Prefix     kube.
    Regex_Parser        custom-tag
    Merge_Log           On
```

#### Final Comments

So at this point the filter is able to gather the values of _pod\_name_ and _namespace_, with that information it will check in the local cache \(internal hash table\) if some metadata for that key pair exists, if so, it will enrich the record with the metadata value, otherwise it will connect to the Kubernetes Master/API Server and retrieve that information.

## Optional Feature: Using Kubelet to Get Metadata

There is an [issue](https://github.com/fluent/fluent-bit/issues/1948) reported about kube-apiserver fall over and become unresponsive when cluster is too large and too many requests are sent to it. For this feature, fluent bit Kubernetes filter will send the request to kubelet /pods endpoint instead of kube-apiserver to retrieve the pods information and use it to enrich the log. Since Kubelet is running locally in nodes, the request would be responded faster and each node would only get one request one time. This could save kube-apiserver power to handle other requests. When this feature is enabled, you should see no difference in the kubernetes metadata added to logs, but the Kube-apiserver bottleneck should be avoided when cluster is large.

### Configuration Setup

There are some configuration setup needed for this feature.

Role Configuration for Fluent Bit DaemonSet Example:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentbitds
  namespace: fluentbit-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: fluentbit
rules:
  - apiGroups: [""]
    resources:
      - namespaces
      - pods
      - nodes
      - nodes/proxy
    verbs:
      - get
      - list
      - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: fluentbit
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluentbit
subjects:
  - kind: ServiceAccount
    name: fluentbitds
    namespace: fluentbit-system
```

The difference is that kubelet need a special permission for resource `nodes/proxy` to get HTTP request in. When creating the `role` or `clusterRole`, you need to add `nodes/proxy` into the rule for resource.

Fluent Bit Configuration Example:

```text
[INPUT]
    Name              tail
    Tag               kube.*
    Path              /var/log/containers/*.log
    DB                /var/log/flb_kube.db
    Parser            docker
    Docker_Mode       On
    Mem_Buf_Limit     50MB
    Skip_Long_Lines   On
    Refresh_Interval  10

[FILTER]
    Name                kubernetes
    Match               kube.*
    Kube_URL            https://kubernetes.default.svc.cluster.local:443
    Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
    Merge_Log           On
    Buffer_Size         0
    Use_Kubelet         true
    Kubelet_Port        10250
```

So for fluent bit configuration, you need to set the `Use_Kubelet` to true to enable this feature.

DaemonSet config Example:

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentbit
  namespace: fluentbit-system
  labels:
    app.kubernetes.io/name: fluentbit
spec:
  selector:
    matchLabels:
      name: fluentbit
  template:
    metadata:
      labels:
        name: fluentbit
    spec:
      serviceAccountName: fluentbitds
      containers:
        - name: fluent-bit
          imagePullPolicy: Always
          image: fluent/fluent-bit:latest
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
            - name: fluentbit-config
              mountPath: /fluent-bit/etc/
          resources:
            limits:
              memory: 1500Mi
            requests:
              cpu: 500m
              memory: 500Mi
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: fluentbit-config
          configMap:
            name: fluentbit-config
```

The key point is to set `hostNetwork` to `true` and `dnsPolicy` to `ClusterFirstWithHostNet` that fluent bit DaemonSet could call Kubelet locally. Otherwise it could not resolve the dns for kubelet.

Now you are good to use this new feature!

### Verify that the Use\_Kubelet option is working

Basically you should see no difference about your experience for enriching your log files with Kubernetes metadata.

To check if Fluent Bit is using the kubelet, you can check fluent bit logs and there should be a log like this:

```text
[ info] [filter:kubernetes:kubernetes.0] testing connectivity with Kubelet...
```

And if you are in debug mode, you could see more:

```text
[debug] [filter:kubernetes:kubernetes.0] Send out request to Kubelet for pods information.
[debug] [filter:kubernetes:kubernetes.0] Request (ns=<namespace>, pod=node name) http_do=0, HTTP Status: 200
[ info] [filter:kubernetes:kubernetes.0] connectivity OK
[2021/02/05 10:33:35] [debug] [filter:kubernetes:kubernetes.0] Request (ns=<Namespace>, pod=<podName>) http_do=0, HTTP Status: 200
[2021/02/05 10:33:35] [debug] [filter:kubernetes:kubernetes.0] kubelet find pod: <podName> and ns: <Namespace> match
```

## Troubleshooting

The following section goes over specific log messages you may run into and how to solve them to ensure that Fluent Bit's Kubernetes filter is operating properly

### I can't see metadata appended to my pod or other Kubernetes objects

If you are not seeing metadata added to your kubernetes logs and see the following in your log message, then you may be facing connectivity issues with the Kubernetes API server.

```text
[2020/10/15 03:48:57] [ info] [filter_kube] testing connectivity with API server...
[2020/10/15 03:48:57] [error] [filter_kube] upstream connection error
[2020/10/15 03:48:57] [ warn] [filter_kube] could not get meta for POD
```

**Potential fix \#1: Check Kubernetes roles**

When Fluent Bit is deployed as a DaemonSet it generally runs with specific roles that allow the application to talk to the Kubernetes API server. If you are deployed in a more restricted environment check that all the Kubernetes roles are set correctly.

You can test this by running the following command (replace `fluentbit-system` with the namespace where your fluentbit is installed)

```text
kubectl auth can-i list pods --as=system:serviceaccount:fluentbit-system:fluentbit
```

If set roles are configured correctly, it should simply respond with `yes`.

For instance, using Azure AKS, running the above command may respond with:

```text
no - Azure does not have opinion for this user.
```

If you have connectivity to the API server, but still "could not get meta for POD" - debug logging might give you a message with `Azure does not have opinion for this user`. Then the following `subject` may need to be included in the `fluentbit` `ClusterRoleBinding`:

appended to `subjects` array:

```yaml
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts
```

**Potential fix \#2: Check Kubernetes IPv6**

There may be cases where you have IPv6 on in the environment and you need to enable this within Fluent Bit. Under the service tag please set the following option `ipv6` to `on` .

**Potential fix \#3: Check connectivity to Kube\_URL**

By default the Kube\_URL is set to `https://kubernetes.default.svc:443` . Ensure that you have connectivity to this endpoint from within the cluster and that there are no special permission interfering with the connection.

### I can't see new objects getting metadata

In some cases, you may only see some objects being appended with metadata while other objects are not enriched. This can occur at times when local data is cached and does not contain the correct id for the kubernetes object that requires enrichment. For most Kubernetes objects the Kubernetes API server is updated which will then be reflected in Fluent Bit logs, however in some cases for `Pod` objects this refresh to the Kubernetes API server can be skipped, causing metadata to be skipped.
