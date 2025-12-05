# PostgreSQL

[PostgreSQL](https://www.postgresql.org) is an open source database management system that supports the SQL language and is capable of storing both structured and unstructured data, such as JSON objects.

Fluent Bit is designed to work with JSON objects, and the `pgsql` output plugin allows users to send their data to a PostgreSQL database and store it using the `JSONB` type.

PostgreSQL 9.4 or higher is required.

## Preliminary steps

According to the parameters set in the configuration file, the plugin creates the table defined by the `table` option in the database defined by the `database` option hosted on the server defined by the `host` option. It will use the PostgreSQL user defined by the `user` option, which must have the correct privileges to create such a table in that database.

{% hint style="info" %}

If you're not familiar with how PostgreSQL's users and grants system works, the links in the [References](#references) section might be helpful.

{% endhint %}

A typical installation consists of a self-contained database for Fluent Bit in which you can store the output of one or more pipelines. You can store them in the same table, or in separate tables, or even in separate databases based on several factors, including workload, scalability, data protection, and security.

This example uses a single table called `fluentbit` in a database called `fluentbit`, owned by the user `fluentbit`.  In your environment, use names appropriate to your needs. For security reasons, don't use the `postgres` user which has `SUPERUSER` privileges.

### Create the `fluentbit` user

Generate a robust random password (for example, `pwgen 20 1`) and store it safely. Then, as the `postgres` system user on the server where PostgreSQL is installed, execute:

```shell
createuser -P fluentbit
```

At the prompt, provide the password that you previously generated.

As a result, the user `fluentbit` without superuser privileges will be created.

If you prefer, instead of the `createuser` application, you can directly use the SQL command [`CREATE USER`](https://www.postgresql.org/docs/current/sql-createuser.html).

### Create the `fluentbit` database

As `postgres` system user, run:

```shell
createdb -O fluentbit fluentbit
```

This creates a database called `fluentbit` owned by the `fluentbit` user. As a result, the `fluentbit` user will be able to safely create the data table.

Alternatively, you can use the SQL command [`CREATE DATABASE`](https://www.postgresql.org/docs/current/sql-createdatabase.html).

### Connection

Ensure that the `fluentbit` user can connect to the `fluentbit` database on the specified target host. This might require you to properly configure the [`pg_hba.conf`](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) file.

## Configuration parameters

This plugin supports the following parameters:

| Key | Description | Default |
|:----|:------------|:-------|
| `Host` | Hostname/IP address of the PostgreSQL instance. | `- (127.0.0.1)`|
| `Port` | PostgreSQL port. | `- (5432)` |
| `User` | PostgreSQL username. | `- (current user)` |
| `Password` | Password of PostgreSQL username. | `-` |
| `Database` | Database name to connect to. | `- (current user)` |
| `Table` | Table name where to store data. | `-` |
| `Connection_Options` | Specifies any valid [PostgreSQL connection options](https://www.postgresql.org/docs/devel/libpq-connect.html#LIBPQ-CONNECT-OPTIONS). | `-` |
| `Timestamp_Key` | Key in the JSON object containing the record timestamp. | `date` |
| `Async` | Define if the plugin will use asynchronous or synchronous connections. | `false` |
| `max_pool_size` | Maximum amount of connections in asynchronous mode. | `4`|
| `min_pool_size` | Minimum number of connection in asynchronous mode. | `1` |
| `cockroachdb` | Set to `true` if you will connect the plugin with a CockroachDB. | `false` |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |
| `Daemon` | Set to `true` if you want run this plugin instance in daemon mode. | `false` |

### Libpq

Fluent Bit relies on [libpq](https://www.postgresql.org/docs/current/libpq.html), the PostgreSQL native client API. For this reason, default values might be affected by [environment variables](https://www.postgresql.org/docs/current/libpq-envars.html) and compilation settings. The previous table lists the most common default values for each connection option.

For security reasons, you're advised to follow the directives included in the [password file](https://www.postgresql.org/docs/current/libpq-pgpass.html) section.

## Configuration example

In your main configuration file add the following section:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: pgsql
      match: '*'
      host: 172.17.0.2
      port: 5432
      user: fluentbit
      password: YourCrazySecurePassword
      database: fluentbit
      table: fluentbit
      connection_options: '-c statement_timeout=0'
      timestamp_key: ts
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
  Name                pgsql
  Match               *
  Host                172.17.0.2
  Port                5432
  User                fluentbit
  Password            YourCrazySecurePassword
  Database            fluentbit
  Table               fluentbit
  Connection_Options  -c statement_timeout=0
  Timestamp_Key       ts
```

{% endtab %}
{% endtabs %}

## The output table

The output plugin automatically creates a table with the name specified by the `table` configuration option and made up of the following fields:

- `tag TEXT`
- `time TIMESTAMP WITHOUT TIMEZONE`
- `data JSONB`

The timestamp doesn't contain any information about the time zone, and it's therefore referred to the time zone used by the connection to PostgreSQL (`timezone` setting).

For more information about the `JSONB` data type in PostgreSQL, refer to the [JSON types](https://www.postgresql.org/docs/current/datatype-json.html) page in the official documentation. You can find instructions on how to index or query the objects (including `jsonpath` introduced in PostgreSQL 12).

## Scalability

PostgreSQL includes support for declarative partitioning. To improve vertical scalability of the database, you can partition your tables on time ranges, such as on a monthly basis. PostgreSQL supports also sub-partitions, which let you partition your records by hash and default partitions.

For more information on horizontal partitioning in PostgreSQL, refer to the [Table partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html) page in the official documentation.

Choose the latest major version of PostgreSQL if you're starting now.

## Additional information

PostgreSQL is a powerful and extensible database engine. More expert users can take advantage of `BEFORE INSERT` triggers on the main table and reroute records on normalised tables, depending on tags and content of the actual JSON objects.

For example, you can use Fluent Bit to send HTTP log records to the `landing` table defined in the configuration file. This table contains a `BEFORE INSERT` trigger (a function in `plpgsql` language) that normalizes the content of the JSON object and that inserts the record in another table (with its own structure and partitioning model). This kind of trigger lets you discard the record from the landing table by returning `NULL`.

## References

Refer to the following a list of resources from the PostgreSQL documentation:

- [Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
- [`GRANT`](https://www.postgresql.org/docs/current/sql-grant.html)
- [`CREATE USER`](https://www.postgresql.org/docs/current/sql-createuser.html)
- [`CREATE DATABASE`](https://www.postgresql.org/docs/current/sql-createdatabase.html)
- [The `pg_hba.conf` file](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)
- [JSON types](https://www.postgresql.org/docs/current/datatype-json.html)
- [Date/Time functions and operators](https://www.postgresql.org/docs/current/functions-datetime.html)
- [Table partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- [libpq - C API for PostgreSQL](https://www.postgresql.org/docs/current/libpq.html)
- [libpq - Environment variables](https://www.postgresql.org/docs/current/libpq-envars.html)
- [libpq - password file](https://www.postgresql.org/docs/current/libpq-pgpass.html)
- [Trigger functions](https://www.postgresql.org/docs/current/plpgsql-trigger.html)
