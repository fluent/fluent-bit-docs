---
description: Use Wasm programs as a filter.
---

# Wasm

The _Wasm_ filter lets you modify the incoming records using [Wasm](https://webassembly.org/) technology.

You can extend Fluent Bit capabilities by writing custom filters using built Wasm programs and its runtime. A Wasm-based filter takes the following steps:

1. (Optional) Compile Ahead Of Time (AOT) objects to optimize the Wasm execution pipeline.
1. Configure the filter in the main configuration.
1. Prepare a Wasm program that will be used by the filter.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `Wasm_Path` | Path to the built Wasm program that will be used. This can be a path relative to the main configuration file. |
| `Event_Format` | Define event format to interact with Wasm programs: `msgpack` or `json`. Default: `json`. |
| `Function_Name` | Wasm function name that will be triggered to do filtering. It's assumed that the function is built inside the Wasm program specified previously. |
| `Accessible_Paths` | Specify the allowlist of paths to be able to access paths from Wasm programs. |
| `Wasm_Heap_Size` | Size of the heap size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |
| `Wasm_Stack_Size` | Size of the stack size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit/unit-sizes.md) for allowed values. |

## Configuration example

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
