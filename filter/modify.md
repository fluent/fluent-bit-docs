# Modify Filter

The _Modify Filter_ plugin allows you to modify a set of keys under a new key

## Example usage

As an example using JSON notation to,

 - Rename 'Key2` to `RenamedKey`
 - Add a key `OtherKey` with value `Value3` if `OtherKey` does not yet exist

_Example (input)_
```
{
  "Key1"     : "Value1",
  "Key2"     : "Value2"
}

```

_Example (output)_
```
{
  "Key1"       : "Value1",
  "RenamedKey" : "Value2",
  "OtherKey"   : "Value3"
}

```

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key                      | Value Format          | Description                          |
|--------------------------|-----------------------|--------------------------------------|
| Add\_if\_not\_present    | FIELD VALUE           | Add a record with key `FIELD` and value `VALUE` if `FIELD` is not present |
| Rename                   | FIELD RENAMED\_FIELD  | Rename a record with key `FIELD` to `RENAMED_FIELD` ||

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
bin/fluent-bit -i mem \
  -p 'tag=mem.local' \
  -F modify \
  -p 'Add_if_not_present=Service1 SOMEVALUE' \
  -p 'Add_if_not_present=Service2 SOMEVALUE3' \
  -p 'Add_if_not_present=Mem.total2 TOTALMEM2' \
  -p 'Rename=Mem.free MEMFREE' \
  -p 'Rename=Mem.used MEMUSED' \
  -p 'Rename=Swap.total SWAPTOTAL' \
  -p 'Add_if_not_present=Mem.total TOTALMEM' \
  -m '*' \
  -o stdout
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
    Name modify
    Match *
    Add_if_not_present Service1 SOMEVALUE
    Add_if_not_present Service3 SOMEVALUE3
    Add_if_not_present Mem.total2 TOTALMEM2
    Rename Mem.free MEMFREE
    Rename Mem.used MEMUSED
    Rename Swap.total SWAPTOTAL
    Add_if_not_present Mem.total TOTALMEM
```

### Result

The output of both the command line and configuration invocations should be identical and result in the following output.

```
[2018/04/06 01:35:13] [ info] [engine] started
[0] mem.local: [1522980610.006892802, {"Mem.total"=>4050908, "MEMUSED"=>738100, "MEMFREE"=>3312808, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[1] mem.local: [1522980611.000658288, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[2] mem.local: [1522980612.000307652, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[3] mem.local: [1522980613.000122671, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
```
