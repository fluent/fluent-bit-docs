# InfluxDB

{% hint style="info" %}
**Supported event types:** `logs` `metrics`
{% endhint %}

The _InfluxDB_ output plugin lets you flush your records into a [InfluxDB](https://www.influxdata.com/products/influxdb-overview) time series database. The following instructions assume that you have an operational InfluxDB service running in your system.

## Configuration parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `add_integer_suffix` | Use integer type of [InfluxDB's line protocol](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_reference/). | `false` |
| `auto_tags` | Automatically tag keys where value is `string`. | `false` |
| `bucket` | InfluxDB bucket name where records will be inserted. If specified, `database` is ignored and v2 of the API is used. | _none_ |
| `database` | InfluxDB database name where records will be inserted. | `fluentbit` |
| `host` | IP address or hostname of the target InfluxDB service. | `127.0.0.1` |
| `http_header` | Add a HTTP header key/value pair. Multiple headers can be set. | _none_ |
| `http_passwd` | Password for user defined in `http_user`. | _none_ |
| `http_token` | Authentication token used with InfluxDB v2. If specified, both `http_user` and `http_passwd` are ignored. | _none_ |
| `http_user` | Optional username for HTTP Basic Authentication. | _none_ |
| `org` | InfluxDB organization name where the bucket is (v2 only). | `fluent` |
| `port` | TCP port of the target InfluxDB service. | `8086` |
| `sequence_tag` | The name of the tag whose value is incremented for consecutive simultaneous events. | _none_ |
| `strip_prefix` | String prefix to be removed from the front of `tag` when writing InfluxDB measurement names. `strip_prefix` is removed only if it matches exactly at the beginning of and is strictly shorter than `tag` (`tag` length will not be reduced to zero if `strip_prefix` and `tag` are identical strings). `strip_prefix` defaults to empty string, which does nothing. | _none_ |
| `tag_keys` | Space-separated list of keys to tag. | _none_ |
| `uri` | Custom URI endpoint. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### TLS / SSL

The InfluxDB output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

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
  Parser          apache2
  Path            /var/log/apache2/access.log

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


### Prefix stripping

When collecting data from many inputs into many buckets, it can be helpful to remove a common prefix using `Strip_prefix`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: cpu
      tag: cpu.one
    - name: cpu
      tag: cpu.two
    - name: cpu
      tag: gpu.one
    - name: cpu
      tag: gpu.two


  outputs:
    - name: influxdb
      match: 'cpu*'
      host: 127.0.0.1
      port: 8086
      bucket: cpubucket
      strip_prefix: cpu.
    - name: influxdb
      match: 'gpu*'
      host: 127.0.0.1
      port: 8086
      bucket: gpubucket
      strip_prefix: gpu.
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name  cpu
    Tag   cpu.one

[INPUT]
    Name  cpu
    Tag   cpu.two

[INPUT]
    Name  cpu
    Tag   gpu.one

[INPUT]
    Name  cpu
    Tag   gpu.two

[OUTPUT]
    Name          influxdb
    Match         cpu*
    Bucket        cpubucket
    Strip_prefix  cpu.

[OUTPUT]
    Name          influxdb
    Match         gpu*
    Bucket        gpubucket
    Strip_prefix  gpu.
```

{% endtab %}
{% endtabs %}


This will result in the buckets `cpubucket` and `gpubucket` each containing two measurement streams named `one` and `two`. Without prefix stripping, the measurement names would be `cpu.one` and `cpu.two` (stored in `cpubucket`), and `gpu.one`, `gpu.two` (stored in `gpubucket`).


### Testing

Before starting Fluent Bit, ensure the target database exists on InfluxDB. Using the previous example, insert the data into a `fluentbit` database.

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

1. Query some specific fields:

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

1. View tags by querying tagged keys:

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
