# eBPF

{% hint style="info" %}
This plugin is experimental and might be unstable. Use it in development or testing environments only. Its features and behavior are subject to change.
{% endhint %}

The `in_ebpf` input plugin uses eBPF (extended Berkeley Packet Filter) to capture low-level system events. This plugin lets Fluent Bit monitor kernel-level activities such as process executions, file accesses, memory allocations, network connections, and signal handling. It provides valuable insights into system behavior for debugging, monitoring, and security analysis.

The `in_ebpf` plugin leverages eBPF to trace kernel events in real-time. By specifying trace points, users can collect targeted system-level metrics and events, giving visibility into operating system interactions and performance characteristics.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
|:----|:------------|:--------|
| `poll_ms` | Set the polling interval in milliseconds for collecting events from the ring buffer. | `1000` |
| `ringbuf_map_name` | Set the name of the eBPF ring buffer map to read events from. | `events` |
| `trace` | Set the eBPF trace to enable (for example, `trace_bind`, `trace_malloc`, `trace_signal`). Can be set multiple times to enable multiple traces. | _none_ |

## System dependencies

To enable `in_ebpf`, ensure the following dependencies are installed on your system:

- **Kernel version**: 4.18 or greater, with eBPF support enabled.
- **Required packages**:
  - `bpftool`: Used to manage and debug eBPF programs.
  - `libbpf-dev`: Provides the `libbpf` library for loading and interacting with eBPF programs.
  - **CMake** 3.13 or higher: Required for building the plugin.

### Installing dependencies on Ubuntu

```shell
sudo apt update
sudo apt install libbpf-dev linux-tools-common cmake
```

## Building Fluent Bit with `in_ebpf`

To enable the `in_ebpf` plugin, follow these steps to build Fluent Bit from source:

1. Clone the Fluent Bit repository:

   ```shell
   git clone https://github.com/fluent/fluent-bit.git
   cd fluent-bit
   ```

1. Configure the build with `in_ebpf`:

   Create a build directory and run `cmake` with the `-DFLB_IN_EBPF=On` flag to enable the `in_ebpf` plugin:

   ```shell
   mkdir build
   cd build
   cmake .. -DFLB_IN_EBPF=On
   ```

1. Compile the source:

   ```shell
   make
   ```

1. Run Fluent Bit:

   Run Fluent Bit with elevated permissions (for example, `sudo`). Loading eBPF programs requires root access or appropriate privileges.

   ```shell
   # For YAML configuration.
   sudo fluent-bit --config fluent-bit.yaml

   # For classic configuration.
   sudo fluent-bit --config fluent-bit.conf
   ```

## Configuration example

Here's a basic example of how to configure the plugin:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: ebpf
      poll_ms: 500
      trace:
        - trace_signal
        - trace_malloc
        - trace_bind
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name          ebpf
  Poll_Ms       500
  Trace         trace_signal
  Trace         trace_malloc
  Trace         trace_bind
```

{% endtab %}
{% endtabs %}

The configuration enables tracing for:

- Signal handling events (`trace_signal`)
- Memory allocation events (`trace_malloc`)
- Network bind operations (`trace_bind`)

You can enable multiple traces by adding multiple `Trace` directives in your configuration.
Full list of existing traces can be seen here: [Fluent Bit eBPF Traces](https://github.com/fluent/fluent-bit/tree/master/plugins/in_ebpf/traces)

## Output fields

Each trace produces records with common fields and trace-specific fields.

### Common fields

All traces include the following fields:

| Field | Description |
|:------|:------------|
| `event_type` | Type of event (`signal`, `malloc`, or `bind`). |
| `pid` | Process ID that generated the event. |
| `tid` | Thread ID that generated the event. |
| `comm` | Command name (process name) that generated the event. |

### Signal trace fields

The `trace_signal` trace includes these additional fields:

| Field | Description |
|:------|:------------|
| `signal` | Signal number that was sent. |
| `tpid` | Target process ID that received the signal. |

### Memory trace fields

The `trace_malloc` trace includes these additional fields:

| Field | Description |
|:------|:------------|
| `operation` | Memory operation type (for example, `0` = `malloc`, `1` = `free`, `2` = `calloc`, `3` = `realloc`). |
| `address` | Memory address of the operation. |
| `size` | Size of the memory operation in bytes. |

### Bind trace fields

The `trace_bind` trace includes these additional fields:

| Field | Description |
|:------|:------------|
| `uid` | User ID of the process. |
| `gid` | Group ID of the process. |
| `port` | Port number the socket is binding to. |
| `bound_dev_if` | Network device interface the socket is bound to. |
| `error_raw` | Error code for the bind operation (`0` indicates success). |
