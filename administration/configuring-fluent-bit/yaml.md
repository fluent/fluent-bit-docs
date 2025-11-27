# YAML configuration files

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=864c6f0e-8977-4838-8772-84416943548e" />

In Fluent Bit v3.2 and later, YAML configuration files support all of the settings
and features that [classic configuration files](../administration/configuring-fluent-bit/classic-mode.md) support, plus additional features that classic configuration files
don't support, like processors.

YAML configuration files support the following top-level sections:

- `env`: Configures [environment variables](../administration/configuring-fluent-bit/yaml/environment-variables-section).
- `includes`: Specifies additional YAML configuration files to [include as part of a parent file](../administration/configuring-fluent-bit/yaml/includes-section).
- `service`: Configures global properties of the Fluent Bit [service](../administration/configuring-fluent-bit/yaml/service-section).
- `pipeline`: Configures active [`inputs`, `filters`, and `outputs`](../administration/configuring-fluent-bit/yaml/pipeline-section).
- `parsers`: Defines [custom parsers](../administration/configuring-fluent-bit/yaml/parsers-section).
- `multiline_parsers`: Defines [custom multiline parsers](../administration/configuring-fluent-bit/yaml/multiline-parsers-section).
- `plugins`: Defines paths for [custom plugins](../administration/configuring-fluent-bit/yaml/plugins-section).
- `upstream_servers`: Defines [nodes](../administration/configuring-fluent-bit/yaml/upstream-servers-section) for output plugins.

{% hint style="info" %}
YAML configuration is used in the smoke tests for containers. An always-correct up-to-date example is here: <https://github.com/fluent/fluent-bit/blob/master/packaging/testing/smoke/container/fluent-bit.yaml>.
{% endhint %}
