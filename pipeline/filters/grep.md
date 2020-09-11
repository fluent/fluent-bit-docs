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

#### Record Accessor Enabled

This plugin enables the [Record Accessor](../../administration/configuring-fluent-bit/record-accessor.md) feature to specify the KEY. Using the _record accessor_ is suggested if you want to match values against nested values.

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

If you want to match or exclude records based on nested values, you can use a [Record Accessor ](../../administration/configuring-fluent-bit/record-accessor.md)format as the KEY name. Consider the following record example:

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

