---
description: Powerful and flexible routing
---

# Rewrite tag

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

Tags make [routing](../../pipeline/router.md) possible. Tags are set in the configuration of the `INPUT` definitions where the records are generated. There are scenarios when you might want to modify the tag in the pipeline to perform more advanced and flexible routing.

The _Rewrite Tag_ filter lets you re-emit a record under a new tag. After a record is re-emitted, the original record can be preserved or discarded.

The Rewrite Tag filter defines rules that match specific record key content against a regular expression. If a match exists, a new record with the defined tag will be emitted. When used as a filter, the new record enters from the beginning of the pipeline. When used as an input processor, it continues at the next processor stage of the same input. Multiple rules can be specified and are processed in order until one of them matches.

The new tag definition can be composed of:

- Alphanumeric characters
- Numbers
- The original tag string or part of it
- Regular expressions groups capture
- Any key or sub-key of the processed record
- Environment variables

## Configuration parameters

The `rewrite_tag` filter supports the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `batch_size` | Experimental maximum number of records in an input processor callback eligible for batching by destination tag. Valid values are `0` through `4096`; `0` disables batching. Only applies when `rewrite_tag` is an input processor. Requires Fluent Bit v5.2 or later; earlier versions reject this property and fail to start. See [Input processor batching](#input-processor-batching). | `0` |
| `emitter_mem_buf_limit` | Set a limit on the amount of memory the tag rewrite emitter can consume if the outputs provide backpressure. With `memory` emitter storage, once the buffer exceeds this limit, Fluent Bit tries to pause the inputs that feed the emitter and keeps them paused until the output drains the buffer below the limit. Inputs that don't support pausing, such as `stdin`, keep collecting. With `filesystem` emitter storage, exceeding this limit doesn't pause the emitter, so this limit alone doesn't bound total memory use. In v5.0.0 or later, the [`storage.max_chunks_up`](../../administration/backpressure.md) setting controls that pausing by default. Earlier versions don't pause the emitter at that limit by default and can keep accumulating chunks in memory during backpressure. Records that the emitter can't accept are kept under their original tag. See [Emitter](#emitter). | `10M` |
| `emitter_name` | Optional name for the internal emitter plugin that handles records emitted under a new tag. This emitter exposes metrics like other pipeline components. | _none_ |
| `emitter_storage.type` | Buffering mechanism for the internal emitter. Supported values are `memory` and `filesystem`. If the destination might face backpressure due to latency or a slow network, use `filesystem`. | `memory` |
| `rule` | Matching criteria and destination tag format. The rule has four components: `KEY REGEX NEW_TAG KEEP`. | _none_ |

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

In v5.2 or later, Fluent Bit doesn't emit a new record if the new tag resolves to an empty string. This happens, for example, when the tag only references a record key that's missing. Fluent Bit keeps the original record under its original tag, regardless of the `KEEP` value. Earlier versions emitted a record with an empty tag under a fallback tag: the emitter's internal instance name, or the input's tag for an input processor. They also discarded the original record when `KEEP` was `false`. Because the original record now continues under its original tag, it reaches every output whose `match` covers that tag, such as a catch-all output. Check those outputs if your rules can produce an empty tag. A tag that resolves only partly isn't empty. For example, `from.$missing` is emitted as `from.`.

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

The original tag `test_tag` will be rewritten as `from.test_tag.new.fluent.bit.out`. Run the YAML configuration as shown, or use `fluent-bit -c fluent-bit.conf` for the classic configuration:

```shell
$ fluent-bit -c fluent-bit.yaml

...
[0] from.test_tag.new.fluent.bit.out: [[1580436933.000050569, {}], {"tool"=>"fluent", "sub"=>{"s1"=>{"s2"=>"bit"}}}]
```

## Use as a processor

You can use `rewrite_tag` as an [input processor](../processors/filters.md) in YAML configuration. Processor placement doesn't use a `match` property: the rules apply to records from the input to which the processor is attached. Fluent Bit still logs the warning `'Match' may cause infinite loop.` for each `rewrite_tag` processor, because processors use an internal wildcard match. You can ignore this warning for processors.

In v5.2 or later, `rewrite_tag` can only be used as a processor on inputs. Fluent Bit fails to start if `rewrite_tag` is configured as a processor on an output, and logs `rewrite_tag only supports input processors`. Earlier versions accepted this configuration, but its emitter expected an input instance, so the placement wasn't reliable. Move any `rewrite_tag` output processors to an input or to the `filters` section before you upgrade.

Moving `rewrite_tag` can change routing. As an output processor, it only rewrote records that had already been routed to that output. As an input processor or a filter, it rewrites records before routing, so every output is affected. With `KEEP` set to `false`, Fluent Bit removes the original record before any output receives it, but only after the rewrite succeeds. If the new tag is empty or the emitter rejects the record, Fluent Bit keeps the original record, as described in [Keep](#keep) and [Emitter](#emitter). Outputs whose `match` doesn't cover the new tag don't receive the rewritten record.

If you move `rewrite_tag` to the `filters` section, the rewritten record starts again at the beginning of the pipeline, so filters run against the rewritten tag. A filter whose `match` covers only the original tag no longer processes the record, and an earlier filter that matches both the original and the rewritten tag can process the same data twice. Review the order and `match` patterns of your filters and outputs, and verify that redaction happens before records reach outputs. If an output received records from several inputs, add the processor to every input that feeds it, or use a `rewrite_tag` filter whose `match` pattern covers only the tags you want to rewrite. When you add the processor to several inputs, keep each emitter name unique, as described in the following paragraphs.

As an input processor, `rewrite_tag` doesn't send a matching record back to the start of the pipeline. Rewritten records continue at the next processor stage of the same input with the new tag. They don't repeat earlier processor stages, and `rewrite_tag` doesn't run on them again. They then follow the input's normal buffering and routing path. Retained originals continue with their original tag. Fluent Bit uses the emitter only if appending a rewritten record to the input fails.

Records sent through the emitter take a different path. They enter the pipeline from the emitter, so they skip the processors that come after `rewrite_tag` on the original input and go through the `filters` section and outputs only. If a later processor on the input removes or redacts sensitive fields, also apply that processing in the `filters` section, or on the outputs, so that records sent through the emitter are covered. A redaction filter must use a `match` or `match_regex` that covers every rewritten tag, otherwise records sent through the emitter skip it.

Fluent Bit still creates an emitter for each `rewrite_tag` processor. When `emitter_name` isn't set, the emitter is named `emitter_for_` followed by the filter alias or instance name, for example `emitter_for_rewrite_tag.0`. Filters used as processors don't keep their own instance numbers, so several `rewrite_tag` processors, on the same input or on different inputs, can all be named `rewrite_tag.0` and produce `emitter_for_rewrite_tag.0`. Earlier versions failed to start in this case. In v5.2 or later, if the name already exists, the emitter is named `emitter_for_<input>_<filter>_<stage>` instead, for example `emitter_for_tail.1_rewrite_tag.0_0`:

- `<input>` is the internal name of the input, such as `tail.1`, even if the input has an alias.
- `<filter>` is the alias or instance name of the filter.
- `<stage>` is the position of the processor among all of the input's processors, starting at `0`. Logs processors are counted first, followed by metrics, traces, and profiles processors.

Fluent Bit checks the final emitter name, including a generated one. If `emitter_name`, or the generated `emitter_for_<input>_<filter>_<stage>` name, is already used by another input, Fluent Bit fails to start and logs `emitter_name '<name>' already exists`. Set a unique `emitter_name` to avoid the collision.

The generated name applies only to processors. Input processors start before the `filters` section, so a processor can take the default name first. A `rewrite_tag` in the `filters` section with the same instance name then fails to start with the same error. This can happen when you move some `rewrite_tag` processors to the `filters` section and keep others. Set `emitter_name` on the filter to avoid it.

## Input processor batching

The experimental `batch_size` option, available in Fluent Bit v5.2 or later, groups rewritten records by destination tag before passing them to downstream processors. This can reduce processing overhead when many records share a destination tag. Workloads with many distinct destination tags can be slower, so test with representative data before enabling batching. The default is `0`, which retains per-record processing.

Batching applies to one input callback at a time. It doesn't wait for more records, accumulate records across callbacks, or split a large callback into batches of `batch_size` records. A callback is eligible when it contains at least two records, no more than `batch_size` records, and no more than 256 KiB of serialized payload. Group context expansion must also fit within the 256 KiB scratch payload limit. Ineligible callbacks or failures while preparing a batch fall back to per-record processing.

Values below `0` or above `4096` cause configuration initialization to fail. Setting `batch_size` on a regular filter doesn't enable batching; filter placement continues to use the internal emitter path.

Batching preserves record order within each destination tag and among retained originals. Interleaving between different destination tags, and between rewritten records and retained originals, can change. Consider this behavior when downstream processors maintain state across records.

### Batching example

This example uses `batch_size: 256` to group eligible records by `$destination`. With `KEEP` set to `false`, successfully rewritten records are removed from the original stream. The `record_modifier` processor runs after rewriting and adds a `processed` field with the string value `"true"` to each record. Both destination tags are routed to standard output.

Processors require YAML configuration; there is no classic configuration equivalent for this example.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  grace: 1
  log_level: info

pipeline:
  inputs:
    - name: dummy
      tag: source
      samples: 1
      dummy: >-
        {"kind":"emit","destination":"routed.a","id":0}
        {"kind":"emit","destination":"routed.b","id":1}
        {"kind":"emit","destination":"routed.a","id":2}
      processors:
        logs:
          - name: rewrite_tag
            rule: $kind ^emit$ $destination false
            batch_size: 256
          - name: record_modifier
            record: processed true

  outputs:
    - name: stdout
      match: routed.*
      format: json_lines
```

{% endtab %}
{% endtabs %}

Records `0` and `2` share the tag `routed.a` and retain that order. Record `1` uses `routed.b`; its position relative to the other tag isn't guaranteed.

## Monitoring

As described in the [Monitoring](../../administration/monitoring.md) section, every component of the pipeline of Fluent Bit exposes metrics. The basic metrics exposed by this filter are `drop_records` and `add_records`, which summarize the total of dropped records from the incoming data chunk or the new records added.

The `rewrite_tag` plugin exposes an additional metric called `emit_records` that counts emitted records, including when batching is enabled. In filter placement, emitted records go through the beginning of the pipeline. Input processor placement continues at the next processor stage; successfully appended inline records aren't counted as internal emitter input records.

### Understand the metrics

The following example uses the filter configuration from [Configuration example](#configuration-example), not the batching example. To query its metrics, enable the HTTP server and bind it to the local host by adding `http_server: on` and `http_listen: 127.0.0.1` to its `service` section, or `HTTP_Server On` and `HTTP_Listen 127.0.0.1` in the classic configuration. The default listen address, `0.0.0.0`, listens on all IPv4 interfaces. The HTTP server has no authentication and also serves endpoints that can change Fluent Bit, such as the hot reload endpoint. Binding to `127.0.0.1` doesn't limit access to Fluent Bit alone. Any process that shares its network namespace can reach the server. This includes other containers in the same Kubernetes pod and, when Fluent Bit uses the host network, any process on the host.

Query the metrics exposed in the HTTP interface:

```shell
curl http://127.0.0.1:2020/api/v1/metrics | jq
```

In a container, `127.0.0.1` is the container's own loopback interface, so you must query it from the container's network namespace. The Fluent Bit production container image is distroless and doesn't include a shell or `curl`, so you can't run the previous command in it with `docker exec`. Instead, run `curl` in a helper container that shares the network namespace of the Fluent Bit container and pipe the response to `jq` on the host. Replace `<container>` with the name of the Fluent Bit container:

```shell
docker run --rm --network container:<container> curlimages/curl -s http://127.0.0.1:2020/api/v1/metrics | jq
```

You will see metrics output similar to the following, trimmed to the keys discussed in this section:

```text
{
  "input": {
    "dummy.0": {
      "records": 2,
      "bytes": 84
    },
    "re_emitted": {
      "records": 2,
      "bytes": 84
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
      "proc_records": 2,
      "proc_bytes": 84,
      "errors": 0,
      "retries": 0,
      "retries_failed": 0
    }
  }
}
```

The _dummy_ input generated two records, while the filter dropped two from the chunks and emitted two new ones under a different tag.

The records generated are handled by the internal emitter, so the new records are summarized in the Emitter metrics. Because the example sets `emitter_name: re_emitted`, the emitter entry is called `re_emitted`. Without `emitter_name`, it's called `emitter_for_rewrite_tag.0`.

### Emitter

The _Emitter_ is an internal Fluent Bit plugin that allows other components of the pipeline to emit custom records. On this case `rewrite_tag` creates an emitter instance to use it exclusively to emit records, allowing for granular control of who is emitting what.

Change the Emitter name in the metrics by adding the `emitter_name` configuration property described previously.

When the emitter's memory buffer is full, as set by `emitter_mem_buf_limit`, it doesn't accept new records. A matching record that would go through the emitter is then kept under its original tag and isn't rewritten, regardless of the [`KEEP`](#keep) value, so it can reach outputs that match the original tag. Sizing `emitter_mem_buf_limit` for your peak load and monitoring the emitter metrics can't guarantee that every matching record is rewritten during a prolonged output outage. To keep original records that weren't rewritten from reaching outputs that expect only rewritten tags, use `match` patterns on those outputs that don't cover the original tags, and route the original tags to a separate output for quarantine or inspection. These measures don't guarantee that records are rewritten or delivered.

In v5.2 or later, records buffered in the emitter are passed to the pipeline when Fluent Bit shuts down. Earlier versions could discard them. This doesn't guarantee delivery: records still need to reach their outputs within the shutdown [grace period](../../administration/configuring-fluent-bit/yaml/service-section.md), and records held in memory are lost if an output is unavailable.

#### Avoid emitter cycles

Cycle detection is available in Fluent Bit version 5.1.0 and greater. Earlier releases, such as 5.0.9 and 5.0.10, don't have this guard, so a rule that matches its own output can emit records repeatedly and consume resources.

Make sure the filter's `match` pattern can't match the new tags the filter itself produces. When it does, the emitted records return to the same filter, which rewrites and emits them again in an endless cycle.

Fluent Bit detects this case and rejects the emission rather than allowing the cycle. It logs an error like the following once for each affected emitter. The prefix shows the emitter name, for example `re_emitted` when `emitter_name` is set as in the [configuration example](#configuration-example):

```text
[error] [input:emitter:emitter_for_rewrite_tag.0] emitter cycle detected: the filter attached to this emitter matches the records it emits (tag=...), the emission is rejected. Adjust the filter 'Match' or its rules so emitted records are not processed again
```

The record that triggered the cycle is the emitted copy, so it stays in the pipeline under the rewritten tag, regardless of the [`KEEP`](#keep) value set on the matching rule. Only the repeated emission is dropped. Fluent Bit only detects a filter that matches its own emitted records. A cycle between two `rewrite_tag` filters that rewrite each other's tags isn't detected. To resolve the error, narrow the filter's `match` pattern or change the rule so that rewritten tags no longer match it.
