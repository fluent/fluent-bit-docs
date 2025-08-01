# Golang output plugins

Fluent Bit supports integration of Golang plugins built as shared objects for output plugins only. The interface for the Golang plugins is currently under development but is functional.

## Get started

Compile Fluent Bit with Golang support:

```shell
$ cd build/

$ cmake -DFLB_DEBUG=On -DFLB_PROXY_GO=On ../

$ make
```

Once compiled, you can see the new `-e` option in the binary which stands for _external plugin_.

```text
$ bin/fluent-bit -h
Usage: fluent-bit [OPTION]

Available Options
  -c  --config=FILE    specify an optional configuration file
  -d, --daemon        run Fluent Bit in background mode
  -f, --flush=SECONDS    flush timeout in seconds (default: 1)
  -i, --input=INPUT    set an input
  -m, --match=MATCH    set plugin match, same as '-p match=abc'
  -o, --output=OUTPUT    set an output
  -p, --prop="A=B"    set plugin configuration property
  -e, --plugin=FILE    load an external plugin (shared lib)
  ...
```

## Build a Go plugin

The `fluent-bit-go` package is available to assist developers in creating Go plugins.

[https://github.com/fluent/fluent-bit-go](https://github.com/fluent/fluent-bit-go)

A minimum Go plugin looks like the following:

```go
package main

import "github.com/fluent/fluent-bit-go/output"

//export FLBPluginRegister
func FLBPluginRegister(def unsafe.Pointer) int {
    // Gets called only once when the plugin.so is loaded
    return output.FLBPluginRegister(def, "gstdout", "Stdout GO!")
}

//export FLBPluginInit
func FLBPluginInit(plugin unsafe.Pointer) int {
    // Gets called only once for each instance you have configured.
    return output.FLB_OK
}

//export FLBPluginFlushCtx
func FLBPluginFlushCtx(ctx, data unsafe.Pointer, length C.int, tag *C.char) int {
    // Gets called with a batch of records to be written to an instance.
    return output.FLB_OK
}

//export FLBPluginExit
func FLBPluginExit() int {
    return output.FLB_OK
}

func main() {
}
```

The previous code is a template to write an output plugin. It's important to keep the package name as `main` and add an explicit `main()` function. This is a requirement as the code will be build as a shared library.

To build the code, use the following line:

```shell
go build -buildmode=c-shared -o out_gstdout.so out_gstdout.go
```

Once built, a shared library called `out_gstdout.so` will be available. Confirm the final `.so` file is as expected. When you use the `ldd` over the library should see something similar to this:

```shell
$ ldd out_gstdout.so
  
  linux-vdso.so.1 =>  (0x00007fff561dd000)
  libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fc4aeef0000)
  libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc4aeb27000)
  /lib64/ld-linux-x86-64.so.2 (0x000055751a4fd000)
```

## Run Fluent Bit with the new plugin

```shell
fluent-bit -e /path/to/out_gstdout.so -i cpu -o gstdout
```

## Configuration file

Fluent Bit can load and run Golang plugins using two configuration files.

- Plugins configuration file
- [Main configuration file](../administration/configuring-fluent-bit/classic-mode/configuration-file.md)

### Plugins configuration file

| Key  | Description |
| ---- | ----------- |
| Path | A path for a Golang plugin. |

#### Plugin file example

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
plugins:
  - /path/to/out_gstdout.so
```
{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[PLUGINS]
  Path /path/to/out_gstdout.so
```

{% endtab %}
{% endtabs %}

### Main configuration file

The keys for Golang plugin available as of this version are described in the following table:

| Key  | Description |
| ---- | ----------- |
| `Plugins_file`    | Path for a plugins configuration file. A plugins configuration file let you define paths for external plugins. For example, [see here](https://github.com/fluent/fluent-bit/blob/master/conf/plugins.conf). |

#### Main configuration file example

The following is an example of a main configuration file.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  - /path/to/plugins.yaml
  
pipeline:
  inputs:
    - name dummy

  outputs:
    - name: gstdout
```
{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
  plugins_file /path/to/plugins.conf

[INPUT]
  Name dummy

[OUTPUT]
  Name gstdout
```

{% endtab %}
{% endtabs %}

#### Config key constraint

The following configuration keys are reserved by Fluent Bit and must not be used by a custom plugin:

- `alias`
- `host`
- `ipv6`
- `listen`
- `log_level`
- `log_suppress_interval`
- `match`
- `match_regex`
- `mem_buf_limit`
- `port`
- `retry_limit`
- `routable`
- `storage.pause_on_chunks_overlimit`
- `storage.total_limit_size`
- `storage.type`
- `tag`
- `threaded`
- `tls`
- `tls.ca_file`
- `tls.ca_path`
- `tls.crt_file`
- `tls.debug`
- `tls.key_file`
- `tls.key_passwd`
- `tls.verify`
- `tls.vhost`
- `workers`

### Run using a configuration file

You can load a main configuration file using `-c` option. You don't need to specify a plugins configuration file from command line.

```shell
fluent-bit -c fluent-bit.conf
```