# Plugins

Fluent Bit comes with a variety of built-in plugins, and also supports loading external plugins at runtime. This feature is especially useful for loading Go or WebAssembly (Wasm) plugins that are built as shared object files (`.so`). Fluent Bit YAML configuration provides the following ways to load these external plugins:

## Inline YAML

You can specify external plugins directly within your main YAML configuration file using the `plugins` section. Here's an example:

```yaml
plugins:
  - /path/to/out_gstdout.so

service:
  log_level: info

pipeline:
  inputs:
    - name: random

  outputs:
    - name: gstdout
      match: '*'
```

## YAML plugins file included using the `plugins_file` option

You can load external plugins from a separate YAML file by specifying the `plugins_file` option in the service section for better modularity.

To configure this:

```yaml
service:
  log_level: info
  plugins_file: extra_plugins.yaml

pipeline:
  inputs:
    - name: random

  outputs:
    - name: gstdout
      match: '*'
```

In this setup, the `extra_plugins.yaml` file might contain the following plugins section:

```yaml
plugins:
  - /other/path/to/out_gstdout.so
```
