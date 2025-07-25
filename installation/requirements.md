# Requirements

[Fluent Bit](http://fluentbit.io) has very low CPU and memory consumption. It's compatible with most x86-, x86_64-, arm32v7-, and arm64v8-based platforms.

The build process requires the following components:

- Compiler: GCC or clang
- CMake
- Flex and Bison: Required for [Stream Processor](https://docs.fluentbit.io/manual/stream-processing/introduction) or [Record Accessor](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor)
- Libyaml development headers and libraries

Core has no other dependencies. Some features depend on third-party components. For example, output plugins with special backend libraries like Kafka include those libraries in the main source code repository.

Fluent Bit is supported on Linux on IBM Z(s390x), but the Wasm and Lua filter plugins aren't.
