# Docker

Fluent Bit container images are available on Docker Hub ready for production usage.
Current available images can be deployed in multiple architectures.

## Quick Start

Get started by simply typing the following command:

```shell
docker run -ti cr.fluentbit.io/fluent/fluent-bit
```

## Tags and Versions

The following table describes the Linux container tags that are available on Docker Hub [fluent/fluent-bit](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tag(s)       | Manifest Architectures    | Description                                                    |
| ------------ | ------------------------- | -------------------------------------------------------------- |
| 3.1.6-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.6 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.6](https://fluentbit.io/announcements/v3.1.6/) |
| 3.1.5-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.5 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.5](https://fluentbit.io/announcements/v3.1.5/) |
| 3.1.4-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.4 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.4](https://fluentbit.io/announcements/v3.1.4/) |
| 3.1.3-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.3 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.3](https://fluentbit.io/announcements/v3.1.3/) |
| 3.1.2-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.2 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.2](https://fluentbit.io/announcements/v3.1.2/) |
| 3.1.1-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.1 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.1](https://fluentbit.io/announcements/v3.1.1/) |
| 3.1.0-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.0 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.0](https://fluentbit.io/announcements/v3.1.0/) |
| 3.0.7-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.7 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.7](https://fluentbit.io/announcements/v3.0.7/) |
| 3.0.6-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.6 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.6](https://fluentbit.io/announcements/v3.0.6/) |
| 3.0.5-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.5 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.5](https://fluentbit.io/announcements/v3.0.5/) |
| 3.0.4-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.4 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.4](https://fluentbit.io/announcements/v3.0.4/) |
| 3.0.3-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.3 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.3](https://fluentbit.io/announcements/v3.0.3/) |
| 3.0.2-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.2 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.2](https://fluentbit.io/announcements/v3.0.2/) |
| 3.0.1-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.1 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.1](https://fluentbit.io/announcements/v3.0.1/) |
| 3.0.0-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.0.0 | x86_64, arm64v8, arm32v7, s390x | Release [v3.0.0](https://fluentbit.io/announcements/v3.0.0/) |
| 2.2.2-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 2.2.2 | x86_64, arm64v8, arm32v7, s390x | Release [v2.2.2](https://fluentbit.io/announcements/v2.2.2/) |
| 2.2.1-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 2.2.1 | x86_64, arm64v8, arm32v7, s390x | Release [v2.2.1](https://fluentbit.io/announcements/v2.2.1/) |
| 2.2.0-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.2.0 | x86_64, arm64v8, arm32v7 | Release [v2.2.0](https://fluentbit.io/announcements/v2.2.0/) |
| 2.1.10-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.10 | x86_64, arm64v8, arm32v7 | Release [v2.1.10](https://fluentbit.io/announcements/v2.1.10/) |
| 2.1.9-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.9 | x86_64, arm64v8, arm32v7 | Release [v2.1.9](https://fluentbit.io/announcements/v2.1.9/) |
| 2.1.8-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.8 | x86_64, arm64v8, arm32v7 | Release [v2.1.8](https://fluentbit.io/announcements/v2.1.8/) |
| 2.1.7-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.7 | x86_64, arm64v8, arm32v7 | Release [v2.1.7](https://fluentbit.io/announcements/v2.1.7/) |
| 2.1.6-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.6 | x86_64, arm64v8, arm32v7 | Release [v2.1.6](https://fluentbit.io/announcements/v2.1.6/) |
| 2.1.5 | x86_64, arm64v8, arm32v7 | Release [v2.1.5](https://fluentbit.io/announcements/v2.1.5/) |
| 2.1.5-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.4 | x86_64, arm64v8, arm32v7 | Release [v2.1.4](https://fluentbit.io/announcements/v2.1.4/) |
| 2.1.4-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.3 | x86_64, arm64v8, arm32v7 | Release [v2.1.3](https://fluentbit.io/announcements/v2.1.3/) |
| 2.1.3-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.2 | x86_64, arm64v8, arm32v7 | Release [v2.1.2](https://fluentbit.io/announcements/v2.1.2/) |
| 2.1.2-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.1        | x86\_64, arm64v8, arm32v7 | Release [v2.1.1](https://fluentbit.io/announcements/v2.1.1/)   |
| 2.1.1-debug  | x86\_64, arm64v8, arm32v7 | v2.1.x releases (production + debug)                           |
| 2.1.0        | x86\_64, arm64v8, arm32v7 | Release [v2.1.0](https://fluentbit.io/announcements/v2.1.0/)   |
| 2.1.0-debug  | x86\_64, arm64v8, arm32v7 | v2.1.x releases (production + debug)                           |
| 2.0.11       | x86\_64, arm64v8, arm32v7 | Release [v2.0.11](https://fluentbit.io/announcements/v2.0.11/) |
| 2.0.11-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                           |
| 2.0.10       | x86\_64, arm64v8, arm32v7 | Release [v2.0.10](https://fluentbit.io/announcements/v2.0.10/) |
| 2.0.10-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                           |
| 2.0.9       | x86\_64, arm64v8, arm32v7 | Release [v2.0.9](https://fluentbit.io/announcements/v2.0.9/) |
| 2.0.9-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.8       | x86\_64, arm64v8, arm32v7 | Release [v2.0.8](https://fluentbit.io/announcements/v2.0.8/) |
| 2.0.8-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.6       | x86\_64, arm64v8, arm32v7 | Release [v2.0.6](https://fluentbit.io/announcements/v2.0.6/) |
| 2.0.6-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.5       | x86\_64, arm64v8, arm32v7 | Release [v2.0.5](https://fluentbit.io/announcements/v2.0.5/) |
| 2.0.5-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.4       | x86\_64, arm64v8, arm32v7 | Release [v2.0.4](https://fluentbit.io/announcements/v2.0.4/) |
| 2.0.4-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.3       | x86\_64, arm64v8, arm32v7 | Release [v2.0.3](https://fluentbit.io/announcements/v2.0.3/) |
| 2.0.3-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.2       | x86\_64, arm64v8, arm32v7 | Release [v2.0.2](https://fluentbit.io/announcements/v2.0.2/) |
| 2.0.2-debug | x86\_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.1       | x86\_64, arm64v8, arm32v7 | Release [v2.0.1](https://fluentbit.io/announcements/v2.0.1/) |
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

Windows container images are provided from v2.0.6 for Windows Server 2019 and Windows Server 2022.
These can be found as tags on the same Docker Hub registry above.

## Multi Architecture Images

Our production stable images are based on [Distroless](https://github.com/GoogleContainerTools/distroless) focusing on security containing just the Fluent Bit binary and minimal system libraries and basic configuration.
We also provide **debug** images for all architectures (from 1.9.0+) which contain a full (Debian) shell and package manager that can be used to troubleshoot or for testing purposes.

From a deployment perspective, there is no need to specify an architecture, the container client tool that pulls the image gets the proper layer for the running architecture.

## Verify signed container images

1.9 and 2.0 container images are signed using Cosign/Sigstore.
These signatures can be verified using `cosign` ([install guide](https://docs.sigstore.dev/cosign/installation/)):

```shell
$ cosign verify --key "https://packages.fluentbit.io/fluentbit-cosign.pub" fluent/fluent-bit:2.0.6

Verification for index.docker.io/fluent/fluent-bit:2.0.6 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"index.docker.io/fluent/fluent-bit"},"image":{"docker-manifest-digest":"sha256:c740f90b07f42823d4ecf4d5e168f32ffb4b8bcd87bc41df8f5e3d14e8272903"},"type":"cosign container image signature"},"optional":{"release":"2.0.6","repo":"fluent/fluent-bit","workflow":"Release from staging"}}]
```

Note: replace `cosign` above with the binary installed if it has a different name (e.g. `cosign-linux-amd64`).

Keyless signing is also provided but this is still experimental:

```shell
COSIGN_EXPERIMENTAL=1 cosign verify fluent/fluent-bit:2.0.6
```

Note: `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed in KEYLESS mode.
To learn more about keyless signing, please refer to [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures).

## Getting Started

Download the last stable image from 2.0 series:

```shell
docker pull cr.fluentbit.io/fluent/fluent-bit:2.0
```

Once the image is in place, now run the following (useless) test which makes Fluent Bit measure CPU usage by the container:

```shell
docker run -ti cr.fluentbit.io/fluent/fluent-bit:2.0 \
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

### Why use distroless containers ?

Briefly tackled in a [blog post](https://calyptia.com/2022/01/26/all-your-arch-are-belong-to-us/#security) which links out to the following possibly opposing views:

* <https://hackernoon.com/distroless-containers-hype-or-true-value-2rfl3wat>
* <https://www.redhat.com/en/blog/why-distroless-containers-arent-security-solution-you-think-they-are>

The reasons for using Distroless are fairly well covered here: <https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images>

* Only include what you need, reduce the attack surface available.
* Reduces size so improves perfomance as well.
* Reduces false positives on scans (and reduces resources required for scanning).
* Reduces supply chain security requirements to just what you need.
* Helps prevent unauthorised processes or users interacting with the container.
* Less need to harden the container (and container runtime, K8S, etc.).
* Faster CICD processes.

With any choice of course there are downsides:

* No shell or package manager to update/add things.
  * Generally though dynamic updating is a bad idea in containers as the time it is done affects the outcome: two containers started at different times using the same base image may perform differently or get different dependencies, etc.
  * A better approach is to rebuild a new image version but then you can do this with Distroless, however it is harder requiring multistage builds or similar to provide the new dependencies.
* Debugging can be harder.
  * More specifically you need applications set up to properly expose information for debugging rather than rely on traditional debug approaches of connecting to processes or dumping memory. This can be an upfront cost vs a runtime cost but does shift left in the development process so hopefully is a reduction overall.
* Assumption that Distroless is secure: nothing is secure (just more or less secure) and there are still exploits so it does not remove the need for securing your system.
* Sometimes you need to use a common base image, e.g. with audit/security/health/etc. hooks integrated, or common base tooling (this could still be Distroless though).

One other important thing to note is that `exec`'ing into a container will potentially impact resource limits.

For debugging, debug containers are available now in K8S: <https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container>

* This can be a quite different container from the one you want to investigate (e.g. lots of extra tools or even a different base).
* No resource limits applied to this container - can be good or bad.
* Runs in pod namespaces, just another container that can access everything the others can.
* May need architecture of the pod to share volumes, etc.
* Requires more recent versions of K8S and the container runtime plus RBAC allowing it.
