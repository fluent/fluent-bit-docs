# Conditional processing

Conditional processing lets you selectively apply [processors](README.md) to logs based on the value of fields within those logs. This feature lets you create processing pipelines that only process records that meet certain criteria, and ignore the rest.

Conditional processing is available in Fluent Bit version 4.0 and greater.

## Configuration

You can turn a standard processor into a conditional processor by adding a `condition` block to the processor's YAML configuration settings.

{% hint style="info" %}
- Conditional processing is only available for [YAML configuration files](../administration/configuring-fluent-bit/yaml/README.md), not [classic configuration files](../administration/configuring-fluent-bit/classic-mode/README.md).
- Conditional processing isn't supported if you're using a [filter as a processor](../pipeline/processors/filters).
{% endhint %}

These `condition` blocks use the following syntax:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
    <...>
        processors:
            logs:
                - name: processor_name
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

{% endtab %}
{% endtabs %}

Each processor can only have a single `condition` block, but that condition can include multiple rules. These rules are stored as items in the `condition.rules` array.

### Condition evaluation

The `condition.op` parameter specifies the condition's evaluation logic. It can have one of the following values:

- `and`: A log entry meets this condition when all the rules in the `condition.rules` array are [truthy](https://developer.mozilla.org/en-US/docs/Glossary/Truthy).
- `or`: A log entry meets this condition when one or more rules in the `condition.rules` array are [truthy](https://developer.mozilla.org/en-US/docs/Glossary/Truthy).

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

### Basic condition

This example applies a condition that only processes logs that contain the string `{"request": {"method": "POST"`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

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

{% endtab %}
{% endtabs %}

### Multiple conditions with `and`

This example applies a condition that only processes logs when all the specified rules are met:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

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

{% endtab %}
{% endtabs %}

### Multiple conditions with `or`

This example applies a condition that only processes logs when one or more of the specified rules are met:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

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

{% endtab %}
{% endtabs %}

### Array of values

This example uses an array for the value of `condition.rules.value`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

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

{% endtab %}
{% endtabs %}

### Multiple processors with conditions

This example uses multiple processors with conditional processing enabled for each:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

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

{% endtab %}
{% endtabs %}

This configuration adds an `alert` field to error logs from critical services, and adds a `paging_required` field to errors that contain specific critical patterns.
