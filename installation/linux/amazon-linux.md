# Amazon Linux

## Install on Amazon Linux

Fluent Bit is distributed as **fluent-bit** package and is available for the latest Amazon Linux 2 and Amazon Linux 2022. The following architectures are supported

* x86\_64
* aarch64 / arm64v8

## Single line install

A simple installation script is provided to be used for most Linux targets.
This will always install the most recent version released.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is purely a convenience helper and should always be validated prior to use.
The recommended secure deployment approach is to follow the instructions below.

## Configure Yum

We provide **fluent-bit** through a Yum repository. In order to add the repository reference to your system, please add a new file called _fluent-bit.repo_ in _/etc/yum.repos.d/_ with the following content:

### Amazon Linux 2

```config
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

### Amazon Linux 2022

```config
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2022/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

Note: we encourage you always enable the _gpgcheck_ for security reasons. All our packages are signed.

### Updated key from March 2022

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

Refer to the [supported platform documentation](../supported-platforms.md) to see which platforms are supported in each release.

### Install

Once your repository is configured, run the following command to install it:

```bash
yum install fluent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
sudo service fluent-bit start
```

If you do a status check, you should see a similar output like this:

```bash
$ service fluent-bit status
Redirecting to /bin/systemctl status  fluent-bit.service
● fluent-bit.service - Fluent Bit
   Loaded: loaded (/usr/lib/systemd/system/fluent-bit.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-07-07 02:08:01 BST; 9s ago
 Main PID: 3820 (fluent-bit)
   CGroup: /system.slice/fluent-bit.service
           └─3820 /opt/fluent-bit/bin/fluent-bit -c etc/fluent-bit/fluent-bit.conf
...
```

The default configuration of **fluent-bit** is collecting metrics of CPU usage and sending the records to the standard output, you can see the outgoing data in your _/var/log/messages_ file.
