---
description: External libraries embedded in Fluent Bit
---

# External libraries

Fluent Bit embeds several external libraries in its [/lib](https://github.com/fluent/fluent-bit/tree/master/lib) directory. These libraries are included to minimize external dependencies and maximize cross-platform compatibility.

## Core Fluent libraries

These libraries are developed and maintained by the Fluent Bit team:

| Library | Purpose | License |
|---------|---------|---------|
| [CFL](https://github.com/fluent/cfl) | Common data structures (strings, lists, key-value pairs, arrays, variants, time utilities, hashing) used across Fluent Bit and related projects. | Apache 2.0 |
| [Chunk I/O](https://github.com/fluent/chunkio) | Manages chunks of data in the file system for buffering. Handles memory-mapped I/O with optional CRC32 checksums for data integrity. Powers Fluent Bit's filesystem buffering. | Apache 2.0 |
| [CMetrics](https://github.com/fluent/cmetrics) | Creates and manages metrics (counters, gauges, histograms, summaries) with label support. Based on Go Prometheus Client API design. | Apache 2.0 |
| [CTraces](https://github.com/fluent/ctraces) | Creates and manages trace contexts with encoding/decoding support for OpenTelemetry and other formats. | Apache 2.0 |
| [CProfiles](https://github.com/fluent/cprofiles) | Creates and manages profiling data based on the OpenTelemetry Profiles schema. | Apache 2.0 |
| [Fluent OTel Proto](https://github.com/fluent/fluent-otel-proto) | Provides C interfaces for OpenTelemetry protocol buffer definitions (common, resource, trace, logs, metrics). | Apache 2.0 |
| [flb_libco](https://github.com/fluent/flb_libco) | Fork of [libco](https://byuu.org/library/libco/) for cooperative multithreading (coroutines). Includes ARMv8 fixes and macOS support. | ISC |

## HTTP and networking

| Library | Purpose | License |
|---------|---------|---------|
| [Monkey](https://github.com/monkey/monkey) | Fast, lightweight HTTP server providing the embedded web server for Fluent Bit's HTTP endpoints (health checks, metrics, etc.). | Apache 2.0 |
| [c-ares](https://c-ares.org/) | Modern asynchronous DNS resolver library. Enables non-blocking DNS queries for network operations. | MIT |
| [nghttp2](https://nghttp2.org/) | HTTP/2 C library implementing the framing layer. Enables HTTP/2 client and server functionality. | MIT |

## Data serialization and parsing

| Library | Purpose | License |
|---------|---------|---------|
| [msgpack-c](https://github.com/msgpack/msgpack-c) | MessagePack serialization library. Used as Fluent Bit's internal data format for records. | Boost 1.0 |
| [Jansson](https://github.com/akheron/jansson) | JSON encoding, decoding, and manipulation with full Unicode support. | MIT |
| [yyjson](https://github.com/ibireme/yyjson) | High-performance JSON library capable of processing gigabytes per second. Used for fast JSON operations. | MIT |
| [jsmn](https://github.com/zserge/jsmn) | Minimalistic JSON parser (~200 lines of code). Zero-copy, no dynamic allocation. | MIT |

## Text processing

| Library | Purpose | License |
|---------|---------|---------|
| [Onigmo](https://github.com/k-takata/Onigmo) | Regular expression library (fork of Oniguruma). Supports Perl 5.10+ expressions like `\K`, `\R`, and conditional patterns. Default regex engine for Ruby 2.0+. | BSD |
| [tutf8e](https://github.com/papplampe/tutf8e) | Tiny UTF-8 encoder supporting ISO-8859-x and Windows-125x character set conversions. | MIT |
| [simdutf](https://github.com/simdutf/simdutf) | SIMD-accelerated Unicode validation and transcoding (UTF-8, UTF-16, UTF-32). | Apache 2.0 |

## Compression

| Library | Purpose | License |
|---------|---------|---------|
| [miniz](https://github.com/richgel999/miniz) | Single-file deflate/inflate, zlib-subset implementation. Provides gzip compression. | Public Domain |
| [Snappy](https://github.com/google/snappy) | Fast compression/decompression library. Prioritizes speed over compression ratio. | BSD |
| [zstd](https://github.com/facebook/zstd) | Zstandard compression providing high compression ratios at fast speeds. | BSD |

## Scripting and WebAssembly

| Library | Purpose | License |
|---------|---------|---------|
| [LuaJIT](https://luajit.org/) | Just-In-Time compiler for Lua. Powers the [Lua filter](../pipeline/filters/lua.md) plugin for custom record processing. | MIT |
| [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime) | WebAssembly Micro Runtime from the Bytecode Alliance. Enables [WASM filter plugins](wasm-filter-plugins.md) and [WASM input plugins](wasm-input-plugins.md). Supports interpreter, AOT, and JIT execution modes. | Apache 2.0 |

## Integration libraries

| Library | Purpose | License |
|---------|---------|---------|
| [librdkafka](https://github.com/confluentinc/librdkafka) | Apache Kafka C/C++ client library. Enables the [Kafka input](../pipeline/inputs/kafka.md) and [Kafka output](../pipeline/outputs/kafka.md) plugins. Supports producer, consumer, and admin clients with high performance (millions of messages/second). | BSD-2 |
| [Avro](https://github.com/apache/avro) | Apache Avro data serialization system. | Apache 2.0 |

## Storage and utilities

| Library | Purpose | License |
|---------|---------|---------|
| [SQLite](https://sqlite.org/) | Self-contained SQL database engine. Used for persistent storage operations. | Public Domain |
| [jemalloc](https://github.com/jemalloc/jemalloc) | General-purpose memory allocator emphasizing fragmentation avoidance and scalable concurrency. Optional alternative to system malloc. | BSD-2 |
| [lwrb](https://github.com/MaJerle/lwrb) | Lightweight ring buffer implementation. Thread-safe FIFO buffer with zero-copy DMA support. | MIT |
| [mpack](https://github.com/ludocode/mpack) | Simple and fast MessagePack encoder/decoder. | MIT |
| [libbacktrace](https://github.com/ianlancetaylor/libbacktrace) | Library for producing symbolic backtraces. Used for debugging and error reporting. | BSD |

## Version information

When Fluent Bit starts, it logs the versions of key libraries:

```text
[2024/11/10 22:25:53] [ info] [ctraces ] version=0.5.7
[2024/11/10 22:25:53] [ info] [cmetrics] version=0.9.9
[2024/11/10 22:25:53] [ info] [cprofiles] version=0.1.5
```

## Build options

Some libraries are optional and can be enabled or disabled at build time:

| CMake option | Library | Default |
|--------------|---------|---------|
| `FLB_WAMRC` | WAMR AOT compiler | Off |
| `FLB_LUAJIT` | LuaJIT | On |
| `FLB_OUT_KAFKA` | librdkafka | Off |
| `FLB_JEMALLOC` | jemalloc | Off (platform dependent) |

For more information on build options, see [Build and install](../installation/downloads/source/build-and-install.md).

