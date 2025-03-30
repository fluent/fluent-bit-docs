# Conditional processing

Conditional processing allows you to selectively apply processors to log records based on field values. This feature enables you to create processing pipelines that apply processors only to records that match specific criteria.

## Configuration format

Conditional processing is available for processors in the YAML configuration format. To apply a processor conditionally, you add a `condition` block to the processor configuration:

```yaml
- name: processor_name
  # Regular processor configuration...
  condition:
    op: and|or
    rules:
      - field: "$field_name"
        op: comparison_operator
        value: comparison_value
      # Additional rules...
```

### Condition operators

The `op` field in the condition block specifies the logical operator to apply across all rules:

| Operator | Description |
| --- | --- |
| `and` | All rules must evaluate to true for the condition to be true |
| `or` | At least one rule must evaluate to true for the condition to be true |

### Rules

Each rule consists of:

- `field`: The field to evaluate (must use [record accessor syntax](/administration/configuring-fluent-bit/classic-mode/record-accessor.md) with `$` prefix)
- `op`: The comparison operator
- `value`: The value to compare against

### Comparison operators

The following comparison operators are supported:

| Operator | Description |
| --- | --- |
| `eq` | Equal to |
| `neq` | Not equal to |
| `gt` | Greater than |
| `lt` | Less than |
| `gte` | Greater than or equal to |
| `lte` | Less than or equal to |
| `regex` | Matches regular expression |
| `not_regex` | Does not match regular expression |
| `in` | Value is in the specified array |
| `not_in` | Value is not in the specified array |

### Field access

You can access record fields using [record accessor syntax](/administration/configuring-fluent-bit/classic-mode/record-accessor.md):

- Simple fields: `$field`
- Nested fields: `$parent['child']['subchild']`

## Examples

### Simple condition

Process records only when the HTTP method is POST:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"request": {"method": "GET", "path": "/api/v1/resource"}}'
      tag: request.log
      processors:
        logs:
          - name: content_modifier
            action: insert
            key: modified_if_post
            value: true
            condition:
              op: and
              rules:
                - field: "$request['method']"
                  op: eq
                  value: "POST"
```

### Multiple conditions with AND

Apply a processor only when both conditions are met:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"request": {"method": "POST", "path": "/api/v1/sensitive-data"}}'
      tag: request.log
      processors:
        logs:
          - name: content_modifier
            action: insert
            key: requires_audit
            value: true
            condition:
              op: and
              rules:
                - field: "$request['method']"
                  op: eq
                  value: "POST"
                - field: "$request['path']"
                  op: regex
                  value: "\/sensitive-.*"
```

### OR condition example

Flag records that meet any of multiple criteria:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"request": {"method": "GET", "path": "/api/v1/resource", "status_code": 200, "response_time": 150}}'
      tag: request.log
      processors:
        logs:
          - name: content_modifier
            action: insert
            key: requires_performance_check
            value: true
            condition:
              op: or
              rules:
                - field: "$request['response_time']"
                  op: gt
                  value: 100
                - field: "$request['status_code']"
                  op: gte
                  value: 400
```

### Using IN operator

Apply a processor when a value matches one of multiple options:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"request": {"method": "GET", "path": "/api/v1/resource"}}'
      tag: request.log
      processors:
        logs:
          - name: content_modifier
            action: insert
            key: high_priority_method
            value: true
            condition:
              op: and
              rules:
                - field: "$request['method']"
                  op: in
                  value: ["POST", "PUT", "DELETE"]
```

## Multiple processors with conditions

You can chain multiple conditional processors to create advanced processing pipelines:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"log": "Error: Connection refused", "level": "error", "service": "api-gateway"}'
      tag: app.log
      processors:
        logs:
          - name: content_modifier
            action: insert
            key: alert
            value: true
            condition:
              op: and
              rules:
                - field: "$level"
                  op: eq
                  value: "error"
                - field: "$service"
                  op: in
                  value: ["api-gateway", "authentication", "database"]

          - name: content_modifier
            action: insert
            key: paging_required
            value: true
            condition:
              op: and
              rules:
                - field: "$log"
                  op: regex
                  value: "(?i)(connection refused|timeout|crash)"
                - field: "$level"
                  op: in
                  value: ["error", "fatal"]
```

This configuration would add the `alert` field to error logs from critical services, and add the `paging_required` field to errors containing specific critical patterns.