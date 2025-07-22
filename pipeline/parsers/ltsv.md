# LTSV

The _LTSV_ parser lets you parse data in the [Labeled Tab-separated Values (LTSV)](http://ltsv.org/) format.

LTSV is a variant of the Tab-separated Values (TSV) format. Each record in an LTSV file is represented as a single line. Each field is separated by a tab and has a label and a value. The label and its value are separated by a colon (`:`).

Here is an example how to use this format in the Apache access log.

Configure this in `httpd.conf`:

```text
LogFormat "host:%h\tident:%l\tuser:%u\ttime:%t\treq:%r\tstatus:%>s\tsize:%b\treferer:%{Referer}i\tua:%{User-Agent}i" combined_ltsv
CustomLog "logs/access_log" combined_ltsv
```

The following is an example parsers configuration file:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
  - name: access_log_ltsv
    format: ltsv
    time_key: time
    time_format: '[%d/%b/%Y:%H:%M:%S %z]'
    types: status:integer size:integer
```

{% endtab %}
{% tab title="parsers.conf" %}

```text
[PARSER]
  Name        access_log_ltsv
  Format      ltsv
  Time_Key    time
  Time_Format [%d/%b/%Y:%H:%M:%S %z]
  Types       status:integer size:integer
```

{% endtab %}
{% endtabs %}

The following log entry is valid content for the previously defined parser:

```text
...
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET / HTTP/1.1      status:200      size:16218      referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/plugins/bootstrap/css/bootstrap.min.css HTTP/1.1        status:200      size:121200     referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/css/headers/header-v6.css HTTP/1.1      status:200      size:37706      referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
host:127.0.0.1  ident:- user:-  time:[10/Jul/2018:13:27:05 +0200]       req:GET /assets/css/style.css HTTP/1.1  status:200      size:1279       referer:http://127.0.0.1/       ua:Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0
...
```

After processing, its internal representation will be:

```text
...
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET / HTTP/1.1", "status"=>200, "size"=>16218, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/plugins/bootstrap/css/bootstrap.min.css HTTP/1.1", "status"=>200, "size"=>121200, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/css/headers/header-v6.css HTTP/1.1", "status"=>200, "size"=>37706, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
[1531222025.000000000, {"host"=>"127.0.0.1", "ident"=>"-", "user"=>"-", "req"=>"GET /assets/css/style.css HTTP/1.1", "status"=>200, "size"=>1279, "referer"=>"http://127.0.0.1/", "ua"=>"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"}]
...
```

The time was converted to Unix timestamp (UTC).