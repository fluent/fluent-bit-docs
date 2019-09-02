# Lua

Lua Filter allows you to modify the incoming records using custom [Lua](https://www.lua.org/) Scripts.

Due to the necessity to have a flexible filtering mechanism, now is possible to extend Fluent Bit capabilities writing simple filters using Lua programming language. A Lua based filter takes two steps:

* Configure the Filter in the main configuration
* Prepare a Lua script that will be used by the Filter

Content:

* [Configuration Parameters](lua.md#config)
* [Getting Started](lua.md#getting_started)
* [Lua Script Filter API](lua.md#lua_api)

## Configuration Parameters {#config}

The plugin supports the following configuration parameters:

| Key | Description |
| :--- | :--- |
| Script | Path to the Lua script that will be used. |
| Call | Lua function name that will be triggered to do filtering. It's assumed that the function is declared inside the Script defined above. |
| Type_int_key | If these keys are matched, the fields are converted to integer. If more than one key, delimit by space |

## Getting Started {#getting_started}

In order to test the filter, you can run the plugin from the command line or through the configuration file. The following examples uses the [dummy](../input/dummy.md) input plugin for data ingestion, invoke Lua filter using the [test.lua](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua) script and calls the [cb\_print\(\)](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua#L29) function which only print the same information to the standard output:

### Command Line

From the command line you can use the following options:

```bash
$ fluent-bit -i dummy -F lua -p script=test.lua -p call=cb_print -m '*' -o null
```

### Configuration File

In your main configuration file append the following _Input_, _Filter_ & _Output_ sections:

```python
[INPUT]
    Name   dummy

[FILTER]
    Name    lua
    Match   *
    script  test.lua
    call    cb_print

[OUTPUT]
    Name   null
    Match  *
```

## Lua Script Filter API {#lua_script}

The life cycle of a filter have the following steps:

* Upon Tag matching by filter\_lua, it may process or bypass the record.
* If filter\_lua accepts the record, it will invoke the function defined in the _call_ property which basically is the name of a function defined in the Lua _script_.
* Invoke Lua function passing each record in JSON format.
* Upon return, validate return value and take some action \(described above\)

## Callback Prototype

The Lua script can have one or multiple callbacks that can be used by filter\_lua, it prototype is as follows:

```lua
function cb_print(tag, timestamp, record)
   return code, timestamp, record
end
```

#### Function Arguments

| name | description |
| :--- | :--- |
| tag | Name of the tag associated with the incoming record. |
| timestamp | Unix timestamp with nanoseconds associated with the incoming record. The original format is a double \(seconds.nanoseconds\) |
| record | Lua table with the record content |

#### Return Values

Each callback **must** return three values:

| name | data type | description |
| :--- | :--- | :--- |
| code | integer | The code return value represents the result and further action that may follows. If _code_ equals -1, means that filter\_lua must drop the record. If _code_ equals 0 the record will not be modified, otherwise if _code_ equals 1, means the original timestamp or record have been modified so it must be replaced by the returned values from _timestamp_ \(second return value\) and _record_ \(third return value\). |
| timestamp | double | If code equals 1, the original record timestamp will be replaced with this new value. |
| record | table | if code equals 1, the original record information will be replaced with this new value. Note that the format of this value **must** be a valid Lua table. |

### Code Examples

For functional examples of this interface, please refer to the code samples provided in the source code of the project located here:

[https://github.com/fluent/fluent-bit/tree/master/scripts](https://github.com/fluent/fluent-bit/tree/master/scripts)

### Number Type

In Lua, Fluent Bit treats number as double. It means an integer field (e.g. IDs, log levels) will be converted double. To avoid type conversion, **Type_int_key** property is available.