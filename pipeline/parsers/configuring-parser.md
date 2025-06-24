# Configuring Parser

Parsers are an important component of [Fluent Bit](http://fluentbit.io), with them you can take any unstructured log entry and give them a structure that makes it easier for processing and further filtering.

The parser engine is fully configurable and can process log entries based in two types of format:

* [JSON Maps](json.md)
* [Regular Expressions](regular-expression.md) \(named capture\)

By default, Fluent Bit provides a set of pre-configured parsers that can be used for different use cases such as logs from:

* Apache
* Nginx
* Docker
* Syslog rfc5424
* Syslog rfc3164

Parsers are defined in one or multiple configuration files that are loaded at start time, either from the command line or through the main Fluent Bit configuration file.

Note: If you are using Regular Expressions note that Fluent Bit uses Ruby based regular expressions and we encourage to use [Rubular](http://www.rubular.com) web site as an online editor to test them.

## Configuration Parameters

Multiple parsers can be defined and each section has it own properties. The following table describes the available options for each parser definition:

| Key | Description |
| :--- | :--- |
| Name | Set an unique name for the parser in question. |
| Format | Specify the format of the parser, the available options here are: [json](json.md), [regex](regular-expression.md), [ltsv](ltsv.md) or [logfmt](logfmt.md). |
| Regex | If format is _regex_, this option _must_ be set specifying the Ruby Regular Expression that will be used to parse and compose the structured message. |
| Time\_Key | If the log entry provides a field with a timestamp, this option specifies the name of that field. |
| Time\_Format | Specify the format of the time field so it can be recognized and analyzed properly. Fluent Bit uses `strptime(3)` to parse time. See the [strptime documentation](https://linux.die.net/man/3/strptime) for available modifiers. The `%L` field descriptor is supported for fractional seconds. |
| Time\_Offset | Specify a fixed UTC time offset \(e.g. -0600, +0200, etc.\) for local dates. |
| Time\_Keep | By default when a time key is recognized and parsed, the parser will drop the original time field. Enabling this option will make the parser to keep the original time field and its value in the log entry. |
| Time\_System\_Timezone | If there is no timezone (`%z`) specified in the given `Time_Format`, enabling this option will make the parser detect and use the system's configured timezone. The configured timezone is detected from the [`TZ` environment variable](https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html). |
| Types | Specify the data type of parsed field. The syntax is `types <field_name_1>:<type_name_1> <field_name_2>:<type_name_2> ...`. The supported types are `string`\(default\), `integer`, `bool`, `float`, `hex`. The option is supported by `ltsv`, `logfmt` and `regex`. |
| Decode\_Field | If the content can be decoded in a structured message, append the structured message (keys and values) to the original log message. Decoder types: `json`, `escaped`, `escaped_utf8`. The syntax is: `Decode_Field <decoder_type> <field_name>`. See [Decoders](pipeline/parsers/decoders.md) for additional information. |
| Decode\_Field\_As | Any decoded content (unstructured or structured) will be replaced in the same key/value, and no extra keys are added. Decoder types: `json`, `escaped`, `escaped_utf8`. The syntax is: `Decode_Field_As <decoder_type> <field_name>`. See [Decoders](pipeline/parsers/decoders.md) for additional information. |
| Skip\_Empty\_Values | Specify a boolean which determines if the parser should skip empty values. The default is `true`. |
| Time_Strict | The default value (`true`) tells the parser to be strict with the expected time format. With this option set to false, the parser will be permissive with the format of the time. This is useful when the format expects time fraction but the time to be parsed doesn't include it.  |

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

Time resolution and its format supported are handled by using the [strftime\(3\)](http://man7.org/linux/man-pages/man3/strftime.3.html) libc system function.

In addition, we extended our time resolution to support fractional seconds like _2017-05-17T15:44:31**.187512963**Z_. Since Fluent Bit v0.12 we have full support for nanoseconds resolution, the **%L** format option for Time\_Format is provided as a way to indicate that content must be interpreted as fractional seconds.

> Note: The option %L is only valid when used after seconds \(`%S`\) or seconds since the Epoch \(`%s`\), e.g: `%S.%L` or `%s.%L`

## Supported Timezone Abbreviations

The current supported time zone labels of 3-4 letter abbreviated strings:

### UTC/GMT and Zulu

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                |
| :----------- | :----------------- | :--------------- | :----- | :------------------------- |
| `GMT`        | +00:00             | 0                | 0      | Greenwich Mean Time        |
| `UTC`        | +00:00             | 0                | 0      | Coordinated Universal Time |
| `Z`          | +00:00             | 0                | 0      | Zulu Time (UTC)            |
| `UT`         | +00:00             | 0                | 0      | Universal Time             |

### North American Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                                              |
| :----------- | :----------------- | :--------------- | :----- | :------------------------------------------------------- |
| `EST`        | -05:00             | -18000           | 0      | Eastern Standard Time                                    |
| `EDT`        | -04:00             | -14400           | 1      | Eastern Daylight Time                                    |
| `CST`        | -06:00             | -21600           | 0      | Central Standard Time (North America)                    |
| `CDT`        | -05:00             | -18000           | 1      | Central Daylight Time (North America)                    |
| `MST`        | -07:00             | -25200           | 0      | Mountain Standard Time                                   |
| `MDT`        | -06:00             | -21600           | 1      | Mountain Daylight Time                                   |
| `PST`        | -08:00             | -28800           | 0      | Pacific Standard Time                                    |
| `PDT`        | -07:00             | -25200           | 1      | Pacific Daylight Time                                    |
| `AKST`       | -09:00             | -32400           | 0      | Alaska Standard Time                                     |
| `AKDT`       | -08:00             | -28800           | 1      | Alaska Daylight Time                                     |
| `HST`        | -10:00             | -36000           | 0      | Hawaii Standard Time                                     |
| `HADT`       | -09:00             | -32400           | 1      | Hawaii-Aleutian Daylight Time (rarely used for Hawaii) |
| `AST`        | -04:00             | -14400           | 0      | Atlantic Standard Time (e.g., Canada, Caribbean)         |
| `ADT`        | -03:00             | -10800           | 1      | Atlantic Daylight Time                                   |
| `NST`        | -03:30             | -12600           | 0      | Newfoundland Standard Time                               |
| `NDT`        | -02:30             | -9000            | 1      | Newfoundland Daylight Time                               |

### European Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                      |
| :----------- | :----------------- | :--------------- | :----- | :------------------------------- |
| `WET`        | +00:00             | 0                | 0      | Western European Time            |
| `WEST`       | +01:00             | 3600             | 1      | Western European Summer Time     |
| `CET`        | +01:00             | 3600             | 0      | Central European Time            |
| `CEST`       | +02:00             | 7200             | 1      | Central European Summer Time     |
| `EET`        | +02:00             | 7200             | 0      | Eastern European Time            |
| `EEST`       | +03:00             | 10800            | 1      | Eastern European Summer Time     |
| `MSK`        | +03:00             | 10800            | 0      | Moscow Standard Time             |

### South American Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                                                              |
| :----------- | :----------------- | :--------------- | :----- | :----------------------------------------------------------------------- |
| `ART`        | -03:00             | -10800           | 0      | Argentina Time                                                           |
| `BRT`        | -03:00             | -10800           | 0      | Brazil Time (main population areas, can vary by region/DST)              |
| `BRST`       | -02:00             | -7200            | 1      | Brazil Summer Time (historical, not currently observed by all)           |
| `CLT`        | -04:00             | -14400           | 0      | Chile Standard Time                                                      |
| `CLST`       | -03:00             | -10800           | 1      | Chile Summer Time                                                        |

### Australasian / Oceanian Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                        |
| :----------- | :----------------- | :--------------- | :----- | :--------------------------------- |
| `AEST`       | +10:00             | 36000            | 0      | Australian Eastern Standard Time   |
| `AEDT`       | +11:00             | 39600            | 1      | Australian Eastern Daylight Time   |
| `ACST`       | +09:30             | 34200            | 0      | Australian Central Standard Time   |
| `ACDT`       | +10:30             | 37800            | 1      | Australian Central Daylight Time |
| `AWST`       | +08:00             | 28800            | 0      | Australian Western Standard Time   |
| `NZST`       | +12:00             | 43200            | 0      | New Zealand Standard Time          |
| `NZDT`       | +13:00             | 46800            | 1      | New Zealand Daylight Time          |

### Asian Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                                               |
| :----------- | :----------------- | :--------------- | :----- | :-------------------------------------------------------- |
| `JST`        | +09:00             | 32400            | 0      | Japan Standard Time                                       |
| `KST`        | +09:00             | 32400            | 0      | Korea Standard Time                                       |
| `SGT`        | +08:00             | 28800            | 0      | Singapore Time                                            |
| `IST`        | +05:30             | 19800            | 0      | India Standard Time                                       |
| `GST`        | +04:00             | 14400            | 0      | Gulf Standard Time (e.g., UAE, Oman)                    |
| `ICT`        | +07:00             | 25200            | 0      | Indochina Time (Thailand, Vietnam, Laos, Cambodia)        |
| `WIB`        | +07:00             | 25200            | 0      | Western Indonesian Time                                   |
| `WITA`       | +08:00             | 28800            | 0      | Central Indonesian Time                                   |
| `WIT`        | +09:00             | 32400            | 0      | Eastern Indonesian Time                                   |
| `MYT`        | +08:00             | 28800            | 0      | Malaysia Time                                             |
| `BDT`        | +06:00             | 21600            | 0      | Bangladesh Standard Time                                  |
| `NPT`        | +05:45             | 20700            | 0      | Nepal Time                                                |

### African Timezones

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                 |
| :----------- | :----------------- | :--------------- | :----- | :-------------------------- |
| `WAT`        | +01:00             | 3600             | 0      | West Africa Time            |
| `CAT`        | +02:00             | 7200             | 0      | Central Africa Time         |
| `EAT`        | +03:00             | 10800            | 0      | East Africa Time            |
| `SAST`       | +02:00             | 7200             | 0      | South Africa Standard Time  |

### Military Timezones

*These are single-letter UTC offset designators. 'J' (Juliett) represents local time and is not included. 'Z' (Zulu) is UTC and listed above.*

| Abbreviation | UTC Offset (HH:MM) | Offset (Seconds) | Is DST | Description                                             |
| :----------- | :----------------- | :--------------- | :----- | :------------------------------------------------------ |
| `A`          | +01:00             | 3600             | 0      | Alpha Time Zone                                         |
| `B`          | +02:00             | 7200             | 0      | Bravo Time Zone                                         |
| `C`          | +03:00             | 10800            | 0      | Charlie Time Zone                                       |
| `D`          | +04:00             | 14400            | 0      | Delta Time Zone                                         |
| `E`          | +05:00             | 18000            | 0      | Echo Time Zone                                          |
| `F`          | +06:00             | 21600            | 0      | Foxtrot Time Zone                                       |
| `G`          | +07:00             | 25200            | 0      | Golf Time Zone                                          |
| `H`          | +08:00             | 28800            | 0      | Hotel Time Zone                                         |
| `I`          | +09:00             | 32400            | 0      | India Time Zone (Military, not India Standard Time)     |
| `K`          | +10:00             | 36000            | 0      | Kilo Time Zone                                          |
| `L`          | +11:00             | 39600            | 0      | Lima Time Zone                                          |
| `M`          | +12:00             | 43200            | 0      | Mike Time Zone                                          |
| `N`          | -01:00             | -3600            | 0      | November Time Zone                                      |
| `O`          | -02:00             | -7200            | 0      | Oscar Time Zone                                         |
| `P`          | -03:00             | -10800           | 0      | Papa Time Zone                                          |
| `Q`          | -04:00             | -14400           | 0      | Quebec Time Zone                                        |
| `R`          | -05:00             | -18000           | 0      | Romeo Time Zone                                         |
| `S`          | -06:00             | -21600           | 0      | Sierra Time Zone                                        |
| `T`          | -07:00             | -25200           | 0      | Tango Time Zone                                         |
| `U`          | -08:00             | -28800           | 0      | Uniform Time Zone                                       |
| `V`          | -09:00             | -32400           | 0      | Victor Time Zone                                        |
| `W`          | -10:00             | -36000           | 0      | Whiskey Time Zone                                       |
| `X`          | -11:00             | -43200           | 0      | X-ray Time Zone                                         |
| `Y`          | -12:00             | -46800           | 0      | Yankee Time Zone                                        |
