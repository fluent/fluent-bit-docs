# Standard output

<!-- vale FluentBit.Repetition = NO -->

The _standard output_ output plugin prints ingested data to standard output.

<!-- vale FluentBit.Repetition = YES -->

## Configuration parameters

| Key | Description | Default |
| --- | ----------- | ------- |
| `Format` | Specify the data format to be printed. Supported formats are `msgpack`, `json`, `json_lines` and `json_stream`. | `msgpack` |
| `json_date_key`| Specify the name of the time key in the output record. To disable the time key set the value to `false`. | `date` |
| `json_date_format` | Specify the format of the date. Supported formats are `double`, `epoch`, `iso8601` (for example, `2018-05-30T09:39:52.000681Z`) and `java_sql_timestamp` (for example, `2018-05-30 09:39:52.000681`). | `double` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

### Command line

```shell
fluent-bit -i cpu -o stdout -v
```

This example directs the plugin to gather [CPU](https://github.com/fluent/fluent-bit-docs/tree/ddc1cf3d996966b9db39f8784596c8b7132b4d5b/pipeline/input/cpu.md) usage metrics and print them out to the standard output in a human-readable way:

```shell
$ fluent-bit -i cpu -o stdout -p format=msgpack -v

...
[0] cpu.0: [1475898721, {"cpu_p"=>0.500000, "user_p"=>0.250000, "system_p"=>0.250000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>1.000000}]
[1] cpu.0: [1475898722, {"cpu_p"=>0.250000, "user_p"=>0.250000, "system_p"=>0.000000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>0.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[2] cpu.0: [1475898723, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>2.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>1.000000, "cpu1.p_cpu"=>0.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>0.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>0.000000, "cpu2.p_system"=>1.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
[3] cpu.0: [1475898724, {"cpu_p"=>1.000000, "user_p"=>0.750000, "system_p"=>0.250000, "cpu0.p_cpu"=>1.000000, "cpu0.p_user"=>1.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>2.000000, "cpu1.p_user"=>1.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>1.000000, "cpu3.p_user"=>1.000000, "cpu3.p_system"=>0.000000}]
...
```
