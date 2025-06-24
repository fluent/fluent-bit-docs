# Wasm filter plugins

[WebAssembly](https://webassembly.org/) (Wasm) is a binary instruction format for stack-based virtual machines.

Fluent Bit supports integration of Wasm plugins built as Wasm/WASI objects for input and filter plugins only. The interface for Wasm filter plugins is currently under development but is functional.

## Prerequisites

### Build Fluent Bit

There are no additional requirements to execute Wasm plugins.

#### Build `flb-wamrc` (optional)

`flb-wamrc` is a `flb`-prefixed AOT (ahead of time) compiler that's provided from [`wasm-micro-runtime`](https://github.com/bytecodealliance/wasm-micro-runtime).

For `flb-wamrc` support, you must install the LLVM infrastructure and some additional libraries (`libmlir`, `libPolly`, `libedit`, and `libpfm`). For example:

```text
# apt install -y llvm libmlir-14-dev libclang-common-14-dev libedit-dev libpfm4-dev
```

### For Wasm programs

Currently, Fluent Bit supports the following Wasm tool chains:

* Rust on `wasm32-unknown-unknown`
  * rustc 1.62.1 (e092d0b6b 2022-07-16) or later
* [TinyGo](https://github.com/tinygo-org/tinygo) on `wasm32-wasi`
  * v0.24.0 or later
* [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 13 or later.

## Get started

As described in the general options in the [source installation](../installation/sources/build-and-install.md) guide, Wasm support is enabled by default. Compile Fluent Bit with Wasm support, for example:

```text
$ cd build/
$ cmake .. [-DFLB_WAMRC=On]
$ make
```

To support AOT-compiled Wasm execution as filter plugins, build Fluent Bit with `-DFLB_WAMRC=On`.

Once compiled, you can see new plugins that handle `wasm`, for example:

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

## Build a Wasm filter for filter plugin

The Fluent Bit Wasm filter assumes C ABI, also known as `wasm32-unknown-unknown` on Rust target and `wasm32-wasi` on TinyGo target.

### To Install Additional Components

TinyGo and WASI SDK support Wasm target by default. When using Rust's `wasm32-unknown-unknown` target, you must install `wasm32-unknown-unknown` by using [rustup](https://rustup.rs/). Then, install the target components as follows:

```text
$ rustup target add wasm32-unknown-unknown
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
pub extern "C" fn rust_filter(tag: *const c_char, tag_len: u32, time_sec: u32, time_nsec: u32, record: *const c_char, record_len: u32)
```

The `//export XXX` attribute on TinyGo and `#[no_mangle]` attribute on Rust are required. This is because TinyGo and Rust will mangle their function names if they aren't specified.

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
Another example of a Rust Wasm filter is the [flb_filter_iis](https://github.com/kenriortega/flb_filter_iis) filter.

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

### Optimize execution of Wasm programs

To optimize Wasm program execution, there is the option of using `flb-wamrc`. This option reduces your runtime footprint and to be best performance for filtering operations.

This tool will be built when the `-DFLB_WAMRC=On` CMake option is specified and LLVM infrastructure is installed on the building box.

```shell
$ flb-wamrc -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
```

For further optimizations to the specific CPU, such as Cortex-A57 series:

```text
$ flb-wamrc --size-level=3 --target=aarch64v8 --cpu=cortex-a57 -o /path/to/built_wasm.aot /path/to/built_wasm.wasm
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

* [C filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_c)
* [Rust Filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_rust)
* [TinyGo filter](https://github.com/fluent/fluent-bit/tree/master/examples/filter_wasm_go)