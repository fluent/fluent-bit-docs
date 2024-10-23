# Type Converter

The _Type Converter Filter_ plugin allows to convert data type and append new key value pair.

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=8984f540-d95a-462b-8a08-09f72f5fab63" />

This plugin is useful in combination with plugins which expect incoming string value.
e.g. [filter_grep](grep.md), [filter_modify](modify.md)

## Configuration Parameters

The plugin supports the following configuration parameters. It needs four parameters.

`<config_parameter> <src_key_name> <dst_key_name> <dst_data_type>`

_dst_data_type_ allows `int`, `uint`, `float` and `string`.

e.g. `int_key id id_str string`


| Key | Description |
| :--- | :--- |
| int_key  | This parameter is for integer source.|
| uint_key | This parameter is for unsigned integer source.|
| float_key| This parameter is for float source.|
| str_key | This parameter is for string source.|

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.

This is a sample in\_mem record to filter. 

```text
{"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>299352, "Swap.total"=>2064380, "Swap.used"=>32656, "Swap.free"=>2031724}
```

The plugin outputs uint values and filter_type_converter converts them into string type.

### Convert uint to string

{% tabs %}
{% tab title="fluent-bit.conf" %}
```python
[INPUT]
    Name mem

[FILTER]
    Name type_converter
    Match *
    uint_key Mem.total Mem.total_str string
    uint_key Mem.used  Mem.used_str  string
    uint_key Mem.free  Mem.free_str  string

[OUTPUT]
    Name stdout
    Match *
```
{% endtab %}

{% tab title="fluent-bit.yaml" %}
```yaml
pipeline:
    inputs:
        - name: mem
    filters:
        - name: type_converter
          match: '*'
          uint_key:
            - Mem.total Mem.total_str string
            - Mem.used  Mem.used_str  string
            - Mem.free  Mem.free_str  string
    outputs:
        - name: stdout
          match: '*'
```
{% endtab %}
{% endtabs %}

You can also run the filter from command line.

```text
$ fluent-bit -i mem -o stdout -F type_converter -p 'uint_key=Mem.total Mem.total_str string' -p 'uint_key=Mem.used Mem.used_str string' -p 'uint_key=Mem.free Mem.free_str string' -m '*'
```

The output will be

```python
[0] mem.0: [1639915154.160159749, {"Mem.total"=>8146052, "Mem.used"=>4513564, "Mem.free"=>3632488, "Swap.total"=>1918356, "Swap.used"=>0, "Swap.free"=>1918356, "Mem.total_str"=>"8146052", "Mem.used_str"=>"4513564", "Mem.free_str"=>"3632488"}]
```
