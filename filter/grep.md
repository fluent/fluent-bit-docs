# Grep Filter

The _Grep Filter_ plugin allows to match or exclude specific records based in regular expression patterns.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         | Value Format          | Description       |
| ------------|-----------------------|-------------------|
| Regex       | FIELD REGEX | Keep records which field matches the regular expression. |
| Exclude     | FIELD REGEX | Exclude records which field matches the regular expression. |

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file. The following example assumes that you have a file called _lines.txt_ with the following content

```
aaa
aab
bbb
ccc
ddd
eee
fff
ggg
```

### Command Line

> Note: using the command line mode need special attention to quote the regular expressions properly. It's suggested to use a configuration file.

The following command will load the _tail_ plugin and read the content of _lines.txt_ file. Then the _grep_ filter will apply a regular expression rule over the _log_ field (created by tail plugin) and only _pass_ the records which field value starts with _aa_:

```
$ bin/fluent-bit -i tail -p 'path=lines.txt' -F grep -p 'regex=log aa' -m '*' -o stdout
```

### Configuration File

```python
[INPUT]
    Name   tail
    Path   lines.txt

[FILTER]
    Name   grep
    Match  *
    Regex  aa

[OUTPUT]
    Name   stdout
    Match  *
```

The filter allows to use multiple rules which are applied in order, you can have many _Regex_ and _Exclude_ entries as required.
