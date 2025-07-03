# Serial interface

The _Serial_ input plugin lets you retrieve messages and data from a serial interface.

## Configuration parameters

This plugin has the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | ---------|
| `File` | Absolute path to the device entry. For example, `/dev/ttyS0`. | _none_ |
| `Bitrate` | The bit rate for the communication. For example: `9600`, `38400`, `115200`. | _none_ |
| `Min_Bytes` | The serial interface expects at least `Min_Bytes` to be available before processing the message. | `1` |
| `Separator` | Specify a separator string that's used to determinate when a message ends. | _none_ |
| `Format` | Specify the format of the incoming data stream. `Format` and `Separator` can't be used at the same time. | `json` (no other options available) |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Get started

To retrieve messages by using the Serial interface, you can run the plugin from the command line or through the configuration file:

### Command line

The following example loads the input serial plugin where it set a `Bitrate` of `9600`, listens from the `/dev/tnt0` interface, and uses the custom tag `data` to route the message.

```shell
$ fluent-bit -i serial -t data -p File=/dev/tnt0 -p BitRate=9600 -o stdout -m '*'
```

The interface (`/dev/tnt0`) is an emulation of the serial interface. Further examples will write some message to the other end of the interface. For example, `/dev/tnt1`.

```shell
$ echo 'this is some message' > /dev/tnt1
```

In Fluent Bit you can run the command:

```shell
$ fluent-bit -i serial -t data -p File=/dev/tnt0 -p BitRate=9600 -o stdout -m '*'
```

Which should produce output like:

```text
Fluent Bit v4.0.3
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/07/01 14:44:47] [ info] [fluent bit] version=4.0.3, commit=f5f5f3c17d, pid=1
[2025/07/01 14:44:47] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/01 14:44:47] [ info] [simd    ] disabled
[2025/07/01 14:44:47] [ info] [cmetrics] version=1.0.3
[2025/07/01 14:44:47] [ info] [ctraces ] version=0.6.6
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] initializing
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] storage_strategy='memory' (memory only)
[2025/07/01 14:44:47] [ info] [sp] stream processor started
[2025/07/01 14:44:47] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
[2025/07/01 14:44:47] [ info] [output:stdout:stdout.0] worker #0 started
[0] data: [1463780680, {"msg"=>"this is some message"}]
```

Using the `Separator` configuration, you can send multiple messages at once.

Run this command after starting Fluent Bit:

```shell
$ echo 'aaXbbXccXddXee' > /dev/tnt1
```

Then, run Fluent Bit:

```shell
$ fluent-bit -i serial -t data -p File=/dev/tnt0 -p BitRate=9600 -p Separator=X -o stdout -m '*'
```

This should produce results similar to the following:

```text
Fluent Bit v4.0.3
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/


[2025/07/01 14:44:47] [ info] [fluent bit] version=4.0.3, commit=f5f5f3c17d, pid=1
[2025/07/01 14:44:47] [ info] [storage] ver=1.5.3, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/07/01 14:44:47] [ info] [simd    ] disabled
[2025/07/01 14:44:47] [ info] [cmetrics] version=1.0.3
[2025/07/01 14:44:47] [ info] [ctraces ] version=0.6.6
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] initializing
[2025/07/01 14:44:47] [ info] [input:mem:mem.0] storage_strategy='memory' (memory only)
[2025/07/01 14:44:47] [ info] [sp] stream processor started
[2025/07/01 14:44:47] [ info] [engine] Shutdown Grace Period=5, Shutdown Input Grace Period=2
[2025/07/01 14:44:47] [ info] [output:stdout:stdout.0] worker #0 started
[0] data: [1463781902, {"msg"=>"aa"}]
[1] data: [1463781902, {"msg"=>"bb"}]
[2] data: [1463781902, {"msg"=>"cc"}]
[3] data: [1463781902, {"msg"=>"dd"}]
```

### Configuration file

In your main configuration file append the following sections:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: serial
          tag: data
          file: /dev/tnt0
          bitrate: 9600
          separator: X

    outputs:
        - name: stdout
          match: '*'        
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name      serial
    Tag       data
    File      /dev/tnt0
    BitRate   9600
    Separator X

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

## Emulating a serial interface on Linux

You can emulate a serial interface on your Linux system and test the serial input plugin locally when you don't have an interface in your computer. The following procedure has been tested on Ubuntu 15.04 running Linux Kernel 4.0.

### Build and install the `tty0tty` module

1. Download the sources:

   ```shell
   $ git clone https://github.com/freemed/tty0tty
   ```

2. Unpack and compile:

   ```shell
   $ cd tty0tty/module
   
   $ make
   ```

3. Copy the new kernel module into the kernel modules directory:

   ```shell
   $ sudo cp tty0tty.ko /lib/modules/$(uname -r)/kernel/drivers/misc/
   ```

4. Load the module:

   ```shell
   $ sudo depmod
   
   $ sudo modprobe tty0tty
   ```

   You should see new serial ports in `dev` (`ls /dev/tnt\*\`).

5. Give appropriate permissions to the new serial ports:

   ```shell
   $ sudo chmod 666 /dev/tnt*
   ```

When the module is loaded, it will interconnect the following virtual interfaces:

```text
/dev/tnt0 <=> /dev/tnt1
/dev/tnt2 <=> /dev/tnt3
/dev/tnt4 <=> /dev/tnt5
/dev/tnt6 <=> /dev/tnt7
```