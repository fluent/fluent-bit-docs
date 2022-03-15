# Raspbian / Raspberry Pi

Fluent Bit is distributed as **fluent-bit** package and is available for the Raspberry, specifically for [Raspbian](http://raspbian.org) distribution, the following versions are supported:

* Raspbian Bullseye \(11\)
* Raspbian Buster \(10\)

## Server GPG key

The first step is to add our server GPG key to your keyring, on that way you can get our signed packages:

```text
curl https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
```

### Updated key for 1.9 release onwards

From the 1.9 release please note that the GPG key has been updated at https://packages.fluentbit.io/fluentbit.key so ensure the new one is added.
The previous key is still available at https://packages.fluentbit.io/fluentbit-legacy.key and may be required to install previous versions.

## Update your sources lists

On Debian and derivative systems such as Raspbian, you need to add our APT server entry to your sources lists, please add the following content at bottom of your **/etc/apt/sources.list** file.

#### Raspbian 11 \(Bullseye\)

```text
deb https://packages.fluentbit.io/raspbian/bullseye bullseye main
```

#### Raspbian 10 \(Buster\)

```text
deb https://packages.fluentbit.io/raspbian/buster buster main
```

### Update your repositories database

Now let your system update the _apt_ database:

```bash
$ sudo apt-get update
```

{% hint style="info" %}
We recommend upgrading your system (```sudo apt-get upgrade```). This could avoid potential issues with expired certificates.
{% endhint %}


## Install Fluent Bit

Using the following _apt-get_ command you are able now to install the latest _fluent-bit_:

```text
$ sudo apt-get install fluent-bit
```

Now the following step is to instruct _systemd_ to enable the service:

```bash
$ sudo service fluent-bit start
```

If you do a status check, you should see a similar output like this:

```bash
sudo service fluent-bit status
● fluent-bit.service - Fluent Bit
   Loaded: loaded (/lib/systemd/system/fluent-bit.service; disabled; vendor preset: enabled)
   Active: active (running) since mié 2016-07-06 16:58:25 CST; 2h 45min ago
 Main PID: 6739 (fluent-bit)
    Tasks: 1
   Memory: 656.0K
      CPU: 1.393s
   CGroup: /system.slice/fluent-bit.service
           └─6739 /opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf
...
```

The default configuration of **fluent-bit** is collecting metrics of CPU usage and sending the records to the standard output, you can see the outgoing data in your _/var/log/syslog_ file.

