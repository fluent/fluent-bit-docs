# Yocto / Embedded Linux

[Fluent Bit](https://fluentbit.io) source code provides Bitbake recipes to configure, build and package the software for a Yocto based image. Note that specific steps of usage of these recipes in your Yocto environment \(Poky\) is out of the scope of this documentation.

We distribute two main recipes, one for testing/dev purposes and other with the latest stable release.

| Version | Recipe | Description |
| :--- | :--- | :--- |
| devel | [fluent-bit\_git.bb](https://github.com/fluent/fluent-bit/blob/master/fluent-bit_git.bb) | Build Fluent Bit from GIT master. This recipe aims to be used for development and testing purposes only. |
| v1.7.4 | [fluent-bit\_1.7.4.bb](https://github.com/fluent/fluent-bit/blob/v1.7.4/fluent-bit_1.7.4.bb) | Build latest stable version of Fluent Bit. |

It's strongly recommended to always use the stable release of Fluent Bit recipe and not the one from GIT master for production deployments.

## Fluent Bit and other architectures

Fluent Bit &gt;= v1.1.x fully supports x86\_64, x86, arm32v7 and arm64v8.

