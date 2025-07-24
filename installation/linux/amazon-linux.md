# Amazon Linux

## Install on Amazon Linux

Fluent Bit is distributed as the `fluent-bit` package and is available for the latest Amazon Linux 2 and Amazon Linux 2023. The following architectures are supported

- x86_64
- aarch64 / arm64v8

Amazon Linux 2022 is no longer supported.

## Single line install

Fluent Bit provides an installation script to use for most Linux targets. This will always install the most recently released version.

```bash copy
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is a convenience helper and should always be validated prior to use. The recommended secure deployment approach is to use the following instructions:

## Configure Yum

The `fluent-bit` is provided through a Yum repository. To add the repository reference to your system, add a new file called `fluent-bit.repo` in `/etc/yum.repos.d/` with the following content:

### Amazon Linux 2

```text copy
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

### Amazon Linux 2023

```text copy
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2023/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

You should always enable `gpgcheck` for security reasons. All Fluent Bit packages are signed.

### Updated key from March 2022

For the 1.9.0 and 1.8.15 and later releases, the [GPG key has been updated](https://packages.fluentbit.io/fluentbit.key). Ensure this new one is added.

The GPG Key fingerprint of the new key is:

```text
C3C0 A285 34B9 293E AF51  FABD 9F9D DC08 3888 C1CD
Fluentbit releases (Releases signing key) <releases@fluentbit.io>
```

The previous key is [still available](https://packages.fluentbit.io/fluentbit-legacy.key) and might be required to install previous versions.

The GPG Key fingerprint of the old key is:

```text
F209 D876 2A60 CD49 E680 633B 4FF8 368B 6EA0 722A
```

Refer to the [supported platform documentation](../supported-platforms.md) to see which platforms are supported in each release.

### Install

1. After your repository is configured, run the following command to install it:

   ```bash copy
   sudo yum install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

```bash copy
sudo systemctl start fluent-bit
```

If you do a status check, you should see a similar output like this:

```bash
$ systemctl status fluent-bit
● fluent-bit.service - Fluent Bit
   Loaded: loaded (/usr/lib/systemd/system/fluent-bit.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-07-07 02:08:01 BST; 9s ago
 Main PID: 3820 (fluent-bit)
   CGroup: /system.slice/fluent-bit.service
           └─3820 /opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf
...
```

The default Fluent Bit configuration collect metrics of CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/messages` file.
