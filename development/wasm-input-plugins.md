# Wasm input plugins

[WebAssembly](https://webassembly.org/) (Wasm) is a binary instruction format for stack-based virtual machines.

Fluent Bit supports integration of Wasm plugins built as Wasm/WASI objects for inputs and filter plugins only. The interface for Wasm filter plugins is currently under development but is functional.

## Prerequisites

### Build Fluent Bit

There are no additional requirements to execute Wasm plugins.

### For Wasm programs

Fluent Bit supports the following Wasm toolchains:

* Rust on `wasm32-unknown-unknown`
  * rustc 1.62.1 (e092d0b6b 2022-07-16) or later
* [TinyGo](https://github.com/tinygo-org/tinygo) on `wasm32-wasi`
  * v0.24.0 or later
* [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 13 or later

## Get started

Compile Fluent Bit with Wasm support. For example:

```text
cd build/
cmake ..
make
```

Once compiled, you can see new plugins that handle `wasm`. For example:

```text
$ bin/fluent-bit -h
Usage: fluent-bit [OPTION]
Inputs
  # ... other input plugin stuffs
  exec_wasi               Exec WASI Input

Filters
  # ... other filter plugin stuffs
  wasm                    WASM program filter
```

## Build a Wasm input for input plugin

Wasm input in Fluent Bit assumes WASI ABI, also known as `wasm32-wasi` on Rust target and `wasm32-wasi` on TinyGo target.

### Install additional components

TinyGo and WASI SDK support Wasm target by default. When using Rust's `wasm32-wasi` target, you must install `wasm32-wasi` by using [rustup](https://rustup.rs/). Then, install the target components as:

```text
rustup target add wasm32-wasi
```

### Requirements of Wasm/WASI programs

Wasm input plugins execute the function that has a WASI main function entrypoint, and Wasm input plugins in Fluent Bit communicate through stdout on Wasm programs.

Wasm programs should handle stdout for ingesting logs into Fluent Bit.

Once built, a Wasm/WASI program will be available. Then you can execute that program with one of the following Fluent Bit configurations:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: exec_wasi
          tag: exec.wasi.local
          wasi_path: /path/to/wasi_built_json.wasm
          # For security reasons, WASM/WASI program cannot access its outer world
          # without accessible permissions. Uncomment below 'accessible_paths' and 
          # run Fluent Bit from the 'wasi_path' location:
          # accessible_paths /path/to/fluent-bit
        
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name exec_wasi
    Tag  exec.wasi.local
    WASI_Path /path/to/wasi_built_json.wasm
    # For security reasons, WASM/WASI program cannot access its outer world
    # without accessible permissions. Uncomment below 'accessible_paths' and 
    # run Fluent Bit from the 'wasi_path' location:
    # accessible_paths /path/to/fluent-bit

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

For an example that handles structured logs, see the [Rust `serde-json` example](https://github.com/fluent/fluent-bit/tree/master/examples/wasi_serde_json).