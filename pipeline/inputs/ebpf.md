# `in_ebpf` input plugin for Fluent Bit (experimental)

{% hint style="info" %}
This plugin is experimental and might be unstable. Use it in development or testing environments only. Its features and behavior are subject to change.
{% endhint %}

The `in_ebpf` input plugin uses eBPF (extended Berkeley Packet Filter) to capture low-level system events. This plugin lets Fluent Bit monitor kernel-level activities such as process executions, file accesses, memory allocations, network connections, and signal handling. It provides valuable insights into system behavior for debugging, monitoring, and security analysis.

The `in_ebpf` plugin leverages eBPF to trace kernel events in real-time. By specifying trace points, users can collect targeted system-level metrics and events, giving visibility into operating system interactions and performance characteristics.

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