# Fluent Bit Query Language: SQL

Fluent Bit stream processor uses common SQL to perform record queries. The following section describe the features available and examples of it.

## Statements

You can find the detailed query language syntax in BNF form [here](https://github.com/fluent/fluent-bit/tree/master/src/stream_processor). The following section will be a brief introduction on how to write SQL queries for Fluent Bit stream processing.

### SELECT Statement

#### Synopsis

```sql
SELECT results_statement
  FROM STREAM:stream_name | TAG:match_rule
  [WINDOW TUMBLING (integer SECOND)]
  [WHERE condition]
  [GROUP BY groupby]
```

#### Description

Select keys from records coming from a stream or records matching a specific Tag pattern. Note that a simple `SELECT` statement __not__ associated from a stream creation will send the results to the standard output interface (stdout), useful for debugging purposes.

The query allows filtering the results by applying a condition using `WHERE` statement. We will explain `WINDOW` and `GROUP BY` statements later in aggregation functions section.

#### Examples

Select all keys from records coming from a stream called _apache_:

```sql
SELECT * FROM STREAM:apache;
```

Select all keys from records which Tag starts with _apache._:

```sql
SELECT code AS http_status FROM TAG:'apache.*';
```

> Since the TAG selector allows the use of wildcards, we put the value between single quotes.

### CREATE STREAM Statement

#### Synopsis

```sql
CREATE STREAM stream_name
  [WITH (property_name=value, [...])]
  AS select_statement
```

#### Description

Create a new stream of data using the results from the `SELECT` statement. New stream created can be optionally re-ingested back into Fluent Bit pipeline if the property _Tag_ is set in the WITH statement.

#### Examples

Create a new stream called _hello_ from stream called _apache_:

```sql
CREATE STREAM hello AS SELECT * FROM STREAM:apache;
```

Create a new stream called hello for all records which original Tag starts with _apache_:

```sql
CREATE STREAM hello AS SELECT * FROM TAG:'apache.*';
```

## Aggregation Functions

Aggregation functions are used in `results_statement` on the keys, allowing to perform data calculation on groups of records.
Group of records that aggregation functions apply on are determined by `WINDOW` keyword. When `WINDOW` is not specified, aggregation functions apply on the current buffer of records received, which may have non-deterministic number of elements. Aggregation functions can be applied on records in a window of a specific time interval (see the syntax of `WINDOW` in select statement).

Fluent Bit streaming currently supports tumbling window, which is non-overlapping window type. That means, a window of size 5 seconds performs aggregation computations on records over a 5-second interval, and then starts new calculations for the next interval.

In addition, the syntax support `GROUP BY` statement, which groups the results by the one or more keys, when they have the same values.

### AVG

#### Synopsis

```sql
SELECT AVG(size) FROM STREAM:apache WHERE method = 'POST' ;
```

#### Description

Calculates the average of request sizes in POST requests.

### COUNT

#### Synopsis

```sql
SELECT host, COUNT(*) FROM STREAM:apache WINDOW TUMBLING (5 SECOND) GROUP BY host;
```

#### Description

Count the number of records in 5 second windows group by host IP addresses.

### MIN

#### Synopsis

```sql
SELECT MIN(key) FROM STREAM:apache;
```

#### Description

Gets the minimum value of a key in a set of records.

### MAX

#### Synopsis

```sql
SELECT MIN(key) FROM STREAM:apache;
```

#### Description

Gets the maximum value of a key in a set of records.

### SUM

#### Synopsis

```sql
SELECT SUM(key) FROM STREAM:apache;
```

#### Description

Calculates the sum of all values of key in a set of records.

## Time Functions

Time functions adds a new key into the record with timing data

### NOW

#### Synopsis

```sql
SELECT NOW() FROM STREAM:apache;
```

#### Description

Add system time using format: %Y-%m-%d %H:%M:%S. Output example: 2019-03-09 21:36:05.

### UNIX_TIMESTAMP

#### Synopsis

```sql
SELECT UNIX_TIMESTAMP() FROM STREAM:apache;
```

#### Description

Add current Unix timestamp to the record. Output example: 1552196165 .

## Record Functions

Record functions append new keys to the record using values from the record context.

### RECORD_TAG

#### Synopsis

```sql
SELECT RECORD_TAG() FROM STREAM:apache;
```

#### Description

Append Tag string associated to the record as a new key.

### RECORD_TIME

#### Synopsis

```sql
SELECT RECORD_TIME() FROM STREAM:apache;
```
## WHERE Condition

Similar to conventional SQL statements, `WHERE` condition is supported in Fluent Bit query language. The language supports conditions over keys and subkeys, for instance:
```sql
SELECT AVG(size) FROM STREAM:apache WHERE method = 'POST' AND status = 200;
```
It is possible to check the existence of a key in the record using record-specific function `@record.contains`:
```sql
SELECT MAX(key) FROM STREAM:apache WHERE @record.contains(key);
```
And to check if the value of a key is/is not `NULL`:
```sql
SELECT MAX(key) FROM STREAM:apache WHERE key IS NULL;
```
```sql
SELECT * FROM STREAM:apache WHERE user IS NOT NULL;
```

#### Description

Append a new key with the record Timestamp in _double_ format: seconds.nanoseconds. Output example: 1552196165.705683 .
