# Supported platforms

Fluent Bit supports the following operating systems and architectures:

| Operating System | Distribution | Architectures |
| :--- | :--- | :--- |
| Linux | [Amazon Linux 2023](linux/amazon-linux.md) | x86_64, Arm64v8 |
|  | [Amazon Linux 2](linux/amazon-linux.md) | x86_64, Arm64v8 |
|  | [CentOS 9 Stream](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [CentOS 8](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [CentOS 7](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Rocky Linux 8](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Rocky Linux 9](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Alma Linux 8](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Alma Linux 9](linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Debian 12 (Bookworm)](linux/debian.md) | x86_64, Arm64v8 |
|  | [Debian 11 (Bullseye)](linux/debian.md) | x86_64, Arm64v8 |
|  | [Debian 10 (Buster)](linux/debian.md) | x86_64, Arm64v8 |
|  | [Ubuntu 24.04 (Noble Numbat)](linux/ubuntu.md) | x86_64, Arm64v8 |
|  | [Ubuntu 22.04 (Jammy Jellyfish)](linux/ubuntu.md) | x86_64, Arm64v8 |
|  | [Raspbian 12 (Bookworm)](linux/raspbian-raspberry-pi.md) | Arm32v7 |
| macOS | * | x86_64, Apple M1 |
| Windows | [Windows Server 2019](windows.md) | x86_64, x86 |
|  | [Windows 10 1903](windows.md) | x86_64, x86 |

From an architecture support perspective, Fluent Bit is fully functional on x86_64,
Arm64v8, and Arm32v7 based processors.

Fluent Bit can work also on macOS and Berkeley Software Distribution (BSD) systems,
but not all plugins will be available on all platforms.

Official support is based on community demand. Fluent Bit might run on older operating
systems, but must be built from source, or using custom packages from
[enterprise providers](https://fluentbit.io/enterprise).

Fluent Bit is supported for Linux on IBM Z (s390x) environments with some
restrictions, but only container images are provided for these targets officially.
