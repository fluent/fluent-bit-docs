# Parser

Parsers are an inportant component of [Fluent Bit](http://fluentbit.io), with them you can take any unstructured log entry and give them a structure that makes easier it processing and further filtering.

The parser engine is fully configurable and can process log entries based in two types of format:

- [JSON Maps](json.md)
- [Regular Expressions](regular_expression.md) (named capture)

By default, Fluent Bit provides a set of pre-configured parsers that can be used for different use cases such as logs from:

- Apache
- Nginx
- Docker
- Syslog rfc5424
- Syslog rfc3164

Parsers are defined in a configuration file that might be loaded at start time, either from the command line or through the main Fluent Bit configuration file.

## Configuration Parameters

The following table describes the available options for each parser definition

| Key         | Description                                            |
|-------------|--------------------------------------------------------|
| Name        | Set an unique name for the parser in question.         |
| Format      | Specify the format of the parser, the available options here are: json or regex. |
| Regex       | If format is _regex_, this option _must_ be set specifying the Ruby Regular Expression that will be used to parse and compose the structured message. |
| Time\_Key    | If the log entry provides a field with a timestamp, this option specify the name of that field. |
| Time\_Format | Specify the format of the time field so it can be recognized and analyzed properly. |
| Time_Keep    | By default when a time key is recognized and parsed, the parser will drop the original time field. Enabling this option will make the parser to keep the original time field and it value in the log entry. |

## Parsers Configuration File

The parsers file expose all parsers available that can be used by the Input plugins that are aware of this feature. A parsers file can have multiple entries like this:

```
[PARSER]
    Name        docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Time_Keep   On

[PARSER]
    Name        syslog-rfc5424
    Format      regex
    Regex       ^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) (?<ident>[^ ]+) (?<pid>[-0-9]+) (?<msgid>[^ ]+) (?<extradata>(\[(.*)\]|-)) (?<message>.+)$
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Time_Keep   On
```

For more information about the parsers available, please refer to the default parsers file distributed with Fluent Bit source code:

https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf
