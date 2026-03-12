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
| `accessible_paths` | Specify the allowlist of paths to be able to access paths from Wasm programs. Default: `.` (current directory). |
| `event_format` | Define event format to interact with Wasm programs: `msgpack` or `json`. Default: `json`. |
| `function_name` | Wasm function name that will be triggered to do filtering. It's assumed that the function is built inside the Wasm program specified previously. |
| `wasm_heap_size` | Size of the heap size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values. |
| `wasm_path` | Path to the built Wasm program that will be used. This can be a path relative to the main configuration file. |
| `wasm_stack_size` | Size of the stack size of Wasm execution. Review [unit sizes](../../administration/configuring-fluent-bit.md#unit-sizes) for allowed values. |

## Configuration example

Here is a configuration example.

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
      event_format: json    # or msgpack
      wasm_path: /path/to/wasm_program.wasm
      function_name: filter_function_name
      # Note: run Fluent Bit from the 'wasm_path' location.
      accessible_paths: /path/to/accessible

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name   dummy
  Tag    dummy.local

[FILTER]
  Name             wasm
  Match            dummy.*
  Event_Format     json # or msgpack
  Wasm_Path        /path/to/wasm_program.wasm
  Function_Name    filter_function_name
  Accessible_Paths .,/path/to/accessible

[OUTPUT]
  Name   stdout
  Match  *
```

{% endtab %}
{% endtabs %}
