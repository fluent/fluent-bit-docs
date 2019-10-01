# Parsers

Parsers are an important component of [Fluent Bit](http://fluentbit.io), with them you can take any unstructured log entry and give them a structure that makes easier it processing and further filtering.

The parser engine is fully configurable and can process log entries based in two types of format:

* [JSON Maps](json.md)
* [Regular Expressions](regular_expression.md) \(named capture\)

By default, Fluent Bit provides a set of pre-configured parsers that can be used for different use cases such as logs from:

* Apache
* Nginx
* Docker
* Syslog rfc5424
* Syslog rfc3164

Parsers are defined in one or multiple configuration files that are loaded at start time, either from the command line or through the main Fluent Bit configuration file.

Note: if you are using Regular Expressions note that Fluent Bit uses Ruby based regular expressions and we encourage to use [Rubular](http://www.rubular.com) web site as an online editor to test them.

## Configuration Parameters

Multiple parsers can be defined and each section have it own properties. The following table describes the available options for each parser definition:

| Key | Description |
| :--- | :--- |
| Name | Set an unique name for the parser in question. |
| Format | Specify the format of the parser, the available options here are: [json](json.md), [regex](regular_expression.md), [ltsv](ltsv.md) or \[logfmt\]\[logfmt.md\]. |
| Regex | If format is _regex_, this option _must_ be set specifying the Ruby Regular Expression that will be used to parse and compose the structured message. |
| Time\_Key | If the log entry provides a field with a timestamp, this option specify the name of that field. |
| Time\_Format | Specify the format of the time field so it can be recognized and analyzed properly. Fluent-bit uses `strptime(3)` to parse time so you can ferer to [strptime documentation](https://linux.die.net/man/3/strptime) for available modifiers. |
| Time\_Offset | Specify a fixed UTC time offset \(e.g. -0600, +0200, etc.\) for local dates. |
| Time\_Keep | By default when a time key is recognized and parsed, the parser will drop the original time field. Enabling this option will make the parser to keep the original time field and it value in the log entry. |
| Types | Specify the data type of parsed field. The syntax is `types <field_name_1>:<type_name_1> <field_name_2>:<type_name_2> ...`. The supported types are `string`\(default\), `integer`, `bool`, `float`, `hex`. |
| Decode\_Field | Decode a field value, the only decoder available is `json`. The syntax is: `Decode_Field json <field_name>`. |

## Parsers Configuration File

All parsers **must** be defined in a _parsers.conf_ file, **not** in the Fluent Bit global configuration file. The parsers file expose all parsers available that can be used by the Input plugins that are aware of this feature. A parsers file can have multiple entries like this:

```text
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
    Types pid:integer
```

For more information about the parsers available, please refer to the default parsers file distributed with Fluent Bit source code:

[https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf)

## Time Resolution and Fractional Seconds

Time resolution and it format supported are handled by using the [strftime\(3\)](http://man7.org/linux/man-pages/man3/strftime.3.html) libc system function.

In addition, we extended our time resolution to support fractional seconds like _2017-05-17T15:44:31**.187512963**Z_. Since Fluent Bit v0.12 we have full support for nanoseconds resolution, the **%L** format option for Time\_Format is provided as a way to indicate that content must be interpreted as fractional seconds.

> Note: The option %L is only valid when used after seconds \(`%S`\) or seconds since the Epoch \(`%s`\), e.g: `%S.%L` or `%s.%L`

