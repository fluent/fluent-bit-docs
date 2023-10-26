# Supported Platforms

The following operating systems and architectures are supported in Fluent Bit.

| Operating System | Distribution | Architectures |
| :--- | :--- | :--- |
| Linux | [Amazon Linux 2023](linux/amazon-linux.md) | x86\_64, Arm64v8 |
|  | [Amazon Linux 2](linux/amazon-linux.md) | x86\_64, Arm64v8 |
|  | [Centos 9 Stream](linux/redhat-centos.md) | x86\_64, Arm64v8 |
|  | [Centos 8](linux/redhat-centos.md) | x86\_64, Arm64v8 |
|  | [Centos 7](linux/redhat-centos.md) | x86\_64, Arm64v8 |
|  | [Rocky Linux 8](linux/redhat-centos.md) | x86\_64, Arm64v8 |
|  | [Alma Linux 8](linux/redhat-centos.md) | x86\_64, Arm64v8 |
|  | [Debian 12 \(Bookworm\)](linux/debian.md) | x86\_64, Arm64v8 |
|  | [Debian 11 \(Bullseye\)](linux/debian.md) | x86\_64, Arm64v8 |
|  | [Debian 10 \(Buster\)](linux/debian.md) | x86\_64, Arm64v8 |
|  | [Ubuntu 22.04 \(Jammy Jellyfish\)](linux/ubuntu.md) | x86\_64, Arm64v8, s390x |
|  | [Ubuntu 20.04 \(Focal Fossa\)](linux/ubuntu.md) | x86\_64, Arm64v8 |
|  | [Ubuntu 18.04 \(Bionic Beaver\)](linux/ubuntu.md) | x86\_64, Arm64v8 |
|  | [Ubuntu 16.04 \(Xenial Xerus\)](linux/ubuntu.md) | x86\_64 |
|  | [Raspbian 11 \(Bullseye\)](linux/raspbian-raspberry-pi.md) | Arm32v7 |
|  | [Raspbian 10 \(Buster\)](linux/raspbian-raspberry-pi.md) | Arm32v7 |
| macOS | * | x86_64, Apple M1 |
| Windows | [Windows Server 2019](windows.md) | x86\_64, x86 |
|  | [Windows 10 1903](windows.md) | x86\_64, x86 |

From an architecture support perspective, Fluent Bit is fully functional on x86\_64, Arm64v8 and Arm32v7 based processors.

Fluent Bit can work also on OSX and \*BSD systems, but not all plugins will be available on all platforms.
Official support will be expanding based on community demand.
Fluent Bit may run on older operating systems though will need to be built from source, or use custom packages from [enterprise providers](https://fluentbit.io/enterprise).

Fluent Bit is supported on Linux on IBM Z (s390x) environment without WASM, because building WAMR is not supported as of today on s390x and LuaJIT as well.
