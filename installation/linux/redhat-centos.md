# Redhat / CentOS

## Install on Redhat / CentOS

Fluent Bit is distributed as **fluent-bit** package and is available for the latest stable CentOS system. The following architectures are supported

* x86\_64
* aarch64 / arm64v8

## Configure Yum

We provide **fluent-bit** through a Yum repository. In order to add the repository reference to your system, please add a new file called _fluent-bit.repo_ in _/etc/yum.repos.d/_ with the following content:

```text
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/centos/7/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

It is best practice to always enable the _gpgcheck_ for security reasons.
All our packages are signed.

### Install

Once your repository is configured, run the following command to install it:

```bash
$ yum install fluent-bit
```

Now the following step is to instruct _Systemd_ to enable the service:

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

