# YAML configuration files

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=864c6f0e-8977-4838-8772-84416943548e" />

In Fluent Bit v3.2 and later, YAML configuration files support all of the settings
and features that [classic configuration files](./classic-mode.md) support, plus additional features that classic configuration files
don't support, like processors.

YAML configuration files support the following top-level sections:

- `env`: Configures [environment variables](./yaml/environment-variables-section.md).
- `includes`: Specifies additional YAML configuration files to [include as part of a parent file](./yaml/includes-section.md).
- `service`: Configures global properties of the Fluent Bit [service](./yaml/service-section.md).
- `pipeline`: Configures active [`inputs`, `filters`, and `outputs`](./yaml/pipeline-section.md).
- `parsers`: Defines [custom parsers](./yaml/parsers-section.md).
- `multiline_parsers`: Defines [custom multiline parsers](./yaml/multiline-parsers-section.md).
- `plugins`: Defines paths for [custom plugins](./yaml/plugins-section.md).
- `upstream_servers`: Defines [nodes](./yaml/upstream-servers-section.md) for output plugins.
- `extensions`: Carries [settings for external tooling](#extensions-section) that Fluent Bit parses but doesn't act on.

{% hint style="info" %}
YAML configuration is used in the smoke tests for containers. An always-correct up-to-date example is here: <https://github.com/fluent/fluent-bit/blob/master/packaging/testing/smoke/container/fluent-bit.yaml>.
{% endhint %}

## `extensions` section

The `extensions` section is available in Fluent Bit version 5.1 and greater.

Use this section to store settings that belong to tooling around Fluent Bit, such as a management agent or a deployment system, in the same file as your pipeline. Fluent Bit parses and retains the section, but nothing in the data pipeline reads it. Adding it doesn't change how Fluent Bit collects, processes, or delivers data.

Unlike other sections, `extensions` accepts arbitrarily nested maps, and preserves the type of each value. Group settings under a key that identifies the tool that consumes them:

```yaml
service:
  flush: 1
  log_level: info

extensions:
  opamp:
    endpoint: 127.0.0.1:4318
    insecure: true
  deployment:
    config_version: 12345
```

Nested values are only accepted in this section. Using a nested map elsewhere fails with `variant values are only valid in the extensions section`.
