# IS NULL, IS NOT NULL, KEY EXISTS ?

> Feature available on Fluent Bit >= 1.2

When working with structured messages (records), there are certain cases where we want to know if a key exists, if it value is _null_ or have a value different than _null_. 

[Fluent Bit](https://fluentbit.io) internal records are a binary serialization of maps with keys and values. A value can be _null_ which is a valid data type. In our SQL language we provide the following statements that can be applied to the conditionals statements:

## Check if a key value IS NULL

The following SQL statement can be used to retrieve all records from stream _test_ where the key called _phone_ has a _null_ value:

```sql
SELECT * FROM STREAM:test WHERE phone IS NULL;
```

## Check if a key value IS NOT NULL

Similar to the example above, there are cases where we want to retrieve all records that certain key value have something different than _null_:

```sql
SELECT * FROM STREAM:test WHERE phone IS NOT NULL;
```

## Check if a key exists

Another common use-case is to check if certain key exists in the record. We provide specific record functions that can be used in the conditional part of the SQL statement. The prototype of the function to check if a key exists in the record is the following:

```
@record.contains(key)
```

The following example query all records that contains a key called _phone_:

```sql
SELECT * FROM STREAM:test WHERE @record.contains(phone);
```

