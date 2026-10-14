---
description: Testing records to ensure they contain an expected key and values
---

# Expect

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

The _expect_ filter plugin lets you validate that records match certain criteria in their structure, like validating that a key exists or it has a specific value.

For a detailed explanation of its usage and use cases, see [Validating and your Data and Structure](../../local-testing/validating-your-data-and-structure.md).

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `action` | Action to take when a rule doesn't match. Available options are `warn`, `exit` or `result_key`. On `warn`, a warning message is sent to the logging layer for each record that fails a `key*` rule. Using `exit` makes Fluent Bit exit with status code `255`. `result_key` adds a matching result to each record. For how each action treats a batch of records, see [Batch behavior](#batch-behavior). | `warn` |
| `key_exists` | Check if a key with a given name exists in the record. | _none_ |
| `key_not_exists` | Check if a key doesn't exist in the record. | _none_ |
| `key_val_eq` | Check that the value of the key equals the given value in the configuration. | _none_ |
| `key_val_is_not_null` | Check that the value of the key is `NOT NULL`. | _none_ |
| `key_val_is_null` | Check that the value of the key is `NULL`. | _none_ |
| `result_key` | Specify a key name for the matching result added when `action` is set to `result_key`. | `matched` |

## Batch behavior

Fluent Bit delivers records to filters in batches. The expect filter evaluates each data record in a batch against your rules, and the configured `action` determines what happens next. Two exceptions apply across the batch: `exit` stops evaluation at the first record that fails a rule, and `result_key` never adds a result to marker records.

- `warn`: each record that fails a rule logs its own `expect check failed` warning. A batch that contains several failing records produces several warnings.
- `exit`: Fluent Bit stops at the first record that fails a rule and exits with status code `255`. The remaining records in the batch aren't evaluated.
- `result_key`: each record gets its own result. A record that passes every rule is marked `true`, and a record that fails any rule is marked `false`, so one failing record doesn't change the result recorded for the other records in the same batch.

Some event types, such as OpenTelemetry logs, include internal marker records that delimit a group of records. The expect filter passes these markers through unchanged and doesn't add the result key to them.
