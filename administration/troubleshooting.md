# Troubleshooting

* [Tap Functionality: generate events or records](troubleshooting.md#tap-functionality)
* [Dump Internals Signal](troubleshooting#dump-internals-signal)

## Tap Functionality

Tap can be used to generate events or records detailing what messages
pass through Fluent Bit, at what time and what filters affect them.


### Simple example

First, we will make sure that the container image we are going to use actually supports Fluent Bit Tap (available in Fluent Bit 2.0+):

```shell
$ docker run --rm -ti fluent/fluent-bit:latest --help | grep -Z
  -Z, --enable-chunk-trace     enable chunk tracing. activating it requires using the HTTP Server API.
```

If the `--enable-chunk-trace` option is present it means Fluent Bit has support for Fluent Bit Tap but it is disabled by default, so remember to enable it with this option.

Tap support is enabled and disabled via the embedded web server, so enable it like so (or the equivalent option in the configuration file):

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

In another window we can activate Tap by either using the instance id of the input; `dummy.0` or its alias. 

Since the alias is more predictable that is what we will use:


```shell
$ curl 127.0.0.1:2020/api/v1/trace/input_dummy
{"status":"ok"}
```

This response means we have activated Tap, the window with Fluent Bit running should now look like this:

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

All the records that now appear are those emitted by the activities of the dummy plugin.

### Complex example

This example takes the same steps but demonstrates the same mechanism works with more complicated configurations. 
In this example we will follow a single input of many which passes through several filters.

```
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

To make sure the window is not cluttered by the actual records generated by the input plugins we send all of it to `null`.

We activate with the following 'curl' command:

```shell
$ curl 127.0.0.1:2020/api/v1/trace/dummy_0
{"status":"ok"}
```

Now we should start seeing output similar to the following:

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
When activating Tap, any plugin parameter can be given to modify the output format, name of the time key, format of the date, etc.

In the next example we will use the parameter "format": "json" to demonstrate how Tap standard outputs can be shown in Json format, however this could be sent to any output plugin.

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
Next, in another window, we activate Tap including the output, in this case standard output, and the parameters wanted, in this case "format": "json":

```shell
$ curl 127.0.0.1:2020/api/v1/trace/input_dummy -d '{"output":"stdout", "params": {"format": "json"}}'
{"status":"ok"}
```
In the first window, we should be seeing the output similar to the following:
```shell
[0] dummy.0: [1674805635.972373840, {"message"=>"dummy"}]
[{"date":1674805634.974457,"type":1,"trace_id":"0","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805634,"record":{"message":"dummy"}}],"start_time":1674805634,"end_time":1674805634},{"date":1674805634.974605,"type":3,"trace_id":"0","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805634,"record":{"message":"dummy"}}],"start_time":1674805634,"end_time":1674805634},{"date":1674805635.972398,"type":1,"trace_id":"1","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805635,"record":{"message":"dummy"}}],"start_time":1674805635,"end_time":1674805635},{"date":1674805635.972413,"type":3,"trace_id":"1","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805635,"record":{"message":"dummy"}}],"start_time":1674805635,"end_time":1674805635}]
[0] dummy.0: [1674805636.973970215, {"message"=>"dummy"}]
[{"date":1674805636.974008,"type":1,"trace_id":"2","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805636,"record":{"message":"dummy"}}],"start_time":1674805636,"end_time":1674805636},{"date":1674805636.974034,"type":3,"trace_id":"2","plugin_instance":"dummy.0","plugin_alias":"input_dummy","records":[{"timestamp":1674805636,"record":{"message":"dummy"}}],"start_time":1674805636,"end_time":1674805636}]
```
This parameter shows standard output in Json format, however, as mentioned before, any plugin parameter can be used with the same method. 

Please visit the following link for more information on standard output parameters:
https://docs.fluentbit.io/manual/pipeline/outputs/standard-output#configuration-parameters

If you wish to use other output parameters please visit:
https://docs.fluentbit.io/manual/pipeline/outputs

### Analysis of a single Tap record

Here we analyze a single record from a filter event to explain the meaning of each field in detail. 
We chose a filter record since it includes the most details of all the record types.

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

### type

The type defines at what stage the event is generated:

- type=1: input record
  - this is the unadulterated input record
- type=2: filtered record
  - this is a record once it has been filtered. One record is generated per filter.
- type=3: pre-output record
  - this is the record right before it is sent for output.

Since this is a record generated by the manipulation of a record by a filter is has the type `2`.

### start_time and end_time

This records the start and end of an event, it is a bit different for each event type:

- type 1: when the input is received, both the start and end time.
- type 2: the time when filtering is matched until it has finished processing.
- type 3: the time when the input is received and when it is finally slated for output.

### trace_id

This is a string composed of a prefix and a number which is incremented with each record received by the input during the Tap session.

### plugin_instance

This is the plugin instance name as it is generated by Fluent Bit at runtime.

### plugin_alias

If an alias is set this field will contain the alias set for a plugin.

### records

This is an array of all the records being sent. Since Fluent Bit handles records in chunks of multiple records and chunks are indivisible the same is done in the Tap output. Each record consists of its timestamp followed by the actual data which is a composite type of keys and values.

## Dump Internals / Signal

When the service is running we can export [metrics](monitoring.md) to see the overall status of the data flow of the service. But there are other use cases where we would like to know the current status of the internals of the service, specifically to answer questions like _what's the current status of the internal buffers ?_ , the Dump Internals feature is the answer.

Fluent Bit v1.4 introduces the Dump Internals feature that can be triggered easily from the command line triggering the `CONT` Unix signal.

{% hint style="info" %}
note: this feature is only available on Linux and BSD family operating systems
{% endhint %}

### Usage

Run the following `kill` command to signal Fluent Bit:

```text
kill -CONT `pidof fluent-bit`
```

> The command `pidof` aims to lookup the Process ID of Fluent Bit. You can replace the

Fluent Bit will dump the following information to the standard output interface \(stdout\):

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

### Input Plugins Dump

The dump provides insights for every input instance configured.

### Status

Overall ingestion status of the plugin.

| Entry | Sub-entry | Description |
| :--- | :--- | :--- |
| overlimit |  | If the plugin has been configured with [Mem\_Buf\_Limit](backpressure.md), this entry will report if the plugin is over the limit or not at the moment of the dump. If it is overlimit, it will print `yes`, otherwise `no`. |
|  | mem\_size | Current memory size in use by the input plugin in-memory. |
|  | mem\_limit | Limit set by Mem\_Buf\_Limit. |

### Tasks

When an input plugin ingest data into the engine, a Chunk is created. A Chunk can contains multiple records. Upon flush time, the engine creates a Task that contains the routes for the Chunk associated in question.

The Task dump describes the tasks associated to the input plugin:

| Entry | Description |
| :--- | :--- |
| total\_tasks | Total number of active tasks associated to data generated by the input plugin. |
| new | Number of tasks not assigned yet to an output plugin. Tasks are in `new` status for a very short period of time \(most of the time this value is very low or zero\). |
| running | Number of active tasks being processed by output plugins. |
| size | Amount of memory used by the Chunks being processed \(Total chunks size\). |

### Chunks

The Chunks dump tells more details about all the chunks that the input plugin has generated and are still being processed.

Depending of the buffering strategy and limits imposed by configuration, some Chunks might be `up` \(in memory\) or `down` \(filesystem\).

| Entry | Sub-entry | Description |
| :--- | :--- | :--- |
| total\_chunks |  | Total number of Chunks generated by the input plugin that are still being processed by the engine. |
| up\_chunks |  | Total number of Chunks that are loaded in memory. |
| down\_chunks |  | Total number of Chunks that are stored in the filesystem but not loaded in memory yet. |
| busy\_chunks |  | Chunks marked as busy \(being flushed\) or locked. Busy Chunks are immutable and likely are ready to \(or being\) processed. |
|  | size | Amount of bytes used by the Chunk. |
|  | size err | Number of Chunks in an error state where it size could not be retrieved. |

### Storage Layer Dump

Fluent Bit relies on a custom storage layer interface designed for hybrid buffering. The `Storage Layer` entry contains a total summary of Chunks registered by Fluent Bit:

| Entry | Sub-Entry | Description |
| :--- | :--- | :--- |
| total chunks |  | Total number of Chunks |
| mem chunks |  | Total number of Chunks memory-based |
| fs chunks |  | Total number of Chunks filesystem based |
|  | up | Total number of filesystem chunks up in memory |
|  | down | Total number of filesystem chunks down \(not loaded in memory\) |
