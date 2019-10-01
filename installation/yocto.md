# Yocto Project

[Fluent Bit](https://fluentbit.io) source code provides Bitbake recipes to configure, build and package the software for a Yocto based image. Note that specific steps of usage of these recipes in your Yocto environment \(Poky\) is out of the scope of this documentation.

We distribute two main recipes, one for testing/dev purposes and other with the latest stable release.

| Version | Recipe | Description |
| :--- | :--- | :--- |
| devel | [fluent-bit\_git.bb](https://github.com/fluent/fluent-bit/blob/master/fluent-bit_git.bb) | Build Fluent Bit from GIT master. This recipe aims to be used for development and testing purposes only. |
| v1.2.0 | [fluent-bit\_1.2.0.bb](https://github.com/fluent/fluent-bit/blob/1.2/fluent-bit_1.2.0.bb) | Build latest stable version of Fluent Bit. |

It's strongly recommended to always use the stable release of Fluent Bit recipe and not the one from GIT master for production deployments.

## Fluent Bit v1.1 and native ARMv8 \(aarch64\) support

Fluent Bit &gt;= v1.1.x already integrates native AArch64 support where stack switches for co-routines are done through native ASM calls, on this scenario there is no issues as the one faced in previous series.

