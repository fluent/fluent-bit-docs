# Linux Packages

The most secure option is to create the repositories according to the instructions for your specific OS.

A simple installation script is provided to be used for most Linux targets.
This will by default install the most recent version released.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is purely a convenience helper and should always be validated prior to use.

## GPG key updates

From the 1.9.0 and 1.8.15 releases please note that the GPG key has been updated at [https://packages.fluentbit.io/fluentbit.key](https://packages.fluentbit.io/fluentbit.key) so ensure this new one is added.

The GPG Key fingerprint of the new key is:

```text
C3C0 A285 34B9 293E AF51  FABD 9F9D DC08 3888 C1CD
Fluentbit releases (Releases signing key) <releases@fluentbit.io>
```

The previous key is still available at [https://packages.fluentbit.io/fluentbit-legacy.key](https://packages.fluentbit.io/fluentbit-legacy.key) and may be required to install previous versions.

The GPG Key fingerprint of the old key is:

```text
F209 D876 2A60 CD49 E680 633B 4FF8 368B 6EA0 722A
```

Refer to the [supported platform documentation](./../supported-platforms.md) to see which platforms are supported in each release.

## Migration to Fluent Bit

From version 1.9, `td-agent-bit` is a deprecated package and is removed after 1.9.9.
The correct package name to use now is `fluent-bit`.
