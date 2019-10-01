# Docker Images

Fluent Bit container images are available on Docker Hub ready for production usage. Our stable images are based in [Distroless](https://github.com/GoogleContainerTools/distroless) focusing on security containing just the Fluent Bit binary, minimal system libraries and basic configuration.

Optionally, we provide _debug_ images which contains Busybox that can be used to troubleshoot or testing purposes.

The following table describe the tags are available on [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tag\(s\) | Description |
| :--- | :--- |
| 1.2, 1.2-debug | Latest release of 1.2.x series |
| 1.2.0, 1.2.0-debug | Container image of Fluent Bit [v1.2.0](http://fluentbit.io/announcements/v1.2.0) |

It's strongly suggested that you always use the latest image of Fluent Bit.

## Getting Started

Download the last stable image from 1.0 series:

```text
$ docker pull fluent/fluent-bit:1.2
```

Once the image is in place, now run the following \(useless\) test which makes Fluent Bit meassure CPU usage by the container:

```text
$ docker run -ti fluent/fluent-bit:1.2 /fluent-bit/bin/fluent-bit -i cpu -o stdout -f 1
```

That command will let Fluent Bit measure CPU usage every second and flush the results to the standard output, e.g:

```text
Fluent-Bit v1.2.x
Copyright (C) Treasure Data

[2017/11/07 14:29:02] [ info] [engine] started
[0] cpu.0: [1504290543.000487750, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
```

## F.A.Q

### Why there is no Fluent Bit Docker image based on Alpine Linux ?

Alpine Linux uses Musl C library instead of Glibc. Musl is not fully compatible with Glibc which generated many issues in the following areas when used with Fluent Bit:

* Memory Allocator: to run Fluent Bit properly in high-load environments, we use Jemalloc as a default memory allocator which reduce fragmentation and provides better performance for our needs. Jemalloc cannot run smoothly with Musl and requires extra work.
* Alpine Linux Musl functions bootstrap have a compatibility issue when loading Golang shared libraries, this generate problems when trying to load Golang output plugins in Fluent Bit.
* Alpine Linux Musl Time format parser does not support Glibc extensions
* Maintainers preference in terms of base image due to security and maintenance reasons are Distroless and Debian.

