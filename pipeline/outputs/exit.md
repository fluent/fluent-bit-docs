---
description: Exit Fluent Bit after a number of flushes, records, or seconds.
---

# Exit

The _exit_ plugin is a utility plugin which causes Fluent Bit to exit after one of the following occurs:

- receiving a set number of records (`record_count`).
- being flushed a set number of times (`flush_count`).
- being flushed after a set number of seconds have transpired (`time_count`).

At least one of these parameters must be set. If more than one is set the plugin exits when any one of the set conditions is met.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `Record_Count` | Number of records to wait for before exiting. |  _none_ |
| `Flush_Count` | Number of flushes to wait for before exiting.| _none_ |
| `Time_Count` | Number of seconds to wait for before exiting. | _none_ |
