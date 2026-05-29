# Plugins

In addition to the plugins that come bundled with Fluent Bit, you can load external plugins. Use this feature for loading Go or WebAssembly (Wasm) plugins that are built as shared object files (`.so`).

{% hint style="info" %}
To configure the settings for individual plugins, use the `inputs` and `outputs` sections nested under the [`pipeline` section](./pipeline-section.md) of YAML configuration files.
{% endhint %}

## Inline YAML

You can specify external plugins in the `plugins` section of YAML configuration files. For example:

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

Additionally, you can define external plugins in a separate YAML file, then reference that file in the `plugins_file` key nested under the [`service` section](./service-section.md) of your YAML configuration file. For example:

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
