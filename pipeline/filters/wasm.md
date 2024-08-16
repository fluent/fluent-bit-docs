---
description: Use Wasm programs as a filter
---

# Wasm Filter

Wasm Filter allows you to modify the incoming records using [Wasm](https://webassembly.org/) technology.

Due to the necessity to have a flexible filtering mechanism, it is now possible to extend Fluent Bit capabilities by writing custom filters using built Wasm programs and its runtime. A Wasm-based filter takes two steps:

0. (Optional) Compiled as AOT (Ahead Of Time) objects to optimize Wasm execution pipeline
1. Configure the Filter in the main configuration
2. Prepare a Wasm program that will be used by the Filter

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Wasm\_Path | Path to the built Wasm program that will be used. This can be a relative path against the main configuration file. |
| Event\_Format | Define event format to interact with Wasm programs: msgpack or json. Default: json |
| Function\_Name | Wasm function name that will be triggered to do filtering. It's assumed that the function is built inside the Wasm program specified above. |
| Accessible\_Paths | Specify the whitelist of paths to be able to access paths from WASM programs. |
| Wasm\_Heap\_Size | Size of the heap size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |
| Wasm\_Stack\_Size | Size of the stack size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |

## Configuration Examples <a id="config_example"></a>

Here is a configuration example.

```python
[INPUT]
    Name   dummy
    Tag    dummy.local

[FILTER]
    Name wasm
    Match dummy.*
    Event_Format json # or msgpack
    WASM_Path /path/to/wasm_program.wasm
    Function_Name filter_function_name
    Accessible_Paths .,/path/to/accessible

[OUTPUT]
    Name   stdout
    Match  *
```
