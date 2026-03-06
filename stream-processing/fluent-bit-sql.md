# Fluent Bit and SQL

Stream processing in Fluent Bit uses SQL to perform record queries.

For more information, see the [stream processing README file](https://github.com/fluent/fluent-bit/tree/master/src/stream_processor).

## Statements

Use the following SQL statements in Fluent Bit.

### `SELECT`

```sql
SELECT results_statement
  FROM STREAM:stream_name | TAG:match_rule
  [WINDOW TUMBLING (integer SECOND) | WINDOW HOPPING (integer SECOND, ADVANCE BY integer SECOND)]
  [WHERE condition]
  [GROUP BY groupby]
```

Groups keys from records that originate from a specified stream, or from records that match a specific tag pattern.

{% hint style="info" %}
A `SELECT` statement not associated with stream creation will send the results to the standard output interface, which can be helpful for debugging purposes.
{% endhint %}

You can filter the results of this query by applying a condition by using a `WHERE` statement. For information about the `WINDOW` and `GROUP BY` statements, see [Aggregation functions](#aggregation-functions).

#### Examples [#select-examples]

Selects all keys from records that originate from a stream called `apache`:

```sql
SELECT * FROM STREAM:apache;
```

Selects the `code` key from records with tags whose name begins with `apache`:

```sql
SELECT code AS http_status FROM TAG:'apache.*';
```

### `CREATE STREAM`

```sql
CREATE STREAM stream_name
  [WITH (property_name=value, [...])]
  AS select_statement
```

Creates a new stream of data using the results from a `SELECT` statement. If the `Tag` property in the `WITH` statement is set, this new stream can optionally be re-ingested into the Fluent Bit pipeline.

#### Examples [#create-stream-examples]

Creates a new stream called `hello_` from a stream called `apache`:

```sql
CREATE STREAM hello AS SELECT * FROM STREAM:apache;
```

Creates a new stream called `hello` for all records whose original tag name begins with `apache`:

```sql
CREATE STREAM hello AS SELECT * FROM TAG:'apache.*';
```

## Aggregation functions

You can use aggregation functions in the `results_statement` on keys, which lets you perform data calculation on groups of records. These groups are determined by the `WINDOW` key. If `WINDOW` is unspecified, aggregation functions are applied to the current buffer of records received, which might have a non-deterministic number of elements. You can also apply aggregation functions to records in a window of a specific time interval.

Fluent Bit supports two window types:

- **Tumbling window** (`WINDOW TUMBLING`): Non-overlapping windows. A window size of `5` performs aggregation on records during a five-second interval, then starts a fresh window for the next interval.
- **Hopping window** (`WINDOW HOPPING`): A sliding window with a configurable advance step. For example, `WINDOW HOPPING (10 SECOND, ADVANCE BY 2 SECOND)` maintains a 10-second window that advances every 2 seconds, so consecutive windows share overlapping records.

Additionally, you can use the `GROUP BY` statement to group results by one or more keys with matching values.

### `AVG`

```sql
SELECT AVG(size) FROM STREAM:apache WHERE method = 'POST' ;
```

Calculates the average size of `POST` requests.

### `COUNT`

```sql
SELECT host, COUNT(*) FROM STREAM:apache WINDOW TUMBLING (5 SECOND) GROUP BY host;
```

Counts the number of records in a five-second tumbling window, grouped by host IP addresses.

### `MIN`

```sql
SELECT MIN(key) FROM STREAM:apache;
```

Returns the minimum value of a key in a set of records.

### `MAX`

```sql
SELECT MAX(key) FROM STREAM:apache;
```

Returns the maximum value of a key in a set of records.

### `SUM`

```sql
SELECT SUM(key) FROM STREAM:apache;
```

Calculates the sum of all values of a key in a set of records.

### `TIMESERIES_FORECAST`

```sql
SELECT TIMESERIES_FORECAST(num, 30) FROM STREAM:apache WINDOW TUMBLING (5 SECOND);
```

Uses linear regression to predict the future value of a key. The first argument is the key to forecast and the second argument is the number of seconds into the future to project. Requires a `WINDOW` to accumulate the data points used for the regression.

### `WINDOW HOPPING` example

```sql
SELECT host, COUNT(*) FROM STREAM:apache WINDOW HOPPING (10 SECOND, ADVANCE BY 2 SECOND) GROUP BY host;
```

Counts records per host using a 10-second hopping window that advances every 2 seconds. Each output overlaps with the previous window, unlike a tumbling window.

## Time functions

Use time functions to add a new key with time data into a record.

### `NOW`

```sql
SELECT NOW() FROM STREAM:apache;
```

Adds the current system time to a record using the format `%Y-%m-%d %H:%M:%S`. Output example: `2019-03-09 21:36:05`.

### `UNIX_TIMESTAMP`

```sql
SELECT UNIX_TIMESTAMP() FROM STREAM:apache;
```

Adds the current Unix time to a record. Output example: `1552196165`.

## Record functions

Use record functions to append new keys to a record using values from the record's context.

### `RECORD_TAG`

```sql
SELECT RECORD_TAG() FROM STREAM:apache;
```

Append tag string associated to the record as a new key.

### `RECORD_TIME`

```sql
SELECT RECORD_TIME() FROM STREAM:apache;
```

Appends the record's timestamp as a new key in double format (`seconds.nanoseconds`). Output example: `1552196165.705683`.

## `WHERE` condition

Similar to conventional SQL statements, Fluent Bit supports the `WHERE` condition. You can use this condition in both keys and subkeys. For example:

```sql
SELECT AVG(size) FROM STREAM:apache WHERE method = 'POST' AND status = 200;
```

You can confirm whether a key exists in a record by using the record-specific function `@record.contains`:

```sql
SELECT MAX(key) FROM STREAM:apache WHERE @record.contains(key);
```

To determine if the value of a key is `NULL`:

```sql
SELECT MAX(key) FROM STREAM:apache WHERE key IS NULL;
```

Or similar:

```sql
SELECT * FROM STREAM:apache WHERE user IS NOT NULL;
```
