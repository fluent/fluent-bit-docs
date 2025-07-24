# Raspbian and Raspberry Pi

Fluent Bit is distributed as the `fluent-bit` package and is available for the Raspberry, specifically for [Raspbian](http://raspbian.org) distribution. The following versions are supported:

* Raspbian Bookworm (12)
* Raspbian Bullseye (11)
* Raspbian Buster (10)

## Server GPG key

The first step is to add the Fluent Bit server GPG key to your keyring so you can get FLuent Bit signed packages:

```shell
sudo sh -c 'curl https://packages.fluentbit.io/fluentbit.key | sudo apt-key add - '
```

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

Refer to the [supported platform documentation](./../supported-platforms.md) to see which platforms are supported in each release.

## Update your sources lists

On Debian and derivative systems such as Raspbian, you need to add the Fluent Bit APT server entry to your sources lists.

Add the following content at bottom of your `/etc/apt/sources.list` file.

### Raspbian 12 (Bookworm)

```text
echo "deb https://packages.fluentbit.io/raspbian/bookworm bookworm main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Raspbian 11 (Bullseye)

```text
echo "deb https://packages.fluentbit.io/raspbian/bullseye bullseye main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Raspbian 10 (Buster)

```text
echo "deb https://packages.fluentbit.io/raspbian/buster buster main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Update your repositories database

Now let your system update the `apt` database:

```bash
sudo apt-get update
```

{% hint style="info" %}
Fluent Bit recommends upgrading your system (`sudo apt-get upgrade`) to avoid potential issues with expired certificates.
{% endhint %}

## Install Fluent Bit

1. Use the following `apt-get` command to install the latest Fluent Bit:

   ```shell
   sudo apt-get install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

   ```bash
   sudo service fluent-bit start
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

The default configuration of Fluent Bit collects metrics for CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/syslog` file.
