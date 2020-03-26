# Nest

The _Nest Filter_ plugin allows you to operate on or with nested data. Its modes of operation are

* `nest` - Take a set of records and place them in a map
* `lift` - Take a map by key and lift its records up

## Example usage \(nest\)

As an example using JSON notation, to nest keys matching the `Wildcard` value `Key*` under a new key `NestKey` the transformation becomes,

_Example \(input\)_

```text
{
  "Key1"     : "Value1",
  "Key2"     : "Value2",
  "OtherKey" : "Value3"
}
```

_Example \(output\)_

```text
{
  "OtherKey" : "Value3"
  "NestKey"  : {
    "Key1"     : "Value1",
    "Key2"     : "Value2",
  }
}
```

## Example usage \(lift\)

As an example using JSON notation, to lift keys nested under the `Nested_under` value `NestKey*` the transformation becomes,

_Example \(input\)_

```text
{
  "OtherKey" : "Value3"
  "NestKey"  : {
    "Key1"     : "Value1",
    "Key2"     : "Value2",
  }
}
```

_Example \(output\)_

```text
{
  "Key1"     : "Value1",
  "Key2"     : "Value2",
  "OtherKey" : "Value3"
}
```

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Value Format | Operation | Description |
| :--- | :--- | :--- | :--- |
| Operation | ENUM \[`nest` or `lift`\] |  | Select the operation `nest` or `lift` |
| Wildcard | FIELD WILDCARD | `nest` | Nest records which field matches the wildcard |
| Nest\_under | FIELD STRING | `nest` | Nest records matching the `Wildcard` under this key |
| Nested\_under | FIELD STRING | `lift` | Lift records nested under the `Nested_under` key |
| Add\_prefix | FIELD STRING | ANY | Prefix affected keys with this string |
| Remove\_prefix | FIELD STRING | ANY | Remove prefix from affected keys if it matches this string |

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file. The following invokes the [Memory Usage Input Plugin](https://github.com/fluent/fluent-bit-docs/tree/ad9d80e5490bd5d79c86955c5689db1cb4cf89db/input/mem.html), which outputs the following \(example\),

```text
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
```

## Example \#1 - nest

### Command Line

> Note: Using the command line mode requires quotes parse the wildcard properly. The use of a configuration file is recommended.

The following command will load the _mem_ plugin. Then the _nest_ filter will match the wildcard rule to the keys and nest the keys matching `Mem.*` under the new key `NEST`.

```text
$ bin/fluent-bit -i mem -p 'tag=mem.local' -F nest -p 'Operation=nest' -p 'Wildcard=Mem.*' -p 'Nest_under=Memstats' -p 'Remove_prefix=Mem.' -m '*' -o stdout
```

### Configuration File

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard Mem.*
    Nest_under Memstats
    Remove_prefix Mem.
```

### Result

The output of both the command line and configuration invocations should be identical and result in the following output.

```text
[2018/04/06 01:35:13] [ info] [engine] started
[0] mem.local: [1522978514.007359767, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Memstats"=>{"total"=>4050908, "used"=>714984, "free"=>3335924}}]
```

## Example \#1 - nest and lift undo

This example nests all `Mem.*` and `Swap,*` items under the `Stats` key and then reverses these actions with a `lift` operation. The output appears unchanged.

### Configuration File

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard Mem.*
    Wildcard Swap.*
    Nest_under Stats
    Add_prefix NESTED

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under Stats
    Remove_prefix NESTED
```

### Result

```text
[2018/06/21 17:42:37] [ info] [engine] started (pid=17285)
[0] mem.local: [1529566958.000940636, {"Mem.total"=>8053656, "Mem.used"=>6940380, "Mem.free"=>1113276, "Swap.total"=>16532988, "Swap.used"=>1286772, "Swap.free"=>15246216}]
```

## Example \#2 - nest 3 levels deep

This example takes the keys starting with `Mem.*` and nests them under `LAYER1`, which itself is then nested under `LAYER2`, which is nested under `LAYER3`.

### Configuration File

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard Mem.*
    Nest_under LAYER1

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard LAYER1*
    Nest_under LAYER2

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard LAYER2*
    Nest_under LAYER3
```

### Result

```text
[0] mem.local: [1524795923.009867831, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "LAYER3"=>{"LAYER2"=>{"LAYER1"=>{"Mem.total"=>4050908, "Mem.used"=>1112036, "Mem.free"=>2938872}}}}]


{
  "Swap.total"=>1046524,
  "Swap.used"=>0,
  "Swap.free"=>1046524,
  "LAYER3"=>{
    "LAYER2"=>{
      "LAYER1"=>{
        "Mem.total"=>4050908,
        "Mem.used"=>1112036,
        "Mem.free"=>2938872
      }
    }
  }
}
```

## Example \#3 - multiple nest and lift filters with prefix

This example starts with the 3-level deep nesting of _Example 2_ and applies the `lift` filter three times to reverse the operations. The end result is that all records are at the top level, without nesting, again. One prefix is added for each level that is lifted.

### Configuration file

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard Mem.*
    Nest_under LAYER1

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard LAYER1*
    Nest_under LAYER2

[FILTER]
    Name nest
    Match *
    Operation nest
    Wildcard LAYER2*
    Nest_under LAYER3

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under LAYER3
    Add_prefix Lifted3_

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under Lifted3_LAYER2
    Add_prefix Lifted3_Lifted2_

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under Lifted3_Lifted2_LAYER1
    Add_prefix Lifted3_Lifted2_Lifted1_
```

### Result

```text
[0] mem.local: [1524862951.013414798, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Lifted3_Lifted2_Lifted1_Mem.total"=>4050908, "Lifted3_Lifted2_Lifted1_Mem.used"=>1253912, "Lifted3_Lifted2_Lifted1_Mem.free"=>2796996}]


{
  "Swap.total"=>1046524, 
  "Swap.used"=>0, 
  "Swap.free"=>1046524, 
  "Lifted3_Lifted2_Lifted1_Mem.total"=>4050908, 
  "Lifted3_Lifted2_Lifted1_Mem.used"=>1253912, 
  "Lifted3_Lifted2_Lifted1_Mem.free"=>2796996
}
```

