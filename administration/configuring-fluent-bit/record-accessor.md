---
description: A full feature set to access content of your records
---

# Record Accessor

Fluent Bit works internally with structured records and it can be composed of an unlimited number of keys and values. Values can be anything like a number, string, array, or a map.

Having a way to select a specific part of the record is critical for certain core functionalities or plugins, this feature is called _Record Accessor._

> consider Record Accessor a simple grammar to specify record content and other miscellaneous values.

## Format

A _record accessor_ rule starts with the character `$`. Using the structured content above as an example the following table describes how to access a record:

```javascript
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

The following table describe some accessing rules and the expected returned value:

| Format | Accessed Value |
| :--- | :--- |
| $log | "some message" |
| $labels\['color'\] | "blue" |
| $labels\['project'\]\['env'\] | "production" |
| $labels\['unset'\] | null |
| $labels\['undefined'\] |  |

If the accessor key does not exist in the record like the last example `$labels['undefined']` , the operation is simply omitted, no exception will occur.

## Usage Example

The feature is enabled on a per plugin basis, not all plugins enable this feature. As an example consider a configuration that aims to filter records using [grep](../../pipeline/filters/grep.md) that only matches where labels have a color blue:

```text
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

```javascript
{"log": "message 1", "labels": {"color": "blue"}}
{"log": "message 2", "labels": {"color": "red"}}
{"log": "message 3", "labels": {"color": "green"}}
{"log": "message 4", "labels": {"color": "blue"}}
```

Running Fluent Bit with the configuration above the output will be:

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

