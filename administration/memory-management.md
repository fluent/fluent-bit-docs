# Memory management

You might need to estimate how much memory Fluent Bit could be using in scenarios like containerized environments where memory limits are essential.

To make an estimate, in-use input plugins must set the `Mem_Buf_Limit`option. Learn more about it in [Backpressure](backpressure.md).

## Estimating

Input plugins append data independently. To make an estimation, impose a limit with the `Mem_Buf_Limit` option. If the limit was set to `10MB`, you can estimate that in the worst case, the output plugin likely could use `20MB`.

Fluent Bit has an internal binary representation for the data being processed. When this data reaches an output plugin, it can create its own representation in a new memory buffer for processing. The best examples are the [InfluxDB](../pipeline/outputs/influxdb.md) and [Elasticsearch](../pipeline/outputs/elasticsearch.md) output plugins, which need to convert the binary representation to their respective custom JSON formats before sending data to the backend servers.

When imposing a limit of `10MB` for the input plugins, and a worst case scenario of the output plugin consuming `20MB`, you need to allocate a minimum (`30MB` x 1.2) = `36MB`.

## Glibc and memory fragmentation

In intensive environments where memory allocations happen in the orders of magnitude, the default memory allocator provided by Glibc could lead to high fragmentation, reporting a high memory usage by the service.

It's strongly suggested that in any production environment, Fluent Bit should be built with [jemalloc](http://jemalloc.net/) enabled (`-DFLB_JEMALLOC=On`). The jemalloc implementation of `malloc` is an alternative memory allocator that can reduce fragmentation, resulting in better performance.

Use the following command to determine if Fluent Bit has been built with jemalloc:

```shell
fluent-bit -h | grep JEMALLOC
```

The output should look like:

```text
Build Flags =  JSMN_PARENT_LINKS JSMN_STRICT FLB_HAVE_TLS FLB_HAVE_SQLDB
FLB_HAVE_TRACE FLB_HAVE_FLUSH_LIBCO FLB_HAVE_VALGRIND FLB_HAVE_FORK
FLB_HAVE_PROXY_GO FLB_HAVE_JEMALLOC JEMALLOC_MANGLE FLB_HAVE_REGEX
FLB_HAVE_C_TLS FLB_HAVE_SETJMP FLB_HAVE_ACCEPT4 FLB_HAVE_INOTIFY
```

If the `FLB_HAVE_JEMALLOC` option is listed in `Build Flags`, jemalloc is enabled.
