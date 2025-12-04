# Regular expression format

Use the _regular expression_ parser format to create custom parsers with Ruby regular expressions. These regular expressions use named capture to define which content belongs to which key name.

Use [Tail multiline](../inputs/tail.md#multiline) when you need to support regular expressions across multiple lines from a `tail`. The Tail input plugin treats each line as a separate entity.

{% hint style="warning" %}

This parser uses Onigmo, which is a backtracking regular expression's engine. When using complex regular expression patterns, Onigmo can take a long time to perform pattern matching. This can cause a [regular expression denial of service (ReDoS)](https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS).

{% end hint %}

Setting the format to regular expressions requires a `regex` configuration key.

## Configuration parameters

The `regex` parser supports the following configuration parameters:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `Skip_Empty_Values` | If enabled, the parser ignores empty value of the record. | `True` |

Fluent Bit uses the [Onigmo](https://github.com/k-takata/Onigmo) regular expression library in Ruby mode.

You can use only alphanumeric characters and underscore in group names. For example, a group name like `(?<user-name>.*)` causes an error due to the invalid dash (`-`) character. Use the [Rubular](http://rubular.com/) web editor to test your expressions.

The following parser configuration example provides rules that can be applied to an Apache HTTP Server log entry:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: apache
    format: regex
    regex: '^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$'
    time_key: time
    time_format: '%d/%b/%Y:%H:%M:%S %z'
    types: pid:integer size:integer
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name   apache
  Format regex
  Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
  Time_Key time
  Time_Format %d/%b/%Y:%H:%M:%S %z
  Types code:integer size:integer
```

{% endtab %}
{% endtabs %}

As an example, review the following Apache HTTP Server log entry:

```text
192.168.2.20 - - [29/Jul/2015:10:27:10 -0300] "GET /cgi-bin/try/ HTTP/1.0" 200 3395
```

This log entry doesn't provide a defined structure for Fluent Bit. Enabling the proper parser can help to make a structured representation of the entry:

```text
[1154104030, {"host"=>"192.168.2.20",
              "user"=>"-",
              "method"=>"GET",
              "path"=>"/cgi-bin/try/",
              "code"=>"200",
              "size"=>"3395",
              "referer"=>"",
              "agent"=>""
              }
]
```
