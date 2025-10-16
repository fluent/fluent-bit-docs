# openSUSE and SLES

Fluent Bit is distributed as the `fluent-bit` package and is available for the latest stable opensuse-leap and sles 15.7 system.

Fluent Bit supports the following architectures:

- `x86_64`
- `aarch64`
- `arm64v8`

For openSUSE 15, Fluent Bit uses [openSUSE Leap](https://get.opensuse.org/leap) as the canonical base system.

The recommended secure deployment approach is to use the following instructions:

## For openSUSE and SUSE Linux Enterprise Server (SLES)

Fluent Bit provides packages for openSUSE (Leap) and SUSE Linux Enterprise Server (SLES). The repository uses the $releasever variable to dynamically fetch packages for your specific system version.

## Configure `zypper`

The `fluent-bit` openSUSE package is provided through a `zypper` repository. To add the repository reference to your system:

1. Import the GPG key used to sign the packages.
1. In `/etc/zypp/repos.d/`, add a new file named `fluent-bit.repo`.
1. Add the following content to the file.
   ```text
   [fluent-bit]
     name = Fluent Bit
     baseurl = https://packages.fluentbit.io/suse/$releasever/
     gpgcheck=1
     gpgkey=https://packages.fluentbit.io/fluentbit.key
     repo_gpgcheck=1
     enabled=1
   ```
1. Refresh the repository to make the new packages available.
   ```text
   sudo zypper refresh
   ```
1. As a best practice, gpgcheck and repo_gpgcheck are enabled by default for security reasons. Fluent Bit signs its repository metadata and all Fluent Bit packages

## Install

Ensure you've configured an appropriate mirror. For example:

```shell
$ sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \

$ sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```

An alternative is to use Rocky or Alma Linux, which should be equivalent.

## SLES

For openSUSE and SUSE Linux Enterprise Server (SLES)

Fluent Bit provides packages for openSUSE (Leap) and SUSE Linux Enterprise Server (SLES). The repository uses the $releasever variable to dynamically fetch packages for your specific system version.

## Configure `zypper`

The`fluent-bit` package is provided through a Yum repository. To add the repository reference to your system:

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

### Install

1. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.

1. After your repository is configured, run the following command to install it:

   ```shell
   sudo dnf install fluent-bit
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

## FAQ

### Yum install fails with a `404 - Page not found` error for the package mirror

The `fluent-bit.repo` file for the latest installations of Fluent Bit uses a `$releasever` variable to determine the correct version of the package to install to your system:

```text
[fluent-bit]
  name = Fluent Bit
  baseurl = https://packages.fluentbit.io/centos/$releasever/$basearch/
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

CentOS 9 and later will no longer be compatible with RHEL 9 as it might track more recent dependencies. Alternative AlmaLinux and RockyLinux repositories are available.

See the previous guidance.
