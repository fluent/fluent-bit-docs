# Docker

Fluent Bit container images are available on Docker Hub ready for production usage. Current available images can be deployed in multiple architectures.

## Tags and Versions

The following table describe the tags are available on Docker Hub [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tag\(s\) | Manifest Architectures | Description |
| :--- | :--- | :--- |
| 1.7 | x86\_64, arm64v8, arm32v7 | Latest release of 1.7.x series. |
| 1.7.4 | x86\_64, arm64v8, arm32v7 | Release [v1.7.4](https://fluentbit.io/announcements/v1.7.4/) |
| 1.7-debug, 1.7.4-debug | x86\_64 | v1.7.x releases + Busybox |
| 1.7.3 | x86\_64, arm64v8, arm32v7 | Release [v1.7.3](https://fluentbit.io/announcements/v1.7.3/) |
| 1.7-debug, 1.7.3-debug | x86\_64 | v1.7.x releases + Busybox |
| 1.7.2 | x86\_64, arm64v8, arm32v7 | Release [v1.7.2](https://fluentbit.io/announcements/v1.7.2/) |
| 1.7-debug, 1.7.2-debug | x86\_64 | v1.7.x releases + Busybox |
| 1.7.1 | x86\_64, arm64v8, arm32v7 | Release [v1.7.1](https://fluentbit.io/announcements/v1.7.1/) |
| 1.7-debug, 1.7.1-debug | x86\_64 | v1.7.x releases + Busybox |
| 1.7.0 | x86\_64, arm64v8, arm32v7 | Release [v1.7.0](https://fluentbit.io/announcements/v1.7.0/) |
| 1.7-debug, 1.7.0-debug | x86\_64 | v1.7.x releases + Busybox |

It's strongly suggested that you always use the latest image of Fluent Bit.

## Multi Architecture Images

Our x86\_64 stable image is based in [Distroless](https://github.com/GoogleContainerTools/distroless) focusing on security containing just the Fluent Bit binary and minimal system libraries and basic configuration. Optionally, we provide **debug** images for x86\_64 which contains Busybox that can be used to troubleshoot or testing purposes.

In addition, the main manifest provides images for arm64v8 and arm32v7 architectures. From a deployment perspective there is no need to specify an architecture, the container client tool that pulls the image gets the proper layer for the running architecture.

For every architecture we build the layers using the following base images:

| Architecture | Base Image |
| :--- | :--- |
| x86\_64 | [Distroless](https://github.com/GoogleContainerTools/distroless) |
| arm64v8 | arm64v8/debian:buster-slim |
| arm32v7 | arm32v7/debian:buster-slim |

## Getting Started

Download the last stable image from 1.7 series:

```text
$ docker pull fluent/fluent-bit:1.7
```

Once the image is in place, now run the following \(useless\) test which makes Fluent Bit measure CPU usage by the container:

```text
$ docker run -ti fluent/fluent-bit:1.7 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 1
```

That command will let Fluent Bit measure CPU usage every second and flush the results to the standard output, e.g:

```text
Fluent-Bit v1.7.x
Copyright (C) Treasure Data

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

### Where 'latest' Tag points to ?

Our Docker containers images are deployed thousands of times per day, we take security and stability very seriously.

The _latest_ tag _most of the time_ points to the latest stable image. When we release a major update to Fluent Bit like for example from v1.3.x to v1.4.0, we don't move _latest_ tag until 2 weeks after the release. That give us extra time to verify with our community that everything works as expected.

