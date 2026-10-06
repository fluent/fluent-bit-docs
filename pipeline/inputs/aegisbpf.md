# AegisBPF

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _AegisBPF_ input plugin streams runtime-security events from a co-located [AegisBPF](https://github.com/ErenAri/Aegis-BPF) agent into the Fluent Bit pipeline. This plugin is available only for Linux.

AegisBPF is a Berkeley Packet Filter (BPF) Linux Security Module (LSM) enforcement agent that exposes an opt-in, root-only Unix control socket. The plugin connects to that socket, requests the event stream, and forwards each newline-delimited JSON Open Cybersecurity Schema Framework (OCSF) security event as a record. It reconnects automatically if the agent restarts.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `reconnect_sec` | Interval in seconds between reconnection attempts while disconnected. | `2` |
| `socket_path` | Path to the AegisBPF control socket (a root-only Unix stream socket). | `/var/run/aegisbpf/aegisbpf.sock` |

## Prerequisites

- The AegisBPF agent must run with its control socket enabled, for example `AEGIS_API_SOCKET=/var/run/aegisbpf/aegisbpf.sock`.
- The socket is created with `0600` permissions and owned by the agent (root), so Fluent Bit must run as the same user (typically root) to connect.

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

```shell
fluent-bit -i aegisbpf -p socket_path=/var/run/aegisbpf/aegisbpf.sock -o stdout
```

### Configuration file

In your configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: aegisbpf
      socket_path: /var/run/aegisbpf/aegisbpf.sock

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name        aegisbpf
  Socket_Path /var/run/aegisbpf/aegisbpf.sock

[OUTPUT]
  Name  stdout
  Match *
```

{% endtab %}
{% endtabs %}

Each security event is emitted as a single record whose body is the JSON object sent by the agent (AegisBPF emits OCSF-formatted events by default). The record timestamp is the time the event was received.
