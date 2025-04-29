# Plugins Section

While Fluent Bit comes with a variety of built-in plugins, it also supports loading external plugins at runtime. This feature is especially useful for loading Go or Wasm plugins that are built as shared object files (.so). Fluent Bit's YAML configuration provides two ways to load these external plugins:

## 1. Inline YAML Section

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

## 2. YAML Plugins File Included using the `plugins_file` Option

Alternatively, you can load external plugins from a separate YAML file by specifying the `plugins_file` option in the service section. Here's how to configure this:

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

### Key Points

- Built-in versus External: Fluent Bit comes with many built-in plugins, but you can load external plugins at runtime to extend the tool's functionality.
- Loading Mechanism: External plugins must be shared object files (.so). You can define them inline in the main YAML configuration or include them from a separate YAML file for better modularity.
