# Docker

Fluent Bit container images are available on Docker Hub ready for production usage. Current available images can be deployed in multiple architectures.

## Tags and Versions

The following table describes the tags that are available on Docker Hub [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tag\(s\) | Manifest Architectures | Description |
| :--- | :--- | :--- |
| 1.9.0 | x86\_64, arm64v8, arm32v7 | Release [v1.9.9](https://fluentbit.io/announcements/v1.9.0/) |
| 1.9.0-debug | x86\_64, arm64v8, arm32v7 | v1.9.x releases (production + debug) |
| 1.8.13 | x86\_64, arm64v8, arm32v7 | Release [v1.8.13](https://fluentbit.io/announcements/v1.8.13/) |
| 1.8-debug, 1.8.13-debug | x86\_64 | v1.8.x releases (production + debug) |
| 1.8.12 | x86\_64, arm64v8, arm32v7 | Release [v1.8.12](https://fluentbit.io/announcements/v1.8.12/) |
| 1.8-debug, 1.8.12-debug | x86\_64 | v1.8.x releases (production + debug) |
| 1.8.11 | x86\_64, arm64v8, arm32v7 | Release [v1.8.11](https://fluentbit.io/announcements/v1.8.11/) |
| 1.8-debug, 1.8.11-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.10 | x86\_64, arm64v8, arm32v7 | Release [v1.8.10](https://fluentbit.io/announcements/v1.8.10/) |
| 1.8-debug, 1.8.10-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.9 | x86\_64, arm64v8, arm32v7 | Release [v1.8.9](https://fluentbit.io/announcements/v1.8.9/) |
| 1.8-debug, 1.8.9-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.8 | x86\_64, arm64v8, arm32v7 | Release [v1.8.8](https://fluentbit.io/announcements/v1.8.8/) |
| 1.8-debug, 1.8.8-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.7 | x86\_64, arm64v8, arm32v7 | Release [v1.8.7](https://fluentbit.io/announcements/v1.8.7/) |
| 1.8-debug, 1.8.7-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.6 | x86\_64, arm64v8, arm32v7 | Release [v1.8.6](https://fluentbit.io/announcements/v1.8.6/) |
| 1.8-debug, 1.8.6-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.5 | x86\_64, arm64v8, arm32v7 | Release [v1.8.5](https://fluentbit.io/announcements/v1.8.5/) |
| 1.8-debug, 1.8.5-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.4 | x86\_64, arm64v8, arm32v7 | Release [v1.8.4](https://fluentbit.io/announcements/v1.8.4/) |
| 1.8-debug, 1.8.4-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.3 | x86\_64, arm64v8, arm32v7 | Release [v1.8.3](https://fluentbit.io/announcements/v1.8.3/) |
| 1.8-debug, 1.8.3-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.2 | x86\_64, arm64v8, arm32v7 | Release [v1.8.2](https://fluentbit.io/announcements/v1.8.2/) |
| 1.8-debug, 1.8.2-debug | x86\_64 | v1.8.x releases + Busybox |
| 1.8.1 | x86\_64, arm64v8, arm32v7 | Release [v1.8.1](https://fluentbit.io/announcements/v1.8.1/) |
| 1.8-debug, 1.8.1-debug | x86\_64 | v1.8.x releases + Busybox |

It's strongly suggested that you always use the latest image of Fluent Bit.

## Multi Architecture Images

Our production stable images are based on [Distroless](https://github.com/GoogleContainerTools/distroless) focusing on security containing just the Fluent Bit binary and minimal system libraries and basic configuration.
We also provide **debug** images for all architectures (from 1.9.0+) which contain a full (Debian) shell and package manager that can be used to troubleshoot or for testing purposes.

From a deployment perspective, there is no need to specify an architecture, the container client tool that pulls the image gets the proper layer for the running architecture.

## Getting Started

Download the last stable image from 1.9 series:

```text
$ docker pull fluent/fluent-bit:1.9.0
```

Once the image is in place, now run the following \(useless\) test which makes Fluent Bit measure CPU usage by the container:

```text
$ docker run -ti fluent/fluent-bit:1.9.0 -i cpu -o stdout -f 1
```

That command will let Fluent Bit measure CPU usage every second and flush the results to the standard output, e.g:

```text
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
