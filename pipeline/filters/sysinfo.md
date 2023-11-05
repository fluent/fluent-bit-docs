# Sysinfo

The _Sysinfo Filter_ plugin allows to append system information.

## Configuration Prameters

The plugin supports the following configuration parameters:

Some properties are supported by specific platform.

|Key|Description|Supported platform|
|---|---|---|
|fluentbit_version_key|Specify the key name for fluent-bit version.| All |
|os_name_key|Specify the key name for os name. e.g. linux, win64 or macos.| All |
|hostname_key|Specify the key name for hostname.| All|
|os_version_key|Specify the key name for os version. It is not supported on some platforms. | Linux |
|kernel_version_key|Specify the key name for kernel version. It is not supported on some platforms.| Linux |


## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.


The following configuration file is to append fluent-bit version and OS name.

```
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

You can also run the filter from command line.

```
fluent-bit -i dummy -o stdout -F sysinfo -m '*' -p fluentbit_version_key=flb_ver -p os_name_key=os_name
```

The output will be 
```
[0] dummy.0: [[1699172858.989654355, {}], {"message"=>"dummy", "flb_ver"=>"2.2.0", "os_name"=>"linux"}]
```