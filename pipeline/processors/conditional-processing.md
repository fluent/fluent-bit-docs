# Conditional processing

Conditional processing allows you to selectively apply processors to log records based on field values. This feature enables you to create processing pipelines that apply processors only to records that match specific criteria.

## Configuration

You can turn a standard processor into a conditional processor by adding a `condition` block to the
processor's YAML configuration settings.

{% hint style="info" %}
Conditional processing is only available for
[YAML configuration files](../../administration/configuring-fluent-bit/yaml/README.md),
not [classic configuration files](../../administration/configuring-fluent-bit/classic-mode/README.md).
{% endhint %}


These `condition` blocks use the following syntax:

```yaml
pipeline:
  inputs:
  <...>
      processors:
        logs:
          - name: {processor_name}
            <...>
            condition:
	      op: {and|or}
              rules:
                - field: {field_name1}
                  op: {comparison_operator}
                  value: {comparison_value1}
                - field: {field_name2}
                  op: {comparison_operator}
                  value: {comparison_value2}
            <...>
```

Each processor can only have a single `condition` block, but can have multiple rules within that condition.
These rules are stored as items in the `condition.rules` array.

### Condition evaluation

The `condition.op` parameter specifies the condition's evaluation logic. It has two possible values:

- `and`: All rules in the `condition.rules` array must evaluate to `true` for the condition to be met.
- `or`: One or more rules in the `conditions.rules` array must evaluate to `true` for the condition to be met.

### Rules

Each item in the `condition.rules` array must include values for the following parameters:

| Parameter | Description |
| --- | --- |
| `field` | The field within your logs to evaluate. The value of this parameter must use [the correct syntax](#field-access) to access the fields inside logs. |
| `op` | The [comparison operator](#comparison-operators) to evaluate whether the rule is true. This parameter (`condition.rules.op`) is distinct from the `condition.op` parameter and has different possible values. |
| `value` | The value of the specified log field to use in your comparison. Optionally, you can provide [an array that contains multiple values](#array-of-values). | 

Rules are evaluated against each log that passes through your data pipeline. For example, given a rule with these parameters:

```
- field: "$status"
   op: eq
   value: 200
```

This rule evaluates to `true` for a log that contains the string `'status':200`, but evaluates to `false` for a log that contains the string `'status':403`.

#### Field access

The `conditions.rules.field` parameter uses [record accessor syntax](/administration/configuring-fluent-bit/classic-mode/record-accessor.md) to reference fields inside logs.

You can use `$field` syntax to access a top-level field, and `$field['child']['subchild']` to access nested fields.

#### Comparison operators

The `conditions.rules.op` parameter has the following possible values:

- `eq`: equal to
- `neq`: not equal to
- `gt`: greater than
- `lt`: less than
- `gte`: greater than or equal to
- `lte`: less than or equal to
- `regex`: matches a regular expression
- `not_regex`: does not match a regular expression
- `in`: is included in the specified array
- `not_in`: is not included in the specified array

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