# Regular expression format

Use the _regular expression_ parser format to create custom parsers with Ruby regular expressions. These regular expressions use named capture to define which content belongs to which key name.

Use [Tail multiline](../inputs/tail.md#multiline-support) when you need to support regular expressions across multiple lines from a `tail`. The Tail input plugin treats each line as a separate entity.

{% hint style="warning" %}

This parser uses Onigmo, which is a backtracking regular expression's engine. When using complex regular expression patterns, Onigmo can take a long time to perform pattern matching. This can cause a [regular expression denial of service (ReDoS)](https://community.owasp.org/attacks/Regular_expression_Denial_of_Service_-_ReDoS).

{% endhint %}

Setting the format to regular expressions requires a `regex` configuration key.

For available configuration parameters, see [Configuring custom parsers](configuring-parser.md).

## Regular expression work limit

In v5.2 or later, Fluent Bit limits how much work the regular expression engine can do for each search, which the engine calls the match operation limit. The limit applies to every regular expression in Fluent Bit, not only to parsers. A search can use up to 10,000,000 engine steps. For a search that scans the text, the steps from all starting positions count toward the same limit. The limit is set when Fluent Bit is built and can't be configured.

When a search reaches the limit, it fails, and Fluent Bit logs an error such as `[regex] search failed: -17`, or `[router] regex match failed: -17` for tag matching. The code `-17` means the limit was reached. Fluent Bit treats the failed search as no match, so the effect depends on where the expression is used:

- The [Parser](../filters/parser.md) filter keeps the original record and tries the next parser, if any.
- The [Syslog](../inputs/syslog.md) input logs the warning `error parsing log message with parser '<name>'` and drops the message.
- A [Grep](../filters/grep.md) filter `regex` rule drops the record, and an `exclude` rule keeps it.
- A [conditional routing](../router.md#conditional-routing) `regex` rule evaluates to false, and a `not_regex` rule evaluates to true.
- A `match_regex` pattern on a filter or output doesn't match the tag, so the filter isn't applied, or the records aren't routed to the output. Filters match the tag each time records are added, and outputs each time a chunk is created, so the error can repeat many times for the same tag.
- A [multiline](multiline-parsing.md) rule treats the line as not matching.
- A [Tail](../inputs/tail.md) input `tag_regex` that fails for a filename prevents that file from being read.

{% hint style="warning" %}

A regular expression can run on data from sources you don't control, such as record fields or tags received by the [Forward](../inputs/forward.md) input. Crafted values can then reach the limit on purpose and change the outcome, for example to skip a filter or get past a Grep rule. For these expressions, use anchored patterns without nested quantifiers such as `(a+)+`, and don't rely on regular expression matching alone for filtering that must always apply.

{% endhint %}

## Configuration parameters

The `regex` parser supports the following format-specific configuration parameter:

| Key | Description | Default |
| --- | ----------- | ------- |
| `skip_empty_values` | If enabled, the parser ignores empty values of the record. | `true` |

Fluent Bit uses the [Onigmo](https://github.com/k-takata/Onigmo) regular expression library in Ruby mode.

You can use only alphanumeric characters and underscore in group names. For example, a group name like `(?<user-name>.*)` causes an error due to the invalid dash (`-`) character. Use the [Rubular](https://rubular.com/) web editor to test your expressions.

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
