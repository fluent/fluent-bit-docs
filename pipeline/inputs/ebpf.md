# `in_ebpf` Input Plugin for Fluent Bit (Experimental)

> **Note:** This plugin is experimental and may be unstable. Use it in development or testing environments only, as its features and behavior are subject to change.

The `in_ebpf` input plugin is an **experimental** plugin for Fluent Bit that uses eBPF (extended Berkeley Packet Filter) to capture low-level system events. This plugin allows Fluent Bit to monitor kernel-level activities such as process executions, file accesses, memory allocations, network connections, and signal handling. It provides valuable insights into system behavior for debugging, monitoring, and security analysis.

## Overview

The `in_ebpf` plugin leverages eBPF to trace kernel events in real-time. By specifying trace points, users can collect targeted system-level metrics and events, which can be particularly useful for gaining visibility into operating system interactions and performance characteristics.

## System Dependencies

To enable `in_ebpf`, ensure the following dependencies are installed on your system:
- **Kernel Version**: 4.18 or higher with eBPF support enabled.
- **Required Packages**:
  - `bpftool`: Used to manage and debug eBPF programs.
  - `libbpf-dev`: Provides the `libbpf` library for loading and interacting with eBPF programs.
  - **CMake** 3.13 or higher: Required for building the plugin.

### Installing Dependencies on Ubuntu
```bash
sudo apt update
sudo apt install libbpf-dev linux-tools-common cmake
```

## Building Fluent Bit with `in_ebpf`

To enable the `in_ebpf` plugin, follow these steps to build Fluent Bit from source:

1. **Clone the Fluent Bit Repository**
```bash
git clone https://github.com/fluent/fluent-bit.git
cd fluent-bit
```

2. **Configure the Build with `in_ebpf`**

Create a build directory and run `cmake` with the `-DFLB_IN_EBPF=On` flag to enable the `in_ebpf` plugin:
```bash
mkdir build
cd build
cmake .. -DFLB_IN_EBPF=On
```

3. **Compile the Source**
```bash
make
```

4. **Run Fluent Bit**

Run Fluent Bit with elevated permissions (e.g., `sudo`), as loading eBPF programs requires root access or appropriate privileges:
```bash
sudo ./bin/fluent-bit -c path/to/your_config.conf
```

## Configuration Example

Here's a basic example of how to configure the plugin:

```
[INPUT]
    Name          ebpf
    Trace         trace_signal
    Trace         trace_malloc
    Trace         trace_bind
```

The configuration above enables tracing for:
- Signal handling events (`trace_signal`)
- Memory allocation events (`trace_malloc`)
- Network bind operations (`trace_bind`)

You can enable multiple traces by adding multiple `Trace` directives in your configuration.
Full list of existing traces can be seen here: [Fluent Bit eBPF Traces](https://github.com/fluent/fluent-bit/tree/master/plugins/in_ebpf/traces)

