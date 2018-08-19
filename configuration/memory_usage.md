# Memory Usage

In certain scenarios would be ideal to estimate how much memory Fluent Bit could be using, this is very useful for containerized environments where memory limits are a must.

In order to estimate we will assume that the input plugins have set the **Mem\_Buf\_Limit** option \(you can learn more about it in the [Backpressure](backpressure.md) section\).

## Estimating

Input plugins append data independently, so in order to do an estimation a limit should be imposed through the **Mem\_Buf\_Limit** option. If the limit was set to _10MB_ we need to estimate that in the worse case, the output plugin likely could use _20MB_.

Fluent Bit has an internal binary representation for the data being processed, but when this data reach an output plugin, this one will likely create their own representation in a new memory buffer for processing. The best example are the [InfluxDB](../output/influxdb.md) and [Elasticsearch](../output/elasticsearch.md) output plugins, both needs to convert the binary repesentation to their respective-custom JSON formats before to talk to their backend servers.

So, if we impose a limit of _10MB_ for the input plugins and considering the worse case scenario of the output plugin consuming _20MB_ extra, as a minimum we need \(_30MB_ x 1.2\) = **36MB**.

## Glibc and Memory Fragmentation

Is well known that in intensive environments where memory allocations happens in the order of magnitude, the default memory allocator provided by Glibc could lead to a high fragmentation, reporting a high memory usage by the service.

It's strongly suggested that in any production environment, Fluent Bit be build with Jemalloc enabled \(-DFLB\_JEMALLOC=On\), which is an alternative memory allocator that have better strategies to reduce fragmentation among others for better performance.

You can check if Fluent Bit has been built with Jemalloc using the following command:

```text
$ bin/fluent-bit -h|grep JEMALLOC
```

The output should looks like:

```text
Build Flags =  JSMN_PARENT_LINKS JSMN_STRICT FLB_HAVE_TLS FLB_HAVE_SQLDB
FLB_HAVE_TRACE FLB_HAVE_FLUSH_LIBCO FLB_HAVE_VALGRIND FLB_HAVE_FORK
FLB_HAVE_PROXY_GO FLB_HAVE_JEMALLOC JEMALLOC_MANGLE FLB_HAVE_REGEX
FLB_HAVE_C_TLS FLB_HAVE_SETJMP FLB_HAVE_ACCEPT4 FLB_HAVE_INOTIFY
```

If the FLB\_JEMALLOC option is listed in _Build Flags_, everything will be fine.

