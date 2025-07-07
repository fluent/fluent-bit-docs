---
description: Concatenate multiline or stack trace log messages. Available on Fluent Bit >=
  v1.8.2.
---

# Multiline

The Multiline filter helps concatenate messages that originally belonged to one context but were split across multiple records or log lines. Common examples are stack traces or applications that print logs in multiple lines.

Along with multiline filters, you can enable one of the following built-in Fluent Bit parsers with auto detection and multi-format support:

- Go
- Python
- Ruby
- Java (Google Cloud Platform Java stack trace format)

When using this filter:

- The usage of this filter depends on a previous configuration of a [multiline parser](../../administration/configuring-fluent-bit/multiline-parsing.md) definition.
- To concatenate messages read from a log file, it's highly recommended to use the multiline support in the [Tail plugin](https://docs.fluentbit.io/manual/pipeline/inputs/tail#multiline-support) itself. This is because performing concatenation while reading the log file is more performant. Concatenating messages originally split by Docker or CRI container engines, is supported in the [Tail plugin](https://docs.fluentbit.io/manual/pipeline/inputs/tail#multiline-support).

{% hint style="warning" %}
This filter only performs buffering that persists across different Chunks when `Buffer` is enabled. Otherwise, the filter processes one chunk at a time and isn't suitable for most inputs which might send multiline messages in separate chunks.

When buffering is enabled, the filter doesn't immediately emit messages it receives. It uses the `in_emitter` plugin, similar to the [Rewrite Tag filter](pipeline/filters/rewrite-tag.md), and emits messages once they're fully concatenated, or a timeout is reached.

{% endhint %}

{% hint style="warning" %}

Since concatenated records are re-emitted to the head of the Fluent Bit log pipeline, you can not configure multiple multiline filter definitions that match the same tags. This will cause an infinite loop in the Fluent Bit pipeline; to use multiple parsers on the same logs, configure a single filter definitions with a comma separated list of parsers for `multiline.parser`. For more, see issue [#5235](https://github.com/fluent/fluent-bit/issues/5235).

Secondly, for the same reason, the multiline filter should be the first filter. Logs will be re-emitted by the multiline filter to the head of the pipeline- the filter will ignore its own re-emitted records, but other filters won't. If there are filters before the multiline filter, they will be applied twice.

{% endhint %}

## Configuration parameters

The plugin supports the following configuration parameters:

| Property | Description |
| -------- | ----------- |
| `multiline.parser` | Specify one or multiple [Multiline Parser definitions](../../administration/configuring-fluent-bit/multiline-parsing.md) to apply to the content. You can specify multiple multiline parsers to detect different formats by separating them with a comma. |
| `multiline.key_content` | Key name that holds the content to process. A multiline parser definition can specify the `key_content` This option allows for overwriting that value for the purpose of the filter. |
| `mode` | Mode can be `parser` for regular expression concatenation, or `partial_message` to concatenate split Docker logs. |
| `buffer` | Enable buffered mode. In buffered mode, the filter can concatenate multiple lines from inputs that ingest records one by one (like Forward), rather than in chunks, re-emitting them into the beginning of the pipeline (with the same tag) using the `in_emitter` instance. With buffer off, this filter won't work with most inputs, except Tail. |
| `flush_ms` | Flush time for pending multiline records. Default: `2000`. |
| `emitter_name` | Name for the emitter input instance which re-emits the completed records at the beginning of the pipeline. |
| `emitter_storage.type` | The storage type for the emitter input instance. This option supports the values `memory` (default) and `filesystem`. |
| `emitter_mem_buf_limit` | Set a limit on the amount of memory the emitter can consume if the outputs provide backpressure. The default for this limit is `10M`. The pipeline will pause once the buffer exceeds the value of this setting.  or example, if the value is set to `10M` then the pipeline pauses if the buffer exceeds `10M`. The pipeline will remain paused until the output drains the buffer below the `10M` limit. |

## Configuration example

The following example aims to parse a log file called `test.log` that contains some full lines, a custom Java stack trace and a Go Stack Trace.

The following example files can be located [in the Fluent Bit repository](https://github.com/fluent/fluent-bit/tree/master/documentation/examples/multiline/filter_multiline).

Example files content:

{% tabs %}
{% tab title="fluent-bit.conf" %}
This is the primary Fluent Bit configuration file. It includes the `parsers_multiline.conf` and tails the file `test.log` by applying the multiline parsers `multiline-regex-test` and `go`. Then it sends the processing to the standard output.

```python
[SERVICE]
    flush                 1
    log_level             info
    parsers_file          parsers_multiline.conf

[INPUT]
    name                  tail
    path                  test.log
    read_from_head        true

[FILTER]
    name                  multiline
    match                 *
    multiline.key_content log
    multiline.parser      go, multiline-regex-test

[OUTPUT]
    name                  stdout
    match                 *

```

{% endtab %}

{% tab title="parsers_multiline.conf" %}
This second file defines a multiline parser for the example. A second multiline parser called `go` is used in `fluent-bit.conf`, but this one is a built-in parser.

```python
[MULTILINE_PARSER]
    name          multiline-regex-test
    type          regex
    flush_timeout 1000
    #
    # Regex rules for multiline parsing
    # ---------------------------------
    #
    # configuration hints:
    #
    #  - first state always has the name: start_state
    #  - every field in the rule must be inside double quotes
    #
    # rules |   state name  | regex pattern                  | next state
    # ------|---------------|--------------------------------------------
    rule      "start_state"   "/([A-Za-z]+ \d+ \d+\:\d+\:\d+)(.*)/"  "cont"
    rule      "cont"          "/^\s+at.*/"                     "cont"

```

{% endtab %}

{% tab title="test.log" %}
An example file with multiline and multi-format content:

```text
single line...
Dec 14 06:41:08 Exception in thread "main" java.lang.RuntimeException: Something has gone wrong, aborting!
    at com.myproject.module.MyProject.badMethod(MyProject.java:22)
    at com.myproject.module.MyProject.oneMoreMethod(MyProject.java:18)
    at com.myproject.module.MyProject.anotherMethod(MyProject.java:14)
    at com.myproject.module.MyProject.someMethod(MyProject.java:10)
    at com.myproject.module.MyProject.main(MyProject.java:6)
another line...
panic: my panic

goroutine 4 [running]:
panic(0x45cb40, 0x47ad70)
  /usr/local/go/src/runtime/panic.go:542 +0x46c fp=0xc42003f7b8 sp=0xc42003f710 pc=0x422f7c
main.main.func1(0xc420024120)
  foo.go:6 +0x39 fp=0xc42003f7d8 sp=0xc42003f7b8 pc=0x451339
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003f7e0 sp=0xc42003f7d8 pc=0x44b4d1
created by main.main
  foo.go:5 +0x58

goroutine 1 [chan receive]:
runtime.gopark(0x4739b8, 0xc420024178, 0x46fcd7, 0xc, 0xc420028e17, 0x3)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc420053e30 sp=0xc420053e00 pc=0x42503c
runtime.goparkunlock(0xc420024178, 0x46fcd7, 0xc, 0x1000f010040c217, 0x3)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc420053e70 sp=0xc420053e30 pc=0x42512e
runtime.chanrecv(0xc420024120, 0x0, 0xc420053f01, 0x4512d8)
  /usr/local/go/src/runtime/chan.go:506 +0x304 fp=0xc420053f20 sp=0xc420053e70 pc=0x4046b4
runtime.chanrecv1(0xc420024120, 0x0)
  /usr/local/go/src/runtime/chan.go:388 +0x2b fp=0xc420053f50 sp=0xc420053f20 pc=0x40439b
main.main()
  foo.go:9 +0x6f fp=0xc420053f80 sp=0xc420053f50 pc=0x4512ef
runtime.main()
  /usr/local/go/src/runtime/proc.go:185 +0x20d fp=0xc420053fe0 sp=0xc420053f80 pc=0x424bad
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc420053fe8 sp=0xc420053fe0 pc=0x44b4d1

goroutine 2 [force gc (idle)]:
runtime.gopark(0x4739b8, 0x4ad720, 0x47001e, 0xf, 0x14, 0x1)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc42003e768 sp=0xc42003e738 pc=0x42503c
runtime.goparkunlock(0x4ad720, 0x47001e, 0xf, 0xc420000114, 0x1)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc42003e7a8 sp=0xc42003e768 pc=0x42512e
runtime.forcegchelper()
  /usr/local/go/src/runtime/proc.go:238 +0xcc fp=0xc42003e7e0 sp=0xc42003e7a8 pc=0x424e5c
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003e7e8 sp=0xc42003e7e0 pc=0x44b4d1
created by runtime.init.4
  /usr/local/go/src/runtime/proc.go:227 +0x35

goroutine 3 [GC sweep wait]:
runtime.gopark(0x4739b8, 0x4ad7e0, 0x46fdd2, 0xd, 0x419914, 0x1)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc42003ef60 sp=0xc42003ef30 pc=0x42503c
runtime.goparkunlock(0x4ad7e0, 0x46fdd2, 0xd, 0x14, 0x1)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc42003efa0 sp=0xc42003ef60 pc=0x42512e
runtime.bgsweep(0xc42001e150)
  /usr/local/go/src/runtime/mgcsweep.go:52 +0xa3 fp=0xc42003efd8 sp=0xc42003efa0 pc=0x419973
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003efe0 sp=0xc42003efd8 pc=0x44b4d1
created by runtime.gcenable
  /usr/local/go/src/runtime/mgc.go:216 +0x58
one more line, no multiline

```

{% endtab %}
{% endtabs %}

Running Fluent Bit with the given configuration file:

```shell
fluent-bit -c fluent-bit.conf
```

Should return something like the following:

```text
[0] tail.0: [1626736433.143567481, {"log"=>"single line..."}]
[1] tail.0: [1626736433.143570538, {"log"=>"Dec 14 06:41:08 Exception in thread "main" java.lang.RuntimeException: Something has gone wrong, aborting!
    at com.myproject.module.MyProject.badMethod(MyProject.java:22)
    at com.myproject.module.MyProject.oneMoreMethod(MyProject.java:18)
    at com.myproject.module.MyProject.anotherMethod(MyProject.java:14)
    at com.myproject.module.MyProject.someMethod(MyProject.java:10)
    at com.myproject.module.MyProject.main(MyProject.java:6)"}]
[2] tail.0: [1626736433.143572538, {"log"=>"another line..."}]
[3] tail.0: [1626736433.143572894, {"log"=>"panic: my panic

goroutine 4 [running]:
panic(0x45cb40, 0x47ad70)
  /usr/local/go/src/runtime/panic.go:542 +0x46c fp=0xc42003f7b8 sp=0xc42003f710 pc=0x422f7c
main.main.func1(0xc420024120)
  foo.go:6 +0x39 fp=0xc42003f7d8 sp=0xc42003f7b8 pc=0x451339
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003f7e0 sp=0xc42003f7d8 pc=0x44b4d1
created by main.main
  foo.go:5 +0x58

goroutine 1 [chan receive]:
runtime.gopark(0x4739b8, 0xc420024178, 0x46fcd7, 0xc, 0xc420028e17, 0x3)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc420053e30 sp=0xc420053e00 pc=0x42503c
runtime.goparkunlock(0xc420024178, 0x46fcd7, 0xc, 0x1000f010040c217, 0x3)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc420053e70 sp=0xc420053e30 pc=0x42512e
runtime.chanrecv(0xc420024120, 0x0, 0xc420053f01, 0x4512d8)
  /usr/local/go/src/runtime/chan.go:506 +0x304 fp=0xc420053f20 sp=0xc420053e70 pc=0x4046b4
runtime.chanrecv1(0xc420024120, 0x0)
  /usr/local/go/src/runtime/chan.go:388 +0x2b fp=0xc420053f50 sp=0xc420053f20 pc=0x40439b
main.main()
  foo.go:9 +0x6f fp=0xc420053f80 sp=0xc420053f50 pc=0x4512ef
runtime.main()
  /usr/local/go/src/runtime/proc.go:185 +0x20d fp=0xc420053fe0 sp=0xc420053f80 pc=0x424bad
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc420053fe8 sp=0xc420053fe0 pc=0x44b4d1

goroutine 2 [force gc (idle)]:
runtime.gopark(0x4739b8, 0x4ad720, 0x47001e, 0xf, 0x14, 0x1)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc42003e768 sp=0xc42003e738 pc=0x42503c
runtime.goparkunlock(0x4ad720, 0x47001e, 0xf, 0xc420000114, 0x1)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc42003e7a8 sp=0xc42003e768 pc=0x42512e
runtime.forcegchelper()
  /usr/local/go/src/runtime/proc.go:238 +0xcc fp=0xc42003e7e0 sp=0xc42003e7a8 pc=0x424e5c
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003e7e8 sp=0xc42003e7e0 pc=0x44b4d1
created by runtime.init.4
  /usr/local/go/src/runtime/proc.go:227 +0x35

goroutine 3 [GC sweep wait]:
runtime.gopark(0x4739b8, 0x4ad7e0, 0x46fdd2, 0xd, 0x419914, 0x1)
  /usr/local/go/src/runtime/proc.go:280 +0x12c fp=0xc42003ef60 sp=0xc42003ef30 pc=0x42503c
runtime.goparkunlock(0x4ad7e0, 0x46fdd2, 0xd, 0x14, 0x1)
  /usr/local/go/src/runtime/proc.go:286 +0x5e fp=0xc42003efa0 sp=0xc42003ef60 pc=0x42512e
runtime.bgsweep(0xc42001e150)
  /usr/local/go/src/runtime/mgcsweep.go:52 +0xa3 fp=0xc42003efd8 sp=0xc42003efa0 pc=0x419973
runtime.goexit()
  /usr/local/go/src/runtime/asm_amd64.s:2337 +0x1 fp=0xc42003efe0 sp=0xc42003efd8 pc=0x44b4d1
created by runtime.gcenable
  /usr/local/go/src/runtime/mgc.go:216 +0x58"}]
[4] tail.0: [1626736433.143585473, {"log"=>"one more line, no multiline"}]

```

Lines that don't match a pattern aren't considered as part of the multiline message, while the ones that matched the rules were concatenated properly.

## Docker partial message use case

When Fluent Bit is consuming logs from a container runtime, such as Docker, these logs will be split when larger than a certain limit, usually 16KB. If your application emits a 100K log line, it will be split into seven partial messages. If you are using the [Fluentd Docker Log Driver](https://docs.docker.com/config/containers/logging/fluentd/) to send the logs to Fluent Bit, they might look like this:

```text
{"source": "stdout", "log": "... omitted for brevity...", "partial_message": "true", "partial_id": "dc37eb08b4242c41757d4cd995d983d1cdda4589193755a22fcf47a638317da0", "partial_ordinal": "1", "partial_last": "false", "container_id": "a96998303938eab6087a7f8487ca40350f2c252559bc6047569a0b11b936f0f2", "container_name": "/hopeful_taussig"}]
```

Fluent Bit can re-combine these logs that were split by the runtime and remove the partial message fields. The following filter example is for this use case.

```python
[FILTER]
     name                  multiline
     match                 *
     multiline.key_content log
     mode                  partial_message
```

The two options for `mode` are mutually exclusive in the filter. If you set the `mode` to `partial_message` then the `multiline.parser` option isn't allowed.
