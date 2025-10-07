# Configure Fluent Bit using classic mode

Fluent Bit classic mode configuration will be deprecated at the end of 2026.

Classic mode is a custom configuration model for Fluent Bit. It's more limited than
the [YAML configuration mode](../configuring-fluent-bit/yaml.md), and doesn't have
the more extensive feature support the YAML configuration has. Classic mode basic design only supports grouping sections with key-value pairs and lacks the ability to handle sub-sections or complex data structures like lists.

Learn more about classic mode:

- [Format and schema](./classic-mode/format-schema.md)
- [Variables](./classic-mode/variables.md)
- [Configuration file](./classic-mode/configuration-file.md)
- [Commands](./classic-mode/commands.md)
- [Upstream servers](./classic-mode/upstream-servers.md)
- [Record accessor syntax](./classic-mode/record-accessor.md)
