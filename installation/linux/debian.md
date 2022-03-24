# Debian

Fluent Bit is distributed as **td-agent-bit** package and is available for the latest \(and old\) stable Debian systems: Buster, Stretch and Jessie.

## Server GPG key

The first step is to add our server GPG key to your keyring, on that way you can get our signed packages:

```text
curl https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
```
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

## Update your sources lists

On Debian, you need to add our APT server entry to your sources lists, please add the following content at bottom of your **/etc/apt/sources.list** file:

#### Debian 10 \(Buster\)

```text
deb https://packages.fluentbit.io/debian/buster buster main
```

#### Debian 9 \(Stretch\)

```text
deb https://packages.fluentbit.io/debian/stretch stretch main
```

### Update your repositories database

Now let your system update the _apt_ database:

```bash
$ sudo apt-get update
```

{% hint style="info" %}
We recommend upgrading your system (```sudo apt-get upgrade```). This could avoid potential issues with expired certificates.
{% endhint %}


## Install TD Agent Bit

Using the following _apt-get_ command you are able now to install the latest _td-agent-bit_:

```text
$ sudo apt-get install td-agent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
$ sudo service td-agent-bit start
```

If you do a status check, you should see a similar output like this:

```bash
sudo service td-agent-bit status
● td-agent-bit.service - TD Agent Bit
   Loaded: loaded (/lib/systemd/system/td-agent-bit.service; disabled; vendor preset: enabled)
   Active: active (running) since mié 2016-07-06 16:58:25 CST; 2h 45min ago
 Main PID: 6739 (td-agent-bit)
    Tasks: 1
   Memory: 656.0K
      CPU: 1.393s
   CGroup: /system.slice/td-agent-bit.service
           └─6739 /opt/td-agent-bit/bin/td-agent-bit -c /etc/td-agent-bit/td-agent-bit.conf
...
```

The default configuration of **td-agent-bit** is collecting metrics of CPU usage and sending the records to the standard output, you can see the outgoing data in your _/var/log/syslog_ file.

