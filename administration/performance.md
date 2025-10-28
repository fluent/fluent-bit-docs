# Performance tips

Fluent Bit is designed for high performance and minimal resource usage. Depending on your use case, you can optimize further using specific configuration options to achieve faster performance or reduce resource consumption.

## Reading files with `tail`

The `Tail` input plugin is used to read data from files on the filesystem. By default, it uses a small memory buffer of `32KB` per monitored file. While this is sufficient for most generic use cases and helps keep memory usage low when monitoring many files, there are scenarios where you might want to increase performance by using more memory.

If your files are typically larger than `32KB`, consider increasing the buffer size to speed up file reading. For example, you can experiment with a buffer size of `128KB`:

```yaml
pipeline:
  inputs:
    - name: tail
      path: '/var/log/containers/*.log'
      buffer_chunk_size: 128kb
      buffer_max_size: 128kb
```

By increasing the buffer size, Fluent Bit will make fewer system calls (read(2)) to read the data, reducing CPU usage and improving performance.

## Fluent Bit and SIMD for JSON encoding

Starting in Fluent Bit v3.2, performance improvements have been introduced for JSON encoding. Plugins that convert logs from the Fluent Bit internal binary representation
to JSON can now do so up to 30% faster using Single Instruction, Multiple Data (SIMD) optimizations.

### Enabling SIMD support

Ensure that your Fluent Bit binary is built with SIMD support. This feature is available for architectures such as x86_64, amd64, aarch64, and arm64. As of now, SIMD is only enabled by default in Fluent Bit container images.

You can check if SIMD is enabled by looking for the following log entry when Fluent Bit starts:

```text
[2024/11/10 22:25:53] [ info] [fluent bit] version=3.2.0, commit=12cb22e0e9, pid=74359
[2024/11/10 22:25:53] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2024/11/10 22:25:53] [ info] [simd    ] SSE2
[2024/11/10 22:25:53] [ info] [cmetrics] version=0.9.8
[2024/11/10 22:25:53] [ info] [ctraces ] version=0.5.7
[2024/11/10 22:25:53] [ info] [sp] stream processor started
```

Look for the `simd` entry, which will indicate the SIMD support type, such as `SSE2`, `NEON`, or `none`.

If your Fluent Bit binary wasn't built with SIMD enabled and you are using a supported platform, you can build Fluent Bit from source using the CMake option `-DFLB_SIMD=On`.

## Run input plugins in threaded mode

By default, most of input plugins runs in the same system thread than the main event loop, however by configuration you can instruct them to run in a separate thread which will allow you to take advantage of other CPU cores in your system.

To run an input plugin in threaded mode, add `threaded: true` as in the following example:

```yaml
pipeline:
  inputs:
    - name: tail
      path: '/var/log/containers/*.log'
      threaded: true
```
