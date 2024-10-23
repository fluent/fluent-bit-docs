# Validating your data and structure

Fluent Bit is a powerful log processing tool that supports mulitple sources and
formats. In addition, it provides filters that can be used to perform custom
modifications. As your pipeline grows, it's important to validate your data and
structure.

Fluent Bit users are encouraged to integrate data validation in their contininuous
integration (CI) systems.

In a normal production environment, inputs, filters, and outputs are defined in the
configuration. Fluent Bit provides the [Expect](../pipeline/filters/expect.md) filter,
which can be used to validate `keys` and `values` from your records and take action
when an exception is found.

A simplified view of the data processing pipeline is as follows:

```mermaid
flowchart LR
IS[Inputs / Sources]
Fil[Filters]
OD[Outputs/ Destination]
IS --> Fil --> OD
```

## Understand structure and configuration

Consider the following pipeline, where your source of data is a file with JSON
content and two filters:

- [grep](../pipeline/filters/grep.md) to exclude certain records
- [record_modifier](../pipeline/filters/record-modifier.md) to alter the record
  content by adding and removing specific keys.

```mermaid
flowchart LR
tail["tail (input)"]
grep["grep (filter)"]
record["record_modifier (filter)"]
stdout["stdout (output)"]

tail --> grep
grep --> record
record --> stdout
```

Add data validation between each step to ensure your data structure is correct.

This example uses the `expect` filter.

```mermaid
flowchart LR
tail["tail (input)"]
grep["grep (filter)"]
record["record_modifier (filter)"]
stdout["stdout  (output)"]
E1["expect (filter)"]
E2["expect (filter)"]
E3["expect (filter)"]
tail --> E1 --> grep
grep --> E2 --> record --> E3 --> stdout
```

`Expect` filters set rules aiming to validate criteria like:

- Does the record contain a key `A`?
- Does the record not contain key `A`?
- Does the record key `A` value equal `NULL`?
- Is the record key `A` value not `NULL`?
- Does the record key `A` value equal `B`?

Every `expect` filter configuration exposes rules to validate the content of your
records using [configuration properties](../pipeline/filters/expect.md#configuration-parameters).

## Test the configuration

Consider a JSON file `data.log` with the following content:

```javascript
{"color": "blue", "label": {"name": null}}
{"color": "red", "label": {"name": "abc"}, "meta": "data"}
{"color": "green", "label": {"name": "abc"}, "meta": null}
```

The following Fluent Bit configuration file configures a pipeline to consume the
log, while applying an `expect` filter to validate that the keys `color` and `label`
exist:

```python
[SERVICE]
    flush        1
    log_level    info
    parsers_file parsers.conf

[INPUT]
    name        tail
    path        ./data.log
    parser      json
    exit_on_eof on

# First 'expect' filter to validate that our data was structured properly
[FILTER]
    name        expect
    match       *
    key_exists  color
    key_exists  $label['name']
    action      exit

[OUTPUT]
    name        stdout
    match       *
```

If the JSON parser fails or is missing in the `tail` input
(`parser json`), the `expect` filter triggers the `exit` action.

To extend the pipeline, add a grep filter to match records that map `label`
containing a key called `name` with value the `abc`, and add an `expect` filter
to re-validate that condition:

```python
[SERVICE]
    flush        1
    log_level    info
    parsers_file parsers.conf

[INPUT]
    name         tail
    path         ./data.log
    parser       json
    exit_on_eof  on

# First 'expect' filter to validate that our data was structured properly
[FILTER]
    name       expect
    match      *
    key_exists color
    key_exists label
    action     exit

# Match records that only contains map 'label' with key 'name' = 'abc'
[FILTER]
    name       grep
    match      *
    regex      $label['name'] ^abc$

# Check that every record contains 'label' with a non-null value
[FILTER]
    name       expect
    match      *
    key_val_eq $label['name'] abc
    action     exit

# Append a new key to the record using an environment variable
[FILTER]
    name       record_modifier
    match      *
    record     hostname ${HOSTNAME}

# Check that every record contains 'hostname' key
[FILTER]
    name       expect
    match      *
    key_exists hostname
    action     exit

[OUTPUT]
    name       stdout
    match      *
```

## Production deployment

When deploying in production, consider removing the `expect` filters from your
configuration. These filters are unneccesary unless you need 100% coverage of
checks at runtime.
