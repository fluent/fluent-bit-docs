# Linux Packages

A simple installation script is provided to be used for most Linux targets.
This will always install the most recent version released.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

If this fails or for more details on the installation then please refer to the specific section for your OS.

## GPG key updates

From the 1.9 release please note that the GPG key has been updated at https://packages.fluentbit.io/fluentbit.key so ensure the new one is added.
The previous key is still available at https://packages.fluentbit.io/fluentbit-legacy.key and may be required to install previous versions.

The fingerprint of the new key is:
```
C3C0 A285 34B9 293E AF51  FABD 9F9D DC08 3888 C1CD
Fluentbit releases (Releases signing key) <releases@fluentbit.io>
```
## Migration to Fluent Bit

From version 1.9, `td-agent-bit` is a deprecated package and will be removed in the future.
The correct package name to use now is `fluent-bit`.
Both are currently provided to allow migration.
