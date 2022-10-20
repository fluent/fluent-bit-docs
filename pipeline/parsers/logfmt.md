# Logfmt

The **logfmt** parser allows to parse the logfmt format described in [https://brandur.org/logfmt](https://brandur.org/logfmt) . A more formal description is in [https://godoc.org/github.com/kr/logfmt](https://godoc.org/github.com/kr/logfmt) .

Here is an example configuration:

```python
[PARSER]
    Name        logfmt
    Format      logfmt
```

The following log entry is a valid content for the parser defined above:

```text
key1=val1 key2=val2 key3
```

After processing, it internal representation will be:

```text
[1540936693, {"key1"=>"val1",
              "key2"=>"val2"
              "key3"=>true}]
```

If you want to be more strict than the logfmt standard and not parse lines where some attributes do
not have values (such as `key3`) in the example above, you can configure the parser as follows:

```python
[PARSER]
    Name        logfmt
    Format      logfmt
    Logfmt_No_Bare_Keys true
```
