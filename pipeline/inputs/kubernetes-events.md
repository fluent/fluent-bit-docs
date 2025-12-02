---
description: Collect Kubernetes events
---

# Kubernetes events

Kubernetes exports events through the API server. This input plugin lets you retrieve those events as logs and process them through the pipeline.

## Configuration parameters

| Key | Description | Default |
|:----|:------------|:--------|
| `db` | Set a database file to keep track of recorded Kubernetes events. | _none_ |
| `db.journal_mode` | Set the journal mode for databases. Values: `DELETE`, `TRUNCATE`, `PERSIST`, `MEMORY`, `WAL`, `OFF`. | `WAL` |
| `db.locking` | Specify that the database will be accessed only by Fluent Bit. Enabling this feature helps increase performance when accessing the database but restricts external tools from querying the content. | `false` |
| `db.sync` | Set a database sync method. Values: `extra`, `full`, `normal`, `off`. | `normal` |
| `dns_retries` | Set the number of DNS lookup retries until the network starts working. | `6` |
| `dns_wait_time` | Set the time interval between network status checks (in seconds). | `30` |
| `interval_nsec` | Set the reconnect interval (sub seconds: nanoseconds). | `500000000` |
| `interval_sec` | Set the reconnect interval (seconds). | `0` |
| `kube_ca_file` | Kubernetes TLS CA file. | `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` |
| `kube_ca_path` | Kubernetes TLS CA path. | _none_ |
| `kube_namespace` | Kubernetes namespace to query events from. Gets events from all namespaces by default. | _none_ |
| `kube_request_limit` | Kubernetes limit parameter for events query. No limit applied when set to `0`. | `0` |
| `kube_retention_time` | Kubernetes retention time for events. | `1h` |
| `kube_token_file` | Kubernetes authorization token file. | `/var/run/secrets/kubernetes.io/serviceaccount/token` |
| `kube_token_ttl` | Kubernetes token time to live, until it's read again from the token file. | `10m` |
| `kube_url` | API Server endpoint. | `https://kubernetes.default.svc` |
| `tls.debug` | Set TLS debug level: `0` (no debug), `1` (error), `2` (state change), `3` (info), and `4` (verbose). | `0` |
| `tls.verify` | Enable or disable verification of TLS peer certificate. | `true` |
| `tls.vhost` | Set optional TLS virtual host. | _none_ |

In Fluent Bit 3.1 or later, this plugin uses a Kubernetes watch stream instead of polling. In versions earlier than 3.1, the interval parameters are used for reconnecting the Kubernetes watch stream.

## Threading

This input always runs in its own [thread](../../administration/multithreading.md#inputs).

## Get started

### Kubernetes service account

The Kubernetes service account used by Fluent Bit must have `get`, `list`, and `watch` permissions to `namespaces` and `pods` for the namespaces watched in the `kube_namespace` configuration parameter. If you're using the Helm chart to configure Fluent Bit, this role is included.

### Basic configuration file

In the following configuration file, the Kubernetes events plugin collects events and exposes them through the [standard output plugin](../outputs/standard-output.md) on the console:


{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  log_level: info
    
pipeline:
  inputs:
    - name: kubernetes_events
      tag: k8s_events
      kube_url: https://kubernetes.default.svc
      
  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  flush           1
  log_level       info

[INPUT]
  name            kubernetes_events
  tag             k8s_events
  kube_url        https://kubernetes.default.svc

[OUTPUT]
  name            stdout
  match           *
```

{% endtab %}
{% endtabs %}

### Event timestamp

Event timestamps are created from the first existing field, based on the following order of precedence:

1. `lastTimestamp`
2. `firstTimestamp`
3. `metadata.creationTimestamp`