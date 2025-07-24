# Red Hat and CentOS

Fluent Bit is distributed as the `fluent-bit` package and is available for the latest stable CentOS system.

Fluent Bit supports the following architectures:

- `x86_64`
- `aarch64`
- `arm64v8`

For CentOS 9 and later, Fluent Bit uses [CentOS Stream](https://www.centos.org/centos-stream/) as the canonical base system.

## Single line install

Fluent Bit provides an installation script to use for most Linux targets. This will always install the most recently released version.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is a convenience helper and should always be validated prior to use. The recommended secure deployment approach is to use the following instructions:

## CentOS 8

CentOS 8 is now end-of-life, so the default Yum repositories are unavailable.

Ensure you've configured an appropriate mirror. For example:

```shell
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```

An alternative is to use Rocky or Alma Linux, which should be equivalent.

## RHEL/AlmaLinux/RockyLinux and CentOS 9 Stream

From CentOS 9 Stream onwards, the CentOS dependencies will update more often than downstream usage. This may mean that incompatible (more recent) versions are provided of certain dependencies (e.g. OpenSSL). For OSS, we also provide RockyLinux and AlmaLinux repositories.

Replace the `centos` string in Yum configuration below with `almalinux` or `rockylinux` to use those repositories instead. This may be required for RHEL 9 as well which will no longer track equivalent CentOS 9 stream dependencies. No RHEL 9 build is provided, it is expected to use one of the OSS variants listed.

## Configure Yum

The `fluent-bit` is provided through a Yum repository. To add the repository reference to your system:

1. In `/etc/yum.repos.d/`, add a new file called `fluent-bit.repo`.
1. Add the following content to the file:

   ```text
   [fluent-bit]
   name = Fluent Bit
   baseurl = https://packages.fluentbit.io/centos/$releasever/
   gpgcheck=1
   gpgkey=https://packages.fluentbit.io/fluentbit.key
   repo_gpgcheck=1
   enabled=1
   ```

1. As a best practice, enable `gpgcheck` and `repo_gpgcheck` for security reasons. Fluent Bit signs its repository metadata and all Fluent Bit packages.

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

   ```bash
   sudo yum install fluent-bit
   ```

1. Instruct `Systemd` to enable the service:

   ```bash
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
           └─3820 /opt/fluent-bit/bin/fluent-bit -c etc/fluent-bit/fluent-bit.conf
...
```

The default Fluent Bit configuration collect metrics of CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/messages` file.

## FAQ

### Yum install fails with a "404 - Page not found" error for the package mirror

The `fluent-bit.repo` file for the latest installations of Fluent Bit uses a `$releasever` variable to determine the correct version of the package to install to your system:

```text
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/centos/$releasever/$basearch/
...
```

Depending on your Red Hat distribution version, this variable can return a value other than the OS major release version (for example, RHEL7 Server distributions return `7Server` instead of `7`). The Fluent Bit package URL uses the major OS release version, so any other value here will cause a 404.

To resolve this issue, replace the `$releasever` variable with your system's OS major release version. For example:

```text
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/centos/7/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
repo_gpgcheck=1
enabled=1
```

### Yum install fails with incompatible dependencies using CentOS 9+

CentOS 9 onwards will no longer be compatible with RHEL 9 as it may track more recent dependencies. Alternative AlmaLinux and RockyLinux repositories are available.

See the guidance above.
