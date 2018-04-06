# Nest Filter

The _Nest Filter_ plugin allows to nest a set of keys under a new key

## Example usage

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

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         | Value Format          | Description       |
|-------------|-----------------------|-------------------|
| Wildcard    | FIELD WILDCARD        | Nest records which field matches the wildcard |
| Nest\_under | FIELD STRING          | Nest records matching the `Wildcard` under this key |

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.
The following invokes the [Memory Usage Input Plugin](../input/mem.html), which outputs the following (example),

```
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[1] memory: [1488543157, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[2] memory: [1488543158, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[3] memory: [1488543159, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
```

### Command Line

> Note: Using the command line mode requires quotes parse the wildcard properly. The use of a configuration file is recommended.

The following command will load the _mem_ plugin.
Then the _nest_ filter will match the wildcard rule to the keys and nest the keys matching `Mem.*` under the new key `NEST`.

```
$ bin/fluent-bit -i mem -p 'tag=mem.local' -F nest -p 'Wildcard=Mem.*' -p 'Nest_under=NEST' -m '*' -o stdout
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
