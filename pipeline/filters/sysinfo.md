# Sysinfo

The _Sysinfo_ filter lets you append system information like the Fluent Bit version or hostname.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Supported platform |
| --- | --- | --- |
| `fluentbit_version_key` | Specify the key name for the Fluent Bit version.| All |
| `os_name_key` | Specify the key name for operating system name. For example, `Linux`, `win64` or `macos`.| All |
| `hostname_key`| Specify the key name for hostname. | All |
| `os_version_key` | Specify the key name for the operating system version. Not supported on some platforms. | Linux |
| `kernel_version_key` | Specify the key name for kernel version. Not supported on some platforms.| Linux |

Some properties are supported by specific platforms.

## Get started

To start filtering records, you can run the filter from the command line or through the configuration file.

The following configuration file is to append the Fluent Bit version and operating system name.

{% tabs %}
{% tab title="fluent-bit.conf" %}

```python
[INPUT]
    Name dummy
    Tag test

[FILTER]
    Name sysinfo
    Match *
    Fluentbit_version_key flb_ver
    Os_name_key os_name

[OUTPUT]
    name stdout
    match *
```

{% endtab %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          tag: test
    filters:
        - name: sysinfo
          match: '*'
          Fluentbit_version_key: flb_ver
          Os_name_key: os_name
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% endtabs %}

You can also run the filter from command line.

```shell
fluent-bit -i dummy -o stdout -F sysinfo -m '*' -p fluentbit_version_key=flb_ver -p os_name_key=os_name
```

The output will be something like the following:

```text
[0] dummy.0: [[1699172858.989654355, {}], {"message"=>"dummy", "flb_ver"=>"2.2.0", "os_name"=>"linux"}]
```
