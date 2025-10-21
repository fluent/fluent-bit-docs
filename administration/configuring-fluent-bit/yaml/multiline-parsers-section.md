# Multiline parsers

Multiline parsers are used to combine logs that span multiple events into a single, cohesive message. Use this parser for handling stack traces, error logs, or any log entry that contains multiple lines of information.

In YAML configuration, the syntax for defining multiline parsers differs slightly from the classic configuration format introducing minor breaking changes, specifically on how the rules are defined.

The following example demonstrates how to define a multiline parser directly in the main configuration file, and how to include additional definitions from external files:

```yaml
multiline_parsers:
  - name: multiline-regex-test
    type: regex
    flush_timeout: 1000
    rules:
      - state: start_state
        regex: '/([a-zA-Z]+ \d+ \d+:\d+:\d+)(.*)/'
        next_state: cont
      - state: cont
        regex: '/^\s+at.*/'
        next_state: cont
```

This example defines a multiline parser named `multiline-regex-test` that uses regular expressions to handle multi-event logs. The parser contains two rules: the first rule transitions from `start_state` to cont when a matching log entry is detected, and the second rule continues to match subsequent lines.

For more detailed information on configuring multiline parsers, including advanced options and use cases, refer to the Configuring Multiline Parsers documentation.
