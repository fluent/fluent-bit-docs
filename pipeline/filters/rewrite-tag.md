---
description: Powerful and flexible routing
---

# Rewrite tag

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

Tags make [routing](../../pipeline/router.md) possible. Tags are set in the configuration of the `INPUT` definitions where the records are generated. There are scenarios when you might want to modify the tag in the pipeline to perform more advanced and flexible routing.

The _Rewrite Tag_ filter lets you re-emit a record under a new tag. After a record is re-emitted, the original record can be preserved or discarded.

The Rewrite Tag filter defines rules that match specific record key content against a regular expression. If a match exists, a new record with the defined tag will be emitted. When `rewrite_tag` runs as a filter, the new record enters from the beginning of the pipeline. When it runs as an input processor, see [Use as a processor](#use-as-a-processor). Multiple rules can be specified and are processed in order until one of them matches.

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
| `emitter_mem_buf_limit` | Set a limit on the amount of memory the tag rewrite emitter can consume if the outputs provide backpressure. The default value is `10M`. The pipeline will pause once the buffer exceeds the value of this setting. For example, if the value is set to `10M` then the pipeline will pause if the buffer exceeds `10M`. The pipeline will remain paused until the output drains the buffer under the `10M` limit. |
| `emitter_name` | Use this property to configure an optional name for the internal emitter plugin that handles filters emitting a record under the new tag. This emitter exposes metrics like any other component of the pipeline. |
| `emitter_storage.type` | Define a buffering mechanism for the new records created. These records are part of the emitter plugin. Supported values are `memory` (default) and `filesystem`. If the destination for the new records generated might face backpressure due to latency or slow network, Fluent Bit strongly recommends enabling the `filesystem` mode. |
| `rule` | Defines the matching criteria and the format of the tag for the matching record. The rule format has four components: `KEY REGEX NEW_TAG KEEP`. |

## Rules

A rule defines matching criteria and specifies how to create a new tag for a record. You can define one or multiple rules in the same configuration section. The rules have the following format:

```text
$KEY  REGEX  NEW_TAG  KEEP
```

### Key

The key represents the name of the _record key_ that holds the `value` to use to match the regular expression. A key name is specified and prefixed with a `$`. Consider the following structured record (formatted for readability):

```text
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

- `$name` = `abc-123`
- `$ss['s1']['s2']` = `flb`

A key must point to a value that contains a string. It's not valid for numbers, Boolean values, maps, or arrays.

### Regular expressions

Use a regular expression to specify a matching pattern to use against the value of the key specified previously. You can take advantage of group capturing to create custom placeholder values.

To match any record that it `$name` contains a value of the format `string-number` like the previous example, you might use:

```text
^([a-z]+)-([0-9]+)$
```

This example uses parentheses to specify groups of data. If the pattern matches the value a placeholder will be created that can be consumed by the `NEW_TAG` section.

If `$name` equals `abc-123`, then the following placeholders will be created:

- `$0` = `abc-123`
- `$1` = `abc`
- `$2` = `123`

If the regular expression doesn't match an incoming record, the rule will be skipped and the next rule (if present) will be processed.

### `New_Tag`

If a regular expression has matched the value of the defined key in the rule, you can compose a new tag for that specific record. The tag is a concatenated string that can contain any of the following characters: `a-z`,`A-Z`, `0-9` and `.-,`.

A tag can take any string value from the matching record, the original tag itself, environment variables, or general placeholders.

In v5.2 or later, if the new tag resolves to an empty string, for example because it only references a record key that's missing, Fluent Bit doesn't emit a new record. It keeps the original record under its original tag, regardless of the [`KEEP`](#keep) value. Earlier versions emitted the record under a fallback tag, either the emitter's internal instance name or, for an input processor, the input's tag, and discarded the original record when `KEEP` was `false`. Because the original record now continues under its original tag, it reaches every output whose `match` covers that tag, such as a catch-all output. Check those outputs if your rules can produce an empty tag. A tag that resolves only partly isn't empty. For example, `from.$missing` is emitted as `from.`.

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
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  Flush     1
  Log_Level info

[INPUT]
  Name   dummy
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
{% endtabs %}

The original tag `test_tag` will be rewritten as `from.test_tag.new.fluent.bit.out`:

```shell
$ fluent-bit -c example.conf

...
[0] from.test_tag.new.fluent.bit.out: [1580436933.000050569, {"tool"=>"fluent", "sub"=>{"s1"=>{"s2"=>"bit"}}}]
```

## Monitoring

As described in the [Monitoring](../../administration/monitoring.md) section, every component of the pipeline of Fluent Bit exposes metrics. The basic metrics exposed by this filter are `drop_records` and `add_records`, which summarize the total of dropped records from the incoming data chunk or the new records added.

When used as a filter, `rewrite_tag` emits new records that go through the beginning of the pipeline. It exposes an additional metric called `emit_records` that summarize the total number of emitted records.

### Understand the metrics

Using the previously provided configuration, when you query the metrics exposed in the HTTP interface:

```shell
curl  http://127.0.0.1:2020/api/v1/metrics/ | jq
```

You will see metrics output similar to the following:

```text
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

### Emitter

The _Emitter_ is an internal Fluent Bit plugin that allows other components of the pipeline to emit custom records. On this case `rewrite_tag` creates an emitter instance to use it exclusively to emit records, allowing for granular control of who is emitting what.

Change the Emitter name in the metrics by adding the `emitter_name` configuration property described previously.

When the emitter has reached `emitter_mem_buf_limit`, it doesn't accept new records. A matching record is then kept under its original tag and isn't rewritten, regardless of the [`KEEP`](#keep) value, so it can reach outputs that match the original tag. If every matching record must be rewritten, size `emitter_mem_buf_limit` for your peak load and monitor the emitter metrics.

In v5.2 or later, records buffered in the emitter are passed to the pipeline when Fluent Bit shuts down. Earlier versions could discard them. This doesn't guarantee delivery: records still need to reach their outputs within the shutdown [grace period](../../administration/configuring-fluent-bit/yaml/service-section.md), and records held in memory are lost if an output is unavailable.

#### Avoid emitter cycles

Make sure the filter's `match` pattern can't match the new tags the filter itself produces. When it does, the emitted records return to the same filter, which rewrites and emits them again in an endless cycle.

Fluent Bit detects this case and rejects the emission rather than allowing the cycle. It logs an error like the following once for each affected emitter:

```text
[error] [input:emitter:emitter_for_rewrite_tag.0] emitter cycle detected: the filter attached to this emitter matches the records it emits (tag=...), the emission is rejected. Adjust the filter 'Match' or its rules so emitted records are not processed again
```

The record that triggered the cycle is the emitted copy, so it stays in the pipeline under the rewritten tag, regardless of the [`KEEP`](#keep) value set on the matching rule. Only the repeated emission is dropped. Fluent Bit only detects a filter that matches its own emitted records. A cycle between two `rewrite_tag` filters that rewrite each other's tags isn't detected. To resolve the error, narrow the filter's `match` pattern or change the rule so that rewritten tags no longer match it.

## Use as a processor

In v5.2 or later, you can use `rewrite_tag` as a [processor](../processors/filters.md) only on inputs. Fluent Bit fails to start if `rewrite_tag` is configured as a processor on an output, and logs `rewrite_tag only supports input processors`. Earlier versions accepted this configuration, but its emitter expected an input instance, so the placement wasn't reliable. Move any `rewrite_tag` output processors to an input or to the `filters` section before you upgrade.

Moving `rewrite_tag` can change routing. As an output processor, it only rewrote records that had already been routed to that output. As an input processor or a filter, it rewrites records before routing, so every output is affected. With `KEEP` set to `false`, the original record is removed before any output receives it, and outputs whose `match` doesn't cover the new tag don't receive the rewritten record. Review the `match` patterns of your outputs when you move the filter.

As an input processor, `rewrite_tag` doesn't send a matching record back to the start of the pipeline. Fluent Bit appends the record with its new tag to the same input, and the record continues through the processors that come after `rewrite_tag`. Earlier processors, including `rewrite_tag` itself, don't run on it again. The emitter is used only if this append fails, so emitter metrics don't normally include these records.

Records sent through the emitter take a different path. They enter the pipeline from the emitter, so they skip the processors that come after `rewrite_tag` on the original input and go through the `filters` section and outputs only. If a later processor on the input removes or redacts sensitive fields, also apply that processing in the `filters` section, or on the outputs, so that records sent through the emitter are covered.

Fluent Bit still creates an emitter for each `rewrite_tag` processor. When `emitter_name` isn't set, the emitter is named `emitter_for_` followed by the filter alias or instance name, for example `emitter_for_rewrite_tag.0`. Filters used as processors don't keep their own instance numbers, so several `rewrite_tag` processors, on the same input or on different inputs, can all be named `rewrite_tag.0` and produce `emitter_for_rewrite_tag.0`. Earlier versions failed to start in this case. In v5.2 or later, if the name already exists, the emitter is named `emitter_for_<input>_<filter>_<stage>` instead, for example `emitter_for_tail.1_rewrite_tag.0_0`:

- `<input>` is the internal name of the input, such as `tail.1`, even if the input has an alias.
- `<filter>` is the alias or instance name of the filter.
- `<stage>` is the position of the processor among all of the input's processors, starting at `0`. Logs processors are counted first, followed by metrics and traces processors.

Fluent Bit checks the final emitter name, including a generated one. If `emitter_name`, or the generated `emitter_for_<input>_<filter>_<stage>` name, is already used by another input, Fluent Bit fails to start and logs `emitter_name '<name>' already exists`. Set a unique `emitter_name` to avoid the collision.

The generated name applies only to processors. Input processors start before the `filters` section, so a processor can take the default name first. A `rewrite_tag` in the `filters` section with the same instance name then fails to start with the same error. This can happen when you move some `rewrite_tag` processors to the `filters` section and keep others. Set `emitter_name` on the filter to avoid it.
