# Requirements

[Fluent Bit](http://fluentbit.io) uses very low CPU and Memory consumption, it's compatible with most of x86, x86\_64, arm32v7 and arm64v8 based platforms. In order to build it you need the following components in your system for the build process:

* Compiler: GCC or clang
* CMake
* Flex & Bison: only if you enable the Stream Processor or Record Accessor feature \(both enabled by default\)

In the core there are not other dependencies, For certain features that depends on third party components like output plugins with special backend libraries \(e.g: kafka\), those are included in the main source code repository.

