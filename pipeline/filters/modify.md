# Modify

The _Modify Filter_ plugin lets you change records using rules and conditions.

## Example usage

As an example, use JSON notation to:

- Rename `Key2` to `RenamedKey`
- Add a key `OtherKey` with value `Value3` if `OtherKey` doesn't yet exist

Example (input):

```text
{
  "Key1"     : "Value1",
  "Key2"     : "Value2"
}
```

Example (output):

```text
{
  "Key1"       : "Value1",
  "RenamedKey" : "Value2",
  "OtherKey"   : "Value3"
}
```

## Configuration parameters

The Modify filter supports multiple parameters.

### Rules

The plugin supports the following rules:

| Operation | Parameter 1 | Parameter 2 | Description |
| :--- | :--- | :--- | :--- |
| `Set` | `STRING:KEY` | `STRING:VALUE` | Add a key/value pair with key `KEY` and value `VALUE`. If `KEY` already exists, this field is overwritten. |
| `Add` | `STRING:KEY` | `STRING:VALUE` | Add a key/value pair with key `KEY` and value `VALUE` if `KEY` doesn't exist. |
| `Remove` | `STRING:KEY` | _none_ | Remove a key/value pair with key `KEY` if it exists. |
| `Remove_wildcard` | `WILDCARD:KEY` | _none_ | Remove all key/value pairs with key matching wildcard `KEY`. |
| `Remove_regex` | `REGEXP:KEY` | _none_ | Remove all key/value pairs with key matching regexp `KEY`. |
| `Rename` | `STRING:KEY` | `STRING:RENAMED_KEY` | Rename a key/value pair with key `KEY` to `RENAMED_KEY` if `KEY` exists and `RENAMED_KEY` doesn't exist. |
| `Hard_rename` | `STRING:KEY` | `STRING:RENAMED_KEY` | Rename a key/value pair with key `KEY` to `RENAMED_KEY` if `KEY` exists. If `RENAMED_KEY` already exists, this field is overwritten. |
| `Copy` | `STRING:KEY` | `STRING:COPIED_KEY` | Copy a key/value pair with key `KEY` to `COPIED_KEY` if `KEY` exists and `COPIED_KEY` doesn't exist. |
| `Hard_copy` | `STRING:KEY` | `STRING:COPIED_KEY` | Copy a key/value pair with key `KEY` to `COPIED_KEY` if `KEY` exists. If `COPIED_KEY` already exists, this field is overwritten. |
| `Move_to_start` | `WILDCARD:KEY` | _none_ | Move key/value pairs with keys matching `KEY` to the start of the message. |
| `Move_to_end` | `WILDCARD:KEY` | _none_ | Move key/value pairs with keys matching `KEY` to the end of the message. |

- Rules are case insensitive, but parameters aren't.
- Any number of rules can be set in a filter instance.
- Rules are applied in the order they appear, with each rule operating on the result of the previous rule.

### Conditions

The plugin supports the following conditions:

| Condition | Parameter | Parameter 2 | Description |
| :--- | :--- | :--- | :--- |
| `Key_exists` | `STRING:KEY` | _none_ | Is `true` if `KEY` exists. |
| `Key_does_not_exist` | `STRING:KEY` | _none_ | Is `true` if `KEY` doesn't exist. |
| `A_key_matches` | `REGEXP:KEY` | _none_ | Is `true` if a key matches regex `KEY`. |
| `No_key_matches` | `REGEXP:KEY` | _none_ | Is `true` if no key matches regex `KEY`. |
| `Key_value_equals` | `STRING:KEY` | `STRING:VALUE` | Is `true` if `KEY` exists and its value is `VALUE`. |
| `Key_value_does_not_equal` | `STRING:KEY` | `STRING:VALUE` | Is `true` if `KEY` exists and its value isn't `VALUE`. |
| `Key_value_matches` | `STRING:KEY` | `REGEXP:VALUE` | Is `true` if key `KEY` exists and its value matches `VALUE`. |
| `Key_value_does_not_match` | `STRING:KEY` | `REGEXP:VALUE` | Is `true` if key `KEY` exists and its value doesn't match `VALUE`. |
| `Matching_keys_have_matching_values` | `REGEXP:KEY` | `REGEXP:VALUE` | Is `true` if all keys matching `KEY` have values that match `VALUE`. |
| `Matching_keys_do_not_have_matching_values` | `REGEXP:KEY` | `REGEXP:VALUE` | Is `true` if all keys matching `KEY` have values that don't match `VALUE`. |

- Conditions are case insensitive, but parameters aren't.
- Any number of conditions can be set.
- Conditions apply to the whole filter instance and all its rules. _Not_ to individual rules.
- All conditions must be `true` for the rules to be applied.
- You can set [Record Accessor](../../administration/configuring-fluent-bit/classic-mode/record-accessor.md) as `STRING:KEY` for nested key.

## Example 1 - add and rename

To start filtering records, you can run the filter from the command line or through
the configuration file. The following invokes the [Memory Usage Input Plugin](../inputs/memory-metrics.md),
which outputs data similar to the following:

```text
[0] memory: [1488543156, {"Mem.total"=>1016044, "Mem.used"=>841388, "Mem.free"=>174656, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[1] memory: [1488543157, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[2] memory: [1488543158, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
[3] memory: [1488543159, {"Mem.total"=>1016044, "Mem.used"=>841420, "Mem.free"=>174624, "Swap.total"=>2064380, "Swap.used"=>139888, "Swap.free"=>1924492}]
```

### Using command line

Using the command line mode requires quotes parse the wildcard properly. The use of a configuration file is recommended.

```shell
$ ./fluent-bit -i mem \
              -p 'tag=mem.local' \
              -F modify \
              -p 'Add=Service1 SOMEVALUE' \
              -p 'Add=Service2 SOMEVALUE3' \
              -p 'Add=Mem.total2 TOTALMEM2' \
              -p 'Rename=Mem.free MEMFREE' \
              -p 'Rename=Mem.used MEMUSED' \
              -p 'Rename=Swap.total SWAPTOTAL' \
              -p 'Add=Mem.total TOTALMEM' \
              -m '*' \
              -o stdout
```

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mem
          tag: mem.local

    filters:
        - name: modify
          match: '*'
          Add:
            - Service1 SOMEVALUE
            - Service3 SOMEVALUE3
            - Mem.total2 TOTALMEM2
            - Mem.total TOTALMEM
          Rename:
            - Mem.free MEMFREE
            - Mem.used MEMUSED
            - Swap.total SWAPTOTAL

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name mem
    Tag  mem.local

[FILTER]
    Name modify
    Match *
    Add Service1 SOMEVALUE
    Add Service3 SOMEVALUE3
    Add Mem.total2 TOTALMEM2
    Rename Mem.free MEMFREE
    Rename Mem.used MEMUSED
    Rename Swap.total SWAPTOTAL
    Add Mem.total TOTALMEM

[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

### Result

The output of both the command line and configuration invocations should be identical and result in the following output:

```text
[2018/04/06 01:35:13] [ info] [engine] started
[0] mem.local: [1522980610.006892802, {"Mem.total"=>4050908, "MEMUSED"=>738100, "MEMFREE"=>3312808, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[1] mem.local: [1522980611.000658288, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[2] mem.local: [1522980612.000307652, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
[3] mem.local: [1522980613.000122671, {"Mem.total"=>4050908, "MEMUSED"=>738068, "MEMFREE"=>3312840, "SWAPTOTAL"=>1046524, "Swap.used"=>0, "Swap.free"=>1046524, "Service1"=>"SOMEVALUE", "Service3"=>"SOMEVALUE3", "Mem.total2"=>"TOTALMEM2"}]
```

## Example 2 - conditionally add and remove

### Use a configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mem
          tag: mem.local
          interval_sec: 1

    filters:
        - name: modify
          match: mem.*
          Condition:
              - Key_Does_Not_Exist cpustats
              - Key_Exists Mem.used
          Set: cpustats UNKNOWN

        - name: modify
          match: mem.*
          Condition: Key_Value_Does_Not_Equal cpustats KNOWN
          Add: sourcetype memstats

        - name: modify
          match: mem.*
          Condition: Key_Value_Equals cpustats UNKNOWN
          Remove_wildcard:
              - Mem
              - Swap
          Add: cpustats_more STILL_UNKNOWN
    
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name mem
    Tag  mem.local
    Interval_Sec 1

[FILTER]
    Name    modify
    Match   mem.*
    Condition Key_Does_Not_Exist cpustats
    Condition Key_Exists Mem.used
    Set cpustats UNKNOWN

[FILTER]
    Name    modify
    Match   mem.*
    Condition Key_Value_Does_Not_Equal cpustats KNOWN
    Add sourcetype memstats

[FILTER]
    Name    modify
    Match   mem.*
    Condition Key_Value_Equals cpustats UNKNOWN
    Remove_wildcard Mem
    Remove_wildcard Swap
    Add cpustats_more STILL_UNKNOWN

[OUTPUT]
    Name           stdout
    Match          *
```

{% endtab %}
{% endtabs %}

### Add and remove result

```text
[2018/06/14 07:37:34] [ info] [engine] started (pid=1493)
[0] mem.local: [1528925855.000223110, {"cpustats"=>"UNKNOWN", "sourcetype"=>"memstats", "cpustats_more"=>"STILL_UNKNOWN"}]
[1] mem.local: [1528925856.000064516, {"cpustats"=>"UNKNOWN", "sourcetype"=>"memstats", "cpustats_more"=>"STILL_UNKNOWN"}]
[2] mem.local: [1528925857.000165965, {"cpustats"=>"UNKNOWN", "sourcetype"=>"memstats", "cpustats_more"=>"STILL_UNKNOWN"}]
[3] mem.local: [1528925858.000152319, {"cpustats"=>"UNKNOWN", "sourcetype"=>"memstats", "cpustats_more"=>"STILL_UNKNOWN"}]
```

## Example 3 - emoji

### Emoji configuration File

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: mem
          tag: mem.local
          interval_sec: 1

    filters:
        - name: modify
          match: mem.*
          Remove_wildcard:
            - Mem
            - Swap
          set:
            - This_plugin_is_on 🔥
            - 🔥 is_hot
            - ❄️ is_cold
            - 💦 is_wet
          copy: 🔥 💦
          rename:  💦 ❄️
          
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name mem
    Tag  mem.local

[FILTER]
    Name modify
    Match *
    Remove_Wildcard Mem
    Remove_Wildcard Swap
    Set This_plugin_is_on 🔥
    Set 🔥 is_hot
    Copy 🔥 💦
    Rename  💦 ❄️
    Set ❄️ is_cold
    Set 💦 is_wet
    
[OUTPUT]
    Name  stdout
    Match *
```

{% endtab %}
{% endtabs %}

### Emoji example result

```text
[2018/06/14 07:46:11] [ info] [engine] started (pid=21875)
[0] mem.local: [1528926372.000197916, {"This_plugin_is_on"=>"🔥", "🔥"=>"is_hot", "❄️"=>"is_cold", "💦"=>"is_wet"}]
[1] mem.local: [1528926373.000107868, {"This_plugin_is_on"=>"🔥", "🔥"=>"is_hot", "❄️"=>"is_cold", "💦"=>"is_wet"}]
[2] mem.local: [1528926374.000181042, {"This_plugin_is_on"=>"🔥", "🔥"=>"is_hot", "❄️"=>"is_cold", "💦"=>"is_wet"}]
[3] mem.local: [1528926375.000090841, {"This_plugin_is_on"=>"🔥", "🔥"=>"is_hot", "❄️"=>"is_cold", "💦"=>"is_wet"}]
[0] mem.local: [1528926376.000610974, {"This_plugin_is_on"=>"🔥", "🔥"=>"is_hot", "❄️"=>"is_cold", "💦"=>"is_wet"}]
```