# Check keys and null values

When working with structured messages (also known as records), there are certain cases where you might want to confirm whether a key exists, and whether its value is null or not null.

In Fluent Bit, records are a binary serialization of maps with keys and value. A value can be `null`, which is a valid data type. The following statements can be applied in Fluent Bit SQL:

## Check if a key value is null

The following statement retrieves all records from the stream `test` where the key `phone` has a value of `null`:

```sql
SELECT * FROM STREAM:test WHERE phone IS NULL;
```

## Check if a key value is not null

The following statement is similar to the previous example, but instead retrieves all records from the stream `test` where the key `phone` has a non-null value:

```sql
SELECT * FROM STREAM:test WHERE phone IS NOT NULL;
```

## Check if a key exists

You can also confirm whether a certain key exists in a record at all, regardless of its value. Fluent Bit provides specific record functions that you can use in the condition part of the SQL statement. The following function determines whether `key` exists in a record:

```sql
@record.contains(key)
```

For example, the following statement retrieves all records that contain a key called `phone`:

```sql
SELECT * FROM STREAM:test WHERE @record.contains(phone);
```
