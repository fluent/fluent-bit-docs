---
description: Select or exclude records per patterns
---

# Grep

The _Grep Filter_ plugin allows you to match or exclude specific records based on regular expression patterns for values or nested values.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Description |
| :--- | :--- | :--- |
| Regex | KEY  REGEX | Keep records in which the content of KEY matches the regular expression. |
| Exclude | KEY REGEX | Exclude records in which the content of KEY matches the regular expression. |
| Logical_Op| Operation | Specify whether to use logical conjuciton or disjunction. `AND` and `OR` are allowed as an Operation.|

#### Record Accessor Enabled

This plugin enables the [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) feature to specify the KEY. Using the _record accessor_ is suggested if you want to match values against nested values.

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file. The following example assumes that you have a file called `lines.txt` with the following content:

```text
{"log": "aaa"}
{"log": "aab"}
{"log": "bbb"}
{"log": "ccc"}
{"log": "ddd"}
{"log": "eee"}
{"log": "fff"}
{"log": "ggg"}
```

### Command Line

> Note: using the command line mode need special attention to quote the regular expressions properly. It's suggested to use a configuration file.

The following command will load the _tail_ plugin and read the content of `lines.txt` file. Then the _grep_ filter will apply a regular expression rule over the _log_ field \(created by tail plugin\) and only _pass_ the records which field value starts with _aa_:

```text
$ bin/fluent-bit -i tail -p 'path=lines.txt' -F grep -p 'regex=log aa' -m '*' -o stdout
```

### Configuration File

```python
[INPUT]
    name   tail
    path   lines.txt
    parser json

[FILTER]
    name   grep
    match  *
    regex  log aa

[OUTPUT]
    name   stdout
    match  *
```

The filter allows to use multiple rules which are applied in order, you can have many _Regex_ and _Exclude_ entries as required.

### Nested fields example

If you want to match or exclude records based on nested values, you can use a [Record Accessor ](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md)format as the KEY name. Consider the following record example:

```javascript
{
    "log": "something",
    "kubernetes": {
        "pod_name": "myapp-0",
        "namespace_name": "default",
        "pod_id": "216cd7ae-1c7e-11e8-bb40-000c298df552",
        "labels": {
            "app": "myapp"
        },
        "host": "minikube",
        "container_name": "myapp",
        "docker_id": "370face382c7603fdd309d8c6aaaf434fd98b92421ce"
    }
}
```

if you want to exclude records that match given nested field \(for example `kubernetes.labels.app`\), you can use the following rule:

```python
[FILTER]
    Name    grep
    Match   *
    Exclude $kubernetes['labels']['app'] myapp
```

### Excluding records missing/invalid fields

It may be that in your processing pipeline you want to drop records that are missing certain keys.

A simple way to do this is just to `exclude` with a regex that matches anything, a missing key will fail this check.

Here is an example that checks for a specific valid value for the key as well:

```
# Use Grep to verify the contents of the iot_timestamp value.
# If the iot_timestamp key does not exist, this will fail
# and exclude the row.
[FILTER]
    Name                     grep
    Alias                    filter-iots-grep
    Match                    iots_thread.*
    Regex                    iot_timestamp ^\d{4}-\d{2}-\d{2}
```

The specified key `iot_timestamp` must match the expected expression - if it does not or is missing/empty then it will be excluded.

### Multiple conditions

If you want to set multiple `Regex` or `Exclude`, you can use `Logical_Op` property to use logical conjuction or disjunction.

Note: If `Logical_Op` is set, setting both 'Regex' and `Exclude` results in an error.

```python
[INPUT]
    Name dummy
    Dummy {"endpoint":"localhost", "value":"something"}
    Tag dummy

[FILTER]
    Name grep
    Match *
    Logical_Op or
    Regex value something
    Regex value error

[OUTPUT]
    Name stdout
```

Output will be
```
Fluent Bit v2.0.9
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2023/01/22 09:46:49] [ info] [fluent bit] version=2.0.9, commit=16eae10786, pid=33268
[2023/01/22 09:46:49] [ info] [storage] ver=1.2.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/01/22 09:46:49] [ info] [cmetrics] version=0.5.8
[2023/01/22 09:46:49] [ info] [ctraces ] version=0.2.7
[2023/01/22 09:46:49] [ info] [input:dummy:dummy.0] initializing
[2023/01/22 09:46:49] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2023/01/22 09:46:49] [ info] [filter:grep:grep.0] OR mode
[2023/01/22 09:46:49] [ info] [sp] stream processor started
[2023/01/22 09:46:49] [ info] [output:stdout:stdout.0] worker #0 started
[0] dummy: [1674348410.558341857, {"endpoint"=>"localhost", "value"=>"something"}]
[0] dummy: [1674348411.546425499, {"endpoint"=>"localhost", "value"=>"something"}]
```