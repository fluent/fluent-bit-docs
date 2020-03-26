# InfluxDB

The **influxdb** output plugin, allows to flush your records into a [InfluxDB](https://www.influxdata.com/time-series-platform/influxdb/) time series database. The following instructions assumes that you have a fully operational InfluxDB service running in your system.

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Host | IP address or hostname of the target InfluxDB service | 127.0.0.1 |
| Port | TCP port of the target InfluxDB service | 8086 |
| Database | InfluxDB database name where records will be inserted | fluentbit |
| Sequence\_Tag | The name of the tag whose value is incremented for the consecutive simultaneous events. | \_seq |
| HTTP\_User | Optional username for HTTP Basic Authentication |  |
| HTTP\_Passwd | Password for user defined in HTTP\_User |  |
| Tag\_Keys | Space separated list of keys that needs to be tagged |  |
| Auto\_Tags | Automatically tag keys where value is _string_. This option takes a boolean value: True/False, On/Off. | Off |

### TLS / SSL

InfluxDB output plugin supports TTL/SSL, for more details about the properties available and general configuration, please refer to the [TLS/SSL](https://github.com/fluent/fluent-bit-docs/tree/16f30161dc4c79d407cd9c586a0c6839d0969d97/pipeline/configuration/tls_ssl.md) section.

## Getting Started

In order to start inserting records into an InfluxDB service, you can run the plugin from the command line or through the configuration file:

### Command Line

The **influxdb** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\) or setting them directly through the service URI. The URI format is the following:

```text
influxdb://host:port
```

Using the format specified, you could start Fluent Bit through:

```text
$ fluent-bit -i cpu -t cpu -o influxdb://127.0.0.1:8086 -m '*'
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```python
[INPUT]
    Name  cpu
    Tag   cpu

[OUTPUT]
    Name          influxdb
    Match         *
    Host          127.0.0.1
    Port          8086
    Database      fluentbit
    Sequence_Tag  _seq
```

#### Tagging

Basic example of `Tag_Keys` usage:

```python
[INPUT]
    Name            tail
    Tag             apache.access
    parser          apache2
    path            /var/log/apache2/access.log

[OUTPUT]
    Name          influxdb
    Match         *
    Host          127.0.0.1
    Port          8086
    Database      fluentbit
    Sequence_Tag  _seq
    # make tags from method and path fields
    Tag_Keys      method path
```

With **Auto\_Tags=On** in this example cause error, because every parsed field value type is _string_. Best usage of this option in metrics like record where one ore more field value is not _string_ typed.

### Testing

Before to start Fluent Bit, make sure the target database exists on InfluxDB, using the above example, we will insert the data into a _fluentbit_ database.

#### 1. Create database

Log into InfluxDB console:

```text
$ influx
Visit https://enterprise.influxdata.com to register for updates, InfluxDB server management, and monitoring.
Connected to http://localhost:8086 version 1.1.0
InfluxDB shell version: 1.1.0
>
```

Create the database:

```text
> create database fluentbit
>
```

Check the database exists:

```text
> show databases
name: databases
name
----
_internal
fluentbit

>
```

#### 2. Run Fluent Bit

The following command will gather CPU metrics from the system and send the data to InfluxDB database every five seconds:

```text
$ bin/fluent-bit -i cpu -t cpu -o influxdb -m '*'
```

Note that all records coming from the _cpu_ input plugin, have a tag _cpu_, this tag is used to generate the measurement in InfluxDB

#### 3. Query the data

From InfluxDB console, choose your database:

```text
> use fluentbit
Using database fluentbit
```

Now query some specific fields:

```text
> SELECT cpu_p, system_p, user_p FROM cpu
name: cpu
time                  cpu_p   system_p    user_p
----                  -----   --------    ------
1481132860000000000   2.75        0.5      2.25
1481132861000000000   2           0.5      1.5
1481132862000000000   4.75        1.5      3.25
1481132863000000000   6.75        1.25     5.5
1481132864000000000   11.25       3.75     7.5
```

The CPU input plugin gather more metrics per CPU core, in the above example we just selected three specific metrics. The following query will give a full result:

```text
> SELECT * FROM cpu
```

#### 4. View tags

Query tagged keys:

```text
> SHOW TAG KEYS ON fluentbit FROM "apache.access"
name: apache.access
tagKey
------
_seq
method
path
```

And now query _method_ key values:

```text
> SHOW TAG VALUES ON fluentbit FROM "apache.access" WITH KEY = "method"
name: apache.access
key    value
---    -----
method "MATCH"
method "POST"
```

