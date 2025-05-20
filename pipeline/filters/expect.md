---
description: Testing records to ensure they contain an expected key and values
---

# Expect

The _expect_ filter plugin lets you validate that records match certain criteria in their structure, like validating that a key exists or it has a specific value.

For a detailed explanation of its usage and use cases, see [Validating and your Data and Structure](../../local-testing/validating-your-data-and-structure.md).

## Configuration parameters

The plugin supports the following configuration parameters:

| Property | Description |
| :--- | :--- |
| `key_exists` | Check if a key with a given name exists in the record. |
| `key_not_exists` | Check if a key doesn't exist in the record. |
| `key_val_is_null` | Check that the value of the key is `NULL`. |
| `key_val_is_not_null` | Check that the value of the key is `NOT NULL`. |
| `key_val_eq` | Check that the value of the key equals the given value in the configuration. |
| `action` | Action to take when a rule doesn't match. Available options are `warn` , `exit` or `result_key`. On `warn`, a warning message is sent to the logging layer when a mismatch of the `key*` rules is found. Using `exit` makes Fluent Bit exit with status code `255`. `result_key` adds a matching result to each record. |
| `result_key` | Specify a key name for the matching result added when `action` is set to `result_key`. |
