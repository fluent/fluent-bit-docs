# Buildroot / Embedded Linux

## Installing

To install, just select fluent-bit in your defconfig.
See the Config.in file for all configuration options.

```defconfig
BR2_PACKAGE_FLUENT_BIT=y
```

## Running

The default config file is written to:

```
/etc/fluent-bit/fluent-bit.conf
```

Fluent-bit is automatically started by the S99fluent-bit script.

## Support

All configurations with a toolchain that supports threads and dynamic library linking are supported.
