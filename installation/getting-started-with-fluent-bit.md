---
description: A guide on how to install, deploy, and upgrade Fluent Bit
---
# Get started with Fluent Bit

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=e9732f9c-44a4-46d3-ab87-86138455c698" />

The Fluent Bit telemetry agent is available for Linux, macOS, Windows, and BSD family operating systems.

If you're interested in learning about Fluent Bit, you can try out the [sandbox environment](../about/sandbox-and-lab-resources.md).

## Requirements

All Fluent Bit installations must meet certain [requirements](./requirements.md).

## Supported platforms and packages

Fluent Bit software is available for a variety of platforms and can be installed using several methods.

You can [direct download and compile the source code](../installation/source.md).

To select a package for a container or operating system, use the instructions for that option from the following links:

### Container deployment

| Deployment Type   | Instructions |
| ----------------- | -------------------------------------------------- |
| Kubernetes        | [Deploy on Kubernetes](downloads/kubernetes.md#installation) |
| Docker            | [Deploy with Docker](downloads/docker.md)                    |
| Containers on AWS | [Deploy on Containers on AWS](downloads/aws-container.md)    |

### Install on Linux (packages)

| Operating System       | Installation instructions |
| ---------------------- | ------------------------- |
| Alma Linux / Red Hat   | [Alma Linux 8](downloads/linux/alma-rocky.md), [Alma Linux 9](downloads/linux/alma-rocky.md), [Alma Linux 10](downloads/linux/alma-rocky.md) |
| CentOS / Red Hat       | [CentOS 7](downloads/linux/redhat-centos.md#install-on-redhat-centos), [CentOS 8](downloads/linux/redhat-centos.md#install-on-redhat-centos), [CentOS 9 Stream](downloads/linux/redhat-centos.md#install-on-redhat-centos), [CentOS 10 Stream](downloads/linux/redhat-centos.md#install-on-redhat-centos) |
| Rocky Linux / Red Hat  | [Rocky Linux 8](downloads/linux/alma-rocky.md), [Rocky Linux 9](downloads/linux/alma-rocky.md), [Rocky Linux 10](downloads/linux/alma-rocky.md) |
| Ubuntu                 | [Ubuntu 16.04 LTS](downloads/linux/ubuntu.md), [Ubuntu 18.04 LTS](downloads/linux/ubuntu.md), [Ubuntu 20.04 LTS](downloads/linux/ubuntu.md), [Ubuntu 22.04 LTS](downloads/linux/ubuntu.md), [Ubuntu 24.04 LTS](downloads/linux/ubuntu.md) |
| Debian                 | [Debian 10](downloads/linux/debian.md), [Debian 11](downloads/linux/debian.md), [Debian 12](downloads/linux/debian.md), [Debian 13](downloads/linux/debian.md) |
| Amazon Linux           | [Amazon Linux 2](downloads/linux/amazon-linux.md#install-on-amazon-linux-2), [Amazon Linux 2023](downloads/linux/amazon-linux.md#amazon-linux-2023) |
| Raspbian / Raspberry Pi | [Raspbian 10](downloads/linux/raspbian-raspberry-pi.md#raspbian-10-buster), [Raspbian 11](downloads/linux/raspbian-raspberry-pi.md#raspbian-11-bullseye) |
| Yocto / Embedded Linux | [Yocto / Embedded Linux](downloads/linux/yocto-embedded-linux.md#fluent-bit-and-other-architectures) |
| Buildroot / Embedded Linux | [Buildroot / Embedded Linux](downloads/linux/buildroot-embedded-linux.md) |

### Install on Windows (packages)

| Operating System    | Installation instructions |
| ------------------- | ------------------------- |
| Windows Server 2019 | [Windows Server `EXE`](downloads/windows.md#installing-from-exe-installer), [Windows Server ZIP](downloads/windows.md#installing-from-zip-archive) |
| Windows 10 2019.03  | [Windows `EXE`](downloads/windows.md#installing-from-exe-installer), [Windows ZIP](downloads/windows.md#installing-from-zip-archive)               |

### Install on macOS (packages)

| Operating System    | Installation instructions                     |
| ------------------- | --------------------------------------------- |
| macOS               | [Homebrew](downloads/macos.md#installing-from-homebrew) |

### Compile from source (Linux, Windows, FreeBSD, macOS)

| Operating system | Installation instructions                                   |
| ---------------- | ----------------------------------------------------------- |
| Linux, FreeBSD   | [Compile from source](downloads/source/build-and-install.md)         |
| macOS            | [Compile from source](downloads/macos.md#compile-from-source) |
| Windows          | [Compile from Source](downloads/windows.md#compile-from-source)       |


### Enterprise packages

Fluent Bit packages are also provided by [enterprise providers](https://fluentbit.io/enterprise) for older end-of-life versions, Unix systems, or for additional support and features including aspects (such as CVE backporting).
