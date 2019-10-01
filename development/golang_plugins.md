# Fluent Bit and Golang Plugins

Fluent Bit currently supports integration of Golang plugins built as shared objects for output plugins only. The interface for the Golang plugins is currently under development but is functional.

## Getting Started

Compile Fluent Bit with Golang support, e.g:

```text
$ cd build/
$ cmake -DFLB_DEBUG=On -DFLB_PROXY_GO=On ../
$ make
```

Once compiled, we can see a new option in the binary `-e` which stands for _external plugin_, e.g:

```text
$ bin/fluent-bit -h
Usage: fluent-bit [OPTION]

Available Options
  -c  --config=FILE    specify an optional configuration file
  -d, --daemon        run Fluent Bit in background mode
  -f, --flush=SECONDS    flush timeout in seconds (default: 5)
  -i, --input=INPUT    set an input
  -m, --match=MATCH    set plugin match, same as '-p match=abc'
  -o, --output=OUTPUT    set an output
  -p, --prop="A=B"    set plugin configuration property
  -e, --plugin=FILE    load an external plugin (shared lib)
  ...
```

## Build a Go Plugin

The _fluent-bit-go_ package is available to assist developers in creating Go plugins.

[https://github.com/fluent/fluent-bit-go](https://github.com/fluent/fluent-bit-go)

At a minimum, a Go plugin looks like this:

```go
package main

import "github.com/fluent/fluent-bit-go/output"

//export FLBPluginRegister
func FLBPluginRegister(def unsafe.Pointer) int {
    // Gets called only once when the plugin.so is loaded
    return output.FLBPluginRegister(ctx, "gstdout", "Stdout GO!")
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

the code above is a template to write an output plugin, it's really important to keep the package name as `main` and add an explicit `main()` function. This is a requirement as the code will be build as a shared library.

To build the code above, use the following line:

```bash
$ go build -buildmode=c-shared -o out_gstdout.so out_gstdout.go
```

Once built, a shared library called `out\_gstdout.so` will be available. It's really important to double check the final .so file is what we expect. Doing a `ldd` over the library we should see something similar to this:

```text
$ ldd out_gstdout.so
    linux-vdso.so.1 =>  (0x00007fff561dd000)
    libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fc4aeef0000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc4aeb27000)
    /lib64/ld-linux-x86-64.so.2 (0x000055751a4fd000)
```

## Run Fluent Bit with the new plugin

```bash
$ bin/fluent-bit -e /path/to/out_gstdout.so -i cpu -o gstdout
```

