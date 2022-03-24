# Amazon Linux

## Install on Amazon Linux 2

Fluent Bit is distributed as **td-agent-bit** package and is available for the latest Amazon Linux 2. The following architectures are supported

* x86\_64
* aarch64 / arm64v8

## Configure Yum

We provide **td-agent-bit** through a Yum repository. In order to add the repository reference to your system, please add a new file called _td-agent-bit.repo_ in _/etc/yum.repos.d/_ with the following content:

```text
[td-agent-bit]
name = TD Agent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

note: we encourage you always enable the _gpgcheck_ for security reasons. All our packages are signed.

### Updated key from March 2022

From the 1.9.0 and 1.8.15 releases please note that the GPG key has been updated at [https://packages.fluentbit.io/fluentbit.key](https://packages.fluentbit.io/fluentbit.key) so ensure this new one is added.

The GPG Key fingerprint of the new key is:
```
C3C0 A285 34B9 293E AF51  FABD 9F9D DC08 3888 C1CD
Fluentbit releases (Releases signing key) <releases@fluentbit.io>
```

The previous key is still available at [https://packages.fluentbit.io/fluentbit-legacy.key](https://packages.fluentbit.io/fluentbit-legacy.key) and may be required to install previous versions.

The GPG Key fingerprint of the old key is:
```
F209 D876 2A60 CD49 E680 633B 4FF8 368B 6EA0 722A
```
Refer to the [supported platform documentation](./../supported-platforms.md) to see which platforms are supported in each release.

### Install

Once your repository is configured, run the following command to install it:

```bash
$ yum install td-agent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
$ sudo service td-agent-bit start
```

If you do a status check, you should see a similar output like this:

```bash
$ service td-agent-bit status
Redirecting to /bin/systemctl status  td-agent-bit.service
● td-agent-bit.service - TD Agent Bit
   Loaded: loaded (/usr/lib/systemd/system/td-agent-bit.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-07-07 02:08:01 BST; 9s ago
 Main PID: 3820 (td-agent-bit)
   CGroup: /system.slice/td-agent-bit.service
           └─3820 /opt/td-agent-bit/bin/td-agent-bit -c etc/td-agent-bit/td-agent-bit.conf
...
```

The default configuration of **td-agent-bit** is collecting metrics of CPU usage and sending the records to the standard output, you can see the outgoing data in your _/var/log/messages_ file.

