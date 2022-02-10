# Linux Packages

A simple installation script is provided to be used for most Linux targets.
This will always install the most recent version released.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

If this fails or for more details on the installation then please refer to the specific section for your OS.

## Migration to Fluent Bit

From version 1.9, `td-agent-bit` is a deprecated package and will be removed in the future.
The correct package name to use now is `fluent-bit`.
Both are currently provided to allow migration.
