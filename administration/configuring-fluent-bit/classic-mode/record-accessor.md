---
description: A full feature set to access content of your records.
---

# Record accessor

Fluent Bit works internally with structured records and it can be composed of an unlimited number of keys and values. Values can be anything like a number, string, array, or a map.

Having a way to select a specific part of the record is critical for certain core functionalities or plugins, this feature is called _Record Accessor._

Consider record accessor to be a basic grammar to specify record content and other miscellaneous values.

## Format

A record accessor rule starts with the character `$`. Use the structured content as an example. The following table describes how to access a record:

```js
{
  "log": "some message",
  "stream": "stdout",
  "labels": {
     "color": "blue",
     "unset": null,
     "project": {
         "env": "production"
      }
  }
}
```

The following table describes some accessing rules and the expected returned value:

| Format | Accessed Value |
| :--- | :--- |
| `$log` | `some message` |
| `$labels['color']` | `blue` |
| `$labels['project']['env']` | `production` |
| `$labels['unset']` | `null` |
| `$labels['undefined']` |  |

If the accessor key doesn't exist in the record like the last example `$labels['undefined']`, the operation is omitted, and no exception will occur.

## Usage

The feature is enabled on a per plugin basis. Not all plugins enable this feature. As an example, consider a configuration that aims to filter records using [grep](../../../pipeline/filters/grep.md) that only matches where labels have a color blue:

```yaml
[SERVICE]
    flush        1
    log_level    info
    parsers_file parsers.conf

[INPUT]
    name      tail
    path      test.log
    parser    json

[FILTER]
    name      grep
    match     *
    regex     $labels['color'] ^blue$

[OUTPUT]
    name      stdout
    match     *
    format    json_lines
```

The file content to process in `test.log` is the following:

```js
{"log": "message 1", "labels": {"color": "blue"}}
{"log": "message 2", "labels": {"color": "red"}}
{"log": "message 3", "labels": {"color": "green"}}
{"log": "message 4", "labels": {"color": "blue"}}
```

When running Fluent Bit with the previous configuration, the output is:

```text
$ bin/fluent-bit -c fluent-bit.conf
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2020/09/11 16:11:07] [ info] [engine] started (pid=1094177)
[2020/09/11 16:11:07] [ info] [storage] version=1.0.5, initializing...
[2020/09/11 16:11:07] [ info] [storage] in-memory
[2020/09/11 16:11:07] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2020/09/11 16:11:07] [ info] [sp] stream processor started
[2020/09/11 16:11:07] [ info] inotify_fs_add(): inode=55716713 watch_fd=1 name=test.log
{"date":1599862267.483684,"log":"message 1","labels":{"color":"blue"}}
{"date":1599862267.483692,"log":"message 4","labels":{"color":"blue"}}
```

### Limitations of `record_accessor` templating

The Fluent Bit `record_accessor` library has a limitation in the characters that can separate template variables. Only dots and commas (`.` and `,`) can come after a template variable. This is because the templating library must parse the template and determine the end of a variable.

The following templates are invalid because the template variables aren't separated by commas or dots:

- `$TaskID-$ECSContainerName`
- `$TaskID/$ECSContainerName`
- `$TaskID_$ECSContainerName`
- `$TaskIDfooo$ECSContainerName`

However, the following are valid:

- `$TaskID.$ECSContainerName`
- `$TaskID.ecs_resource.$ECSContainerName`
- `$TaskID.fooo.$ECSContainerName`

And the following are valid since they only contain one template variable with nothing after it:

- `fooo$TaskID`
- `fooo____$TaskID`
- `fooo/bar$TaskID`
