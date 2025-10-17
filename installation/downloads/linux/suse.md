# openSUSE and SUSE Linux Enterprise Server (SLES)

Fluent Bit is distributed as the `fluent-bit` package and is available for OpenSUSE-Leap 15.6 and SLES 15.7 systems.

Fluent Bit supports the following architectures:

- `x86_64`
- `aarch64`

Fluent Bit supports the following distro versions:

- opensuse/leap:15.6
- sles/15.7

For openSUSE, Fluent Bit uses [openSUSE Leap Base Container Images (BCI)](https://build.opensuse.org/project/show/openSUSE:Containers:Leap) as the canonical base system.

For SLES, Fluent Bit uses [SUSE Base Container Images (BCI)](https://www.suse.com/products/base-container-images/) as the canonical base system.

The recommended secure deployment approach is to use the following instructions:

## Ensure you select the correct openSUSE verse SLES Package

The openSUSE package is built and tested specifically for openSUSE Leap environments, ensuring compatibility with openSUSE libraries, update cycles, and system dependencies. Using the openSUSE package on openSUSE Leap systems helps avoid potential issues with mismatched dependencies or unsupported features that may arise from using SLES packages.

The SLES package is tailored for SUSE Linux Enterprise Server and is built against the SUSE Base Container Image, which may include different versions of libraries. It uses enterprise repositories with specific package versions, while Leap uses free, community driven repositories that have a broader range of packages. Installing the SLES package on openSUSE Leap is not recommended, as it may lead to library incompatibilities.


**In summary:**  
- Use the openSUSE package for openSUSE Leap systems.  
- Use the SLES package for SUSE Linux Enterprise Server systems.

This ensures you receive the correct updates and compatibility for your chosen platform.


## openSUSE Leap

Ensure your system repositories are up to date. For openSUSE Leap, use the following repository path:

- `https://packages.fluentbit.io/opensuse/leap/$releaserver`

### Configure Zypper for openSUSE Leap

1. In `/etc/zypp/repos.d/`, add a new file called `fluent-bit.repo`.
1. Add the following content to the file (replace `$releaserver` with your Leap version, e.g., `15.6`):

   ```text
   [fluent-bit]
     name=Fluent Bit
     baseurl=https://packages.fluentbit.io/opensuse/leap/$releaserver/
     gpgcheck=1
     repo_gpgcheck=1
     gpgkey=https://packages.fluentbit.io/fluentbit.key
     enabled=1
   ```

1. As a best practice, enable `gpgcheck` for security reasons. Fluent Bit signs its repository metadata and all Fluent Bit packages.

## SUSE Linux Enterprise Server (SLES)

Ensure your system repositories are up to date. For SLES, use the following repository path:

- `https://packages.fluentbit.io/sles/$releasever`

### Configure Zypper for SLES

1. In `/etc/zypp/repos.d/`, add a new file called `fluent-bit.repo`.
1. Add the following content to the file:

   ```text
   [fluent-bit]
     name=Fluent Bit
     baseurl=https://packages.fluentbit.io/sles/$releasever/
     gpgcheck=1
     repo_gpgcheck=1
     gpgkey=https://packages.fluentbit.io/fluentbit.key
     enabled=1
   ```

1. As a best practice, enable `gpgcheck` for security reasons. Fluent Bit signs its repository metadata and all Fluent Bit packages.   

### Install Fluent Bit

1. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.

1. After your repository is configured, run the following command to install it:

   ```shell
   sudo zypper refresh
   sudo zypper install fluent-bit
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

The default Fluent Bit configuration collects metrics of CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/messages` file.

## FAQ

### Zypper install fails with a `404 - Page not found` error for the package mirror

Ensure you use the correct `$releaserver` (e.g., `15.6`) in your repo path:

For openSUSE Leap:

```text
baseurl=https://packages.fluentbit.io/opensuse/leap/15.6/
```

For SLES

```text
baseurl=https://packages.fluentbit.io/sles/15.7/
```

zypper knows about special variables like $releasever. It has its own internal logic to replace these with the correct values from your system's baseproduct file.

### Zypper install fails with incompatible dependencies

OpenSUSE may track more recent dependencies than SLES. If you encounter dependency issues, ensure you are using the correct repository path for your OS distro.
