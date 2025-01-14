# Yocto embedded Linux

[Fluent Bit](https://fluentbit.io) source code provides BitBake recipes to configure,
build, and package the software for a Yocto-based image. Specific steps in the
usage of these recipes in your Yocto environment (Poky) is out of the scope of this
documentation.

Fluent Bit distributes two main recipes, one for testing/dev purposes and
one with the latest stable release.

| Version | Recipe | Description |
| :--- | :--- | :--- |
| `devel` | [fluent-bit\_git.bb](https://github.com/fluent/fluent-bit/blob/master/fluent-bit_git.bb) | Build Fluent Bit from Git master. Use for development and testing purposes only. |
| `v1.8.11` | [fluent-bit\_1.8.11.bb](https://github.com/fluent/fluent-bit/blob/v1.8.11/fluent-bit_1.8.11.bb) | Build latest stable version of Fluent Bit. |

It's strongly recommended to always use the stable release of the Fluent Bit recipe
and not the one from Git master for production deployments.

## Fluent Bit and other architectures

Fluent Bit &gt;= v1.1.x fully supports `x86_64`, `x86`, `arm32v7`, and `arm64v8`.
