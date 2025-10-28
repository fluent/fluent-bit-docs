# Raspberry Pi

Fluent Bit is distributed as the `fluent-bit` package and is available for [Raspberry Pi](https://www.raspberrypi.com/software/operating-systems/). The following versions are supported:

- Raspbian Bookworm (12)
- Raspbian Bullseye (11)
- Raspbian Buster (10)

## Server GPG key

The first step is to add the Fluent Bit server GPG key to your keyring so you can get FLuent Bit signed packages:

```shell
sudo sh -c 'curl https://packages.fluentbit.io/fluentbit.key | sudo apt-key add - '
```

## Update your sources lists

On Debian and derivative systems such as Raspbian, you need to add the Fluent Bit APT server entry to your sources lists.

Add the following content at bottom of your `/etc/apt/sources.list` file.

### Raspbian 12 (Bookworm)

```shell
echo "deb https://packages.fluentbit.io/raspbian/bookworm bookworm main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Raspbian 11 (Bullseye)

```shell
echo "deb https://packages.fluentbit.io/raspbian/bullseye bullseye main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Raspbian 10 (Buster)

```shell
echo "deb https://packages.fluentbit.io/raspbian/buster buster main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Update your repositories database

Now let your system update the `apt` database:

```shell
sudo apt-get update
```

{% hint style="info" %}

Fluent Bit recommends upgrading your system (`sudo apt-get upgrade`) to avoid potential issues with expired certificates.

{% endhint %}

## Install Fluent Bit

1. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.

1. Use the following `apt-get` command to install the latest Fluent Bit:

   ```shell
   sudo apt-get install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

   ```shell
   sudo service fluent-bit start
   ```

If you do a status check, you should see a similar output like this:

```shell
$ sudo service fluent-bit status

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

The default configuration of Fluent Bit collects metrics for CPU usage and sends the
records to the standard output. You can see the outgoing data in your
`/var/log/syslog` file.
