# Standard Output

The **stdout** output plugin allows to print to the standard output the data received through the _input_ plugin. Their usage is very simple as follows:

## Configuration Parameters

| Key                | Description                                                                                                                                                                        | default |
|:-------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| Format             | Specify the data format to be printed. Supported formats are _msgpack_, _json_, _json\_lines_ and _json\_stream_.                                                                  | msgpack |
| json\_date\_key    | Specify the name of the time key in the output record. To disable the time key just set the value to `false`.                                                                      | date    |
| json\_date\_format | Specify the format of the date. Supported formats are _double_, _epoch_, _iso8601_ (eg: _2018-05-30T09:39:52.000681Z_) and _java_sql_timestamp_ (eg: _2018-05-30 09:39:52.000681_) | double  |
| workers            | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output.                                                               | `1`     |

### Command Line

```shell
fluent-bit -i cpu -o stdout -v
```

We have specified to gather [CPU](https://github.com/fluent/fluent-bit-docs/tree/ddc1cf3d996966b9db39f8784596c8b7132b4d5b/pipeline/input/cpu.md) usage metrics and print them out to the standard output in a human-readable way:

```shell
$ fluent-bit -i cpu -o stdout -p format=msgpack -v

...
[0] cpu.0: [1475898721, {"cpu_p"=>0.500000, "user_p"=>0.250000, "system_p"=>0.250000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>1.000000}]
[1] cpu.0: [1475898722, {"cpu_p"=>0.250000, "user_p"=>0.250000, "system_p"=>0.000000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[2] cpu.0: [1475898723, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>2.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>1.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>1.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[3] cpu.0: [1475898724, {"cpu_p"=>1.000000, "user_p"=>0.750000, "system_p"=>0.250000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>2.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
...
```

No more, no less, it just works.