# Nest Filter

The _Nest Filter_ plugin allows you to operate on or with nested data. Its modes of operation are

  * `nest` - Take a set of records and place them in a map
  * `lift` - Take a map by key and lift its records up

## Example usage (nest)

As an example using JSON notation, 
to nest keys matching the `Wildcard` value `Key*` under a new key `NestKey` the transformation becomes,

_Example (input)_
```
{
  "Key1"     : "Value1",
  "Key2"     : "Value2",
  "OtherKey" : "Value3"
}

```

_Example (output)_
```
{
  "OtherKey" : "Value3"
  "NestKey"  : {
    "Key1"     : "Value1",
    "Key2"     : "Value2",
  }
}

```

## Example usage (lift)

As an example using JSON notation, 
to lift keys nested under the `Nested_under` value `NestKey*` the transformation becomes,

_Example (input)_
```
{
  "OtherKey" : "Value3"
  "NestKey"  : {
    "Key1"     : "Value1",
    "Key2"     : "Value2",
  }
}

```

_Example (output)_
```
{
  "Key1"     : "Value1",
  "Key2"     : "Value2",
  "OtherKey" : "Value3"
}

```

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key           | Value Format          | Operation   | Description       |
|---------------|-----------------------|-------------|-------------------|
| Operation     | ENUM [`nest`\|`lift`] |             | Select the operation `nest` or `lift` |
| Wildcard      | FIELD WILDCARD        | `nest`      | Nest records which field matches the wildcard |
| Nest\_under   | FIELD STRING          | `nest`      | Nest records matching the `Wildcard` under this key |
| Nested\_under | FIELD STRING          | `lift`      | Lift records nested under the `Nested_under` key |
| Prefix\_with  | FIELD STRING          | `lift`      | Prefix lifted keys with this string |

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.
The following invokes the [Memory Usage Input Plugin](../input/mem.html), which outputs the following (example),

```
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[1] memory: [1488543157, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[2] memory: [1488543158, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[3] memory: [1488543159, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
```

## Example #1 - nest

### Command Line

> Note: Using the command line mode requires quotes parse the wildcard properly. The use of a configuration file is recommended.

The following command will load the _mem_ plugin.
Then the _nest_ filter will match the wildcard rule to the keys and nest the keys matching `Mem.*` under the new key `NEST`.

```
$ bin/fluent-bit -i mem -p 'tag=mem.local' -F nest -p 'Operation=nest' -p 'Wildcard=Mem.*' -p 'Nest_under=NEST' -m '*' -o stdout
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
    Nest_under NEST
```

### Result

The output of both the command line and configuration invocations should be identical and result in the following output.

```
[2018/04/06 01:35:13] [ info] [engine] started
[0] mem.local: [1522978514.007359767, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "NEST"=>{"Mem.total"=>4050908, "Mem.used"=>714984, "Mem.free"=>3335924}}]
[1] mem.local: [1522978515.000715559, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "NEST"=>{"Mem.total"=>4050908, "Mem.used"=>714984, "Mem.free"=>3335924}}]
[2] mem.local: [1522978516.001057673, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "NEST"=>{"Mem.total"=>4050908, "Mem.used"=>714984, "Mem.free"=>3335924}}]
[3] mem.local: [1522978517.000795638, {"Swap.total"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "NEST"=>{"Mem.total"=>4050908, "Mem.used"=>714984, "Mem.free"=>3335924}}]
```

## Example #2 - nest 3 levels deep

This example takes the keys starting with `Mem.*` and nests them under
`LAYER1`, which itself is then nested under `LAYER2`, which is nested under
`LAYER3`.

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

```
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

## Example #3 - multiple nest and lift filters with prefix

This example starts with the 3-level deep nesting of _Example 2_ and applies
the `lift` filter three times to reverse the operations. The end result is that
all records are at the top level, without nesting, again. One prefix is added
for each level that is lifted.

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
    Prefix_with Lifted3_

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under Lifted3_LAYER2
    Prefix_with Lifted3_Lifted2_

[FILTER]
    Name nest
    Match *
    Operation lift
    Nested_under Lifted3_Lifted2_LAYER1
    Prefix_with Lifted3_Lifted2_Lifted1_
```

### Result

```
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
