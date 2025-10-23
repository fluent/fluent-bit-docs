# SNMP

The _SNMP_ input plugin lets you collect metrics from devices by SNMP (Simple Network Management Protocol) request.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Target_Host`  | The target host IP to send the request. | `127.0.0.1` |
| `Port` | The port to send the request. | `161` |
| `Timeout` | The timeout of the request in seconds. | `5` |
| `Version` | The SNMP version to use for the request. Supported versions: `1` and `2c`. |  `2c` |
| `Community` | The SNMP community setting to use for the request. | `public` |
| `Retries` |The number of retries for the request. | `3` |
| `Oid_Type` | The type of SNMP request to send, current support `get` ([snmpget](https://net-snmp.sourceforge.io/wiki/index.php/TUT:snmpget)) and `walk` ([snmpwalk](https://net-snmp.sourceforge.io/wiki/index.php/TUT:snmpwalk)). | `get` |
| `Oid` | The SNMP OID (Object Identifier) setting to use for the request. | `1.3.6.1.2.1.1.3.0` (System up time) |

## Get started

You can run the plugin from the command line or through the configuration file:

### Command line

```bash
$ fluent-bit -i snmp -o stdout
Fluent Bit v2.x.x
* Copyright (C) 2015-2022 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io
[0] snmp.test: [[1689404515.194358800, {}], {"iso.3.6.1.2.1.1.3.0"=>"58"}]
[0] snmp.test: [[1689404516.194328000, {}], {"iso.3.6.1.2.1.1.3.0"=>"59"}]
```

### Configuration file

In your main configuration file append the following sections:

```python
[INPUT]
    Name            snmp
    Tag             snmp.test
    Target_Host     192.168.0.1
    Community       public
    Oid_Type        get
    Oid             1.3.6.1.2.1.1.3.0

[OUTPUT]
    Name    stdout
    Match   *
```
