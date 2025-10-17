# Download Fluent Bit for supported platforms

Fluent Bit supports the following operating systems and architectures:

| Operating System | Distribution | Architectures |
| :--- | :--- | :--- |
| Linux | [Amazon Linux 2023](downloads/linux/amazon-linux.md) | x86_64, Arm64v8 |
|  | [Amazon Linux 2](downloads/linux/amazon-linux.md) | x86_64, Arm64v8 |
|  | [CentOS 9 Stream](downloads/linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [CentOS 8](downloads/linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [CentOS 7](downloads/linux/redhat-centos.md) | x86_64, Arm64v8 |
|  | [Rocky Linux 8](downloads/linux/alma-rocky.md) | x86_64, Arm64v8 |
|  | [Rocky Linux 9](downloads/linux/alma-rocky.md) | x86_64, Arm64v8 |
|  | [Alma Linux 8](downloads/linux/alma-rocky.md) | x86_64, Arm64v8 |
|  | [Alma Linux 9](downloads/linux/alma-rocky.md) | x86_64, Arm64v8 |
|  | [Debian 12 (Bookworm)](downloads/linux/debian.md) | x86_64, Arm64v8 |
|  | [Debian 11 (Bullseye)](downloads/linux/debian.md) | x86_64, Arm64v8 |
|  | [Debian 10 (Buster)](downloads/linux/debian.md) | x86_64, Arm64v8 |
|  | [Ubuntu 24.04 (Noble Numbat)](downloads/linux/ubuntu.md) | x86_64, Arm64v8 |
|  | [Ubuntu 22.04 (Jammy Jellyfish)](downloads/linux/ubuntu.md) | x86_64, Arm64v8 |
|  | [Raspbian 12 (Bookworm)](downloads/linux/raspbian-raspberry-pi.md) | Arm32v7 |
| macOS | * | x86_64, Apple M1 |
| Windows | [Windows Server 2019](downloads/windows.md) | x86_64, x86 |
|  | [Windows 10 1903](downloads/windows.md) | x86_64, x86 |
|  | [openSUSE Leap 15.6](downloads/linux/suse.md) | x86_64, Arm64v8 |
|  | [SUSE Linux Enterprise Server (SLES) 15.7](downloads/linux/suse.md) | x86_64, Arm64v8 |

From an architecture support perspective, Fluent Bit is fully functional on x86_64, Arm64v8, and Arm32v7 based processors.

Fluent Bit can work also on macOS and Berkeley Software Distribution (BSD) systems, but not all plugins will be available on all platforms.

Official support is based on community demand. Fluent Bit might run on older operating systems, but must be built from source, or using custom packages from [enterprise providers](https://fluentbit.io/enterprise).

Fluent Bit is supported for Linux on IBM Z (s390x) environments with some restrictions, but only container images are provided for these targets officially.
