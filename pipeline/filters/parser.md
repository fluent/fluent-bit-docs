# Parser

The _Parser Filter_ plugin allows for parsing fields in event records.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Key\_Name | Specify field name in record to parse. |  |
| Parser | Specify the parser name to interpret the field. Multiple _Parser_ entries are allowed \(one per line\). |  |
| Preserve\_Key | Keep original `Key_Name` field in the parsed result. If false, the field will be removed. | False |
| Reserve\_Data | Keep all other original fields in the parsed result. If false, all other original fields will be removed. | False |

## Getting Started

### Configuration File

This is an example of parsing a record `{"data":"100 0.5 true This is example"}`.

The plugin needs a parser file which defines how to parse each field.

```python
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

The path of the parser file should be written in configuration file under the **\[SERVICE\]** section.

```python
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test

[OUTPUT]
    Name stdout
    Match *
```

The output is

```text
$ fluent-bit -c dummy.conf
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2017/07/06 22:33:12] [ info] [engine] started
[0] dummy.data: [1499347993.001371317, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[1] dummy.data: [1499347994.001303118, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[2] dummy.data: [1499347995.001296133, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[3] dummy.data: [1499347996.001320284, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
```

You can see the records `{"data":"100 0.5 true This is example"}` are parsed.

### Preserve original fields

By default, the parser plugin only keeps the parsed fields in its output.

If you enable `Reserve_Data`, all other fields are preserved:

```python
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

```python
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test
    Reserve_Data On
```

This will produce the output:

```text
$ fluent-bit -c dummy.conf
Fluent-Bit v0.12.0
Copyright (C) Treasure Data

[2017/07/06 22:33:12] [ info] [engine] started
[0] dummy.data: [1499347993.001371317, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}, "key1":"value1", "key2":"value2"]
[1] dummy.data: [1499347994.001303118, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}, "key1":"value1", "key2":"value2"]
[2] dummy.data: [1499347995.001296133, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}, "key1":"value1", "key2":"value2"]
[3] dummy.data: [1499347996.001320284, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}, "key1":"value1", "key2":"value2"]
```

If you enable `Reserved_Data` and `Preserve_Key`, the original key field will be preserved as well:

```python
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

```python
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test
    Reserve_Data On
    Preserve_Key On

[OUTPUT]
    Name stdout
    Match *
```

This will produce the following output:

```text
$ fluent-bit -c dummy.conf
Fluent Bit v2.1.1
* Copyright (C) 2015-2022 The Fluent Bit Authors
...
...
[0] dummy.data: [[1687122778.299116136, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1687122779.296906553, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1687122780.297475803, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
```
