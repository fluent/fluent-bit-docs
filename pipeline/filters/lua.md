# Lua

The **Lua** filter allows you to modify the incoming records (even split one record into multiple records) using custom [Lua](https://www.lua.org/) scripts.

Due to the necessity to have a flexible filtering mechanism, it is now possible to extend Fluent Bit capabilities by writing custom filters using Lua programming language. A Lua-based filter takes two steps:

1. Configure the Filter in the main configuration
2. Prepare a Lua script that will be used by the Filter

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| script | Path to the Lua script that will be used. This can be a relative path against the main configuration file. |
| call | Lua function name that will be triggered to do filtering. It's assumed that the function is declared inside the **script** parameter defined above. |
| type\_int\_key | If these keys are matched, the fields are converted to integer. If more than one key, delimit by space. Note that starting from Fluent Bit v1.6 integer data types are preserved and not converted to double as in previous versions. |
| type\_array\_key| If these keys are matched, the fields are handled as array. If more than one key, delimit by space. It is useful the array can be empty. |
| protected\_mode | If enabled, Lua script will be executed in protected mode. It prevents Fluent Bit from crashing when invalid Lua script is executed or the triggered Lua function throws exceptions. Default is true. |
| time\_as\_table | By default when the Lua script is invoked, the record timestamp is passed as a *floating number* which might lead to precision loss when it is converted back. If you desire timestamp precision, enabling this option will pass the timestamp as a Lua table with keys `sec` for seconds since epoch and `nsec` for nanoseconds. |

## Getting Started <a id="getting_started"></a>

In order to test the filter, you can run the plugin from the command line or through the configuration file. The following examples use the [dummy](../inputs/dummy.md) input plugin for data ingestion, invoke Lua filter using the [test.lua](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua) script and call the [cb\_print\(\)](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua#L29) function which only prints the same information to the standard output:

### Command Line

From the command line you can use the following options:

```bash
$ fluent-bit -i dummy -F lua -p script=test.lua -p call=cb_print -m '*' -o null
```

### Configuration File

In your main configuration file append the following _Input_, _Filter_ & _Output_ sections:

```python
[INPUT]
    Name    dummy

[FILTER]
    Name    lua
    Match   *
    script  test.lua
    call    cb_print

[OUTPUT]
    Name    null
    Match   *
```

## Lua Script Filter API <a id="lua_script"></a>

The life cycle of a filter have the following steps:

1. Upon Tag matching by this filter, it may process or bypass the record.
2. If tag matched, it will accept the record and invoke the function defined in the `call` property which basically is the name of a function defined in the Lua `script`.
3. Invoke Lua function and pass each record in JSON format.
4. Upon return, validate return value and continue the pipeline.

## Callback Prototype

The Lua script can have one or multiple callbacks that can be used by this filter. The function prototype is as follows:

```lua
function cb_print(tag, timestamp, record)
    ...
    return code, timestamp, record
end
```

#### Function Arguments

| name | description |
| :--- | :--- |
| tag | Name of the tag associated with the incoming record. |
| timestamp | Unix timestamp with nanoseconds associated with the incoming record. The original format is a double (seconds.nanoseconds) |
| record | Lua table with the record content |

#### Return Values

Each callback **must** return three values:

| name | data type | description |
| :--- | :--- | :--- |
| code | integer | The code return value represents the result and further action that may follows. If _code_ equals -1, means that the record will be dropped. If _code_ equals 0, the record will not be modified, otherwise if _code_ equals 1, means the original timestamp and record have been modified so it must be replaced by the returned values from _timestamp_ (second return value) and _record_ (third return value). If _code_ equals 2, means the original timestamp is not modified and the record has been modified so it must be replaced by the returned values from _record_ (third return value). The _code_ 2 is supported from v1.4.3. |
| timestamp | double | If code equals 1, the original record timestamp will be replaced with this new value. |
| record | table | If code equals 1, the original record information will be replaced with this new value. Note that the _record_ value **must** be a valid Lua table. This value can be an array of tables (i.e., array of objects in JSON format), and in that case the input record is effectively split into multiple records. (see below for more details) |

### Code Examples

For functional examples of this interface, please refer to the code samples provided in the source code of the project located here:

[https://github.com/fluent/fluent-bit/tree/master/scripts](https://github.com/fluent/fluent-bit/tree/master/scripts)

### Number Type

+Lua treats number as double. It means an integer field (e.g. IDs, log levels) will be converted double. To avoid type conversion, The `type_int_key` property is available.

### Protected Mode

Fluent Bit supports protected mode to prevent crash when executes invalid Lua script. See also [Error Handling in Application Code](https://www.lua.org/pil/24.3.1.html).

### Record Split

The Lua callback function can return an array of tables (i.e., array of records) in its third _record_ return value. With this feature, the Lua filter can split one input record into multiple records according to custom logic.

For example:

#### Lua script

```lua
function cb_split(tag, timestamp, record)
    if record["x"] ~= nil then
        return 2, timestamp, record["x"]
    else
        return 2, timestamp, record
    end
end
```

#### Configuration

```python
[Input]
    Name    stdin

[Filter]
    Name    lua
    Match   *
    script  test.lua
    call    cb_split

[Output]
    Name    stdout
    Match   *
```

#### Input

```
{"x": [ {"a1":"aa", "z1":"zz"}, {"b1":"bb", "x1":"xx"}, {"c1":"cc"} ]}
{"x": [ {"a2":"aa", "z2":"zz"}, {"b2":"bb", "x2":"xx"}, {"c2":"cc"} ]}
{"a3":"aa", "z3":"zz", "b3":"bb", "x3":"xx", "c3":"cc"}
```

#### Output

```
[0] stdin.0: [1538435928.310583591, {"a1"=>"aa", "z1"=>"zz"}]
[1] stdin.0: [1538435928.310583591, {"x1"=>"xx", "b1"=>"bb"}]
[2] stdin.0: [1538435928.310583591, {"c1"=>"cc"}]
[3] stdin.0: [1538435928.310588359, {"z2"=>"zz", "a2"=>"aa"}]
[4] stdin.0: [1538435928.310588359, {"b2"=>"bb", "x2"=>"xx"}]
[5] stdin.0: [1538435928.310588359, {"c2"=>"cc"}]
[6] stdin.0: [1538435928.310589790, {"z3"=>"zz", "x3"=>"xx", "c3"=>"cc", "a3"=>"aa", "b3"=>"bb"}]
```

See also [Fluent Bit: PR 811](https://github.com/fluent/fluent-bit/pull/811).
