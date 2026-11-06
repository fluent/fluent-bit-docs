# Native recipe blocks

A _native recipe_ configures Fluent Typed Scripting (FTS) with an ordered list of built-in blocks instead of a Lua policy. Set `recipe` in place of `script` or `code`. Each step runs a reviewed block with validated parameters, and every step for an item runs in the same transaction: a failure in any step rolls back the item's earlier recipe edits and applies `error_mode`.

Native recipe blocks are different from the [Recipes](recipes.md) page, which contains complete Lua policy examples.

## Recipe structure

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"message": "login", "password": "example-secret"}'
      processors:
        logs:
          - name: fts
            context: native
            error_mode: drop
            recipe:
              - id: privacy
                use: shared.redact_keys
                with:
                  targets: [{root: body, path: []}]
                  keys: [password, authorization]
  outputs:
    - name: stdout
      match: '*'
```

Each step accepts the following keys:

| Key | Description |
| --- | ----------- |
| `id` | Unique step name. Starts with a letter and contains letters, digits, `_`, or `-`, up to 64 bytes. |
| `use` | Block ID, such as `shared.redact_keys`, or `<pack>/<block>` for a block from a [local pack](#local-packs). |
| `with` | Block parameters. |
| `when` | Optional condition for log and trace steps, using the same grammar as `logs.drop_matching`. When the condition is false, the step is skipped. Metric steps don't support `when`, because metrics have no selector roots; setting it on a metric step fails initialization. |

A recipe can contain up to 64 steps. Unknown blocks, unknown parameters, duplicate step IDs, and blocks that don't support the processor's signal fail initialization. Set `recipe_version: 1`, the default. Recipes don't support `jit: true`.

On a build that supports recipes, run `fluent-bit --dry-run -c fluent-bit.yaml` to validate recipes without starting the pipeline. Older development builds don't validate processor parameters with `--dry-run`, so a recipe configuration can pass the dry run and still fail at startup. See [Check recipe support](configuration.md#check-recipe-support) to confirm that a build supports recipes. [Hot reload](../../../administration/hot-reload.md) also validates recipes before it replaces the running pipeline.

## Selectors

Blocks address fields with a selector: a `root` and a `path` array of literal keys. An empty path selects the root itself.

```yaml
source: {root: body, path: [request, headers]}
```

| Signal | Roots |
| ------ | ----- |
| Logs | `body`, `metadata`, `attributes`, `resource.attributes`, `scope.attributes` |
| Traces | `attributes`, `events`, `links`, `resource.attributes`, `scope.attributes` |

`metadata` selectors require `context: native`, and their first path element can't be `otlp`. Paths can contain up to 32 keys of up to 256 bytes each.

The processor's `context` setting declares which logs the recipe expects: `native` for Fluent Bit logs, `otel` for logs with OpenTelemetry context, or `any`, the default.

Constant values can be strings, booleans, plain YAML numbers, or explicit typed values such as `{type: uint64, value: "18446744073709551615"}`, `{type: double, value: 1.5}`, `{type: "null"}`, or `{type: bytes, value: "0001ff"}`. Use a quoted decimal string in a typed value when a large integer must stay exact.

## Stateless blocks

| Block | Signals | Parameters |
| ----- | ------- | ---------- |
| `logs.parse_json` | Logs | `source` and `destination` selectors (required); `remove_source` (default `false`); `on_missing`: `error` (default) or `skip`; `collision`: `error` (default), `overwrite`, or `preserve_destination`. The `source` and `destination` paths must be non-empty and must not overlap, and `remove_source: true` can't be combined with `collision: preserve_destination`; otherwise initialization fails. The source must be a string that contains a JSON object; arrays and scalar JSON values are rejected and apply `error_mode`. |
| `logs.normalize_severity` | Logs | `source` selector and `destination` (required). `destination` is a selector, or `otel` to set the OpenTelemetry severity, which requires `context: otel`; `profile`: `common` (default); `overwrite` (default `false`); `on_missing`: `skip` (default) or `error`; `on_unknown`: `preserve` (default) or `error`. A selector `destination` needs a non-empty path; otherwise initialization fails. When `source` and `destination` are the same selector, the field is normalized in place and `overwrite` is always `true`, even if set to `false`. A non-string source, or an `otel` destination on a log without OpenTelemetry context, fails and applies `error_mode`. |
| `logs.parse_timestamp` | Logs | `source` selector of RFC 3339 text (required); `on_missing`: `error` (default) or `skip`. Sets event time and preserves observed time. A non-string source fails and applies `error_mode`. |
| `logs.drop_matching` | Logs | `condition` (required). Drops the log when the condition matches. |
| `logs.validate_fields` | Logs | `rules` (required): a non-empty list of rules, each with a `selector`, a `type` (`integer`, `int64`, `uint64`, `double`, `string`, `bool`, `bytes`, `null`, `array`, or `map`), a boolean `required` (default `true`), and an optional `enum` of 1 to 128 values of that type, for scalar types only. Invalid rules fail initialization. A missing field fails a rule unless the rule sets `required: false`; a field that's present must still match `type` and `enum`. A failed rule applies `error_mode`, which by default drops the log. |
| `fields.edit` | Logs, traces | `operations` (required): a non-empty, ordered list using `set`, `set_default`, `copy`, `rename`, `remove`, and `keep`. Targets can't use the `events` or `links` roots. `keep`, and `remove` on a whole map, need `names`, `prefixes`, or both; other operations need a non-empty target path. `copy` and `rename` sources can't overlap their targets, and `rename` needs a non-empty source path. Invalid operations fail initialization. |
| `shared.redact_keys` | Logs, traces | `targets` selectors and `keys` (required); `replacement` (default `[REDACTED]`). Requires `error_mode: drop`. A target that isn't a map or array fails and applies `error_mode`. |
| `fields.truncate` | Logs, traces | `target` and `marker` selectors and `max_bytes` from `0` to `1048576` (required); `collision`: `error` (default) or `overwrite`; `on_missing`: `skip` (default) or `error`. The `target` and `marker` paths must be non-empty, can't use the `events` or `links` roots, and can't overlap; otherwise initialization fails. When the target is truncated, Fluent Bit sets `marker` to boolean `true`. If `marker` already exists and `collision` is `error`, the item fails and applies `error_mode`, which by default drops it. A non-string target or invalid UTF-8 fails and applies `error_mode`. |
| `traces.name_from_route` | Traces | `method_attribute` (default `http.request.method`); `route_attribute` (default `http.route`); `on_missing`: `preserve` (default) or `error`. Renames server spans only. A non-string route or method fails and applies `error_mode`. |
| `metrics.select` | Metrics | Exactly one of `keep` or `drop`, each with `names`, literal `prefixes`, or both. Selects whole metric families. |
| `metrics.rename` | Metrics | `mapping` of 1 to 128 old names to new names, each 1 to 256 bytes (required). Two names can't map to the same target, and mappings can't form chains or cycles; otherwise initialization fails. |
| `metrics.scale` | Metrics | `names`, `input_unit`, `output_unit`, and a positive `factor` (required); `numeric_policy`: `preserve_integer` (default) or `allow_double`. With `preserve_integer`, a fractional `factor` fails on any integer datapoint or exemplar, and the failure applies `error_mode`; use `allow_double` for fractional scaling of metrics that can contain integers. A selected metric whose unit isn't `input_unit` also fails and applies `error_mode`. |
| `metrics.merge_histogram_buckets` | Metrics | `names` and `bounds` (required). Bounds must be an increasing subset of the existing bounds. |
| `metrics.aggregate_dimensions` | Metrics | `names` and `operation` (required); `keep_attributes` (default empty); `max_exemplars` from `0` to `128` (default `0`). Gauges accept `sum`, `min`, `max`, `mean`, or `count`; sums and explicit histograms accept `sum` only. Each `keep_attributes` entry must be 1 to 256 bytes; otherwise initialization fails. A selected family that isn't a gauge, sum, or explicit histogram, or a non-gauge with an operation other than `sum`, fails and applies `error_mode`. |

`shared.redact_keys` matches key names in maps and arrays. It doesn't inspect text, including JSON embedded in a string, so parse or remove raw text first. For `events` and `links` targets, it redacts keys only within each entry's `attributes` map; other fields, such as an event's name, IDs, and timestamps, are unchanged. These targets require an empty `path`. `fields.edit` and `shared.redact_keys` update the OpenTelemetry dropped attribute counts when they remove attributes.

Merge histogram buckets before scaling the same metric; the loader rejects the opposite order. `metrics.rename` checks for name collisions only within the current resource and scope batch.

### Conditions

`logs.drop_matching` and a step's `when` key use the same condition grammar. A condition is either a leaf with `selector`, `op`, and `value` (`values` for `in` and `not_in`), or an `all` or `any` list of conditions:

```yaml
- id: drop_health_checks
  use: logs.drop_matching
  with:
    condition:
      all:
        - {selector: {root: body, path: [path]}, op: eq, value: /health}
        - {selector: {root: body, path: [status]}, op: eq, value: 200}
```

Operators are `eq`, `neq`, `in`, `not_in`, `gt`, `gte`, `lt`, and `lte`. A missing field or a value of the wrong type never matches, including for negative operators such as `neq`. Integer comparisons are exact across signed and unsigned 64-bit values. Conditions evaluate the item as already edited by earlier steps.

The following rules apply when the recipe loads; a condition that breaks them fails initialization. Condition selectors can't use the `events` or `links` roots. `all` and `any` lists, and `values` for `in` and `not_in`, must be non-empty, and all `values` must have the same type. `gt`, `gte`, `lt`, and `lte` require a numeric `value`.

## Stateful log blocks

`logs.dedupe` and `logs.throttle` keep per-key state. They must be the last step of a recipe in a processor attached to an input, and they require `state_commit: local`. `state_limit` bounds their native memory.

```yaml
processors:
  logs:
    - name: fts
      context: native
      state_commit: local
      state_limit: 1M
      recipe:
        - id: privacy
          use: shared.redact_keys
          with:
            targets: [{root: body, path: []}]
            keys: [password, authorization]
        - id: duplicates
          use: logs.dedupe
          with:
            tenant: {root: body, path: [trusted_tenant]}
            keys: [{root: body, path: [event_id]}]
            ttl_ms: 60000
```

Both blocks accept the following parameters:

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `keys` | List of 1 to 16 selectors whose values form the key. Required. | _none_ |
| `tenant` | Optional selector for a trusted tenant identity added to the key. | _none_ |
| `ttl_ms` | Key lifetime in milliseconds, from `1` to `86400000`. Required. | _none_ |
| `max_keys` | Maximum number of tracked keys, up to `65536`. | `1024` |
| `max_key_bytes` | Maximum encoded key size in bytes, up to `65536`. | `1024` |
| `on_missing` | `error` fails the item when a key field is missing; `keep` passes it through without tracking. | `error` |
| `overflow` | `keep` passes an item through untracked when capacity is full or its encoded key exceeds `max_key_bytes`. No other value is supported. | `keep` |

`logs.dedupe` keeps the first item for a key and drops repeats until the key expires after `ttl_ms`. A repeat doesn't extend the expiry time.

`logs.throttle` is a token bucket per key. It also requires `rate`, in tokens per second, and `burst`, the initial and maximum number of tokens, each from `1` to `1000000`. Each admitted item consumes one token. `ttl_ms` measures inactivity and must be at least `1000 * burst / rate` milliseconds.

Key values are typed: the string `"1"`, the integer `1`, and the double `1.0` are different keys. A key value that's a map, an array, or a non-finite double fails and applies `error_mode`. Apply parsing, normalization, and privacy steps before the stateful step.

State is volatile and local to one processor instance. It's lost on restart, reload, and shutdown, and separate inputs or processes don't share it. State is committed when FTS finishes a batch, before later processing or delivery, so a later failure can suppress a duplicate whose original was lost, or consume throttle capacity without delivery. These blocks provide best-effort local suppression, not end-to-end deduplication. When capacity is full, or an item's encoded key exceeds `max_key_bytes`, the item passes through untracked instead of evicting existing keys.

### Request log windows

`window.hold_until` holds log records under a key until a fixed processing-time deadline, which starts with the first record and isn't extended by later records. If any record in the window matches `retain_when` before the deadline, every record in the window is released. Otherwise, only records that match `keep_when` are released, and the rest are discarded. For example, hold a request's logs, keep all of them when an `ERROR` occurs, and otherwise keep everything except `DEBUG`. Like the stateful blocks, it must be the last step of an input processor recipe and requires `state_commit: local`. It supports only the `dummy`, `tail`, `forward`, `http`, and `opentelemetry` inputs; attaching it to any other input fails initialization. Held records count toward `state_limit`.

Retention isn't guaranteed for every window. When the window store is full, or when a record continues a group that started in an earlier chunk, the record passes through without entering the window. A `retain_when` match on such a record doesn't apply to the window, so records already held for that key can still be discarded.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `keys` | Selectors that identify a window. Required. | _none_ |
| `tenant` | Optional trusted tenant selector. | _none_ |
| `hold_ms` | How long to hold records, from `1` to `86400000` milliseconds. Required. | _none_ |
| `retain_when` | Condition that marks a window for retention. Required. | _none_ |
| `keep_when` | Optional condition for records to release when no record matches `retain_when`. When omitted and no record matches `retain_when`, every held record in the window is discarded. | _none_ |
| `late_ms` | How long to recognize late records for a closed window, from `0` to `86400000` milliseconds. | `60000` |
| `ready_timeout_ms` | How long to retry releasing records, from `1` to `86400000` milliseconds. | `60000` |
| `max_keys` | Maximum open windows, up to `65536`. | `1024` |
| `max_key_bytes` | Maximum encoded key size in bytes, up to `65536`. | `1024` |
| `on_missing` | `error` or `keep`. | `error` |
| `overflow` | `keep`. | `keep` |

Decisions use processing time, not record timestamps. Records that arrive for a closed window pass through and are counted as late. Records still held at shutdown, or when the release retry expires, are discarded and counted. The block processes logs only.

## Local packs

A recipe can use blocks from trusted local Lua packs. Set `packages_dir` to the directory that holds the packs, and `packs` to a list of pack manifest paths relative to that directory. Reference a pack block in `use` as `<pack>/<block>`. Packs are loaded only from local files.

```yaml
processors:
  logs:
    - name: fts
      packages_dir: /etc/fluent-bit/packs
      packs: [my-pack/pack.json]
      recipe:
        - id: custom_step
          use: <pack-id>/<block-name>
          with:
            <parameter>: <value>
```

Replace `<pack-id>` with the `id` field of the pack manifest and `<block-name>` with the `name` of one of its blocks. List the parameters that the pack block declares under `with`. When a block has no parameters, omit `with` or set it to an empty mapping, `with: {}`. For example, a manifest with the `id` `org.fluentbit.policy.pseudonyms` and a block named `apply` is used as `org.fluentbit.policy.pseudonyms/apply`. Relative `packages_dir` paths resolve against the Fluent Bit process working directory, not the configuration file directory, so prefer an absolute path. Pack code runs with the same trust as other configuration; review packs before deploying them.

## Metrics

FTS recipes report the following metrics. Each has the labels `name` (the owning input or output), `scope`, `processor`, `stage`, `signal`, and `outcome`. These metrics count processing decisions, not delivery.

| Metric | Description |
| ------ | ----------- |
| `fluentbit_fts_recipe_callbacks_total` | Recipe callback outcomes: `keep`, `drop`, `hold`, or `error`. A failure handled by `error_mode: keep` counts as `error`. |
| `fluentbit_fts_state_keys` | Committed keys currently tracked by a stateful block. |
| `fluentbit_fts_evictions_total` | Keys removed after `ttl_ms` expired. |
| `fluentbit_fts_overflow_untracked_total` | Items passed through untracked because capacity was full or their encoded key exceeded `max_key_bytes`. |
| `fluentbit_fts_local_state_commits_total` | Committed state batches. |
| `fluentbit_fts_dropped_by_policy_total` | Items dropped by a committed dedupe or throttle decision. |
| `fluentbit_fts_window_events_total` | Request window events, with outcomes including `held`, `decision`, `released`, `release_retry`, `ready_expired`, `late_passthrough`, `context_passthrough`, `overflow_keep`, and `shutdown`. |
