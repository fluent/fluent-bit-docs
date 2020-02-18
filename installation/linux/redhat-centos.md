# Redhat / CentOS

## Install on Redhat / CentOS

Fluent Bit is distributed as **td-agent-bit** package and is available for the latest stable CentOS system. This stable Fluent Bit distribution package is maintained by [Treasure Data, Inc](https://www.treasuredata.com).

## Configure Yum

We provide **td-agent-bit** through a Yum repository. In order to add the repository reference to your system, please add a new file called _td-agent-bit.repo_ in _/etc/yum.repos.d/_ with the following content:

```text
[td-agent-bit]
name = TD Agent Bit
baseurl = https://packages.fluentbit.io/centos/7
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
```

note: we encourage you always enable the _gpgcheck_ for security reasons. All our packages are signed.

The GPG Key fingerprint is `F209 D876 2A60 CD49 E680 633B 4FF8 368B 6EA0 722A`

### Install

Once your repository is configured, run the following command to install it:

```bash
$ yum install td-agent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
$ service td-agent-bit start
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

