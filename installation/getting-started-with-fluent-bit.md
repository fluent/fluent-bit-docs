---
description: The following serves as a guide on how to install/deploy/upgrade Fluent Bit
---

# Getting Started with Fluent Bit

## Container Deployment

| Deployment Type   | Instructions                                       |
| ----------------- | -------------------------------------------------- |
| Kubernetes        | [Deploy on Kubernetes](kubernetes.md#installation) |
| Docker            | [Deploy with Docker](docker.md)                    |
| Containers on AWS | [Deploy on Containers on AWS](aws-container.md)    |

## Install on Linux (Packages)

| Operating System       | Installation Instructions                                                                                                                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CentOS / Red Hat       | [CentOS 7](linux/redhat-centos.md#install-on-redhat-centos), [CentOS 8](linux/redhat-centos.md#install-on-redhat-centos)                                                                                |
| Ubuntu                 | [Ubuntu 16.04 LTS](linux/ubuntu.md#ubuntu-16-04-lts-xenial-xerus), [Ubuntu 18.04 LTS](linux/ubuntu.md#ubuntu-18-04-lts-bionic-beaver), [Ubuntu 20.04 LTS](linux/ubuntu.md#ubuntu-20-04-lts-focal-fossa), [Ubuntu 22.04 LTS](linux/ubuntu.md#ubuntu-22-04-lts-jammy-jellyfish)  |
| Debian                 | [Debian 9](linux/debian.md#debian-9-stretch), [Debian 10](linux/debian.md#debian-10-buster)                                                                                                             |
| Amazon Linux           | [Amazon Linux 2](linux/amazon-linux.md#install-on-amazon-linux-2)                                                                                                                                       |
| Raspbian / Rasberry Pi | [Raspbian 10](linux/raspbian-raspberry-pi.md#raspbian-10-buster)                                                                                                                                        |
| Yocto / Embedded Linux | [Yocto / Embedded Linux](yocto-embedded-linux.md#fluent-bit-and-other-architectures)                                                                                                                    |

## Install on Windows (Packages)

| Operating System    | Installation Instructions                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Windows Server 2019 | [Windows Server EXE](windows.md#installing-from-exe-installer), [Windows Server ZIP](windows.md#installing-from-zip-archive) |
| Windows 10 2019.03  | [Windows EXE](windows.md#installing-from-exe-installer), [Windows ZIP](windows.md#installing-from-zip-archive)               |

## Compile from Source (Linux, Windows, FreeBSD, MacOS)

| Operating System | Installation Instructions                                   |
| ---------------- | ----------------------------------------------------------- |
| Linux, FreeBSD   | [Compile from source](sources/build-and-install.md)         |
| MacOS            | [Compile from source](macos.md#get-the-source-and-build-it) |
| Windows          | [Compile from Source](windows.md#compile-from-source)       |

## Sandbox Environment

If you are interested in learning about Fluent Bit you can try out the sandbox environment

{% embed url="https://play.instruqt.com/embed/Fluent/tracks/fluent-bit-getting-started-101?token=em_S2zOzhhDQepM0vDS" %}
Fluent Bit Sandbox Environment
{% endembed %}

## Enterprise Packages

Fluent Bit packages are also provided by [enterprise providers](https://fluentbit.io/enterprise) for older end of life versions, Unix systems, and additional support and features. A list provided by fluentbit.io/enterprise is provided below

* [Calyptia Fluent Bit LTS](https://www.calyptia.com/download)
