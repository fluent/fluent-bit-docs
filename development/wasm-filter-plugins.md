# WASM Filter Plugins

Fluent Bit currently supports integration of wasm plugins built as wasm/wasi objects for input and filter plugins only. The interface for the WASM filter plugins is currently under development but is functional.

## Prerequisites

### For Build fluent-bit

For only execution of WASM input and filter plugins, there is no additional requirement.

#### Building flb-wamrc (optional)

For `flb-wamrc` support, users have to install llvm infrastructure, e.g:

```text
# apt install -y llvm
```

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
$ cmake .. [-DFLB_WAMRC=On]
$ make
```

To support AOT compiled WASM execution as filter plugins, users have to built fluent-bit with `-DFLB_WAMRC=On`.

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

## Build a WASM Filter for Filter Plugin

Currently, fluent-bit's WASM filter assumes C ABI that is also known as `wasm32-unknown-unknown` on Rust target and `wasm32-wasi` on TinyGo target.

### To Install Additional Components

TinyGo and WASI SDK support wasm target by default.
When using Rust's `wasm32-unknown-unknown` target, users must install `wasm32-unknown-unknown` via [rustup](https://rustup.rs/). Then, installing that target components as:

```text
$ rustup target add wasm32-unknown-unknown
```

### Requirements of WASM programs

WASM filter plugins execute the function that has the following signagure.

For C:

```text
// We can use an arbitrary function name for filter operations w/ WASM.
char* c_filter(char*, int, uint32_t, uint32_t, char*, int);
```

For Go(TinyGo):

```text
//export go_filter
// And this function should be placed in the main package.
func go_filter(tag *uint8, tag_len uint, time_sec uint, time_nsec uint, record *uint8, record_len uint) *uint8
```

For Rust:

```text
// #[no_mangle] attribute is needed for preventing mangles and align C ABI.
// Also we can use an arbitrary function name for filter operations w/ WASM.
#[no_mangle]
pub extern “C” fn rust_filter(tag: *const c_char, tag_len: u32, time_sec: u32, time_nsec: u32, record: *const c_char, record_len: u32)
```

Note that `//export XXX` on TinyGo and `#[no_mangle]` attributes on Rust are required. This is because TinyGo and Rust will mangle their function names if they are not specified.

Once built, a WASM program will be available. Then, that built program can be executed with the following fluent-bit configuration:

```text
[SERVICE]
    Flush        1
    Daemon       Off
    Log_Level    info
    HTTP_Server  Off
    HTTP_Listen  0.0.0.0
    HTTP_Port    2020

[INPUT]
    Name dummy
    Tag dummy.local

[FILTER]
    Name wasm
    Tag  dummy.*
    WASM_Path /path/to/built_filter.wasm
    Function_Name super_awesome_filter
    accessible_paths .,/path/to/fluent-bit

[OUTPUT]
    Name  stdout
    Match *
```

### Optimize execution of WASM programs

To optimize WASM program execution, users can use `flb-wamrc` for this purpose.
This tool will be built when `-DFLB_WAMRC=On` cmake option is specififed and llvm infrastructure is installed on the building box.

```text
$ flb-wamrc -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
```

For more optimizing the specific CPU such as Cortex-A57 series, e.g:

```text
$ flb-wamrc --size-level=3 --target=aarch64v8 --cpu=cortex-a57 -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
```

Then, when AOT compiling is succeeded:

```text
Create AoT compiler with:
  target:        aarch64v8
  target cpu:    cortex-a57
  cpu features:
  opt level:     3
  size level:    3
  output format: AoT file
Compile success, file /path/to/built_wasm.aot was generated.
```

Note that AOT compiling should generate CPU architecture-dependent objects. If users want to use AOT compiled object on the different archtecture, it must align the **target** and **target cpu** for actual environments.

### Further Concrete Examples

* C Filter
  * https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_c
* Rust Filter
  * https://github.com/fluent/fluent-bit/tree/master/examples/filter_rust
* TinyGo Filter
  * https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_go
