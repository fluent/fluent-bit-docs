# Stream Processor Changelog

Upon new versions of [Fluent Bit](https://fluentbit.io), the Stream Processor engine gets new improvements. In the following section you will find the details of the new additions in the major release versions.

## Fluent Bit v1.2

> Release date: June 27, 2019

### Sub-key selection and conditionals support

It's pretty common that records contains nested maps or sub-keys. Now we provide the ability to use sub-keys to perform conditionals and keys selection. Consider the following record:

```json
{
  "key1": 123,
  "key2": 456,
  "key3": {
    "sub1": {
      "sub2": 789
    }
  }
}
```

Now you can perform queries like:

```sql
SELECT key3['sub1']['sub2'] FROM STREAM:test WHERE key3['sub1']['sub2'] = 789;
```

### New @record functions

On conditionals we have introduced the new *@record* functions:

| Function              | Description                                         |
| :-------------------- | :-------------------------------------------------- |
| @record.time()        | returns the record timestamp                        |
| @record.contains(key) | returns true or false if *key* exists in the record |

### IS NULL, IS NOT NULL

We currently support different data types such as *strings*, *integers*, *floats*, *maps* and *null*. In Fluent Bit, a *null* value is totally valid and is not related to the absence of a value as in normal databases. To compare if an existing key in the record have a *null* value or not, we have introduced *IS NULL* and *IS NOT NULL* statements, e.g:

```sql
SELECT * FROM STREAM:test WHERE key3['sub1'] IS NOT NULL;
```

For more details please review the section [Check Keys and NULL values](../getting_started/is_null_is_not_null_record_contains)

## Fluent Bit v1.1

> Release date: May 09, 2019

This is the initial version of the Stream Processor into Fluent Bit.
