# PostgreSQL

[PostgreSQL](https://www.postgresql.org) is a very popular and versatile open source database management system that supports the SQL language and that is capable of storing both structured and unstructured data, such as JSON objects.

Given that Fluent Bit is designed to work with JSON objects, the `pgsql` output plugin allows users to send their data to a PostgreSQL database and store it using the `JSONB` type.

PostgreSQL 9.4 or higher is required.

## Preliminary steps

According to the parameters you have set in the configuration file, the plugin will create the table defined by the `table` option in the database defined by the `database` option hosted on the server defined by the `host` option. It will use the PostgreSQL user defined by the `user` option, which needs to have the right privileges to create such a table in that database.

{% hint style="info" %}

If you are not familiar with how PostgreSQL's users and grants system works, you might find useful reading the recommended links in the "References" section at the bottom.

{% endhint %}

A typical installation normally consists of a self-contained database for Fluent Bit in which you can store the output of one or more pipelines. Ultimately, it is your choice to store them in the same table, or in separate tables, or even in separate databases based on several factors, including workload, scalability, data protection and security.

In this example, for the sake of simplicity, we use a single table called `fluentbit` in a database called `fluentbit` that is owned by the user `fluentbit`. Feel free to use different names. Preferably, for security reasons, do not use the `postgres` user \(which has `SUPERUSER` privileges\).

### Create the `fluentbit` user

Generate a robust random password \(e.g. `pwgen 20 1`\) and store it safely. Then, as `postgres` system user on the server where PostgreSQL is installed, execute:

```shell
createuser -P fluentbit
```

At the prompt, please provide the password that you previously generated.

As a result, the user `fluentbit` without superuser privileges will be created.

If you prefer, instead of the `createuser` application, you can directly use the SQL command [`CREATE USER`](https://www.postgresql.org/docs/current/sql-createuser.html).

### Create the `fluentbit` database

As `postgres` system user, please run:

```shell
createdb -O fluentbit fluentbit
```

This will create a database called `fluentbit` owned by the `fluentbit` user. As a result, the `fluentbit` user will be able to safely create the data table.

Alternatively, you can use the SQL command [`CREATE DATABASE`](https://www.postgresql.org/docs/current/sql-createdatabase.html).

### Connection

Make sure that the `fluentbit` user can connect to the `fluentbit` database on the specified target host. This might require you to properly configure the [`pg_hba.conf`](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) file.

## Configuration Parameters

| Key                  | Description                                                                                                                         | Default            |
|:---------------------|:------------------------------------------------------------------------------------------------------------------------------------|:-------------------|
| `Host`               | Hostname/IP address of the PostgreSQL instance                                                                                      | - \(127.0.0.1\)    |
| `Port`               | PostgreSQL port                                                                                                                     | - \(5432\)         |
| `User`               | PostgreSQL username                                                                                                                 | - \(current user\) |
| `Password`           | Password of PostgreSQL username                                                                                                     | -                  |
| `Database`           | Database name to connect to                                                                                                         | - \(current user\) |
| `Table`              | Table name where to store data                                                                                                      | -                  |
| `Connection_Options` | Specifies any valid [PostgreSQL connection options](https://www.postgresql.org/docs/devel/libpq-connect.html#LIBPQ-CONNECT-OPTIONS) | -                  |
| `Timestamp_Key`      | Key in the JSON object containing the record timestamp                                                                              | date               |
| `Async`              | Define if we will use async or sync connections                                                                                     | false              |
| `min_pool_size`      | Minimum number of connection in async mode                                                                                          | 1                  |
| `max_pool_size`      | Maximum amount of connections in async mode                                                                                         | 4                  |
| `cockroachdb`        | Set to `true` if you will connect the plugin with a CockroachDB                                                                     | false              |
| `workers`            | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output.                | `0`                |

### Libpq

Fluent Bit relies on [libpq](https://www.postgresql.org/docs/current/libpq.html), the PostgreSQL native client API, written in C language. For this reason, default values might be affected by [environment variables](https://www.postgresql.org/docs/current/libpq-envars.html) and compilation settings. The above table, in brackets, list the most common default values for each connection option.

For security reasons, it is advised to follow the directives included in the [password file](https://www.postgresql.org/docs/current/libpq-pgpass.html) section.

## Configuration Example

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

* `tag TEXT`
* `time TIMESTAMP WITHOUT TIMEZONE`
* `data JSONB`

As you can see, the timestamp does not contain any information about the time zone, and it is therefore referred to the time zone used by the connection to PostgreSQL \(`timezone` setting\).

For more information on the `JSONB` data type in PostgreSQL, please refer to the [JSON types](https://www.postgresql.org/docs/current/datatype-json.html) page in the official documentation, where you can find instructions on how to index or query the objects \(including `jsonpath` introduced in PostgreSQL 12\).

## Scalability

PostgreSQL 10 introduces support for declarative partitioning. In order to improve vertical scalability of the database, you can decide to partition your tables on _time ranges_ \(for example on a monthly basis\). PostgreSQL supports also subpartitions, allowing you to even partition by _hash_ your records \(version 11+\), and default partitions \(version 11+\).

For more information on horizontal partitioning in PostgreSQL, please refer to the [Table partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html) page in the official documentation.

If you are starting now, our recommendation at the moment is to choose the latest major version of PostgreSQL.

## There's more ...

PostgreSQL is a really powerful and extensible database engine. More expert users can indeed take advantage of `BEFORE INSERT` triggers on the main table and re-route records on normalised tables, depending on tags and content of the actual JSON objects.

For example, you can use Fluent Bit to send HTTP log records to the _landing_ table defined in the configuration file. This table contains a `BEFORE INSERT` trigger \(a function in `plpgsql` language\) that _normalises_ the content of the JSON object and that inserts the record in another table \(with its own structure and partitioning model\). This kind of triggers allow you to _discard_ the record from the landing table by returning `NULL`.

## References

Here follows a list of useful resources from the PostgreSQL documentation:

* [Database Roles](https://www.postgresql.org/docs/current/user-manag.html)
* [`GRANT`](https://www.postgresql.org/docs/current/sql-grant.html)
* [`CREATE USER`](https://www.postgresql.org/docs/current/sql-createuser.html)
* [`CREATE DATABASE`](https://www.postgresql.org/docs/current/sql-createdatabase.html)
* [The `pg_hba.conf` file](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)
* [JSON types](https://www.postgresql.org/docs/current/datatype-json.html)
* [Date/Time functions and operators](https://www.postgresql.org/docs/current/functions-datetime.html)
* [Table partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
* [libpq - C API for PostgreSQL](https://www.postgresql.org/docs/current/libpq.html)
* [libpq - Environment variables](https://www.postgresql.org/docs/current/libpq-envars.html)
* [libpq - password file](https://www.postgresql.org/docs/current/libpq-pgpass.html)
* [Trigger functions](https://www.postgresql.org/docs/current/plpgsql-trigger.html)