# Parsers

Parsers enable Fluent Bit components to transform unstructured data into a structured internal representation. You can define YAML parsers either directly in the main configuration file or in separate external files for better organization.

This page provides a general overview of how to declare parsers.

The main section name is `parsers`, and it lets you define a list of parser configurations. The following example demonstrates how to set up two basic parsers:

```yaml
parsers:
  - name: json
    format: json

  - name: docker
    format: json
    time_key: time
    time_format: "%Y-%m-%dT%H:%M:%S.%L"
    time_keep: true
```

You can define multiple parsers sections, either within the main configuration file or distributed across included files.

For more detailed information on parser options and advanced configurations, refer to the [Configuring Parsers](../../../pipeline/parsers/configuring-parser.md) documentation.
