# Modify

{% hint style="info" %}
**Supported event types:** `logs`
{% endhint %}

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
| `Hard_Rename` | `STRING:KEY` | `STRING:RENAMED_KEY` | Equivalent to `Hard_rename`. This spelling is also accepted by the plugin. |
| `Copy` | `STRING:KEY` | `STRING:COPIED_KEY` | Copy a key/value pair with key `KEY` to `COPIED_KEY` if `KEY` exists and `COPIED_KEY` doesn't exist. |
| `Hard_copy` | `STRING:KEY` | `STRING:COPIED_KEY` | Copy a key/value pair with key `KEY` to `COPIED_KEY` if `KEY` exists. If `COPIED_KEY` already exists, this field is overwritten. |
| `Move_to_start` | `WILDCARD:KEY` | _none_ | Move key/value pairs with keys matching `KEY` to the start of the message. |
| `Move_To_Start` | `WILDCARD:KEY` | _none_ | Equivalent to `Move_to_start`. This spelling is also accepted by the plugin. |
| `Move_to_end` | `WILDCARD:KEY` | _none_ | Move key/value pairs with keys matching `KEY` to the end of the message. |
| `Move_To_End` | `WILDCARD:KEY` | _none_ | Equivalent to `Move_to_end`. This spelling is also accepted by the plugin. |

- Rules are case-insensitive, but parameters aren't.
- Any number of rules can be set in a filter instance.
- Rules are applied in the order they appear, with each rule operating on the result of the previous rule.
- Parameters of rules and conditions are separated by spaces. To use a key or value that contains spaces, start and end the parameter with double (`"`) or single (`'`) quotes, for example `Set message "hello world"`. Inside a quoted parameter, use a backslash to escape the enclosing quote character or a backslash. In YAML, wrap the entire rule value in YAML single quotes when it starts with a quote, for example `'"my key" value'`, so that YAML keeps the inner quotes. Also wrap the entire rule value in YAML single quotes when it contains a space followed by `#`. YAML treats ` #` as the start of a comment, even when the value starts with an unquoted key, and drops the rest of the line. The same applies to a value that starts with `#`, for example `remove: '#metadata'`. Without the quotes, YAML treats the whole value as a comment and the rule has no parameters. A plain YAML value that contains a colon followed by a space, such as `message "a: b"`, fails to parse, even if the Modify parameter is already quoted. Wrapping the entire value protects it, either in YAML single quotes, for example `'message "a: b"'`, or in YAML double quotes, where you escape inner double quotes with a backslash. Inside YAML single quotes, write a single quote as `''`.

#### Rules with too many parameters

Starting with v5.2, Fluent Bit rejects a rule with more parameters than its operation accepts and doesn't start. Earlier releases might accept such a rule and handle the extra parameters differently, so quote any key or value that contains spaces regardless of version. Fluent Bit logs one of these messages:

- For a rule with three space-separated parameters, such as `Set message hello world`: `Invalid config for <rule>: expected one or two arguments; quote values containing spaces`.
- For a rule with four or more parameters: `Invalid config for <rule>`.
- For a one-parameter rule, such as `Remove`, given two parameters: `Invalid operation <rule> : <parameters> in configuration`.

In these messages, `<rule>` is the rule name as Fluent Bit stores it, for example `set` in classic configuration files. `<parameters>` is the rule value after YAML parsing, so search for the value as Fluent Bit logs it and not for the original YAML text. During a [hot reload](../../administration/hot-reload.md), the previous pipeline has already stopped when the rule is checked, so the reload is aborted and Fluent Bit exits. The `--dry-run` option doesn't detect these errors. To avoid them, quote the individual key or value parameter that contains spaces, for example `Set message "hello world"`, so the rule keeps its required parameter count.

### Conditions

The plugin supports the following conditions:

| Condition | Parameter | Parameter 2 | Description |
| :--- | :--- | :--- | :--- |
| `Key_exists` | `STRING:KEY` | _none_ | Is `true` if `KEY` exists. |
| `Key_does_not_exist` | `STRING:KEY` | _none_ | Is `true` if `KEY` doesn't exist. |
| `A_key_matches` | `REGEXP:KEY` | _none_ | Is `true` if a key matches regular expression `KEY`. |
| `No_key_matches` | `REGEXP:KEY` | _none_ | Is `true` if no key matches regular expression `KEY`. |
| `Key_value_equals` | `STRING:KEY` | `STRING:VALUE` | Is `true` if `KEY` exists and its value is `VALUE`. |
| `Key_value_does_not_equal` | `STRING:KEY` | `STRING:VALUE` | Is `true` if `KEY` exists and its value isn't `VALUE`. |
| `Key_value_matches` | `STRING:KEY` | `REGEXP:VALUE` | Is `true` if key `KEY` exists and its value matches `VALUE`. |
| `Key_value_does_not_match` | `STRING:KEY` | `REGEXP:VALUE` | Is `true` if key `KEY` exists and its value doesn't match `VALUE`. |
| `Matching_keys_have_matching_values` | `REGEXP:KEY` | `REGEXP:VALUE` | Is `true` if all keys matching `KEY` have values that match `VALUE`. |
| `Matching_keys_do_not_have_matching_values` | `REGEXP:KEY` | `REGEXP:VALUE` | Is `true` if all keys matching `KEY` have values that don't match `VALUE`. |

- Conditions are case-insensitive, but parameters aren't.
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
fluent-bit -i mem \
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

### Emoji configuration file

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
