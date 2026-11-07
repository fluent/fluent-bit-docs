# Wasm filter plugins

[WebAssembly](https://webassembly.org/) (Wasm) is a binary instruction format for stack-based virtual machines.

Fluent Bit supports integration of Wasm plugins built as Wasm/WASI objects for input and filter plugins only. The interface for Wasm filter plugins is currently under development but is functional.

## Prerequisites

### Build Fluent Bit

There are no additional requirements to execute Wasm plugins.

#### Build `flb-wamrc` (optional)

`flb-wamrc` is a `flb`-prefixed Ahead of Time (AOT) compiler that's provided from [`wasm-micro-runtime`](https://github.com/wasm-micro-runtime/wasm-micro-runtime).

For `flb-wamrc` support, you must install the LLVM infrastructure and some additional libraries (`libmlir`, `libPolly`, `libedit`, and `libpfm`). For example:

```text
# apt install -y llvm libmlir-14-dev libclang-common-14-dev libedit-dev libpfm4-dev
```

### For Wasm programs

Fluent Bit supports the following Wasm tool chains:

- Rust on `wasm32-unknown-unknown`
  - rustc 1.62.1 (`e092d0b6b` 2022-07-16) or later
- [TinyGo](https://github.com/tinygo-org/tinygo) on `wasm32-wasi`
  - v0.24.0 or later
- [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 13 or later.

## Get started

As described in the general options in the [source installation](../installation/downloads/source/build-and-install.md) guide, Wasm support is enabled by default. Compile Fluent Bit with Wasm support, for example:

```text
cd build/
cmake .. [-DFLB_WAMRC=On]
make
```

To support AOT-compiled Wasm execution as filter plugins, build Fluent Bit with `-DFLB_WAMRC=On`.

Once compiled, you can see new plugins that handle `wasm`, for example:

```shell
bin/fluent-bit -h
```

Which returns results similar to:

```text
Usage: fluent-bit [OPTION]
Inputs
  # ... other input plugin stuffs
  exec_wasi               Exec WASI Input

Filters
  # ... other filter plugin stuffs
  wasm                    WASM program filter
```

## Build a Wasm filter for filter plugin

The Fluent Bit Wasm filter assumes C ABI, also known as `wasm32-unknown-unknown` on Rust target and `wasm32-wasi` on TinyGo target.

### Install additional components

TinyGo and WASI SDK support Wasm target by default. When using Rust's `wasm32-unknown-unknown` target, you must install `wasm32-unknown-unknown` by using [`rustup`](https://rustup.rs/). Then, install the target components as follows:

```text
rustup target add wasm32-unknown-unknown
```

### Requirements of Wasm programs

Wasm filter plugins execute the function that has the following signature.

For C:

```text
// We can use an arbitrary function name for filter operations w/ Wasm.
char* c_filter(char*, int, uint32_t, uint32_t, char*, int);
```

For Go (TinyGo):

```text
//export go_filter
// And this function should be placed in the main package.
func go_filter(tag *uint8, tag_len uint, time_sec uint, time_nsec uint, record *uint8, record_len uint) *uint8
```

For Rust:

```text
// #[no_mangle] attribute is needed for preventing mangles and align C ABI.
// Also we can use an arbitrary function name for filter operations w/ Wasm.
#[no_mangle]
pub extern "C" fn rust_filter(tag: *const c_char, tag_len: u32, time_sec: u32, time_nsec: u32, record: *const c_char, record_len: u32) -> *const u8
```

The `//export XXX` attribute on TinyGo and `#[no_mangle]` attribute on Rust are required. This is because TinyGo and Rust will mangle their function names if they aren't specified.

In the Rust 2024 edition, `no_mangle` is an unsafe attribute, so write `#[unsafe(no_mangle)]` instead. This form requires Rust 1.82 or later. The examples on this page use `#[no_mangle]`, which works with earlier editions.

Once built, a Wasm program will be available. Then you can execute that built program with one of the following Fluent Bit configurations:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          tag: dummy.local

    filters:
      - name: wasm
        match: 'dummy.*'
        wasm_path: /path/to/built_filter.wasm
        function_name: super_awesome_filter
        # Note: run Fluent Bit from the 'wasm_path' location.
        accessible_paths: /path/to/fluent-bit

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name dummy
    Tag dummy.local

[FILTER]
    Name wasm
    Match dummy.*
    WASM_Path /path/to/built_filter.wasm
    Function_Name super_awesome_filter
    accessible_paths /path/to/fluent-bit

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

For example, one of the sample [Rust Wasm filters](https://github.com/fluent/fluent-bit/tree/master/examples/filter_rust) should generate its filtered logs as follows:

```text
[0] dummy.local: [1666270588.271704000, {"lang"=>"Rust", "message"=>"dummy", "original"=>"{"message":"dummy"}", "tag"=>"dummy.local", "time"=>"2022-10-20T12:56:28.271704000 +0000"}]
[0] dummy.local: [1666270589.270348000, {"lang"=>"Rust", "message"=>"dummy", "original"=>"{"message":"dummy"}", "tag"=>"dummy.local", "time"=>"2022-10-20T12:56:29.270348000 +0000"}]
[0] dummy.local: [1666270590.271107000, {"lang"=>"Rust", "message"=>"dummy", "original"=>"{"message":"dummy"}", "tag"=>"dummy.local", "time"=>"2022-10-20T12:56:30.271107000 +0000"}]
```

Another example of a Rust Wasm filter is the [`flb_filter_iis`](https://github.com/kenriortega/flb_filter_iis) filter.

This filter takes the [Internet Information Services (IIS)](https://learn.microsoft.com/en-us/iis/manage/provisioning-and-managing-iis/configure-logging-in-iis) [w3c logs](https://learn.microsoft.com/en-us/iis/manage/provisioning-and-managing-iis/configure-logging-in-iis#select-w3c-fields-to-log) (with some custom modifications) and transforms the raw string into a standard Fluent Bit JSON structured record.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"log": "2023-08-11 19:56:44 W3SVC1 WIN-PC1 ::1 GET / - 80 ::1 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/115.0.0.0+Safari/537.36+Edg/115.0.1901.200 - - localhost 304 142 756 1078 -"}'
          tag: 'iis.*'

    filters:
      - name: wasm
        match: 'iis.*'
        wasm_path: /plugins/flb_filter_iis_wasm.wasm
        function_name: flb_filter_log_iis_w3c_custom
        accessible_paths: .

    outputs:
        - name: stdout
          match: 'iis.*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name             dummy
    Dummy            {"log": "2023-08-11 19:56:44 W3SVC1 WIN-PC1 ::1 GET / - 80 ::1 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/115.0.0.0+Safari/537.36+Edg/115.0.1901.200 - - localhost 304 142 756 1078 -"}
    Tag              iis.*

[FILTER]
    Name             wasm
    match            iis.*
    WASM_Path        /plugins/flb_filter_iis_wasm.wasm
    Function_Name    flb_filter_log_iis_w3c_custom
    accessible_paths .

[OUTPUT]
    name             stdout
    match            iis.*
```

{% endtab %}
{% endtabs %}

The incoming raw strings from an IIS log are composed of the following fields:

`date time s-sitename s-computername s-ip cs-method cs-uri-stem cs-uri-query s-port c-ip cs(User-Agent) cs(Cookie) cs(Referer) cs-host sc-status sc-bytes cs-bytes time-taken c-authorization-header`

The output after the filter logic will be:

```text
[0] iis.*: [[1692131925.559486675, {}], {"c_authorization_header"=>"-", "c_ip"=>"::1", "cs_bytes"=>756, "cs_cookie"=>"-", "cs_host"=>"localhost", "cs_method"=>"GET", "cs_referer"=>"-", "cs_uri_query"=>"-", "cs_uri_stem"=>"/", "cs_user_agent"=>"Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/115.0.0.0+Safari/537.36+Edg/115.0.1901.200", "date"=>"2023-08-11 19:56:44", "s_computername"=>"WIN-PC1", "s_ip"=>"::1", "s_port"=>"80", "s_sitename"=>"W3SVC1", "sc_bytes"=>142, "sc_status"=>"304", "source"=>"LogEntryIIS", "tag"=>"iis.*", "time"=>"2023-08-15T20:38:45.559486675 +0000", "time_taken"=>1078}]
```

This filter approach offers several advantages inherent to programming languages. For example:

- It can be extended by adding type conversion to fields, such as `sc_bytes`, `cs_bytes`, and `time_taken`. You can use this to validate data results.
- It allows for the use of conditions to apply more descriptive filters. For example, you can get only all logs that contain status codes higher than `4xx` or `5xx`.
- It can be used to define allow lists and deny lists using a data structure array or a file to store predefined IP addresses.
- It makes it possible to call an external resource such as an API or database to enhance your data.
- It allows all methods to be thoroughly tested and shared as a binary bundle or library.

These examples can be applied in a demo and can serve as an ideal starting point to create more complex logic, depending on your requirements.

### ABI version 2: value-length return

The signatures in [Requirements of Wasm programs](#requirements-of-wasm-programs) use ABI version `1`, the default, where the function returns a pointer to a null-terminated string. Set `abi_version` to `2` in the [Wasm filter](../pipeline/filters/wasm.md) to use the value-length convention instead. With version `2`, the output doesn't need a null terminator, so the function can return binary MessagePack and JSON.

The function takes the same six arguments as version `1` (tag, tag length, seconds, nanoseconds, record, record length) and returns one 64-bit integer. The low 32 bits hold the offset of the output in Wasm linear memory, and the high 32 bits hold its length in bytes. At startup, Fluent Bit verifies that the function has six 32-bit integer parameters and a 64-bit integer result, and fails to start if it doesn't.

For C:

```c
#include <stdint.h>

uint64_t c_filter_v2(const char *tag, uint32_t tag_length,
                     uint32_t seconds, uint32_t nanoseconds,
                     const char *record, uint32_t record_length)
{
    return ((uint64_t) record_length << 32) | (uint32_t) (uintptr_t) record;
}
```

For Go (TinyGo):

```go
package main

import "unsafe"

//export filter_v2
func filter_v2(tag *byte, tagLength uint32, seconds uint32, nanoseconds uint32,
	record *byte, recordLength uint32) uint64 {
	return uint64(recordLength)<<32 | uint64(uint32(uintptr(unsafe.Pointer(record))))
}

func main() {}
```

For Rust:

```rust
#[no_mangle]
pub extern "C" fn filter_v2(
    _tag: *const u8,
    _tag_length: u32,
    _seconds: u32,
    _nanoseconds: u32,
    record: *const u8,
    record_length: u32,
) -> u64 {
    ((record_length as u64) << 32) | (record as u32 as u64)
}
```

These examples return the incoming record unchanged.

The returned value is handled as follows:

- Returning `0` drops the record. A non-zero value with a zero offset or zero length is invalid.
- The output must contain exactly one map: a JSON object when `event_format` is `json`, or a MessagePack map when `event_format` is `msgpack`. With JSON, only whitespace can follow the object.
- The record keeps its original timestamp and metadata. The output replaces only the record body.
- If the call fails, or the output is invalid, Fluent Bit logs `WASM call or output is invalid; keeping original record` and passes the original record through unchanged. With version `1`, a failed call drops the record instead.

Fluent Bit copies the output as soon as the function returns, before it releases the input, so the function can return a slice of the input record. Output stored in module-owned memory must stay valid after the function returns, until the next call. Don't return stack-local storage or memory that's freed when the function returns, such as a dropped Rust `Vec`. To avoid leaking memory, reuse or release module-owned buffers instead of allocating new ones on every call.

The following configuration uses the Rust example with ABI version `2`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: example

  filters:
    - name: wasm
      match: '*'
      wasm_path: filter_v2.wasm
      function_name: filter_v2
      abi_version: 2
      event_format: json

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name dummy
    Tag  example

[FILTER]
    Name          wasm
    Match         *
    WASM_Path     filter_v2.wasm
    Function_Name filter_v2
    Abi_Version   2
    Event_Format  json

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

### Optimize execution of Wasm programs

To optimize Wasm program execution, there is the option of using `flb-wamrc`. This option reduces your runtime footprint and to be best performance for filtering operations.

This tool will be built when the `-DFLB_WAMRC=On` CMake option is specified and LLVM infrastructure is installed on the building box.

```shell
flb-wamrc -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
```

For further optimizations to the specific CPU, such as Cortex-A57 series:

```text
flb-wamrc --size-level=3 --target=aarch64v8 --cpu=cortex-a57 -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
```

Then, when AOT (Ahead Of Time) compiling has succeeded:

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

AOT compiling should generate CPU architecture-dependent objects. If you want to use an AOT compiled object on different architecture, it must align the `target` and `target cpu` for actual environments.

### Further examples

- [C filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_c)
- [Rust Filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_rust)
- [Rust ABI version 2 filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_rust)
- [TinyGo
  filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_go)
