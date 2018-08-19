# Standard Input

The **stdin** plugin allows to retrieve valid JSON text messages over the standard input interface \(stdin\). In order to use it, specify the plugin name as the input, e.g:

```bash
$ fluent-bit -i stdin -o stdout
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
$ ./test.sh | fluent-bit -i stdin -o stdout
Fluent-Bit v0.9.0
Copyright (C) Treasure Data

[2016/10/07 21:44:46] [ info] [engine] started
[0] stdin.0: [1475898286, {"key"=>"some value"}]
[1] stdin.0: [1475898287, {"key"=>"some value"}]
[2] stdin.0: [1475898288, {"key"=>"some value"}]
[3] stdin.0: [1475898289, {"key"=>"some value"}]
[4] stdin.0: [1475898290, {"key"=>"some value"}]
```

