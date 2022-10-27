# Docker

Fluent Bit container images are available on Docker Hub ready for production usage. Current available images can be deployed in multiple architectures.

## Quick Start

Get started by simply typing the following command:

```shell
docker run -ti cr.fluentbit.io/fluent/fluent-bit
```

## Tags and Versions

The following table describes the tags that are available on Docker Hub [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tag(s)      | Manifest Architectures    | Description                                                  |
| ----------- | ------------------------- | ------------------------------------------------------------ |
| 2.0.1       | x86\_64, arm64v8, arm32v7 | Release [v2.0.0](https://fluentbit.io/announcements/v2.0.1/) |
| 2.0.1-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.0       | x86\_64, arm64v8, arm32v7 | Release [v2.0.0](https://fluentbit.io/announcements/v2.0.0/) |
| 2.0.0-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 1.9.9       | x86\_64, arm64v8, arm32v7 | Release [v1.9.9](https://fluentbit.io/announcements/v1.9.9/) |
| 1.9.9-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.8       | x86\_64, arm64v8, arm32v7 | Release [v1.9.8](https://fluentbit.io/announcements/v1.9.8/) |
| 1.9.8-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.7       | x86\_64, arm64v8, arm32v7 | Release [v1.9.7](https://fluentbit.io/announcements/v1.9.7/) |
| 1.9.7-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.6       | x86\_64, arm64v8, arm32v7 | Release [v1.9.6](https://fluentbit.io/announcements/v1.9.6/) |
| 1.9.6-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.5       | x86\_64, arm64v8, arm32v7 | Release [v1.9.5](https://fluentbit.io/announcements/v1.9.5/) |
| 1.9.5-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.4       | x86\_64, arm64v8, arm32v7 | Release [v1.9.4](https://fluentbit.io/announcements/v1.9.4/) |
| 1.9.4-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.3       | x86\_64, arm64v8, arm32v7 | Release [v1.9.3](https://fluentbit.io/announcements/v1.9.3/) |
| 1.9.3-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.2       | x86\_64, arm64v8, arm32v7 | Release [v1.9.2](https://fluentbit.io/announcements/v1.9.2/) |
| 1.9.2-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.1       | x86\_64, arm64v8, arm32v7 | Release [v1.9.1](https://fluentbit.io/announcements/v1.9.1/) |
| 1.9.1-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.0       | x86\_64, arm64v8, arm32v7 | Release [v1.9.0](https://fluentbit.io/announcements/v1.9.0/) |
| 1.9.0-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |

It is strongly suggested that you always use the latest image of Fluent Bit.

## Multi Architecture Images

Our production stable images are based on [Distroless](https://github.com/GoogleContainerTools/distroless) focusing on security containing just the Fluent Bit binary and minimal system libraries and basic configuration. We also provide **debug** images for all architectures (from 1.9.0+) which contain a full (Debian) shell and package manager that can be used to troubleshoot or for testing purposes.

From a deployment perspective, there is no need to specify an architecture, the container client tool that pulls the image gets the proper layer for the running architecture.

## Getting Started

Download the last stable image from 1.9 series:

```shell
docker pull cr.fluentbit.io/fluent/fluent-bit:1.9
```

Once the image is in place, now run the following (useless) test which makes Fluent Bit measure CPU usage by the container:

```shell
docker run -ti cr.fluentbit.io/fluent/fluent-bit:1.9 \
  -i cpu -o stdout -f 1
```

That command will let Fluent Bit measure CPU usage every second and flush the results to the standard output, e.g:

```shell
[2019/10/01 12:29:02] [ info] [engine] started
[0] cpu.0: [1504290543.000487750, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
```

## F.A.Q

### Why there is no Fluent Bit Docker image based on Alpine Linux ?

Alpine Linux uses Musl C library instead of Glibc. Musl is not fully compatible with Glibc which generated many issues in the following areas when used with Fluent Bit:

* Memory Allocator: to run Fluent Bit properly in high-load environments, we use Jemalloc as a default memory allocator which reduce fragmentation and provides better performance for our needs. Jemalloc cannot run smoothly with Musl and requires extra work.
* Alpine Linux Musl functions bootstrap have a compatibility issue when loading Golang shared libraries, this generate problems when trying to load Golang output plugins in Fluent Bit.
* Alpine Linux Musl Time format parser does not support Glibc extensions
* Maintainers preference in terms of base image due to security and maintenance reasons are Distroless and Debian.
