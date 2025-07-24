# Troubleshooting

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=759ddb3d-b363-4ee6-91fa-21025259767a" />

- [Tap: generate events or records](#tap)
- [Dump internals signal](#dump-internals-and-signal)

## Tap

Tap can be used to generate events or records detailing what messages
pass through Fluent Bit, at what time and what filters affect them.

### Tap example

Ensure that the container image supports Fluent Bit Tap (available in Fluent Bit 2.0+):

```shell
docker run --rm -ti fluent/fluent-bit:latest --help | grep trace
  -Z, --enable-chunk-traceenable chunk tracing, it can be activated either through the http api or the command line
  --trace-input           input to start tracing on startup.
  --trace-output          output to use for tracing on startup.
  --trace-output-property set a property for output tracing on startup.
  --trace                 setup a trace pipeline on startup. Uses a single line, ie: "input=dummy.0 output=stdout output.format='json'"
```

If the `--enable-chunk-trace` option is present, your Fluent Bit version supports
Fluent Bit Tap, but it's disabled by default. Use this option to enable it.

You can start Fluent Bit with tracing activated from the beginning by using the
`trace-input` and `trace-output` properties:

```bash
fluent-bit -Z -i dummy -o stdout -f 1 --trace-input=dummy.0 --trace-output=stdout
Fluent Bit v2.1.8
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2023/07/21 16:27:01] [ info] [fluent bit] version=2.1.8, commit=824ba3dd08, pid=622937
[2023/07/21 16:27:01] [ info] [storage] ver=1.4.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/07/21 16:27:01] [ info] [cmetrics] version=0.6.3
[2023/07/21 16:27:01] [ info] [ctraces ] version=0.3.1
[2023/07/21 16:27:01] [ info] [input:dummy:dummy.0] initializing
[2023/07/21 16:27:01] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2023/07/21 16:27:01] [ info] [sp] stream processor started
[2023/07/21 16:27:01] [ info] [output:stdout:stdout.0] worker #0 started
[2023/07/21 16:27:01] [ info] [fluent bit] version=2.1.8, commit=824ba3dd08, pid=622937
[2023/07/21 16:27:01] [ info] [storage] ver=1.4.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/07/21 16:27:01] [ info] [cmetrics] version=0.6.3
[2023/07/21 16:27:01] [ info] [ctraces ] version=0.3.1
[2023/07/21 16:27:01] [ info] [input:emitter:trace-emitter] initializing
[2023/07/21 16:27:01] [ info] [input:emitter:trace-emitter] storage_strategy='memory' (memory only)
[2023/07/21 16:27:01] [ info] [sp] stream processor started
[2023/07/21 16:27:01] [ info] [output:stdout:stdout.0] worker #0 started
.[0] dummy.0: [[1689971222.068537501, {}], {"message"=>"dummy"}]
[0] dummy.0: [[1689971223.068556121, {}], {"message"=>"dummy"}]
[0] trace: [[1689971222.068677045, {}], {"type"=>1, "trace_id"=>"0", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971222, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971222, "end_time"=>1689971222}]
[1] trace: [[1689971222.068735577, {}], {"type"=>3, "trace_id"=>"0", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971222, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971222, "end_time"=>1689971222}]
[0] dummy.0: [[1689971224.068586317, {}], {"message"=>"dummy"}]
[0] trace: [[1689971223.068626923, {}], {"type"=>1, "trace_id"=>"1", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971223, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971223, "end_time"=>1689971223}]
[1] trace: [[1689971223.068675735, {}], {"type"=>3, "trace_id"=>"1", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971223, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971223, "end_time"=>1689971223}]
[2] trace: [[1689971224.068689341, {}], {"type"=>1, "trace_id"=>"2", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971224, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971224, "end_time"=>1689971224}]
[3] trace: [[1689971224.068747182, {}], {"type"=>3, "trace_id"=>"2", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971224, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971224, "end_time"=>1689971224}]
^C[2023/07/21 16:27:05] [engine] caught signal (SIGINT)
[2023/07/21 16:27:05] [ warn] [engine] service will shutdown in max 5 seconds
[2023/07/21 16:27:05] [ info] [input] pausing dummy.0
[0] dummy.0: [[1689971225.068568875, {}], {"message"=>"dummy"}]
[2023/07/21 16:27:06] [ info] [engine] service has stopped (0 pending tasks)
[2023/07/21 16:27:06] [ info] [input] pausing dummy.0
[2023/07/21 16:27:06] [ warn] [engine] service will shutdown in max 1 seconds
[0] trace: [[1689971225.068654038, {}], {"type"=>1, "trace_id"=>"3", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971225, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971225, "end_time"=>1689971225}]
[1] trace: [[1689971225.068695829, {}], {"type"=>3, "trace_id"=>"3", "plugin_instance"=>"dummy.0", "records"=>[{"timestamp"=>1689971225, "record"=>{"message"=>"dummy"}}], "start_time"=>1689971225, "end_time"=>1689971225}]
[2023/07/21 16:27:07] [ info] [engine] service has stopped (0 pending tasks)
[2023/07/21 16:27:07] [ info] [output:stdout:stdout.0] thread worker #0 stopping...
[2023/07/21 16:27:07] [ info] [output:stdout:stdout.0] thread worker #0 stopped
[2023/07/21 16:27:07] [ info] [output:stdout:stdout.0] thread worker #0 stopping...
[2023/07/21 16:27:07] [ info] [output:stdout:stdout.0] thread worker #0 stopped
```

The following warning indicates the `-Z` or `--enable-chunk-tracing` option is missing:

```text
[2023/07/21 16:26:42] [ warn] [chunk trace] enable chunk tracing via the configuration or  command line to be able to activate tracing.
```

Set properties for the output using the `--trace-output-property` option:

```bash
$ fluent-bit -Z -i dummy -o stdout -f 1 --trace-input=dummy.0 --trace-output=stdout --trace-output-property=format=json_lines
Fluent Bit v2.1.8
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2023/07/21 16:28:59] [ info] [fluent bit] version=2.1.8, commit=824ba3dd08, pid=623170
[2023/07/21 16:28:59] [ info] [storage] ver=1.4.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/07/21 16:28:59] [ info] [cmetrics] version=0.6.3
[2023/07/21 16:28:59] [ info] [ctraces ] version=0.3.1
[2023/07/21 16:28:59] [ info] [input:dummy:dummy.0] initializing
[2023/07/21 16:28:59] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2023/07/21 16:28:59] [ info] [sp] stream processor started
[2023/07/21 16:28:59] [ info] [output:stdout:stdout.0] worker #0 started
[2023/07/21 16:28:59] [ info] [fluent bit] version=2.1.8, commit=824ba3dd08, pid=623170
[2023/07/21 16:28:59] [ info] [storage] ver=1.4.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/07/21 16:28:59] [ info] [cmetrics] version=0.6.3
[2023/07/21 16:28:59] [ info] [ctraces ] version=0.3.1
[2023/07/21 16:28:59] [ info] [input:emitter:trace-emitter] initializing
[2023/07/21 16:28:59] [ info] [input:emitter:trace-emitter] storage_strategy='memory' (memory only)
[2023/07/21 16:29:00] [ info] [sp] stream processor started
[2023/07/21 16:29:00] [ info] [output:stdout:stdout.0] worker #0 started
.[0] dummy.0: [[1689971340.068565891, {}], {"message"=>"dummy"}]
[0] dummy.0: [[1689971341.068632477, {}], {"message"=>"dummy"}]
{"date":1689971340.068745,"type":1,"trace_id":"0","plugin_instance":"dummy.0","records":[{"timestamp":1689971340,"record":{"message":"dummy"}}],"start_time":1689971340,"end_time":1689971340}
{"date":1689971340.068825,"type":3,"trace_id":"0","plugin_instance":"dummy.0","records":[{"timestamp":1689971340,"record":{"message":"dummy"}}],"start_time":1689971340,"end_time":1689971340}
[0] dummy.0: [[1689971342.068613646, {}], {"message"=>"dummy"}]
```

With that option set, the stdout plugin emits traces in `json_lines` format:

```json
{"date":1689971340.068745,"type":1,"trace_id":"0","plugin_instance":"dummy.0","records":[{"timestamp":1689971340,"record":{"message":"dummy"}}],"start_time":1689971340,"end_time":1689971340}
```

All three options can also be defined using the more flexible `--trace` option:

```bash
fluent-bit -Z -i dummy -o stdout -f 1 --trace="input=dummy.0 output=stdout output.format=json_lines"
```

This example defines the Tap pipeline using this configuration: `input=dummy.0 output=stdout output.format=json_lines` which defines the following:

- `input`: `dummy.0` listens to the tag or alias `dummy.0`.
- `output`: `stdout` outputs to a stdout plugin.
- `output.format`: `json_lines` sets the stdout format to `json_lines`.

Tap support can also be activated and deactivated using the embedded web server:

```shell
$ docker run --rm -ti -p 2020:2020 fluent/fluent-bit:latest -Z -H -i dummy -p alias=input_dummy -o stdout -f 1
Fluent Bit v2.0.0
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2022/10/21 10:03:16] [ info] [fluent bit] version=2.0.0, commit=3000f699f2, pid=1
[2022/10/21 10:03:16] [ info] [output:stdout:stdout.0] worker #0 started
[2022/10/21 10:03:16] [ info] [storage] ver=1.3.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2022/10/21 10:03:16] [ info] [cmetrics] version=0.5.2
[2022/10/21 10:03:16] [ info] [input:dummy:input_dummy] initializing
[2022/10/21 10:03:16] [ info] [input:dummy:input_dummy] storage_strategy='memory' (memory only)
[2022/10/21 10:03:16] [ info] [http_server] listen iface=0.0.0.0 tcp_port=2020
[2022/10/21 10:03:16] [ info] [sp] stream processor started
[0] dummy.0: [1666346597.203307010, {"message"=>"dummy"}]
[0] dummy.0: [1666346598.204103793, {"message"=>"dummy"}]
...

```

In another terminal, activate Tap by either using the instance id of the input
(`dummy.0`) or its alias. The alias is more predictable, and is used here:

```shell
$ curl 127.0.0.1:2020/api/v1/trace/input_dummy
{"status":"ok"}
```

This response means Tap is active. The terminal with Fluent Bit running should now
look like this:

```shell
[0] dummy.0: [1666346615.203253156, {"message"=>"dummy"}]
[2022/10/21 10:03:36] [ info] [fluent bit] version=2.0.0, commit=3000f699f2, pid=1
[2022/10/21 10:03:36] [ info] [storage] ver=1.3.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2022/10/21 10:03:36] [ info] [cmetrics] version=0.5.2
[2022/10/21 10:03:36] [ info] [input:emitter:trace-emitter] initializing
[2022/10/21 10:03:36] [ info] [input:emitter:trace-emitter] storage_strategy='memory' (memory only)
[2022/10/21 10:03:36] [ info] [sp] stream processor started
[2022/10/21 10:03:36] [ info] [output:stdout:stdout.0] worker #0 started
[0] dummy.0: [1666346616.203551736, {"message"=>"dummy"}]
[0] trace: [1666346617.205221952, {"type"=>1, "trace_id"=>"trace.0", "plugin_instance"=>"dummy.0", "plugin_alias"=>"input_dummy", "records"=>[{"timestamp"=>1666346617, "record"=>{"message"=>"dummy"}}], "start_time"=>1666346617, "end_time"=>1666346617}]
[0] dummy.0: [1666346617.205131790, {"message"=>"dummy"}]
[0] trace: [1666346617.205419358, {"type"=>3, "trace_id"=>"trace.0", "plugin_instance"=>"dummy.0", "plugin_alias"=>"input_dummy", "records"=>[{"timestamp"=>1666346617, "record"=>{"message"=>"dummy"}}], "start_time"=>1666346617, "end_time"=>1666346617}]
[0] trace: [1666346618.204110867, {"type"=>1, "trace_id"=>"trace.1", "plugin_instance"=>"dummy.0", "plugin_alias"=>"input_dummy", "records"=>[{"timestamp"=>1666346618, "record"=>{[0] dummy.0: [1666346618.204049246, {"message"=>"dummy"}]
"message"=>"dummy"}}], "start_time"=>1666346618, "end_time"=>1666346618}]
[0] trace: [1666346618.204198654, {"type"=>3, "trace_id"=>"trace.1", "plugin_instance"=>"dummy.0", "plugin_alias"=>"input_dummy", "records"=>[{"timestamp"=>1666346618, "record"=>{"message"=>"dummy"}}], "start_time"=>1666346618, "end_time"=>1666346618}]

```

All the records that display are those emitted by the activities of the dummy plugin.

### Complex Tap example

This example takes the same steps but demonstrates how the mechanism works with more
complicated configurations.

This example follows a single input, out of many, and which passes through several
filters.

```shell
$ docker run --rm -ti -p 2020:2020 \
   fluent/fluent-bit:latest \
   -Z -H \
      -i dummy -p alias=dummy_0 -p \
         dummy='{"dummy": "dummy_0", "key_name": "foo", "key_cnt": "1"}' \
      -i dummy -p alias=dummy_1 -p dummy='{"dummy": "dummy_1"}' \
      -i dummy -p alias=dummy_2 -p dummy='{"dummy": "dummy_2"}' \
      -F record_modifier -m 'dummy.0' -p record="powered_by fluent" \
      -F record_modifier -m 'dummy.1' -p record="powered_by fluent-bit" \
      -F nest -m 'dummy.0' \
         -p operation=nest -p wildcard='key_*' -p nest_under=data \
      -o null -m '*' -f 1
```

To ensure the window isn't cluttered by the records generated by the input plugins,
send all of it to `null`.

Activate with the following `curl` command:

```shell
$ curl 127.0.0.1:2020/api/v1/trace/dummy_0
{"status":"ok"}
```

You should start seeing output similar to the following:

```shell
[0] trace: [1666349359.325597543, {"type"=>1, "trace_id"=>"trace.0", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349359, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1"}}], "start_time"=>1666349359, "end_time"=>1666349359}]
[0] trace: [1666349359.325723747, {"type"=>2, "start_time"=>1666349359, "end_time"=>1666349359, "trace_id"=>"trace.0", "plugin_instance"=>"record_modifier.0", "records"=>[{"timestamp"=>1666349359, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1", "powered_by"=>"fluent"}}]}]
[0] trace: [1666349359.325783954, {"type"=>2, "start_time"=>1666349359, "end_time"=>1666349359, "trace_id"=>"trace.0", "plugin_instance"=>"nest.2", "records"=>[{"timestamp"=>1666349359, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}]}]
[0] trace: [1666349359.325913783, {"type"=>3, "trace_id"=>"trace.0", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349359, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}], "start_time"=>1666349359, "end_time"=>1666349359}]
[0] trace: [1666349360.323826619, {"type"=>1, "trace_id"=>"trace.1", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349360, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1"}}], "start_time"=>1666349360, "end_time"=>1666349360}]
[0] trace: [1666349360.323859618, {"type"=>2, "start_time"=>1666349360, "end_time"=>1666349360, "trace_id"=>"trace.1", "plugin_instance"=>"record_modifier.0", "records"=>[{"timestamp"=>1666349360, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1", "powered_by"=>"fluent"}}]}]
[0] trace: [1666349360.323900784, {"type"=>2, "start_time"=>1666349360, "end_time"=>1666349360, "trace_id"=>"trace.1", "plugin_instance"=>"nest.2", "records"=>[{"timestamp"=>1666349360, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}]}]
[0] trace: [1666349360.323926366, {"type"=>3, "trace_id"=>"trace.1", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349360, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}], "start_time"=>1666349360, "end_time"=>1666349360}]
[0] trace: [1666349361.324223752, {"type"=>1, "trace_id"=>"trace.2", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349361, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1"}}], "start_time"=>1666349361, "end_time"=>1666349361}]
[0] trace: [1666349361.324263959, {"type"=>2, "start_time"=>1666349361, "end_time"=>1666349361, "trace_id"=>"trace.2", "plugin_instance"=>"record_modifier.0", "records"=>[{"timestamp"=>1666349361, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1", "powered_by"=>"fluent"}}]}]
[0] trace: [1666349361.324283250, {"type"=>2, "start_time"=>1666349361, "end_time"=>1666349361, "trace_id"=>"trace.2", "plugin_instance"=>"nest.2", "records"=>[{"timestamp"=>1666349361, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}]}]
[0] trace: [1666349361.324294291, {"type"=>3, "trace_id"=>"trace.2", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349361, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}], "start_time"=>1666349361, "end_time"=>1666349361}]
^C[2022/10/21 10:49:23] [engine] caught signal (SIGINT)
[2022/10/21 10:49:23] [ warn] [engine] service will shutdown in max 5 seconds
[2022/10/21 10:49:23] [ info] [input] pausing dummy_0
[2022/10/21 10:49:23] [ info] [input] pausing dummy_1
[2022/10/21 10:49:23] [ info] [input] pausing dummy_2
[2022/10/21 10:49:23] [ info] [engine] service has stopped (0 pending tasks)
[2022/10/21 10:49:23] [ info] [input] pausing dummy_0
[2022/10/21 10:49:23] [ info] [input] pausing dummy_1
[2022/10/21 10:49:23] [ info] [input] pausing dummy_2
[0] trace: [1666349362.323272011, {"type"=>1, "trace_id"=>"trace.3", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349362, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1"}}], "start_time"=>1666349362, "end_time"=>1666349362}]
[0] trace: [1666349362.323306843, {"type"=>2, "start_time"=>1666349362, "end_time"=>1666349362, "trace_id"=>"trace.3", "plugin_instance"=>"record_modifier.0", "records"=>[{"timestamp"=>1666349362, "record"=>{"dummy"=>"dummy_0", "key_name"=>"foo", "key_cnt"=>"1", "powered_by"=>"fluent"}}]}]
[0] trace: [1666349362.323323884, {"type"=>2, "start_time"=>1666349362, "end_time"=>1666349362, "trace_id"=>"trace.3", "plugin_instance"=>"nest.2", "records"=>[{"timestamp"=>1666349362, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}]}]
[0] trace: [1666349362.323334509, {"type"=>3, "trace_id"=>"trace.3", "plugin_instance"=>"dummy.0", "plugin_alias"=>"dummy_0", "records"=>[{"timestamp"=>1666349362, "record"=>{"dummy"=>"dummy_0", "powered_by"=>"fluent", "data"=>{"key_name"=>"foo", "key_cnt"=>"1"}}}], "start_time"=>1666349362, "end_time"=>1666349362}]
[2022/10/21 10:49:24] [ warn] [engine] service will shutdown in max 1 seconds
[2022/10/21 10:49:25] [ info] [engine] service has stopped (0 pending tasks)
[2022/10/21 10:49:25] [ info] [output:stdout:stdout.0] thread worker #0 stopping...
[2022/10/21 10:49:25] [ info] [output:stdout:stdout.0] thread worker #0 stopped
[2022/10/21 10:49:25] [ info] [output:null:null.0] thread worker #0 stopping...
[2022/10/21 10:49:25] [ info] [output:null:null.0] thread worker #0 stopped
```

### Parameters for the output in Tap

When activating Tap, any plugin parameter can be given. These parameters can be used
to modify the output format, the name of the time key, the format of the date, and
other details.

The following example uses the parameter `"format": "json"` to demonstrate how
to show `stdout` in JSON format.

First, run Fluent Bit enabling Tap:

```shell
$ docker run --rm -ti -p 2020:2020 fluent/fluent-bit:latest -Z -H -i dummy -p alias=input_dummy -o stdout -f 1
Fluent Bit v2.0.8
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2023/01/27 07:44:25] [ info] [fluent bit] version=2.0.8, commit=9444fdc5ee, pid=1
[2023/01/27 07:44:25] [ info] [storage] ver=1.4.0, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2023/01/27 07:44:25] [ info] [cmetrics] version=0.5.8
[2023/01/27 07:44:25] [ info] [ctraces ] version=0.2.7
[2023/01/27 07:44:25] [ info] [input:dummy:input_dummy] initializing
[2023/01/27 07:44:25] [ info] [input:dummy:input_dummy] storage_strategy='memory' (memory only)
[2023/01/27 07:44:25] [ info] [output:stdout:stdout.0] worker #0 started
[2023/01/27 07:44:25] [ info] [http_server] listen iface=0.0.0.0 tcp_port=2020
[2023/01/27 07:44:25] [ info] [sp] stream processor started
[0] dummy.0: [1674805465.976012761, {"message"=>"dummy"}]
[0] dummy.0: [1674805466.973669512, {"message"=>"dummy"}]
...
```

In another terminal, activate Tap including the output (`stdout`), and the
parameters wanted (`"format": "json"`):

```shell
$ curl 127.0.0.1:2020/api/v1/trace/input_dummy -d '{"output":"stdout", "params": {"format": "json"}}'
{"status":"ok"}
```

In the first terminal, you should see the output similar to the following:

```shell
[0] dummy.0: [1674805635.972373840, {"message"=>"dummy"}]
[{"date":1674805634.974457,"type":1,"trace_id":"0","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805634,"record":{"message":"dummy"}}],"start_time":1674805634,"end_time":1674805634},{"date":1674805634.974605,"type":3,"trace_id":"0","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805634,"record":{"message":"dummy"}}],"start_time":1674805634,"end_time":1674805634},{"date":1674805635.972398,"type":1,"trace_id":"1","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805635,"record":{"message":"dummy"}}],"start_time":1674805635,"end_time":1674805635},{"date":1674805635.972413,"type":3,"trace_id":"1","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805635,"record":{"message":"dummy"}}],"start_time":1674805635,"end_time":1674805635}]
[0] dummy.0: [1674805636.973970215, {"message"=>"dummy"}]
[{"date":1674805636.974008,"type":1,"trace_id":"2","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805636,"record":{"message":"dummy"}}],"start_time":1674805636,"end_time":1674805636},{"date":1674805636.974034,"type":3,"trace_id":"2","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805636,"record":{"message":"dummy"}}],"start_time":1674805636,"end_time":1674805636}]
```

This parameter shows stdout in JSON format.

See [output plugins](https://docs.fluentbit.io/manual/pipeline/outputs) for
additional information.

### Analyze a single Tap record

This filter record is an example to explain the details of a Tap record:

```json
{
   "type": 2,
   "start_time": 1666349231,
   "end_time": 1666349231,
   "trace_id": "trace.1",
   "plugin_instance": "nest.2",
   "records": [{
      "timestamp": 1666349231,
      "record": {
         "dummy": "dummy_0",
         "powered_by": "fluent",
         "data": {
            "key_name": "foo",
            "key_cnt": "1"
         }
      }
   }]
}
```

- `type`: Defines the stage the event is generated:
  - `1`: Input record. This is the unadulterated input record.
  - `2`: Filtered record. This is a record after it was filtered. One record is
    generated per filter.
  - `3`: Pre-output record. This is the record right before it's sent for output.

  This example is a record generated by the manipulation of a record by a filter so
  it has the type `2`.
- `start_time` and `end_time`: Records the start and end of an event, and is
  different for each event type:
  - type 1: When the input is received, both the start and end time.
  - type 2: The time when filtering is matched until it has finished processing.
  - type 3: The time when the input is received and when it's finally slated for output.
- `trace_id`: A string composed of a prefix and a number which is incremented with
  each record received by the input during the Tap session.
- `plugin_instance`: The plugin instance name as generated by Fluent Bit at runtime.
- `plugin_alias`: If an alias is set this field will contain the alias set for a plugin.
- `records`: An array of all the records being sent. Fluent Bit handles records in
  chunks of multiple records and chunks are indivisible, the same is done in the Tap
  output. Each record consists of its timestamp followed by the actual data which is
  a composite type of keys and values.

## Dump Internals and signal

When the service is running, you can export [metrics](monitoring.md) to see the
overall status of the data flow of the service. There are other use cases where
you might need to know the current status of the service internals, like the current
status of the internal buffers. Dump Internals can help provide this information.

Fluent Bit v1.4 introduced the Dump Internals feature, which can be triggered from
the command line triggering the `CONT` Unix signal.

{% hint style="info" %}
This feature is only available on Linux and BSD operating systems.
{% endhint %}

### Usage

Run the following `kill` command to signal Fluent Bit:

```shell
kill -CONT `pidof fluent-bit`
```

The command `pidof` aims to identify the Process ID of Fluent Bit.

Fluent Bit will dump the following information to the standard output interface
(`stdout`):

```text
[engine] caught signal (SIGCONT)
[2020/03/23 17:39:02] Fluent Bit Dump

===== Input =====
syslog_debug (syslog)
│
├─ status
│  └─ overlimit     : no
│     ├─ mem size   : 60.8M (63752145 bytes)
│     └─ mem limit  : 61.0M (64000000 bytes)
│
├─ tasks
│  ├─ total tasks   : 92
│  ├─ new           : 0
│  ├─ running       : 92
│  └─ size          : 171.1M (179391504 bytes)
│
└─ chunks
   └─ total chunks  : 92
      ├─ up chunks  : 35
      ├─ down chunks: 57
      └─ busy chunks: 92
         ├─ size    : 60.8M (63752145 bytes)
         └─ size err: 0

===== Storage Layer =====
total chunks     : 92
├─ mem chunks    : 0
└─ fs chunks     : 92
   ├─ up         : 35
   └─ down       : 57
```

### Input plugins

The input plugins dump provides insights for every input instance configured.

### Status

Overall ingestion status of the plugin.

| Entry | Sub-entry | Description |
| :--- | :--- | :--- |
| `overlimit` |  | If the plugin has been configured with [`Mem_Buf_Limit`](backpressure.md), this entry will report if the plugin is over the limit or not at the moment of the dump. Over the limit prints `yes`, otherwise `no`. |
|  | `mem_size` | Current memory size in use by the input plugin in-memory. |
|  | `mem_limit` | Limit set by `Mem_Buf_Limit`. |

### Tasks

When an input plugin ingests data into the engine, a Chunk is created. A Chunk can
contains multiple records. At flush time, the engine creates a Task that contains the
routes for the Chunk associated in question.

The Task dump describes the tasks associated to the input plugin:

| Entry | Description |
| :--- | :--- |
| `total_tasks` | Total number of active tasks associated to data generated by the input plugin. |
| `new` | Number of tasks not yet assigned to an output plugin. Tasks are in `new` status for a very short period of time. This value is normally very low or zero. |
| `running` | Number of active tasks being processed by output plugins. |
| `size` | Amount of memory used by the Chunks being processed (total chunk size). |

### Chunks

The Chunks dump tells more details about all the chunks that the input plugin has
generated and are still being processed.

Depending of the buffering strategy and limits imposed by configuration, some Chunks
might be `up` (in memory) or `down` (filesystem).

| Entry | Sub-entry | Description |
| :--- | :--- | :--- |
| `total_chunks` |  | Total number of Chunks generated by the input plugin that are still being processed by the engine. |
| `up_chunks` |  | Total number of Chunks loaded in memory. |
| `down_chunks` |  | Total number of Chunks stored in the filesystem but not loaded in memory yet. |
| `busy_chunks` |  | Chunks marked as busy (being flushed) or locked. Busy Chunks are immutable and likely are ready to be or are being processed. |
|  | `size` | Amount of bytes used by the Chunk. |
|  | `size err` | Number of Chunks in an error state where its size couldn't be retrieved. |

### Storage Layer

Fluent Bit relies on a custom storage layer interface designed for hybrid buffering.
The `Storage Layer` entry contains a total summary of Chunks registered by Fluent
Bit:

| Entry | Sub-Entry | Description |
| :--- | :--- | :--- |
| `total chunks` |  | Total number of Chunks. |
| `mem chunks` |  | Total number of Chunks memory-based. |
| `fs chunks` |  | Total number of Chunks filesystem based. |
|  | `up` | Total number of filesystem chunks up in memory. |
|  | `down` | Total number of filesystem chunks down (not loaded in memory). |
