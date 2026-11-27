# Defaults

The `defaults` section of YAML configuration files holds reusable values. Fluent Bit checks the values in this section but doesn't create any service, pipeline, or other runtime configuration from them. Mark values in `defaults` with YAML anchors (`&name`), then reuse them elsewhere with aliases (`*name`) and merge keys (`<<`).

Anchors, aliases, and merge keys work in any part of a YAML configuration file, and across [included files](./includes-section.md). The `defaults` section is a place to define values that aren't used where they're written.

## Usage

The following example keeps shared settings in `defaults.yaml`:

```yaml
defaults:
  service: &service_defaults
    flush: 5
    grace: 2
    log_level: info
  output: &stdout_defaults
    name: stdout
    match: '*'
```

The main file, `fluent-bit.yaml`, includes `defaults.yaml` and defines one service:

```yaml
includes:
  - defaults.yaml

service:
  <<: *service_defaults
  flush: 1

pipeline:
  inputs:
    - name: dummy
      samples: 1
  outputs:
    - <<: *stdout_defaults
      format: json_lines
```

The resulting service has `flush: 1`, `grace: 2`, and `log_level: info`. The `flush` key written in the `service` section overrides the value from `service_defaults`.

The `defaults` section doesn't create a `service` section. Defining `service` more than once, in one file or across included files, is still an error. To share service settings, use a merge key as shown in the previous example.

## Rules for the `defaults` section

- The value of `defaults` must be a mapping, or an alias of a mapping. An empty `defaults:` key, for example one with all its entries commented out, is an error. Write `defaults: {}` instead.
- Use `defaults` only as a top-level key, written literally. It can't come from a merge key (`<<`).
- The name is case-sensitive. Fluent Bit treats a section named `Defaults` as an unknown section. If it holds only scalar values, Fluent Bit ignores it with a warning. If it holds mappings or lists, which is the usual case, Fluent Bit stops with an error.
- Fluent Bit checks the anchors, aliases, and merge keys in `defaults` even when nothing uses them. An error in an unused value still stops Fluent Bit.

## Anchors and aliases

Fluent Bit reads the main file and its included files as one document, in order: each included file is read where its `includes` entry appears. Anchors and aliases follow that order:

- An anchor must appear before any alias that uses it. To use an anchor from an included file, put the `includes` entry before the alias.
- In a list written directly under `includes`, Fluent Bit reads each file before it reads the next entry. A later entry in the same list can use an anchor that an earlier file defined, including as the include path itself.
- All files share one set of anchor names. If an anchor name is defined again, aliases after the new definition use the new value. Aliases before it keep the earlier value. Fluent Bit doesn't warn when an anchor is redefined, so use distinct anchor names across files.
- An include path can be an alias of a string. The whole `includes` list can also be an alias of a list. In that case, aliases inside the list use the anchor values in effect where the list is defined, not values from files that the list includes.

## Merge keys

A merge key copies the keys of another mapping into the current mapping. Write it as `<<`, unquoted, or as `!!merge <<`. Its value must be a mapping, an alias of a mapping, or a list of them.

The following example merges two anchors into the `service` section:

```yaml
defaults:
  first: &first
    flush: 5
    grace: 2
  second: &second
    flush: 10
    log_level: info

service:
  grace: 1
  <<:
    - *first
    - *second
```

The resulting service has `flush: 5`, `grace: 1`, and `log_level: info`. Merge keys follow these rules:

- A key written in the mapping overrides a merged key, whether it appears before or after `<<`.
- When a merge key lists several mappings, a mapping earlier in the list takes precedence over a later one. If a mapping has more than one merge key, an earlier merge key takes precedence over a later one.
- Merges are shallow. If a key holds a nested mapping, the whole nested mapping is used as the value. Fluent Bit doesn't combine nested mappings key by key.
- In the `service` section, keys are compared without regard to case after Fluent Bit converts them to their standard names, so `log_level` written in the section overrides a merged `logLevel` or `LOG_LEVEL`.
- In other sections, keys are compared exactly. If a merged key and a written key differ only in case or naming style, such as `Match` and `match`, or `jsonDateKey` and `json_date_key`, Fluent Bit passes both to the plugin. Depending on the property, either value can take effect, with or without a warning, or Fluent Bit fails to start. Use the same spelling for a key in an anchor and in the mappings that merge it.
- A merge key at the top level of a file doesn't combine sections. If any file in the configuration writes a section such as `pipeline`, Fluent Bit ignores the merged `pipeline` entirely, without a warning. Section names are compared without regard to case. Use merge keys inside sections, not at the top level.
- A quoted `'<<'` or `"<<"`, or `!!str <<`, is an ordinary key, not a merge key.

## Errors

Fluent Bit stops with an error, which names the file, line, and column, in any of these cases:

- An alias appears before its anchor, or uses an anchor that doesn't exist. The error is `unresolved alias (anchors must precede aliases)`.
- An alias refers to the node that contains it. The error is `recursive alias or excessive expansion depth`.
- A mapping key isn't a scalar value, such as a key that's itself a mapping or a list.
- The value of a merge key isn't a mapping or a list of mappings.
- `includes` or `defaults` comes from a merge key instead of being written as a top-level key.

When a configuration parsing error involves a value that came from an alias or merge key, the error names the file where that value is defined.

## Limits

Fluent Bit applies the following limits to the combined configuration, including all included files:

| Limit | Value |
| :--- | :--- |
| Files, including the main file and empty files | 4,096 |
| YAML nodes in all files | 65,536 |
| Nesting depth, including levels added by aliases | 128 |
| Total size of all files | 64 MiB |
| Total size of scalar values, tags, anchor names, and the source path stored for each node | 64 MiB |
| Total size of strings after aliases and merge keys are expanded | 64 MiB |
| Composition work units: comparisons, appends, and emitted nodes | 1,048,576 |

These limits also stop aliases that expand into very large configurations, such as aliases nested inside other aliases. The work count grows with the number of anchors multiplied by the number of aliases, so a configuration with about a thousand anchors and aliases can reach it, even if its files are small. Generated configurations are subject to these limits too.

A configuration that reaches a limit fails with an error such as `YAML input size or nesting limit exceeded`, `YAML expansion limit exceeded`, or `composition work limit exceeded`.
