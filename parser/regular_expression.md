# Regular Expression

The **regex** parser allows to define a custom Ruby Regular Expression that will use a named capture feature to define which content belongs to which key name.

> Note: understanding how regular expressions works is out of the scope of this content.

From a configuration perspective, when the format is set to **regex**, is mandatory and expected that a _Regex_ configuration key exists.

The following parser configuration example aims to provide rules that can be applied to an Apache HTTP Server log entry:

```python
[PARSER]
    Name   apache
    Format regex
    Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z
```

As an example, takes the following Apache HTTP Server log entry:

```text
192.168.2.20 - - [29/Jul/2015:10:27:10 -0300] "GET /cgi-bin/try/ HTTP/1.0" 200 3395
```

The above content do not provide a defined structure for Fluent Bit, but enabling the proper parser we can help to make a structured representation of it:

```text
[1154104030, {"host"=>"192.168.2.20",
              "user"=>"-",
              "method"=>"GET",
              "path"=>"/cgi-bin/try/",
              "code"=>"200",
              "size"=>"3395",
              "referer"=>"",
              "agent"=>""
              }
]
```

In order to understand, learn and test regular expressions like the example above, we suggest you try the following Ruby Regular Expression Editor: [http://rubular.com/r/X7BH0M4Ivm](http://rubular.com/r/X7BH0M4Ivm)

