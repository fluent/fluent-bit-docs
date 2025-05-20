# Kubernetes

Fluent Bit _Kubernetes_ filter enriches your log files with Kubernetes metadata.

When Fluent Bit is deployed in Kubernetes as a DaemonSet and configured to read the log files from the containers (using `tail` or `systemd` input plugins), this filter can perform the following operations:

- Analyze the Tag and extract the following metadata:
  - Pod Name
  - Namespace
  - Container Name
  - Container ID
- Query Kubernetes API Server or Kubelet to obtain extra metadata for the pod in question:
  - Pod ID
  - Labels
  - Owner References
  - Annotations
  - Namespace Labels
  - Namespace Annotations

The data is cached locally in memory and appended to each record.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Buffer_Size` | Set the buffer size for HTTP client when reading responses from Kubernetes API server. The value must be according to the [unit size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. A value of `0` results in no limit, and the buffer will expand as-needed. If pod specifications exceed the buffer limit, the API response is discarded when retrieving metadata, and some Kubernetes metadata will fail to be injected to the logs. | `32k` |
| `Kube_URL` | API Server end-point | [https://kubernetes.default.svc:443](https://kubernetes.default.svc:443) |
| `Kube_CA_File` | CA certificate file | `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` |
| `Kube_CA_Path` | Absolute path to scan for certificate files | _none_ |
| `Kube_Token_File` | Token file | `/var/run/secrets/kubernetes.io/serviceaccount/token` |
| `Kube_Tag_Prefix` | When the source records come from `tail` input plugin, this option specifies the prefix used in `tail` configuration. | `kube.var.log.containers.` |
| `Merge_Log` | When enabled, it checks if the `log` field content is a JSON string map. If yes, it appends the map fields as part of the log structure. | `Off` |
| `Merge_Log_Key` | When `Merge_Log` is enabled, the filter tries to assume the `log` field from the incoming message is a JSON string message and make a structured representation of it at the same level of the `log` field in the map. If `Merge_Log_Key` is set (a string name), all the new structured fields taken from the original `log` content are inserted under the new key. | _none_ |
| `Merge_Log_Trim` | When `Merge_Log` is enabled, trim (remove possible `\n` or `\r\`) field values. | `On` |
| `Merge_Parser` | Optional parser name to specify how to parse the data contained in the `log` key. Recommended for developers or testing only. | _none_ |
| `Keep_Log` | When `Keep_Log` is disabled, the `log` field is removed from the incoming message once it has been successfully merged (`Merge_Log` must be enabled as well). | `On` |
| `tls.debug` | Debug level between `0 (no information) and 4 (all details). | `-1` |
| `tls.verify` | When enabled, turns on certificate validation when connecting to the Kubernetes API server. | `On` |
| `tls.verify_hostname` | When enabled, turns on hostname validation for certificates. | `Off` |
| `Use_Journal` | When enabled, the filter reads logs coming in `Journald` format. | `Off` |
| `Cache_Use_Docker_Id` | When enabled, metadata will be fetched from Kubernetes when `docker_id` is changed. | `Off` |
| `Regex_Parser` | Set an alternative Parser to process record tags and extract `pod_name`, `namespace_name`, `container_name`, and `docker_id`. The parser must be registered in a [parsers file](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf) (refer to parser `filter-kube-test` as an example). | _none_ |
| `K8S-Logging.Parser` | Allow Kubernetes pods to suggest a pre-defined parser. | `Off` |
| `K8S-Logging.Exclude` | Allow Kubernetes pods to exclude their logs from the log processor. | `Off` |
| `Labels` | Include Kubernetes pod resource labels in the extra metadata. | `On` |
| `Annotations` | Include Kubernetes pod resource annotations in the extra metadata. | `On` |
| `Kube_meta_preload_cache_dir` | If set, Kubernetes metadata can be cached or pre-loaded from files in JSON format in this directory, named `namespace-pod.meta` | _none_ |
| `Dummy_Meta` | If set, use dummy-meta data (for test/dev purposes). | `Off` |
| `DNS_Retries` | DNS lookup retries N times until the network start working. | `6` |
| `DNS_Wait_Time` | DNS lookup interval between network status checks. | `30` |
| `Use_Kubelet` | Optional feature flag to get metadata information from Kubelet instead of calling Kube Server API to enhance the log. This could mitigate the [Kube API heavy traffic issue for large cluster](kubernetes.md#optional-feature-using-kubelet-to-get-metadata). If used when any [Kubernetes Namespace Meta](#kubernetes-namespace-meta) fields are enabled, Kubelet will be used to fetch pod data, but namespace meta will still be fetched using the `Kube_URL` settings.| `Off` |
| `Use_Tag_For_Meta` | When enabled, Kubernetes metadata (for example, `pod_name`, `container_name`, and `namespace_name`) will be extracted from the tag itself. Connection to Kubernetes API Server won't get established and API calls for metadata won't be made. See [Workflow of Tail + Kubernetes Filter](#workflow-of-tail--kubernetes-filter) and [Custom tag For enhanced filtering](#custom-tag-for-enhanced-filtering) to better understand metadata extraction from tags. | `Off` |
| `Kubelet_Port` | Kubelet port using for HTTP request, this only works when `Use_Kubelet`  set to `On`. | `10250` |
| `Kubelet_Host` | Kubelet host using for HTTP request, this only works when `Use_Kubelet`  set to `On`. | `127.0.0.1` |
| `Kube_Meta_Cache_TTL` | Configurable `TTL` for Kubernetes cached pod metadata. By default, it's set to `0` which means `TTL` for cache entries is disabled and cache entries are evicted at random when capacity is reached. To enable this option, set the number to a time interval. For example, set the value to `60` or `60s` and cache entries which have been created more than 60 seconds ago will be evicted. | `0` |
| `Kube_Token_TTL` | Configurable time-to-live for the Kubernetes token. After this time, the token is reloaded from `Kube_Token_File` or the `Kube_Token_Command`.| `600` |
| `Kube_Token_Command` | Command to get Kubernetes authorization token. Defaults to `NULL` uses the token file to get the token. To manually choose a command to get it, set the command here. For example, run `aws-iam-authenticator -i your-cluster-name token --token-only` to set token. This option is currently Linux-only. | `NULL` |
| `Kube_Meta_Namespace_Cache_TTL` | Configurable `TTL` for Kubernetes cached namespace metadata. Setting this to `0` will mean entries are evicted at random once the cache is full. | `900` (seconds) |
| `Namespace_Labels` | Include Kubernetes namespace resource labels in the extra metadata. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| `Off` |
| `Namespace_Annotations` | Include Kubernetes namespace resource annotations in the extra metadata. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| `Off` |
| `Namespace_Metadata_Only` | Include Kubernetes namespace metadata only and no pod metadata. When set, the values of `Labels` and `Annotations` are ignored. See [Kubernetes Namespace Meta](#kubernetes-namespace-meta)| `Off` |
| `Owner_References` | Include Kubernetes owner references in the extra metadata. | `Off` |

## Processing the `log` value

Kubernetes filter provides several ways to process the data contained in the `log` key. The following explanation of the workflow assumes that your original Docker parser defined in `parsers.conf` is as follows:

```python
[PARSER]
    Name         docker
    Format       json
    Time_Key     time
    Time_Format  %Y-%m-%dT%H:%M:%S.%L
    Time_Keep    On
```

For Fluent Bit v1.2 or greater, don't use decoders (`Decode_Field_As`) if you are using Elasticsearch database in the output to avoid data type conflicts.

To perform processing of the `log` key, you must enable the `Merge_Log` configuration property in this filter, then the following processing order will be done:

- If a pod suggests a parser, the filter will use that parser to process the content of `log`.
- If the `Merge_Parser` options was set and the pod didn't suggest a parser, process the `log` content using the suggested parser in the configuration.
- If no pod was suggested and no `Merge_Parser` is set, try to handle the content as JSON.

If `log` value processing fails, the value is untouched. The order of processing isn't chained, meaning it's exclusive and the filter will try only one of the options, not all of them.

## Kubernetes namespace meta

Enable namespace meta using the following settings:

- `Namespace_Labels`
- `Namespace_Annotations`

Using any namespace meta requires the use of the Kube API. It can not be fetched directly from Kubelet. If `Use_Kubelet On` has been set, the Kubelet API will only be used to fetch pod metadata, while namespace meta is fetched from the upstream Kubernetes API.

If collected, namespace meta will be stored in a `kubernetes_namespace` record key.

Namespace meta isn't be guaranteed to be in sync as namespace labels and annotations can be adjusted after pod creation. Adjust `Kube_Meta_Namespace_Cache_TTL` to lower caching times to fit your use case.

- `Namespace_Metadata_Only`
  - Using this feature will instruct Fluent Bit to only fetch namespace metadata and to not fetch pod metadata at all.
    Pod basic metadata like `container id` and `host` won't be added and the labels and annotations configuration options which are used specifically for pod Metadata will be ignored.

## Kubernetes pod annotations

Fluent Bit Kubernetes filters allow Kubernetes pods to suggest certain behaviors for the log processor pipeline when processing the records. It can:

- Suggest a pre-defined parser
- Request to exclude logs

The following annotations are available:

| Annotation | Description | Default |
| :--- | :--- | :--- |
| `fluentbit.io/parser[_stream][-container]` | Suggest a pre-defined parser. The parser must be registered already by Fluent Bit. This option will only be processed if Fluent Bit configuration (Kubernetes Filter) has enabled the option `K8S-Logging.Parser`. If present, the stream (stdout or stderr) will restrict that specific stream. If present, the container can override a specific container in a Pod. | _none_ |
| `fluentbit.io/exclude[_stream][-container]` | Request Fluent Bit to exclude or not the logs generated by the pod. This option will only be processed if Fluent Bit configuration (Kubernetes Filter) have enabled the option `K8S-Logging.Exclude`. | `False` |

### Annotation examples in pod definition

#### Suggest a parser

The following pod definition runs a pod that emits Apache logs to the standard output. The Annotations suggest that the data should be processed using the pre-defined parser called `apache`:

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

The following example defines a request that the log processor skip the logs from the pod in question:

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

The annotation value is boolean which can take a `"true"` or `"false"`.

## Kubernetes owner references

An optional feature of Fluent Bit Kubernetes filter includes owner references information under `kubernetes.ownerReferences` field in the record when enabled.

For example:

```text
"kubernetes"=>{"pod_name"=>"fluentbit-gke-2p6b5", "namespace_name"=>"kube-system", "pod_id"=>"c759a5f5-xxxx-xxxx-9117-8a1dc0b1f907", "labels"=>{"component"=>"xxxx", "controller-revision-hash"=>"77665fff9", "k8s-app"=>"fluentbit-xxxx"}, "ownerReferences"=>[{"apiVersion"=>"apps/v1", "kind"=>"DaemonSet", "name"=>"fluentbit-gke", "uid"=>"1a12c3e2-d6c4-4a8a-b877-dd3c857d1aea", "controller"=>true, "blockOwnerDeletion"=>true}], "host"=>"xxx-2a9c049c-qgw3", "pod_ip"=>"10.128.0.111", "container_name"=>"fluentbit", "docker_id"=>"2accxxx", "container_hash"=>"xxxx", "container_image"=>"sha256:5163dxxxxea2"}
```

## Workflow of tail and Kubernetes filter

Kubernetes Filter depends on either [Tail](../inputs/tail.md) or [Systemd](../inputs/systemd.md) input plugins to process and enrich records with Kubernetes metadata. Consider the following configuration example:

```python
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

In the input section, the [Tail](../inputs/tail.md) plugin monitors all files ending in `.log` in the path `/var/log/containers/`. For every file it will read every line and apply the Docker parser. The records are emitted to the next step with an expanded tag.

Tail supports tags expansion. If a tag has a star character (`*`), it will replace the value with the absolute path of the monitored file, so if your filename and path is:

```text
/var/log/container/apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

then the tag for every record of that file becomes:

```text
kube.var.log.containers.apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

Slashes (`/`) are replaced with dots (`.`).

When Kubernetes filter runs, it tries to match all records that start with `kube.`. Records from the previous file match the rule and the filter will try to enrich the records.

Kubernetes filter doesn't care from where the logs comes from, but it cares about the absolute name of the monitored file. That information contains the pod name and namespace name that are used to retrieve associated metadata to the running pod from the Kubernetes Master/API Server.

If you have large pod specifications (can be caused by large numbers of environment variables), be sure to increase the `Buffer_Size` parameter of the Kubernetes filter. If object sizes exceed this buffer, some metadata will fail to be injected to the logs.

If the configuration property `Kube_Tag_Prefix` was configured (available on Fluent Bit &gt;= 1.1.x), it will use that value to remove the prefix that was appended to the Tag in the previous `Input` section. The configuration property defaults to `kube.var.logs.containers.` , so the previous tag content will be transformed from:

```text
kube.var.log.containers.apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

to:

```text
apache-logs-annotated_default_apache-aeeccc7a9f00f6e4e066aeff0434cf80621215071f1b20a51e8340aa7c35eac6.log
```

The transformation doesn't modify the original tag, it creates a new representation for the filter to perform metadata lookup.

The new value is used by the filter to lookup the pod name and namespace, for that purpose it uses an internal regular expression:

```text
(?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64}).log$
```

For more details, review the source code of that definition [here](https://github.com/fluent/fluent-bit/blob/master/plugins/filter_kubernetes/kube_regex.h#L26>).

You can see on the [Rublar.com](https://rubular.com/r/HZz3tYAahj6JCd) website how this operation is performed. See the following demo link:

[https://rubular.com/r/HZz3tYAahj6JCd](https://rubular.com/r/HZz3tYAahj6JCd)

### Custom regular expressions

Under some uncommon conditions, a user might want to alter that hard-coded regular expression. Use the `Regex_Parser` option.

#### Custom tags For enhanced filtering

One such use case involves splitting logs by namespace, pods, containers or container id. The tag is restructured within the tail input using match groups. Restructuring can simplify the filtering by those match groups later in the pipeline. Since the tag no longer follows the original filename, a custom `Regex_Parser` that matches the new tag structure is required:

```python
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

Now, the filter is able to gather the values of `pod_name` and `namespace`. With that information it will check in the local cache (internal hash table) if some metadata for that key pair exists. If it exists, it will enrich the record with the metadata value, otherwise it will connect to the Kubernetes Master/API Server and retrieve that information.

## Using Kubelet to get metadata

There is an [issue](https://github.com/fluent/fluent-bit/issues/1948) reported about kube-apiserver fall over and become unresponsive when cluster is too large and too many requests are sent to it. For this feature, fluent bit Kubernetes filter will send the request to kubelet /pods endpoint instead of kube-apiserver to retrieve the pods information and use it to enrich the log. Since Kubelet is running locally in nodes, the request would be responded faster and each node would only get one request one time. This could save kube-apiserver power to handle other requests. When this feature is enabled, you should see no difference in the Kubernetes metadata added to logs, but the Kube-apiserver bottleneck should be avoided when cluster is large.

### Configuration setup

There are some configuration setup needed for this feature.

The following example demonstrates role configuration for the Fluent Bit DaemonSet:

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

Kubelet needs special permission for the resource `nodes/proxy` to get HTTP requests. When creating the `role` or `clusterRole`, you need to add `nodes/proxy` into the rule for resource.

For Fluent Bit configuration, you must set the `Use_Kubelet` to `true` to enable this feature.

Fluent Bit configuration example:

```yaml
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

DaemonSet configuration example:

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

Set `hostNetwork` to `true` and `dnsPolicy` to `ClusterFirstWithHostNet` so the Fluent Bit DaemonSet can call Kubelet locally. Otherwise it can't resolve DNS for kubelet.

### Verify the `Use_Kubelet` option is working

To know if Fluent Bit is using the kubelet, you can review Fluent Bit logs. There should be a log like this:

```text
[ info] [filter:kubernetes:kubernetes.0] testing connectivity with Kubelet...
```

If you are in debug mode, you could see more:

```text
[debug] [filter:kubernetes:kubernetes.0] Send out request to Kubelet for pods information.
[debug] [filter:kubernetes:kubernetes.0] Request (ns=<namespace>, pod=node name) http_do=0, HTTP Status: 200
[ info] [filter:kubernetes:kubernetes.0] connectivity OK
[2021/02/05 10:33:35] [debug] [filter:kubernetes:kubernetes.0] Request (ns=<Namespace>, pod=<podName>) http_do=0, HTTP Status: 200
[2021/02/05 10:33:35] [debug] [filter:kubernetes:kubernetes.0] kubelet find pod: <podName> and ns: <Namespace> match
```

## Troubleshooting

The following section goes over specific log messages you might receive. Learn how to solve them to ensure that the Fluent Bit Kubernetes filter is operating properly

- You can't see metadata appended to your pods or other Kubernetes objects

  If you aren't seeing metadata added to your Kubernetes logs and see the following in your log message, then you might be facing connectivity issues with the Kubernetes API server.

  ```text
  [2020/10/15 03:48:57] [ info] [filter_kube] testing connectivity with API server...
  [2020/10/15 03:48:57] [error] [filter_kube] upstream connection error
  [2020/10/15 03:48:57] [ warn] [filter_kube] could not get meta for POD
  ```

  - Potential fix #1: Check Kubernetes roles

    When Fluent Bit is deployed as a DaemonSet it generally runs with specific roles that allow the application to talk to the Kubernetes API server. If you are deployed in a more restricted environment ensure that all the Kubernetes roles are set correctly.

    You can test this by running the following command (replace `fluentbit-system` with the namespace where your Fluent Bit is installed)

    ```text
    kubectl auth can-i list pods --as=system:serviceaccount:fluentbit-system:fluentbit
    ```

    If set roles are configured correctly, it should respond with `yes`.

    For instance, using Azure AKS, running the previous command might respond with:

    ```text
    no - Azure does not have opinion for this user.
    ```

    If you have connectivity to the API server, but still `could not get meta for POD` - debug logging might give you a message with `Azure does not have opinion for this user`. Then the following `subject` might need to be included in the `fluentbit` `ClusterRoleBinding`:

    appended to `subjects` array:

    ```yaml
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts
    ```

  - Potential fix #2: Check Kubernetes IPv6

    There might be cases where you have IPv6 on in the environment and you need to enable this within Fluent Bit. Under the service tag set the following option `ipv6` to `on` .

  - Potential fix #3: Check connectivity to `Kube_URL`

    By default the Kube_URL is set to `https://kubernetes.default.svc:443`. Ensure that you have connectivity to this endpoint from within the cluster and that there are no special permission interfering with the connection.

- You  can't see new objects getting metadata

  In some cases, you might only see some objects being appended with metadata while other objects aren't enriched. This can occur at times when local data is cached and doesn't contain the correct id for the Kubernetes object that requires enrichment. For most Kubernetes objects the Kubernetes API server is updated which will then be reflected in Fluent Bit logs. In some cases for `Pod` objects this refresh to the Kubernetes API server can be skipped, causing metadata to be skipped.

## Credit

The Kubernetes Filter plugin is fully inspired by the [Fluentd Kubernetes Metadata Filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) written by [Jimmi Dyson](https://github.com/jimmidyson).
