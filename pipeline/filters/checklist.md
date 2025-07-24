# CheckList

The _CheckList_ plugin (introduced in version 1.8.4) looks up a value in a specified list to see if it exists. The plugin then allows the addition of a record to indicate if the value was found.

## Configuration parameters

The plugin supports the following configuration parameters

| Key | Description | Default |
| :-- | :---------- | :------ |
| `file` | The single value file that Fluent Bit will use as a lookup table to determine if the specified `lookup_key` exists. | _none_ |
| `lookup_key` | The specific key to look up and determine if it exists. Supports [record accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor). | _none_ |
| `record` | The record to add if the `lookup_key` is found in the specified `file`. You can add multiple record parameters. | _none_ |
| `mode` | Set the check mode. `exact` and `partial` are supported. | `exact`|
| `print_query_time` | Print to stdout the elapsed query time for every matched record. | `false` |
| `ignore_case` | Compare strings by ignoring case. | `false` |

## Example configuration

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: tail
          tag: test1
          path: test1.log
          read_from_head: true
          parser: json

    filters:
        - name: checklist
          match: test1
          file: ip_list.txt
          lookup_key: $remote_addr
          record:
              - ioc abc
              - badurl null
          log_level: debug

    outputs:
        - name: stdout
          match: test1
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

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

{% endtab %}
{% endtabs %}

The following configuration reads a file `test1.log` that includes the following values:

```text
{"remote_addr": true, "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.2", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.3", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.4", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.5", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.6", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}
{"remote_addr": "7.7.7.7", "ioc":"false", "url":"https://badurl.com/payload.htm","badurl":"no"}

```

Additionally, it uses  the following lookup file which contains a list of malicious IP addresses (`ip_list.txt`).

```text
1.2.3.4
6.6.4.232
7.7.7.7
```

The configuration uses `$remote_addr` as the lookup key, and `7.7.7.7` is malicious. The record output for the last record would look like the following:

```text
{"remote_addr": "7.7.7.7", "ioc":"abc", "url":"https://badurl.com/payload.htm","badurl":"null"}
```
