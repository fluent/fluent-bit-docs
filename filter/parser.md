# Parser

The _Parser Filter_ plugin allows to parse field in event records.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Key\_Name | Specify field name in record to parse. |  |
| Parser | Specify the parser name to interpret the field. Multiple _Parser_ entries are allowed \(one per line\). |  |
| Preserve\_Key | Keep original `Key_Name` field in the parsed result. If false, the field will be removed. | False |
| Reserve\_Data | Keep all other original fields in the parsed result. If false, all other original fields will be removed. | False |
| Unescape\_Key | If the key is a escaped string \(e.g: stringify JSON\), unescape the string before to apply the parser. | False |

## Getting Started

### Configuration File

This is an example to parser a record `{"data":"100 0.5 true This is example"}`.

The plugin needs parser file which defines how to parse field.

```python
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

The path of parser file should be written in configuration file at **\[SERVICE\]** section.

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
Fluent-Bit v0.12.0
Copyright (C) Treasure Data

[2017/07/06 22:33:12] [ info] [engine] started
[0] dummy.data: [1499347993.001371317, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[1] dummy.data: [1499347994.001303118, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[2] dummy.data: [1499347995.001296133, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[3] dummy.data: [1499347996.001320284, {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
```

You can see the record `{"data":"100 0.5 true This is example"}` are parsed.

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
```

This will produce the output:

```text
$ fluent-bit -c dummy.conf
Fluent-Bit v0.12.0
Copyright (C) Treasure Data

[2017/07/06 22:33:12] [ info] [engine] started
[0] dummy.data: [1499347993.001371317, {"data":"100 0.5 true This is example", "INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[1] dummy.data: [1499347994.001303118, {"data":"100 0.5 true This is example", "INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[2] dummy.data: [1499347995.001296133, {"data":"100 0.5 true This is example", "INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[3] dummy.data: [1499347996.001320284, {"data":"100 0.5 true This is example", "INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
```

