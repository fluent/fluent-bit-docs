# Rocky Linux and Alma Linux

Fluent Bit is distributed as the `fluent-bit` package and is available for the latest versions of Rocky or Alma Linux now that CentOS Stream is tracking more recent dependencies.

Fluent Bit supports the following architectures:

- `x86_64`
- `aarch64`
- `arm64v8`

## Single line install

Fluent Bit provides an installation script to use for most Linux targets. This will always install the most recently released version.

```shell
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is a convenience helper and should always be validated prior to use. Older versions of this install script won't support auto-detecting Rocky or Alma Linux. The recommended secure deployment approach is to use the following instructions:

## RHEL 9

From CentOS 9 Stream and later, the CentOS dependencies will update more often than
downstream usage. This might mean that incompatible (more recent) versions are
provided of certain dependencies (for example, OpenSSL). For OSS, there are RockyLinux
and AlmaLinux repositories. This might be required for RHEL 9 as well which will no
longer track equivalent CentOS 9 stream dependencies. No RHEL 9 build is provided, it
is expected to use one of the OSS variants listed.

## Configure YUM

The `fluent-bit` package is provided through a Yum repository. To add the repository reference to your system:

1. In `/etc/yum.repos.d/`, add a new file called `fluent-bit.repo`.
1. Add the following content to the file - replace `almalinux` with `rockylinux` if required:

   ```text
   [fluent-bit]
     name = Fluent Bit
     baseurl = https://packages.fluentbit.io/almalinux/$releasever/
     gpgcheck=1
     gpgkey=https://packages.fluentbit.io/fluentbit.key
     repo_gpgcheck=1
     enabled=1
   ```

1. As a best practice, enable `gpgcheck` and `repo_gpgcheck` for security reasons. Fluent Bit signs its repository metadata and all Fluent Bit packages.

## Install

1. After your repository is configured, run the following command to install it:

   ```shell
   sudo yum install fluent-bit
   ```

1. Instruct `Systemd` to enable the service:

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
           └─3820 /opt/fluent-bit/bin/fluent-bit -c etc/fluent-bit/fluent-bit.conf
...
```

The default Fluent Bit configuration collect metrics of CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/messages` file.