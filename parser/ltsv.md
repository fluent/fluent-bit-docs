# LTSV Parser

The **ltsv** parser allows to parse [LTSV](http://ltsv.org/) formatted texts. 

Labeled Tab-separated Values (LTSV format is a variant of Tab-separated Values (TSV). Each record in a LTSV file is represented as a single line. Each field is separated by TAB and has a label and a value. The label and the value have been separated by ':'.

Here is an example how to use this format in the apache access log.

Config this in httpd.conf:

```text
LogFormat "host:%h\tident:%l\tuser:%u\ttime:%t\treq:%r\tstatus:%>s\tsize:%b\treferer:%{Referer}i\tua:%{User-Agent}i" combined_ltsv
CustomLog "logs/access_log" combined_ltsv
```

The parser.conf:

```python
[PARSER]
    Name        access_log_ltsv
    Format      ltsv
    Time_Key    time
    Time_Format [%d/%b/%Y:%H:%M:%S %z]
    Types       status:integer size:integer
```

The following log entry is a valid content for the parser defined above:

```text
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET / HTTP/1.1      status:200      size:16218      referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/plugins/bootstrap/css/bootstrap.min.css HTTP/1.1        status:200      size:121200     referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/css/headers/header-v6.css HTTP/1.1      status:200      size:37706      referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/css/style.css HTTP/1.1  status:200      size:1279       referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
```

After processing, it internal representation will be:

```text
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET / HTTP/1.1", "status"=>200, "size"=>16218, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/plugins/bootstrap/css/bootstrap.min.css HTTP/1.1", "status"=>200, "size"=>121200, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/css/headers/header-v6.css HTTP/1.1", "status"=>200, "size"=>37706, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/css/style.css HTTP/1.1", "status"=>200, "size"=>1279, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
```

The time has been converted to Unix timestamp \(UTC\).
