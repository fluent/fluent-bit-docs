# Configuring parsers

You can use parsers to transform unstructured log entries into structured log entries, which makes it easier to process and further filter those logs.

The parser engine is fully configurable and can process log entries based in two formats:

- [JSON maps](json.md)
- [Regular expressions](regular-expression.md) (named capture)

By default, Fluent Bit provides a set of pre-configured parsers that can be used for different use cases, such as logs from:

- Apache
- NGINX
- Docker
- Syslog rfc5424
- Syslog rfc3164

Parsers are defined in one or more configuration files that are loaded at start time, either from the command line or through the main Fluent Bit configuration file.

{% hint style="info" %}

Fluent Bit uses Ruby-based regular expressions. You can use [Rubular](http://www.rubular.com) to test your regular expressions for Ruby compatibility.

{% endhint %}

## Configuration parameters

Multiple parsers can be defined and each section has it own properties. The following table describes the available options for each parser definition:

| Key | Description |
| --- | ----------- |
| `Name` | Sets the name of your parser. |
| `Format` | Specifies the format of the parser. Possible options: [`json`](json.md), [`regex`](regular-expression.md), [`ltsv`](ltsv.md), or [`logfmt`](logfmt.md). |
| `Regex` | Required for parsers with the `regex` format. Specifies the Ruby regular expression for parsing and composing the structured message. |
| `Time_Key` | If the log entry provides a field with a timestamp, this option specifies the name of that field. |
| `Time_Format` | Specifies the format of the time field so it can be recognized and analyzed properly. Fluent Bit uses `strptime(3)` to parse time. See the [`strptime` documentation](https://linux.die.net/man/3/strptime) for available modifiers. The `%L` field descriptor is supported for fractional seconds. |
| `Time_Offset` | Specifies a fixed UTC time offset (such as `-0600` or `+0200`) for local dates. |
| `Time_Keep` | If enabled, when a time key is recognized and parsed, the parser will keep the original time key. If disabled, the parser will drop the original time field. |
| `Time_System_timezone` | If there is no time zone (`%z`) specified in the given `Time_Format`, enabling this option will make the parser detect and use the system's configured time zone. The configured time zone is detected from the [`TZ` environment variable](https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html). |
| `Types` | Specifies the data type of parsed field. The syntax is `types <field_name_1>:<type_name_1> <field_name_2>:<type_name_2> ...`. The supported types are `string` (default), `integer`, `bool`, `float`, `hex`. The option is supported by `ltsv`, `logfmt` and `regex`. |
| `Decode_Field` | If the content can be decoded in a structured message, append the structured message (keys and values) to the original log message. Decoder types: `json`, `escaped`, `escaped_utf8`. The syntax is: `Decode_Field <decoder_type> <field_name>`. See [Decoders](decoders.md) for additional information. |
| `Decode_Field_As` | Any decoded content (unstructured or structured) will be replaced in the same key/value, and no extra keys are added. Decoder types: `json`, `escaped`, `escaped_utf8`. The syntax is: `Decode_Field_As <decoder_type> <field_name>`. See [Decoders](decoders.md) for additional information. |
| `Skip_Empty_Values` | Specifies a boolean which determines if the parser should skip empty values. The default is `true`. |
| `Time_Strict` | The default value (`true`) tells the parser to be strict with the expected time format. With this option set to false, the parser will be permissive with the format of the time. You can use this when the format expects time fraction but the time to be parsed doesn't include it.  |

## Parsers configuration file

All parsers can be defined in a parsers file. The parsers file exposes all parsers available that can be used by the input plugins that are aware of this feature. A parsers file can have multiple entries, like so:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: docker
    format: json
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on

  - name: syslog-rfc5424
    format: regex
    regex: '^\<(?<pri>[0-9]{1,5})\>1 (?<time>[^ ]+) (?<host>[^ ]+) (?<ident>[^ ]+) (?<pid>[-0-9]+) (?<msgid>[^ ]+) (?<extradata>(\[(.*)\]|-)) (?<message>.+)$'
    time_key: time
    time_format: '%Y-%m-%dT%H:%M:%S.%L'
    time_keep: on
    types: pid:integer
```

{% endtab %}
{% tab title="parsers.conf" %}

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

{% endtab %}
{% endtabs %}

For more information about the parsers available, refer to the [default parsers file](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf) distributed with Fluent Bit source code.

## Time resolution and fractional seconds

Time resolution and its format supported are handled by using the [strftime\(3\)](http://man7.org/linux/man-pages/man3/strftime.3.html) `libc` system function.

In addition, Fluent Bit extends its time resolution to support fractional seconds like `017-05-17T15:44:31**.187512963**Z`. The `%L` format option for `Time_Format` is provided as a way to indicate that content must be interpreted as fractional seconds.

{% hint style="info" %}

The option `%L` is only valid when used after seconds (`%S`) or seconds since the epoch (`%s`). For example, `%S.%L` and `%s.%L` are valid strings.

{% endhint %}

## Supported time zone abbreviations

The following time zone abbreviations are supported.

### Universal time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                |
| ------------ | -------------------- | ---------------- | ------ | -------------------------- |
| `GMT`        | `+00:00`             | `0`              | no     | Greenwich Mean Time        |
| `UTC`        | `+00:00`             | `0`              | no     | Coordinated Universal Time |
| `Z`          | `+00:00`             | `0`              | no     | Zulu Time (UTC)            |
| `UT`         | `+00:00`             | `0`              | no     | Universal Time             |

<!-- vale FluentBit.Headings = NO -->

### North American time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                                              |
| ------------ | -------------------- | ---------------- | ------ | -------------------------------------------------------- |
| `EST`        | `-05:00`             | `-18000`         | no     | Eastern Standard Time                                    |
| `EDT`        | `-04:00`             | `-14400`         | yes    | Eastern Daylight Time                                    |
| `CST`        | `-06:00`             | `-21600`         | no     | Central Standard Time (North America)                    |
| `CDT`        | `-05:00`             | `-18000`         | yes    | Central Daylight Time (North America)                    |
| `MST`        | `-07:00`             | `-25200`         | no     | Mountain Standard Time                                   |
| `MDT`        | `-06:00`             | `-21600`         | yes    | Mountain Daylight Time                                   |
| `PST`        | `-08:00`             | `-28800`         | no     | Pacific Standard Time                                    |
| `PDT`        | `-07:00`             | `-25200`         | yes    | Pacific Daylight Time                                    |
| `AKST`       | `-09:00`             | `-32400`         | no     | Alaska Standard Time                                     |
| `AKDT`       | `-08:00`             | `-28800`         | yes    | Alaska Daylight Time                                     |
| `HST`        | `-10:00`             | `-36000`         | no     | Hawaii Standard Time                                     |
| `HADT`       | `-09:00`             | `-32400`         | yes    | Hawaii-Aleutian Daylight Time (rarely used for Hawaii)   |
| `AST`        | `-04:00`             | `-14400`         | no     | Atlantic Standard Time (for example, Canada, Caribbean)  |
| `ADT`        | `-03:00`             | `-10800`         | yes    | Atlantic Daylight Time                                   |
| `NST`        | `-03:30`             | `-12600`         | no     | Newfoundland Standard Time                               |
| `NDT`        | `-02:30`             | `-9000`          | yes    | Newfoundland Daylight Time                               |

### European time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                      |
| ------------ | -------------------- | ---------------- | ------ | -------------------------------- |
| `WET`        | `+00:00`             | `0`              | no     | Western European Time            |
| `WEST`       | `+01:00`             | `3600`           | yes    | Western European Summer Time     |
| `CET`        | `+01:00`             | `3600`           | no     | Central European Time            |
| `CEST`       | `+02:00`             | `7200`           | yes    | Central European Summer Time     |
| `EET`        | `+02:00`             | `7200`           | no     | Eastern European Time            |
| `EEST`       | `+03:00`             | `10800`          | yes    | Eastern European Summer Time     |
| `MSK`        | `+03:00`             | `10800`          | no     | Moscow Standard Time             |

### South American time zones

<!-- vale FluentBit.Headings = YES -->

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                                                              |
| ------------ | -------------------- | ---------------- | ------ | ------------------------------------------------------------------------ |
| `ART`        | `-03:00`             | `-10800`         | no     | Argentina Time                                                           |
| `BRT`        | `-03:00`             | `-10800`         | no     | Brazil Time (main population areas, can vary by region/DST)              |
| `BRST`       | `-02:00`             | `-7200`          | yes    | Brazil Summer Time (historical, not currently observed by all)           |
| `CLT`        | `-04:00`             | `-14400`         | no     | Chile Standard Time                                                      |
| `CLST`       | `-03:00`             | `-10800`         | yes    | Chile Summer Time                                                        |

### Australasian and Oceania time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                        |
| ------------ | -------------------- | ---------------- | ------ | ---------------------------------- |
| `AEST`       | `+10:00`             | `36000`          | no     | Australian Eastern Standard Time   |
| `AEDT`       | `+11:00`             | `39600`          | yes    | Australian Eastern Daylight Time   |
| `ACST`       | `+09:30`             | `34200`          | no     | Australian Central Standard Time   |
| `ACDT`       | `+10:30`             | `37800`          | yes    | Australian Central Daylight Time   |
| `AWST`       | `+08:00`             | `28800`          | no     | Australian Western Standard Time   |
| `NZST`       | `+12:00`             | `43200`          | no     | New Zealand Standard Time          |
| `NZDT`       | `+13:00`             | `46800`          | yes    | New Zealand Daylight Time          |

### Asian time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                                               |
| ------------ | -------------------- | ---------------- | ------ | --------------------------------------------------------- |
| `JST`        | `+09:00`             | `32400`          | no     | Japan Standard Time                                       |
| `KST`        | `+09:00`             | `32400`          | no     | Korea Standard Time                                       |
| `SGT`        | `+08:00`             | `28800`          | no     | Singapore Time                                            |
| `IST`        | `+05:30`             | `19800`          | no     | India Standard Time                                       |
| `GST`        | `+04:00`             | `14400`          | no     | Gulf Standard Time (for example, UAE, Oman)               |
| `ICT`        | `+07:00`             | `25200`          | no     | Indochina Time (Thailand, Vietnam, Laos, Cambodia)        |
| `WIB`        | `+07:00`             | `25200`          | no     | Western Indonesian Time                                   |
| `WITA`       | `+08:00`             | `28800`          | no     | Central Indonesian Time                                   |
| `WIT`        | `+09:00`             | `32400`          | no     | Eastern Indonesian Time                                   |
| `MYT`        | `+08:00`             | `28800`          | no     | Malaysia Time                                             |
| `BDT`        | `+06:00`             | `21600`          | no     | Bangladesh Standard Time                                  |
| `NPT`        | `+05:45`             | `20700`          | no     | Nepal Time                                                |

### African time zones

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                 |
| ------------ | -------------------- | ---------------- | ------ | --------------------------- |
| `WAT`        | `+01:00`             | `3600`           | no     | West Africa Time            |
| `CAT`        | `+02:00`             | `7200`           | no     | Central Africa Time         |
| `EAT`        | `+03:00`             | `10800`          | no     | East Africa Time            |
| `SAST`       | `+02:00`             | `7200`           | no     | South Africa Standard Time  |

### Military time zones

{% hint style="info" %}

These are single-letter UTC offset designators. `J` (Juliet) represents local time and isn't included. `Z` represents Zulu Time, as listed in the [Universal time zones](#universal-time-zones) list.

{% endhint %}

| Abbreviation | UTC Offset (`HH:MM`) | Offset (seconds) | Is DST | Description                                             |
| ------------ | -------------------- | ---------------- | ------ | ------------------------------------------------------- |
| `A`          | `+01:00`             | `3600`           | no     | Alpha Time Zone                                         |
| `B`          | `+02:00`             | `7200`           | no     | Bravo Time Zone                                         |
| `C`          | `+03:00`             | `10800`          | no     | Charlie Time Zone                                       |
| `D`          | `+04:00`             | `14400`          | no     | Delta Time Zone                                         |
| `E`          | `+05:00`             | `18000`          | no     | Echo Time Zone                                          |
| `F`          | `+06:00`             | `21600`          | no     | Foxtrot Time Zone                                       |
| `G`          | `+07:00`             | `25200`          | no     | Golf Time Zone                                          |
| `H`          | `+08:00`             | `28800`          | no     | Hotel Time Zone                                         |
| `I`          | `+09:00`             | `32400`          | no     | India Time Zone (military, not Indian Standard Time)    |
| `K`          | `+10:00`             | `36000`          | no     | Kilo Time Zone                                          |
| `L`          | `+11:00`             | `39600`          | no     | Lima Time Zone                                          |
| `M`          | `+12:00`             | `43200`          | no     | Mike Time Zone                                          |
| `N`          | `-01:00`             | `-3600`          | no     | November Time Zone                                      |
| `O`          | `-02:00`             | `-7200`          | no     | Oscar Time Zone                                         |
| `P`          | `-03:00`             | `-10800`         | no     | Papa Time Zone                                          |
| `Q`          | `-04:00`             | `-14400`         | no     | Quebec Time Zone                                        |
| `R`          | `-05:00`             | `-18000`         | no     | Romeo Time Zone                                         |
| `S`          | `-06:00`             | `-21600`         | no     | Sierra Time Zone                                        |
| `T`          | `-07:00`             | `-25200`         | no     | Tango Time Zone                                         |
| `U`          | `-08:00`             | `-28800`         | no     | Uniform Time Zone                                       |
| `V`          | `-09:00`             | `-32400`         | no     | Victor Time Zone                                        |
| `W`          | `-10:00`             | `-36000`         | no     | Whiskey Time Zone                                       |
| `X`          | `-11:00`             | `-43200`         | no     | X-ray Time Zone                                         |
| `Y`          | `-12:00`             | `-46800`         | no     | Yankee Time Zone                                        |
