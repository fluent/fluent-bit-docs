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
| `flush_count` | Number of flushes to wait for before exiting. | `-1` |
| `record_count` | Number of records to wait for before exiting. | `-1` |
| `time_count` | Number of seconds to wait for before exiting. | `-1` |

## Get started

The following example uses a `dummy` input to generate records and exits Fluent Bit after 5 records have been received.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: test

  outputs:
    - name: exit
      match: '*'
      record_count: 5
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name  dummy
  Tag   test

[OUTPUT]
  Name         exit
  Match        *
  Record_Count 5
```

{% endtab %}
{% endtabs %}
