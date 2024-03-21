---
description: 'Exit fluent-bit after a number of flushes, records or seconds'
---

# Exit

The exit plugin is a utility plugin which will cause fluent-bit to exit after one of the following occurs:
  * receiving a set number of records (record_count).
  * being flushed a set number of times (flush_count).
  * being flushed after a set number of seconds have transpired (time_count).

At least one of these parameters must be set. If more than one is set it will wait until any one of the set conditions is met.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Record\_Count | Number of records to wait for before exiting |  |
| Flush\_Count | Number of flushes to wait for before exiting |  |
| Time\_Count | Number of seconds to wait for before exiting |  |
