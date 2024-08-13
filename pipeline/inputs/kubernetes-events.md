---
description: >-
  Collects Kubernetes Events
---

# Kubernetes Events

Kubernetes exports it events through the API server. This input plugin allows to retrieve those events as logs and get them processed through the pipeline.

## Configuration


| Key                 | Description                                                                           | Default                                              |
|---------------------|---------------------------------------------------------------------------------------|------------------------------------------------------|
| db                  | Set a database file to keep track of recorded Kubernetes events                       |                                                      |
| db.sync             | Set a database sync method. values: extra, full, normal and off                       | normal                                               |
| interval_sec        | Set the polling interval for each channel.                                            | 0                                                    |
| interval_nsec       | Set the polling interval for each channel (sub seconds: nanoseconds)                  | 500000000                                            | 
| kube_url            | API Server end-point                                                                  | https://kubernetes.default.svc                       |
| kube_ca_file        | Kubernetes TLS CA file                                                                | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |
| kube_ca_path        | Kubernetes TLS ca path                                                                |                                                      |
| kube_token_file     | Kubernetes authorization token file.                                                  | /var/run/secrets/kubernetes.io/serviceaccount/token  |
| kube_token_ttl      | kubernetes token ttl, until it is reread from the token file.                         | 10m                                                  |
| kube_request_limit  | kubernetes limit parameter for events query, no limit applied when set to 0.          | 0                                                    |
| kube_retention_time | Kubernetes retention time for events.                                                 | 1h                                                   |
| kube_namespace      | Kubernetes namespace to query events from. Gets events from all namespaces by default |                                                      |
| tls.debug           | Debug level between 0 (nothing) and 4 (every detail).                                 | 0                                                    |
| tls.verify          | Enable or disable verification of TLS peer certificate.                               | On                                                   |
| tls.vhost           | Set optional TLS virtual host.                                                        |                                                      |

## Getting Started

### Simple Configuration File

In the following configuration file, the input plugin *kubernetes_events* collects events every 5 seconds (default for *interval_nsec*) and exposes them through the [standard output plugin](../outputs/standard-output.md) on the console.

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

### Event Timestamp
Event timestamp will be created from the first existing field in the following order of precendence: lastTimestamp, firstTimestamp, metadata.creationTimestamp
