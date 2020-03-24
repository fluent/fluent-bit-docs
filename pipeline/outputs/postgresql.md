# PostgreSQL

The `pgsql` output plugin allows to send data from Fluent Bit to a PostgreSQL Database Server 9.4 or above. To store the data we use the JSON type so make sure that your PostgreSQL instance supports this type.

## Configuration Parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| Host | Hostname of PostgreSQL instance | 127.0.0.1 |
| Port | PostgreSQL port | 5432 |
| Database | Database name to connect | fluentbit |
| Table | Table name where to store data | fluentbit |
| User | PostgreSQL username | current user |
| Password | Password of PostgreSLQ username |  |
| Timestamp\_Key | Key to store the record timestamp | date |

## Configuration Example

In your main configuration file add the following section:

```text
[OUTPUT]
    Name          pgsql
    Match         *
    Host          172.17.0.2
    Port          5432
    Database      fluentbit
    Table         fluentbit
    User          postgres
    Password      YourCrazySecurePassword
    Timestamp_Key timestamp
```

