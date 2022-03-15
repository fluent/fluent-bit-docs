# Amazon Linux

## Install on Amazon Linux 2

Fluent Bit is distributed as **fluent-bit** package and is available for the latest Amazon Linux 2. The following architectures are supported

* x86\_64
* aarch64 / arm64v8

## Configure Yum

We provide **fluent-bit** through a Yum repository. In order to add the repository reference to your system, please add a new file called _fluent-bit.repo_ in _/etc/yum.repos.d/_ with the following content:

```text
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

note: we encourage you always enable the _gpgcheck_ for security reasons. All our packages are signed.

### Updated key for 1.9 release onwards

From the 1.9 release please note that the GPG key has been updated at https://packages.fluentbit.io/fluentbit.key so ensure the new one is added.
The previous key is still available at https://packages.fluentbit.io/fluentbit-legacy.key and may be required to install previous versions.

### Install

Once your repository is configured, run the following command to install it:

```bash
$ yum install fluent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
$ sudo service fluent-bit start
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

