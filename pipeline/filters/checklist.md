---
description: >-
  The following plugin looks up if a value in a specified list exists and then
  allows the addition of a record to indicate if found. Introduced in version
  1.8.4
---

# CheckList

## Configuration Parameters

The plugin supports the following configuration parameters

| Key | Description |
| :--- | :--- |
| file | The single value file that Fluent Bit will use as a lookup table to determine if the specified `lookup_key` exists |
| lookup\_key | The specific key to look up and determine if it exists, supports record accessor |
| record | The record to add if the `lookup_key` is found in the specified `file`. Note you may add multiple record parameters. |
| mode | Set the check mode. `exact` and `partial` are supported. Default : `exact`.|
| print_query_time | Print to stdout the elapseed query time for every matched record. Default: false|
| ignore_case | Compare strings by ignoring case. Default: false |

## Example Configuration

```text
[INPUT]
    name           tail
    tag            test1
    path           test1.log
    read_from_head true
    parser         json

[FILTER]
    name       checklist
    match      test1
    file       ip_list.txt
    lookup_key $remote_addr
    record     ioc    abc
    record     badurl null
    log_level  debug

[OUTPUT]
    name       stdout
    match      test1
```

In the following configuration we will read a file `test1.log` that includes the following values 

```text
{"remote_addr": true, "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.2", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.3", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.4", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.5", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.6", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.7", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}

```

Additionally, we will use the following lookup file which contains a list of malicious IPs \(`ip_list.txt`\)

```text
1.2.3.4
6.6.4.232
7.7.7.7
```

In the configuration we are using $remote\_addr as the lookup key and 7.7.7.7 is malicious. This means the record we would output for the last record would look like the following

```text
{"remote_addr": "7.7.7.7", "ioc":"abc", "url":"https://badurl.com/payload.htm","badurl":"null"}
```

