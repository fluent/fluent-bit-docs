# Amazon Linux

## Install on Amazon Linux

Fluent Bit is distributed as the `fluent-bit` package and is available for the latest Amazon Linux 2 and Amazon Linux 2023. The following architectures are supported

- x86_64
- aarch64 / arm64v8

Amazon Linux 2022 is no longer supported.

The recommended secure deployment approach is to use the following instructions:

## Configure YUM

The `fluent-bit` is provided through a Yum repository. To add the repository reference to your system, add a new file called `fluent-bit.repo` in `/etc/yum.repos.d/` with the following content:

### Amazon Linux 2

```text
[fluent-bit]
  name = Fluent Bit
  baseurl = https://packages.fluentbit.io/amazonlinux/2/
  gpgcheck=1
  gpgkey=https://packages.fluentbit.io/fluentbit.key
  enabled=1
```

### Amazon Linux 2023

```text
[fluent-bit]
  name = Fluent Bit
  baseurl = https://packages.fluentbit.io/amazonlinux/2023/
  gpgcheck=1
  gpgkey=https://packages.fluentbit.io/fluentbit.key
  enabled=1
```

You should always enable `gpgcheck` for security reasons. All Fluent Bit packages are signed.

### Install

1. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.
1. After your repository is configured, run the following command to install it:

   ```shell
   sudo yum install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

```shell
sudo systemctl start fluent-bit
```

If you do a status check, you should see a similar output like this:

```shell
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
