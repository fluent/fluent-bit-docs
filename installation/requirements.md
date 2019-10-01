# Requirements

[Fluent Bit](http://fluentbit.io) uses very low CPU and Memory consumption, it's compatible with most of x86, x86\_64, AArch32 and AArch64 based platforms. In order to build it you need the following components in your system:

* Compiler: GCC or clang
* CMake
* Flex  \(only if Stream Processor is enabled\)
* Bison \(only if Stream Processor is enabled\)

There are not other dependencies besides _libc_ and _pthreads_ in the most basic mode. For certain features that depends on third party components, those are included in the main source code repository.

