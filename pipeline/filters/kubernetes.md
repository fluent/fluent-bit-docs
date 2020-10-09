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
| Use\_Journal | When enabled, the filter reads logs coming in Journald format. | Off |
| Regex\_Parser | Set an alternative Parser to process record Tag and extract pod\_name, namespace\_name, container\_name and docker\_id. The parser must be registered in a [parsers file](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf) \(refer to parser _filter-kube-test_ as an example\). |  |
| K8S-Logging.Parser | Allow Kubernetes Pods to suggest a pre-defined Parser \(read more about it in Kubernetes Annotations section\) | Off |
| K8S-Logging.Exclude | Allow Kubernetes Pods to exclude their logs from the log processor \(read more about it in Kubernetes Annotations section\). | Off |
| Labels | Include Kubernetes resource labels in the extra metadata. | On |
| Annotations | Include Kubernetes resource annotations in the extra metadata. | On |
| Kube\_meta\_preload\_cache\_dir | If set, Kubernetes meta-data can be cached/pre-loaded from files in JSON format in this directory, named as namespace-pod.meta |  |
| Dummy\_Meta | If set, use dummy-meta data \(for test/dev purposes\) | Off |
| DNS\_Retries | DNS lookup retries N times until the network start working | 6 |
| DNS\_Wait\_Time | DNS lookup interval between network status checks | 30 |

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

## Kubernetes Annotations

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
    Parser  docker

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

If the configuration property **Kube\_Tag\_Prefix** was configured \(available on Fluent Bit &gt;= 1.1.x\), it will use that value to remove the prefix that was appended to the Tag in the previous Input section. Note that the configuration property defaults to \_kube.\_var.logs.containers. , so the previous Tag content will be transformed from:

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

#### Custom Regex

Under certain and not common conditions, a user would want to alter that hard-coded regular expression, for that purpose the option **Regex\_Parser** can be used \(documented on top\).

#### Final Comments

So at this point the filter is able to gather the values of _pod\_name_ and _namespace_, with that information it will check in the local cache \(internal hash table\) if some metadata for that key pair exists, if so, it will enrich the record with the metadata value, otherwise it will connect to the Kubernetes Master/API Server and retrieve that information.

