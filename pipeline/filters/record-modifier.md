# Record Modifier

The _Record Modifier Filter_ plugin allows to append fields or to exclude specific fields.

## Configuration Parameters

The plugin supports the following configuration parameters: _Remove\_key_ and _Allowlist\_key_ are exclusive.

| Key | Description |
| :--- | :--- |
| Record | Append fields. This parameter needs key and value pair. |
| Remove\_key | If the key is matched, that field is removed. |
| Allowlist\_key | If the key is **not** matched, that field is removed. |
| Whitelist\_key | An alias of `Allowlist_key` for backwards compatibility. |

## Getting Started

In order to start filtering records, you can run the filter from the command line or through the configuration file.

This is a sample in\_mem record to filter.

```text
{"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>299352, "Swap.total"=>2064380, "Swap.used"=>32656, "Swap.free"=>2031724}
```

### Append fields

The following configuration file is to append product name and hostname \(via environment variable\) to record.

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name record_modifier
    Match *
    Record hostname ${HOSTNAME}
    Record product Awesome_Tool
```

You can also run the filter from command line.

```text
$ fluent-bit -i mem -o stdout -F record_modifier -p 'Record=hostname ${HOSTNAME}' -p 'Record=product Awesome_Tool' -m '*'
```

The output will be

```python
[0] mem.local: [1492436882.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>299352, "Swap.total"=>2064380, "Swap.used"=>32656, "Swap.free"=>2031724, "hostname"=>"localhost.localdomain", "product"=>"Awesome_Tool"}]
```

### Remove fields with Remove\_key

The following configuration file is to remove 'Swap.\*' fields.

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name record_modifier
    Match *
    Remove_key Swap.total
    Remove_key Swap.used
    Remove_key Swap.free
```

You can also run the filter from command line.

```text
$ fluent-bit -i mem -o stdout -F  record_modifier -p 'Remove_key=Swap.total' -p 'Remove_key=Swap.free' -p 'Remove_key=Swap.used' -m '*'
```

The output will be

```python
[0] mem.local: [1492436998.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>295332}]
```

### Remove fields with Allowlist\_key

The following configuration file is to remain 'Mem.\*' fields.

```python
[INPUT]
    Name mem
    Tag  mem.local

[OUTPUT]
    Name  stdout
    Match *

[FILTER]
    Name record_modifier
    Match *
    Allowlist_key Mem.total
    Allowlist_key Mem.used
    Allowlist_key Mem.free
```

You can also run the filter from command line.

```text
$ fluent-bit -i mem -o stdout -F  record_modifier -p 'Allowlist_key=Mem.total' -p 'Allowlist_key=Mem.free' -p 'Allowlist_key=Mem.used' -m '*'
```

The output will be

```python
[0] mem.local: [1492436998.000000000, {"Mem.total"=>1016024, "Mem.used"=>716672, "Mem.free"=>295332}]
```

