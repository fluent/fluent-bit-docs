# Regular Expression

The **Regex** parser lets you define a custom Ruby regular expression that uses
a named capture feature to define which content belongs to which key name.

Use [Tail Multiline](../inputs/tail.md#multiline) when you need to support regexes
across multiple lines from a `tail`. The [Tail](../inputs/tail.md) input plugin
treats each line as a separate entity.

{% hint style="warning" %}
Security Warning: Onigmo is a backtracking regex engine. When using expensive
regex patterns Onigmo can take a long time to perform pattern matching. Read
["ReDoS"](https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS)
on OWASP for additional information.
{% end hint %}

Setting the format to **regex** requires a `regex` configuration key.

## Configuration Parameters

The regex parser supports the following configuration parameters:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `Skip_Empty_Values` | If enabled, the parser ignores empty value of the record. | `True` |

Fluent Bit uses the [Onigmo](https://github.com/k-takata/Onigmo) regular expression
library on Ruby mode.

You can use only alphanumeric characters and underscore in group names. For example,
a group name like `(?<user-name>.*)` causes an error due to the invalid dash (`-`)
character. Use the [Rubular](http://rubular.com/) web editor to test your expressions.

The following parser configuration example provides rules that can be applied to an
Apache HTTP Server log entry:

```python
[PARSER]
    Name   apache
    Format regex
    Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z
    Types code:integer size:integer
```

As an example, review the following Apache HTTP Server log entry:

```text
192.168.2.20 - - [29/Jul/2015:10:27:10 -0300] "GET /cgi-bin/try/ HTTP/1.0" 200 3395
```

This log entry doesn't provide a defined structure for Fluent Bit. Enabling the
proper parser can help to make a structured representation of the entry:

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
