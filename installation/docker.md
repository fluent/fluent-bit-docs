# Docker

Fluent Bit container images are available on Docker Hub ready for production usage. Current available images can be deployed in multiple architectures.

## Start Docker

Use the following command to start Docker with Fluent Bit:

```shell
docker run -ti cr.fluentbit.io/fluent/fluent-bit
```

### Use a configuration file

Use the following command to start Fluent Bit while using a configuration file:

{% tabs %}
{% tab title="fluent-bit.conf" %}

```shell
docker run -ti -v ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf \
  cr.fluentbit.io/fluent/fluent-bit
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```shell
docker run -ti -v ./fluent-bit.yaml:/fluent-bit/etc/fluent-bit.yaml \
  cr.fluentbit.io/fluent/fluent-bit \
  -c /fluent-bit/etc/fluent-bit.yaml

```

{% endtab %}
{% endtabs %}

## Tags and versions

The following table describes the Linux container tags that are available on Docker Hub [`fluent/fluent-bit`](https://hub.docker.com/r/fluent/fluent-bit/) repository:

| Tags       | Manifest Architectures    | Description                                                    |
| ------------ | ------------------------- | -------------------------------------------------------------- |
| 4.0.7-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.7 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.7](https://fluentbit.io/announcements/v4.0.7/) |
| 4.0.6-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.6 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.6](https://fluentbit.io/announcements/v4.0.6/) |
| 4.0.5-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.5 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.5](https://fluentbit.io/announcements/v4.0.5/) |
| 4.0.4-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.4 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.4](https://fluentbit.io/announcements/v4.0.4/) |
| 4.0.3-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.3 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.3](https://fluentbit.io/announcements/v4.0.3/) |
| 4.0.1-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.1 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.1](https://fluentbit.io/announcements/v4.0.1/) |
| 4.0.0-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 4.0.0 | x86_64, arm64v8, arm32v7, s390x | Release [v4.0.0](https://fluentbit.io/announcements/v4.0.0/) |
| 3.2.10-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.10 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.10](https://fluentbit.io/announcements/v3.2.10/) |
| 3.2.9-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.9 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.9](https://fluentbit.io/announcements/v3.2.9/) |
| 3.2.8-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.8 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.8](https://fluentbit.io/announcements/v3.2.8/) |
| 3.2.7-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.7 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.7](https://fluentbit.io/announcements/v3.2.7/) |
| 3.2.6-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.6 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.6](https://fluentbit.io/announcements/v3.2.6/) |
| 3.2.5-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.5 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.5](https://fluentbit.io/announcements/v3.2.5/) |
| 3.2.4-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.4 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.4](https://fluentbit.io/announcements/v3.2.4/) |
| 3.2.3-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.3 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.3](https://fluentbit.io/announcements/v3.2.3/) |
| 3.2.2-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.2 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.2](https://fluentbit.io/announcements/v3.2.2/) |
| 3.2.1-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.2.1 | x86_64, arm64v8, arm32v7, s390x | Release [v3.2.1](https://fluentbit.io/announcements/v3.2.1/) |
| 3.1.10-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.10 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.10](https://fluentbit.io/announcements/v3.1.10/) |
| 3.1.9-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.9 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.9](https://fluentbit.io/announcements/v3.1.9/) |
| 3.1.8-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.8 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.8](https://fluentbit.io/announcements/v3.1.8/) |
| 3.1.7-debug | x86_64, arm64v8, arm32v7, s390x | Debug images |
| 3.1.7 | x86_64, arm64v8, arm32v7, s390x | Release [v3.1.7](https://fluentbit.io/announcements/v3.1.7/) |
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
| 2.1.3 | x86_64, arm64v8, arm32v7 | Release [v2.1.3](https://fluentbit.io/announcements/v2.1.3/) |
| 2.1.3-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.2 | x86_64, arm64v8, arm32v7 | Release [v2.1.2](https://fluentbit.io/announcements/v2.1.2/) |
| 2.1.2-debug | x86_64, arm64v8, arm32v7 | Debug images |
| 2.1.1        | x86_64, arm64v8, arm32v7 | Release [v2.1.1](https://fluentbit.io/announcements/v2.1.1/)   |
| 2.1.1-debug  | x86_64, arm64v8, arm32v7 | v2.1.x releases (production + debug)                           |
| 2.1.0        | x86_64, arm64v8, arm32v7 | Release [v2.1.0](https://fluentbit.io/announcements/v2.1.0/)   |
| 2.1.0-debug  | x86_64, arm64v8, arm32v7 | v2.1.x releases (production + debug)                           |
| 2.0.11       | x86_64, arm64v8, arm32v7 | Release [v2.0.11](https://fluentbit.io/announcements/v2.0.11/) |
| 2.0.11-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                           |
| 2.0.10       | x86_64, arm64v8, arm32v7 | Release [v2.0.10](https://fluentbit.io/announcements/v2.0.10/) |
| 2.0.10-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                           |
| 2.0.9       | x86_64, arm64v8, arm32v7 | Release [v2.0.9](https://fluentbit.io/announcements/v2.0.9/) |
| 2.0.9-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.8       | x86_64, arm64v8, arm32v7 | Release [v2.0.8](https://fluentbit.io/announcements/v2.0.8/) |
| 2.0.8-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.6       | x86_64, arm64v8, arm32v7 | Release [v2.0.6](https://fluentbit.io/announcements/v2.0.6/) |
| 2.0.6-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.5       | x86_64, arm64v8, arm32v7 | Release [v2.0.5](https://fluentbit.io/announcements/v2.0.5/) |
| 2.0.5-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.4       | x86_64, arm64v8, arm32v7 | Release [v2.0.4](https://fluentbit.io/announcements/v2.0.4/) |
| 2.0.4-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.3       | x86_64, arm64v8, arm32v7 | Release [v2.0.3](https://fluentbit.io/announcements/v2.0.3/) |
| 2.0.3-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.2       | x86_64, arm64v8, arm32v7 | Release [v2.0.2](https://fluentbit.io/announcements/v2.0.2/) |
| 2.0.2-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.1       | x86_64, arm64v8, arm32v7 | Release [v2.0.1](https://fluentbit.io/announcements/v2.0.1/) |
| 2.0.1-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 2.0.0       | x86_64, arm64v8, arm32v7 | Release [v2.0.0](https://fluentbit.io/announcements/v2.0.0/) |
| 2.0.0-debug | x86_64, arm64v8, arm32v7 | v2.0.x releases (production + debug)                         |
| 1.9.9       | x86_64, arm64v8, arm32v7 | Release [v1.9.9](https://fluentbit.io/announcements/v1.9.9/) |
| 1.9.9-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.8       | x86_64, arm64v8, arm32v7 | Release [v1.9.8](https://fluentbit.io/announcements/v1.9.8/) |
| 1.9.8-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.7       | x86_64, arm64v8, arm32v7 | Release [v1.9.7](https://fluentbit.io/announcements/v1.9.7/) |
| 1.9.7-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.6       | x86_64, arm64v8, arm32v7 | Release [v1.9.6](https://fluentbit.io/announcements/v1.9.6/) |
| 1.9.6-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.5       | x86_64, arm64v8, arm32v7 | Release [v1.9.5](https://fluentbit.io/announcements/v1.9.5/) |
| 1.9.5-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.4       | x86_64, arm64v8, arm32v7 | Release [v1.9.4](https://fluentbit.io/announcements/v1.9.4/) |
| 1.9.4-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.3       | x86_64, arm64v8, arm32v7 | Release [v1.9.3](https://fluentbit.io/announcements/v1.9.3/) |
| 1.9.3-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.2       | x86_64, arm64v8, arm32v7 | Release [v1.9.2](https://fluentbit.io/announcements/v1.9.2/) |
| 1.9.2-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.1       | x86_64, arm64v8, arm32v7 | Release [v1.9.1](https://fluentbit.io/announcements/v1.9.1/) |
| 1.9.1-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |
| 1.9.0       | x86_64, arm64v8, arm32v7 | Release [v1.9.0](https://fluentbit.io/announcements/v1.9.0/) |
| 1.9.0-debug | x86_64, arm64v8, arm32v7 | v1.9.x releases (production + debug)                         |

It's strongly suggested that you always use the latest image of Fluent Bit.

Container images for Windows Server 2019 and Windows Server 2022 are provided for v2.0.6 and later. These can be found as tags on the same Docker Hub registry.

## Multi-architecture images

Fluent Bit production stable images are based on [Distroless](https://github.com/GoogleContainerTools/distroless). Focusing on security, these images contain only the Fluent Bit binary and minimal system libraries and basic configuration.

Debug images are available for all architectures (for 1.9.0 and later), and contain a full Debian shell and package manager that can be used to troubleshoot or for testing purposes.

From a deployment perspective, there's no need to specify an architecture. The container client tool that pulls the image gets the proper layer for the running architecture.

## Verify signed container images

Version 1.9 and 2.0 container images are signed using Cosign/Sigstore. Verify these signatures using `cosign` ([install guide](https://docs.sigstore.dev/quickstart/quickstart-cosign/)):

```shell
$ cosign verify --key "https://packages.fluentbit.io/fluentbit-cosign.pub" fluent/fluent-bit:2.0.6

Verification for index.docker.io/fluent/fluent-bit:2.0.6 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"index.docker.io/fluent/fluent-bit"},"image":{"docker-manifest-digest":"sha256:c740f90b07f42823d4ecf4d5e168f32ffb4b8bcd87bc41df8f5e3d14e8272903"},"type":"cosign container image signature"},"optional":{"release":"2.0.6","repo":"fluent/fluent-bit","workflow":"Release from staging"}}]
```

Replace `cosign` with the binary installed if it has a different name (for example, `cosign-linux-amd64`).

Keyless signing is also provided but is still experimental:

```shell
COSIGN_EXPERIMENTAL=1 cosign verify fluent/fluent-bit:2.0.6
```

`COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed in keyless mode. To learn more about keyless signing, see the [Sigstore keyless signature](https://docs.sigstore.dev/cosign/signing/overview/) documentation.

## Get started

1. Download the last stable image from 2.0 series:

   ```shell
   docker pull cr.fluentbit.io/fluent/fluent-bit:2.0
   ```

1. After the image is in place, run the following test which makes Fluent Bit measure CPU usage by the container:

   ```shell
   docker run -ti cr.fluentbit.io/fluent/fluent-bit:2.0 \
     -i cpu -o stdout -f 1
   ```

That command lets Fluent Bit measure CPU usage every second and flushes the results
to the standard output. For example:

```shell
[2019/10/01 12:29:02] [ info] [engine] started
[0] cpu.0: [1504290543.000487750, {"cpu_p"=>0.750000, "user_p"=>0.250000, "system_p"=>0.500000, "cpu0.p_cpu"=>0.000000, "cpu0.p_user"=>0.000000, "cpu0.p_system"=>0.000000, "cpu1.p_cpu"=>1.000000, "cpu1.p_user"=>0.000000, "cpu1.p_system"=>1.000000, "cpu2.p_cpu"=>1.000000, "cpu2.p_user"=>1.000000, "cpu2.p_system"=>0.000000, "cpu3.p_cpu"=>0.000000, "cpu3.p_user"=>0.000000, "cpu3.p_system"=>0.000000}]
```

## FAQ

### Why there is no Fluent Bit Docker image based on Alpine Linux?

Alpine Linux uses Musl C library instead of Glibc. Musl isn't fully compatible with Glibc, which generated many issues in the following areas when used with Fluent Bit:

- Memory Allocator: To run properly in high-load environments, Fluent Bit uses Jemalloc as a default memory allocator which reduces fragmentation and provides better performance. Jemalloc can't run smoothly with Musl and requires extra work.
- Alpine Linux Musl functions bootstrap have a compatibility issue when loading Golang shared libraries. This causes problems when trying to load Golang output plugins in Fluent Bit.
- Alpine Linux Musl Time format parser doesn't support Glibc extensions.
- The Fluent Bit maintainers' preference for base images are Distroless and Debian for security and maintenance reasons.

### Why use distroless containers?

The reasons for using distroless are well covered in
[Why should I use Distroless images?](https://github.com/GoogleContainerTools/distroless#why-should-i-use-distroless-images).

- Include only what you need, reduce the attack surface available.
- Reduces size and improves performance.
- Reduces false positives on scans (and reduces resources required for scanning).
- Reduces supply chain security requirements to only what you need.
- Helps prevent unauthorised processes or users interacting with the container.
- Less need to harden the container (and container runtime, K8s, and so on).
- Faster CI/CD processes.

With any choice, there are downsides:

- No shell or package manager to update or add things.
  - Generally, dynamic updating is a bad idea in containers as the time it's done affects the outcome: two containers started at different times using the same base image can perform differently or get different dependencies.
  - A better approach is to rebuild a new image version. You can do this with Distroless, but it's harder and requires multistage builds or similar to provide the new dependencies.
- Debugging can be harder.
  - More specifically you need applications set up to properly expose information for debugging rather than rely on traditional debug approaches of connecting to processes or dumping memory. This can be an upfront cost versus a runtime cost but does shift left in the development process so hopefully is a reduction overall.
- Assumption that Distroless is secure: nothing is secure and there are still exploits so it doesn't remove the need for securing your system.
- Sometimes you need to use a common base image, such as with audits, security, health, and so on.

Using `exec` to access a container will potentially impact resource limits.

For debugging, debug containers are available now in K8S:
<https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container>

- This can be a significantly different container from the one you want to investigate, with lots of extra tools or even a different base.
- No resource limits applied to this container, which can be good or bad.
- Runs in pod namespaces. It's another container that can access everything the others can.
- Might need architecture of the pod to share volumes or other information.
- Requires more recent versions of K8S and the container runtime plus RBAC allowing it.
