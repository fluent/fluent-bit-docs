---
description: Validate the content of your records
---

# Expect



## Configuration Parameters

The plugin supports the following configuration parameters:

| Property | Description |
| :--- | :--- |
| key\_exists | Check if a key with a given name exists in the record. |
| key\_not\_exists | Check if a key does not exist in the record. |
| key\_val\_is\_null | check that the value of the key is NULL. |
| key\_val\_is\_not\_null | check that the value of the key is NOT NULL. |
| key\_val\_eq | check that the value of the key equals the given value in the configuration. |
| action | action to take when a rule does not match. The available options are  `warn` or `exit`. On `warn`, a warning message is sent to the logging layer when a mismatch of the rules above is found; using `exit` makes Fluent Bit abort with status code `255` |

