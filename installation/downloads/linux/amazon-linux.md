# Amazon Linux

Fluent Bit is distributed as the `fluent-bit` package and is available for Amazon Linux 2 and Amazon Linux 2023. The following architectures are supported:

- x86_64
- aarch64 / arm64v8

## Install on Amazon EC2

To install Fluent Bit and related AWS output plugins on Amazon Linux 2 on EC2 using AWS Systems Manager, follow [this AWS guide](https://github.com/aws/aws-for-fluent-bit/tree/mainline/examples/fluent-bit/systems-manager-ec2).

## General installation

To install Fluent Bit on any Amazon Linux instance, follow these steps.

<!-- markdownlint-disable MD029 -->

1. Fluent Bit is provided through a Yum repository. To add the repository reference to your system, add a new file called `fluent-bit.repo` in `/etc/yum.repos.d/` with the following content:

{% tabs %}
{% tab title="Amazon Linux 2" %}

```text
[fluent-bit]
  name = Fluent Bit
  baseurl = https://packages.fluentbit.io/amazonlinux/2/
  gpgcheck=1
  gpgkey=https://packages.fluentbit.io/fluentbit.key
  enabled=1
```

{% endtab %}
{% tab title="Amazon Linux 2023" %}

```text
[fluent-bit]
  name = Fluent Bit
  baseurl = https://packages.fluentbit.io/amazonlinux/2023/
  gpgcheck=1
  gpgkey=https://packages.fluentbit.io/fluentbit.key
  enabled=1
```

{% endtab %}
{% endtabs %}

{% hint style="info" %}

You should always enable `gpgcheck` for security reasons. All Fluent Bit packages are signed.

{% endhint %}

2. Ensure your [GPG key](../linux.md#gpg-key-updates) is up to date.
3. After your repository is configured, run the following command to install it:

   ```shell
   sudo yum install fluent-bit
   ```

4. Instruct `systemd` to enable the service:

```shell
sudo systemctl start fluent-bit
```

If you do a status check, you should see a similar output like this:

```shell
$ systemctl status fluent-bit

● fluent-bit.service - Fluent Bit
   Loaded: loaded (/usr/lib/systemd/system/fluent-bit.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-07-07 02:08:01 BST; 9s ago
 Main PID: 3820 (fluent-bit)
   CGroup: /system.slice/fluent-bit.service
           └─3820 /opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf
...
```

The default Fluent Bit configuration collect metrics of CPU usage and sends the records to the standard output. You can see the outgoing data in your `/var/log/messages` file.

<!-- markdownlint-enable MD029 -->
