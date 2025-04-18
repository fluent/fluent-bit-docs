# Buildroot / Embedded Linux

Install Fluent Bit in your embedded Linux system.

## Install

To install, select Fluent Bit in your `defconfig`.
See the `Config.in` file for all configuration options.

```text
BR2_PACKAGE_FLUENT_BIT=y
```

## Run

The default configuration file is written to:

```text
/etc/fluent-bit/fluent-bit.conf
```

Fluent Bit is started by the `S99fluent-bit` script.

## Support

All configurations with a toolchain that supports threads and dynamic library
linking are supported.
