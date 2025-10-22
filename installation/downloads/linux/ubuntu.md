# Ubuntu

Fluent Bit is distributed as the `fluent-bit` package and is available for long-term support releases of Ubuntu. The latest officially supported version is Noble Numbat (24.04).

The recommended secure deployment approach is to use the following instructions.

## Server GPG key

Add the Fluent Bit server GPG key to your keyring to ensure you can get the correct signed packages.

Follow the official [Debian wiki guidance](https://wiki.debian.org/DebianRepository/UseThirdParty#OpenPGP_Key_distribution).

```shell
sudo sh -c 'curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg'
```

## Update your sources lists

On Ubuntu, you need to add the Fluent Bit APT server entry to your sources lists.
Ensure `codename` is set to your specific [Ubuntu release name](https://wiki.ubuntu.com/Releases). For example, `focal` for Ubuntu 20.04.

```shell
codename=$(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release 2>/dev/null || lsb_release -cs 2>/dev/null)
```

Update your source's list:

```shell
echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/ubuntu/$codename $codename main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Update your repositories database

Update the `apt` database on your system:

```shell
sudo apt-get update
```

{% hint style="info" %}

Fluent Bit recommends upgrading your system to avoid potential issues with expired certificates:

`sudo apt-get upgrade`

If you receive the error `Certificate verification failed`, check if the package `ca-certificates` is properly installed:

`sudo apt-get install ca-certificates`

{% endhint %}

## Install Fluent Bit

1. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.

1. Use the following `apt-get` command to install the latest Fluent Bit:

   ```shell
   sudo apt-get install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

   ```shell
   sudo systemctl start fluent-bit
   ```

If you do a status check, you should see a similar output like this:

```shell
$ systemctl status fluent-bit

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

The default configuration of `fluent-bit` is collecting metrics of CPU usage and
sending the records to the standard output. You can see the outgoing data in your
`/var/log/syslog` file.
