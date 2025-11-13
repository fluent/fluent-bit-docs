
# Download and install Fluent Bit

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=e9732f9c-44a4-46d3-ab87-86138455c698" />

Fluent Bit is compatible with a variety of platforms and can be installed using several different methods.

## Requirements

Fluent Bit has very low CPU and memory consumption. It's compatible with most x86-based, x86_64-based, arm32v7-based, and arm64v8-based systems.

The build process requires the following components:

- Compiler: GCC or clang
- CMake
- Flex and Bison: Required for [Stream Processor](../stream-processing/overview) or [Record Accessor](../administration/configuring-fluent-bit/classic-mode/record-accessor)
- Libyaml development headers and libraries

Certain features of Fluent Bit depend on additional third-party components. For example, output plugins with special backend libraries like Kafka include those libraries in the main source code repository.

## Build from source code

You can [build and install Fluent Bit from its source code](../installation/downloads/source). There are also platform-specific guides for building Fluent Bit from source on [macOS](../installation/downloads/macos#compile-from-source) and [Windows](../installation/downloads/windows#compile-from-source).

## Supported platforms and packages

To install Fluent Bit from one of the available packages, use the installation method for your chosen platform.

### Container deployment

Fluent Bit is available for the following container deployments:

- [Containers on AWS](../installation/downloads/aws-container)
- [Docker](../installation/downloads/docker)
- [Kubernetes](../installation/downloads/kubernetes)

### Linux

Fluent Bit is available on [Linux](../installation/downloads/linux), including the following distributions:

- [Amazon Linux](../installation/downloads/linux/amazon-linux)
- [Buildroot embedded Linux](../installation/downloads/linux/buildroot-embedded-linux)
- [Debian](../installation/downloads/linux/debian)
- [Raspbian and Raspberry Pi](../installation/downloads/linux/raspbian-raspberry-pi)
- [Red Hat and CentOS](../installation/downloads/linux/redhat-centos)
- [Rocky Linux and Alma Linux](../installation/downloads/linux/alma-rocky)
- [Ubuntu](../installation/downloads/linux/ubuntu)
- [Yocto embedded Linux](../installation/downloads/linux/yocto-embedded-linux)

### macOS

Fluent Bit is available on [macOS](../installation/downloads/macos).

### Windows

Fluent Bit is available on [Windows](../installation/downloads/windows).

### Other platforms

Official support is based on community demand. Fluent Bit might run on older operating systems, but must be built from source or using custom packages.

Fluent Bit can run on Berkeley Software Distribution (BSD) systems and IBM Z Linux (s390x) systems with restrictions. Not all plugins and filters are supported.

## Enterprise providers

Fluent Bit packages are also provided by [enterprise providers](https://fluentbit.io/enterprise) for older end-of-life versions, Unix systems, or for additional support and features including aspects (such as CVE backporting).
