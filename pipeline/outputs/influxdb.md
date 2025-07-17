# InfluxDB

The _InfluxDB_ output plugin lets you flush your records into a [InfluxDB](https://www.influxdata.com/time-series-platform/influxdb/) time series database. The following instructions assumes that you have an operational InfluxDB service running in your system.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Host` | IP address or hostname of the target InfluxDB service. | `127.0.0.1` |
| `Port` | TCP port of the target InfluxDB service. | `8086` |
| `Database` | InfluxDB database name where records will be inserted | `fluentbit` |
| `Bucket` | InfluxDB bucket name where records will be inserted. If specified, `database` is ignored and v2 of API is used. | _none_ |
| `Org` | InfluxDB organization name where the bucket is (v2 only). | `fluent` |
| `Sequence_Tag` | The name of the tag whose value is incremented for the consecutive simultaneous events. | `_seq` |
| `HTTP_User` | Optional username for HTTP Basic Authentication. | _none_ |
| `HTTP_Passwd` | Password for user defined in `HTTP_User`. | _none_ |
| `HTTP_Token` | Authentication token used with InfluxDB v2. If specified, both `HTTP_User` and `HTTP_Passwd` are ignored. | _none_ |
| `HTTP_Header` | Add a HTTP header key/value pair. Multiple headers can be set. | _none_ |
| `Tag_Keys` | Space separated list of keys that needs to be tagged | _none_ |
| `Auto_Tags` | Automatically tag keys where value is `string`.  This option takes a Boolean value: `True`/`False`, `On`/`Off`. | `Off` |
| `Uri` | Custom URI endpoint. | _none_ |
| `Add_Integer_Suffix` | Use integer type of [InfluxDB's line protocol](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_reference/). This option takes a Boolean value: `True`/`False`, `On`/`Off`. | `Off` |
| `Workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The InfluxDB output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

To start inserting records into an InfluxDB service, you can run the plugin from the command line or through the configuration file.

### Command line

The InfluxDB plugin can read the parameters from the command line through the `-p` argument (property) or by setting them directly through the service URI. The URI format is the following:

```text
influxdb://host:port
```

Using the format specified, you could start Fluent Bit:

```shell
fluent-bit -i cpu -t cpu -o influxdb://127.0.0.1:8086 -m '*'
```

### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu

  outputs:
    - name: influxdb
      match: '*'
      host: 127.0.0.1
      port: 8086
      database: fluentbit
      sequence_tag: _seq
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

#### Tagging

Basic example of `Tag_Keys` usage:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      tag: apache.access
      parser: apache2
      path: /var/log/apache2/access.log

  outputs:
    - name: influxdb
      match: '*'
      host: 127.0.0.1
      port: 8086
      database: fluentbit
      sequence_tag: _seq
      # make tags from method and path fields
      tag_keys: method path
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
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

{% endtab %}
{% endtabs %}

`Auto_Tags=On` in this example causes an error, because every parsed field value type is `string`. The best usage of this option in metrics like record where one or more field value isn't `string` typed.

A basic example of `Tags_List_Key` usage:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      # tagged fields: level, ID, businessObjectID, status
      dummy: '{"msg": "Transfer completed", "level": "info", "ID": "1234", "businessObjectID": "qwerty", "status": "OK", "tags": ["ID", "businessObjectID"]}'

  outputs:
    - name: influxdb
      match: '*'
      host: 127.0.0.1
      port: 8086
      database: fluentbit
      sequence_tag: _seq
      # make tags from method and path fields
      tag_keys: method path
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name              dummy
  # tagged fields: level, ID, businessObjectID, status
  Dummy             {"msg": "Transfer completed", "level": "info", "ID": "1234", "businessObjectID": "qwerty", "status": "OK", "tags": ["ID", "businessObjectID"]}

[OUTPUT]
  Name          influxdb
  Match         *
  Host          127.0.0.1
  Port          8086
  Bucket        My_Bucket
  Org           My_Org
  Sequence_Tag  _seq
  HTTP_Token    My_Token
  # tag all fields inside tags string array
  Tags_List_Enabled True
  Tags_List_Key tags
  # tag level, status fields
  Tag_Keys level status
```

{% endtab %}
{% endtabs %}

### Testing

Before starting Fluent Bit, make sure the target database exists on InfluxDB. Using the previous example, insert the data into a `fluentbit` database.

1. Log into the InfluxDB console:

   ```shell
   influx
   ```

   Which should return a result like:

   ```text
   Visit https://enterprise.influxdata.com to register for updates, InfluxDB server management, and monitoring.
   Connected to http://localhost:8086 version 1.1.0
   InfluxDB shell version: 1.1.0
   >
   ```

1. Create the database:

   ```text
   > create database fluentbit
   >
   ```

1. Check that the database exists:

   ```text
   > show databases
   name: databases
   name
   ----
   _internal
   fluentbit

   >
   ```

1. Run Fluent Bit:

   The following command will gather CPU metrics from the system and send the data to InfluxDB database every five seconds:

   ```shell
   fluent-bit -i cpu -t cpu -o influxdb -m '*'
   ```

   All records coming from the `cpu` input plugin have a tag `cpu`. This tag is used to generate the measurement in InfluxDB.

1. Query the data:

   From InfluxDB console, choose your database:

   ```text
   > use fluentbit
   Using database fluentbit
   ```

1. query some specific fields:

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

   The CPU input plugin gathers more metrics per CPU core. This example selected three specific metrics. The following query will give a full result:

   ```text
   > SELECT * FROM cpu
   ```

1. View tags:

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

1. Query `method` key values:

   ```text
   > SHOW TAG VALUES ON fluentbit FROM "apache.access" WITH KEY = "method"
   name: apache.access
   key    value
   ---    -----
   method "MATCH"
   method "POST"
   ```
