---
description: Powerful and flexible routing
---

# Rewrite Tag

Tags make [routing](../../concepts/data-pipeline/router.md) possible. Tags are set in the configuration of the `INPUT` definitions where the records are generated. There are scenarios where you might want to modify the tag in the pipeline to perform more advanced and flexible routing.

The _Rewrite Tag_ filter lets you re-emit a record under a new tag. Once a record has been re-emitted, the original record can be preserved or discarded.

The Rewrite Tag filter defines rules that match specific record key content against a regular expression. If a match exists, a new record with the defined tag will be emitted, entering from the beginning of the pipeline. Multiple rules can be specified and are processed in order until one of them matches.

The new tag definition can be composed of:

- Alphanumeric characters
- Numbers
- The original tag string or part of it
- Regular expressions groups capture
- Any key or sub-key of the processed record
- Environment variables

## Configuration parameters

The `rewrite_tag` filter supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| `Rule` | Defines the matching criteria and the format of the tag for the matching record. The Rule format has four components: `KEY REGEX NEW_TAG KEEP`. |
| `Emitter_Name` | Use this property to configure an optional name for the internal emitter plugin that handles filters emitting a record under the new tag. This emitter exposes metrics like any other component of the pipeline. |
| `Emitter_Storage.type` | Define a buffering mechanism for the new records created. These records are part of the emitter plugin. Supported values are `memory` (default) and `filesystem`. If the destination for the new records generated might face backpressure due to latency or slow network, Fluent Bit strongly recommends enabling the `filesystem` mode. |
| `Emitter_Mem_Buf_Limit` | Set a limit on the amount of memory the tag rewrite emitter can consume if the outputs provide backpressure. The default value is `10M`. The pipeline will pause once the buffer exceeds the value of this setting. For example, if the value is set to `10M` then the pipeline will pause if the buffer exceeds `10M`. The pipeline will remain paused until the output drains the buffer below the `10M` limit. |

## Rules

A rule defines matching criteria and specifies how to create a new tag for a record. You can define one or multiple rules in the same configuration section. The rules have the following format:

```text
$KEY  REGEX  NEW_TAG  KEEP
```

### Key

The key represents the name of the _record key_ that holds the `value` to use to match the regular expression. A key name is specified and prefixed with a `$`. Consider the following structured record (formatted for readability):

```javascript
{
  "name": "abc-123",
  "ss": {
    "s1": {
      "s2": "flb"
    }
  }
}
```

To match against the value of the key `name`, you must use `$name`. The key selector is flexible enough to allow to match nested levels of sub-maps from the structure. To capture the value of the nested key `s2`, specify `$ss['s1']['s2']`, for short:

-`$name` = "abc-123"
-`$ss['s1']['s2']` = "flb"

A key must point to a value that contains a string. It's not valid for numbers, Booleans, maps, or arrays.

### Regular expressions

Use a regular expression to specify a matching pattern to use against the value of the key specified previously. You can take advantage of group capturing to create custom placeholder values.

To match any record that it `$name` contains a value of the format `string-number` like the previous example, you might use:

```text
^([a-z]+)-([0-9]+)$
```

This example uses parentheses to specify groups of data. If the pattern matches the value a placeholder will be created that can be consumed by the `NEW_TAG` section.

If `$name` equals `abc-123` , then the following placeholders will be created:

-`$0` = "abc-123"
-`$1` = "abc"
-`$2` = "123"

If the regular expression doesn't match an incoming record, the rule will be skipped and the next rule (if present) will be processed.

### `New_Tag`

If a regular expression has matched the value of the defined key in the rule, you can compose a new tag for that specific record. The tag is a concatenated string that can contain any of the following characters: `a-z`,`A-Z`, `0-9` and `.-,`.

A tag can take any string value from the matching record, the original tag it self, environment variables, or general placeholders.

Consider the following incoming data on the rule:

- Tag = aa.bb.cc
- Record =  `{"name": "abc-123", "ss": {"s1": {"s2": "flb"}}}`
- Environment variable $HOSTNAME = fluent

With this information you can create a custom tag for your record like the following:

```text
newtag.$TAG.$TAG[1].$1.$ss['s1']['s2'].out.${HOSTNAME}
```

the expected generated tag will be:

```text
newtag.aa.bb.cc.bb.abc.flb.out.fluent
```

This make use of placeholders, record content, and environment variables.

### Keep

If a rule matches, the filter will emit a copy of the record with the new defined tag. The `keep` property takes a Boolean value to determine if the original record with the old tag must be preserved and continue in the pipeline or be discarded.

You can use `true` or `false` to decide the expected behavior. This field is mandatory and has no default value.

## Configuration example

The following configuration example will emit a dummy record. The filter will rewrite the tag, discard the old record, and print the new record to the standard output interface:

{% tabs %}
{% tab title="fluent-bit.conf" %}

```python
[SERVICE]
    Flush     1
    Log_Level info

[INPUT]
    NAME   dummy
    Dummy  {"tool": "fluent", "sub": {"s1": {"s2": "bit"}}}
    Tag    test_tag

[FILTER]
    Name          rewrite_tag
    Match         test_tag
    Rule          $tool ^(fluent)$  from.$TAG.new.$tool.$sub['s1']['s2'].out false
    Emitter_Name  re_emitted

[OUTPUT]
    Name   stdout
    Match  from.*
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    log_level: info
pipeline:
    inputs:
        - name: dummy
          tag:  test_tag
          dummy: '{"tool": "fluent", "sub": {"s1": {"s2": "bit"}}}'
    filters:
        - name: rewrite_tag
          match: test_tag
          rule: $tool ^(fluent)$  from.$TAG.new.$tool.$sub['s1']['s2'].out false
          emitter_name: re_emitted
    outputs:
        - name: stdout
          match: from.*
```

{% endtab %}
{% endtabs %}

The original tag `test_tag` will be rewritten as `from.test_tag.new.fluent.bit.out`:

```bash
$ bin/fluent-bit -c example.conf
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

...
[0] from.test_tag.new.fluent.bit.out: [1580436933.000050569, {"tool"=>"fluent", "sub"=>{"s1"=>{"s2"=>"bit"}}}]
```

## Monitoring

As described in the [Monitoring](../../administration/monitoring.md) section, every component of the pipeline of Fluent Bit exposes metrics. The basic metrics exposed by this filter are `drop_records` and `add_records`, which summarize the total of dropped records from the incoming data chunk or the new records added.

`rewrite_tag` emits new records that go through the beginning of the pipeline, and exposes an additional metric called `emit_records` that summarize the total number of emitted records.

### Understand the metrics

Using the previously provided configuration, when you query the metrics exposed in the HTTP interface:

```bash
curl  http://127.0.0.1:2020/api/v1/metrics/ | jq
```

You will see metrics output similar to the following:

```javascript
{
  "input": {
    "dummy.0": {
      "records": 2,
      "bytes": 80
    },
    "emitter_for_rewrite_tag.0": {
      "records": 1,
      "bytes": 40
    }
  },
  "filter": {
    "rewrite_tag.0": {
      "drop_records": 2,
      "add_records": 0,
      "emit_records": 2
    }
  },
  "output": {
    "stdout.0": {
      "proc_records": 1,
      "proc_bytes": 40,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

The _dummy_ input generated two records, while the filter dropped two from the chunks and emitted two new ones under a different tag.

The records generated are handled by the internal emitter, so the new records are summarized in the Emitter metrics. Take a look at the entry called `emitter_for_rewrite_tag.0`.

### The Emitter

The _Emitter_ is an internal Fluent Bit plugin that allows other components of the pipeline to emit custom records. On this case `rewrite_tag` creates an emitter instance to use it exclusively to emit records, allowing for granular control of who is emitting what.

Change the Emitter name in the metrics by adding the `Emitter_Name` configuration property described previously.
