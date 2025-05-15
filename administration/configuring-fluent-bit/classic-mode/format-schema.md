# Formats and schema

Fluent Bit might optionally use a configuration file to define how the service will behave.

The schema is defined by three concepts:

- Sections
- Entries: key/value
- Indented Configuration Mode

An example of a configuration file is as follows:

```python
[SERVICE]
    # This is a commented line
    Daemon    off
    log_level debug
```

## Sections

A section is defined by a name or title inside brackets. Using the previous example, a Service section has been set using `[SERVICE]` definition. The following rules apply:

- All section content must be indented (four spaces ideally).
- Multiple sections can exist on the same file.
- A section must have comments and entries.
- Any commented line under a section must be indented too.
- End-of-line comments aren't supported, only full-line comments.

## Entries: key/value

A section can contain entries. An entry is defined by a line of text that contains a `Key` and a `Value`. Using the previous example, the `[SERVICE]` section contains two entries: one is the key `Daemon` with value `off` and the other is the key `Log_Level` with the value `debug`. The following rules apply:

- An entry is defined by a key and a value.
- A key must be indented.
- A key must contain a value which ends in the breakline.
- Multiple keys with the same name can exist.

Commented lines are set prefixing the `#` character. Commented lines aren't processed but they must be indented.

## Indented configuration mode

Fluent Bit configuration files are based in a strict indented mode. Each configuration file must follow the same pattern of alignment from left to right when writing text. By default, an indentation level of four spaces from left to right is suggested. Example:

```python
[FIRST_SECTION]
    # This is a commented line
    Key1  some value
    Key2  another value
    # more comments

[SECOND_SECTION]
    KeyN  3.14
```

This example shows two sections with multiple entries and comments. Empty lines are allowed.
