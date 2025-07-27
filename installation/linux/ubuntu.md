# Ubuntu

Fluent Bit is distributed as the `fluent-bit` package and is available for long-term support releases of Ubuntu. The latest officially supported version is Noble Numbat (24.04).

## Single line install

An installation script is provided for most Linux targets. This will always install the most recent version released.

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

This is purely a convenience helper and should always be validated prior to use. The recommended secure deployment approach is to use the following instructions.

## Server GPG key

The first step is to add the Fluent Bit server GPG key to your keyring to ensure you can get the correct signed packages.

Follow the official [Debian wiki guidance](https://wiki.debian.org/DebianRepository/UseThirdParty#OpenPGP_Key_distribution).

```bash
sudo sh -c 'curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg'
```

### Updated key from March 2022

For releases 1.9.0 and 1.8.15 and later, the [GPG key has been updated](https://packages.fluentbit.io/fluentbit.key). Ensure the new key is added.

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

Refer to the [supported platform documentation](../supported-platforms.md) to see which platforms are supported in each release.

## Update your sources lists

On Ubuntu, you need to add the Fluent Bit APT server entry to your sources lists. Ensure `CODENAME` is set to your specific [Ubuntu release name](https://wiki.ubuntu.com/Releases). For example, `focal` for Ubuntu 20.04.

```bash
echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/ubuntu/$(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release || lsb_release -cs) $(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list
```

### Update your repositories database

Update the `apt` database on your system:

```bash
sudo apt-get update
```

{% hint style="info" %}
Fluent Bit recommends upgrading your system to avoid potential issues with expired certificates:

`sudo apt-get upgrade`


If you receive the error `Certificate verification failed`, check if the package `ca-certificates` is properly installed:

`sudo apt-get install ca-certificates`
{% endhint %}

## Install Fluent Bit

1. Use the following `apt-get` command to install the latest Fluent Bit:

   ```bash copy
   sudo apt-get install fluent-bit
   ```

1. Instruct `systemd` to enable the service:

   ```bash copy
   sudo systemctl start fluent-bit
   ```

If you do a status check, you should see a similar output like this:

```bash
systemctl status fluent-bit
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

The default configuration of `fluent-bit` is collecting metrics of CPU usage and sending the records to the standard output. You can see the outgoing data in your `/var/log/syslog` file.
