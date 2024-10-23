---
description: >-
  Made for testing: make sure that your records contain the expected key and
  values
---

# Expect

The _expect_ filter plugin allows you to validate that records match certain criteria in their structure, like validating that a key exists or it has a specific value.

The following page just describes the configuration properties available, for a detailed explanation of its usage and use cases, please refer the following page:

* [Validating and your Data and Structure](../../local-testing/validating-your-data-and-structure.md)

## Configuration Parameters

The plugin supports the following configuration parameters:

| Property | Description |
| :--- | :--- |
| key\_exists | Check if a key with a given name exists in the record. |
| key\_not\_exists | Check if a key does not exist in the record. |
| key\_val\_is\_null | check that the value of the key is NULL. |
| key\_val\_is\_not\_null | check that the value of the key is NOT NULL. |
| key\_val\_eq | check that the value of the key equals the given value in the configuration. |
| action | action to take when a rule does not match. The available options are  `warn` , `exit` or "result_key". On `warn`, a warning message is sent to the logging layer when a mismatch of the rules above is found; using `exit` makes Fluent Bit abort with status code `255`; `result_key` is to add a matching result to each record. |
| result\_key | specify a key name of matching result. This key is to be used only when 'action' is 'result_key'.|

## Getting Started

As mentioned on top, refer to the following page for specific details of usage of this filter:

* [Validating and your Data and Structure](../../local-testing/validating-your-data-and-structure.md)

