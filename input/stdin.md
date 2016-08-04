# Standard Input

The __stdin__ plugin allows to retrieve valid JSON text messages over the standard input interface (stdin). In order to use it, specify the plugin name as the input, e.g:

```bash
$ ./bin/fluent-bit -i stdin -o stdout
```

As input data the _stdin_ plugin recognize the following JSON data formats:

```bash
1. { map => val, map => val, map => val }
2. [ time, { map => val, map => val, map => val } ]
```

A better example to demonstrate how it works will be through a _Bash_ script that generates messages and writes them to [Fluent Bit](http://fluentbit.io). Write the following content in a file named _test.sh_:

```bash
#!/bin/sh

while :; do
  echo -n "{\"key\": \"some value\"}"
  sleep 1
done
```

Give the script execution permission:

```bash
$ chmod 755 test.sh
```

Now lets start the script and [Fluent Bit](http://fluentbit.io) in the following way:

```bash
$ ./test.sh | bin/fluent-bit -i stdin -o stdout -v
Fluent-Bit v0.8.3
Copyright (C) Treasure Data

[2016/07/24 20:57:28] [ info] starting engine
[2016/07/24 20:57:28] [debug] [router] default match rule stdin.0:stdout.0
[0] (null): [1469361448, {"key"=>"some value"}]
[1] (null): [1469361449, {"key"=>"some value"}]
[2] (null): [1469361450, {"key"=>"some value"}]
[3] (null): [1469361451, {"key"=>"some value"}]
[4] (null): [1469361452, {"key"=>"some value"}]
```
