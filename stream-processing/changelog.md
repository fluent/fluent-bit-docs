# Changelog

This page details new additions to the stream processor engine in major release versions of Fluent Bit.

## Fluent Bit v1.2

> Release date: June 27, 2019

### Sub-key selection and conditionals support

Added the ability to use nested maps and sub-keys to perform conditions and key selections. For example, consider the following record:

```javascript
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

For conditionals, added the new _@record_ functions:

| Function | Description |
| :--- | :--- |
| `@record.time()` | Returns the record timestamp. |
| `@record.contains(key)` | Returns `true` or false if `key` exists in the record, or `false` if not. |

### `IS NULL` and `IS NOT NULL`

Added `IS NULL` and `IS NOT NULL` statements to determine whether an existing key in a record has a null value. For example:

```sql
SELECT * FROM STREAM:test WHERE key3['sub1'] IS NOT NULL;
```

For more details, see [Check keys and null values](../stream-processing/getting-started/check-keys-null-values.md).

## Fluent Bit v1.1

> Release date: 2019-05-09

Added the stream processor to Fluent Bit.
