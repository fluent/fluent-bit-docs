# WASM Input Plugins

[WebAssembly](https://webassembly.org/) is binary instruction format for stack based virtual machine.

Fluent Bit currently supports integration of wasm plugins built as wasm/wasi objects for input and filter plugins only.
The interface for the WASM filter plugins is currently under development but is functional.

## Prerequisites

### Building Fluent Bit

There are no additional requirements to execute WASM plugins.

### For Build WASM programs

Currently, fluent-bit supports the following WASM toolchains:

* Rust on `wasm32-unknown-unknown`.
  * rustc 1.62.1 (e092d0b6b 2022-07-16) or later
* [TinyGo](https://github.com/tinygo-org/tinygo) on wasm32-wasi
  * v0.24.0 or later
* [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 13 or later.

## Getting Started

Compile Fluent Bit with WASM support, e.g:

```text
$ cd build/
$ cmake ..
$ make
```

Once compiled, we can see new plugins in which handles _wasm_, e.g:

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

## Build a WASM Input for Input Plugin

Currently, Fluent Bit's WASM input assumes WASI ABI that is also known as `wasm32-wasi` on Rust target and `wasm32-wasi` on TinyGo target.

### To Install Additional Components

TinyGo and WASI SDK support wasm target by default.
When using Rust's `wasm32-wasi` target, users must install `wasm32-wasi` via [rustup](https://rustup.rs/). Then, installing that target components as:

```text
$ rustup target add wasm32-wasi
```

### Requirements of WASM/WASI programs

WASM input plugins execute the function that has wasi main function entrypoint.
And Fluent Bit's WASM input plugin communicates via stdout on WASM programs.

WASM programs should handle stdout for ingesting logs into Fluent Bit.


Once built, a WASM/WASI program will be available. Then, that built program can be executed with the following Fluent Bit configuration:

```text
[INPUT]
    Name exec_wasi
    Tag  exec.wasi.local
    WASI_Path /path/to/wasi_built_json.wasm
    # For security reasons, WASM/WASI program cannot access its outer world
    # without accessible permissions.
    # accessible_paths .,/path/to/fluent-bit

[OUTPUT]
    Name  stdout
    Match *
```

For further example that handles structured logs, fluent-bit has a Rust serde-json example: https://github.com/fluent/fluent-bit/tree/master/examples/wasi_serde_json
