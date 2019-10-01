# Logfmt Parser

The **logfmt** parser allows to parse the logfmt format described in [https://brandur.org/logfmt](https://brandur.org/logfmt) . A more formal description is in [https://godoc.org/github.com/kr/logfmt](https://godoc.org/github.com/kr/logfmt) .

Here is an example configuration:

```python
[PARSER]
    Name        logfmt
    Format      logfmt
```

The following log entry is a valid content for the parser defined above:

```text
key1=val1 key2=val2
```

After processing, it internal representation will be:

```text
[1540936693, {"key1"=>"val1",
              "key2"=>"val2"}]
```

