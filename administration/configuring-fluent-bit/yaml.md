# YAML configuration

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=864c6f0e-8977-4838-8772-84416943548e" />

## Before you get started

Fluent Bit traditionally offered a `classic` configuration mode, a custom configuration format that's phasing out. While `classic` mode has served well for many years, it has several limitations. Its basic design only supports grouping sections with key-value pairs and lacks the ability to handle sub-sections or complex data structures like lists.

YAML has become essential in a cloud ecosystem. To minimize friction and provide a more intuitive experience for creating data pipelines, users are encouraged to transition to YAML. The YAML format enables features, such as processors, that aren't possible to configure in `classic` mode.

As of Fluent Bit v3.2, you can configure everything in YAML.

## List of available sections

Configuring Fluent Bit with YAML introduces the following root-level sections:

| Section Name | Description |
|--------------|-------------|
| `service` | Describes the global configuration for the Fluent Bit service. Optional. If not set, default values will apply. Only one `service` section can be defined. |
| `parsers` | Lists parsers to be used by components like inputs, processors, filters, or output plugins. You can define multiple `parsers` sections, which can also be loaded from external files included in the main YAML configuration. |
| `multiline_parsers`  | Lists multiline parsers, functioning similarly to `parsers`. Multiple definitions can exist either in the root or in included files. |
| `pipeline` | Defines a pipeline composed of inputs, processors, filters, and output plugins. You can define multiple `pipeline` sections, but they won't operate independently. Instead, all components will be merged into a single pipeline internally. |
| `plugins` | Specifies the path to external plugins (`.so` files) to be loaded by Fluent Bit at runtime. |
| `upstream_servers` | Refers to a group of node endpoints that can be referenced by output plugins that support this feature. |
| `env` | Sets a list of environment variables for Fluent Bit. System environment variables are available, while the ones defined in the configuration apply only to Fluent Bit. |

## Section documentation

To access detailed configuration guides for each section, use the following links:

- [Service Section documentation](./yaml/service-section.md)
  - Overview of global settings, configuration options, and examples.
- [Parsers Section documentation](./yaml/parsers-section.md)
  - Detailed guide on defining parsers and supported formats.
- [Multiline Parsers Section documentation](./yaml/multiline-parsers-section.md)
  - Explanation of multiline parsing configuration.
- [Pipeline Section documentation](./yaml/pipeline-section.md)
  - Details on setting up pipelines and using processors.
- [Plugins Section documentation](./yaml/plugins-section.md)
  - How to load external plugins.
- [Upstream Servers Section documentation](./yaml/upstream-servers-section.md)
  - Guide on setting up and using upstream nodes with supported plugins.
- [Environment Variables Section documentation](./yaml/environment-variables-section.md)
  - Information on setting environment variables and their scope within Fluent Bit.
- [Includes Section documentation](./yaml/includes-section.md)
  - Description on how to include external YAML files.