# Standard Input

The **stdin** plugin supports retrieving a message stream from the standard input interface \(stdin\) of the Fluent Bit process.
In order to use it, specify the plugin name as the input, e.g:

```bash
$ fluent-bit -i stdin -o stdout
```

If the stdin stream is closed (end-of-file), the stdin plugin will instruct
Fluent Bit to exit with success (0) after flushing any pending output.

## Input formats

If no parser is configured for the stdin plugin, it expects *valid json* input input data with one of the following data formats:

```bash
1. { map => val, map => val, map => val }
2. [ time, { map => val, map => val, map => val } ]
```

Any input data that is *not* in one of the above formats will cause the plugin to log errors like:

```
[error] [input:stdin:stdin.0] invalid record found, it's not a JSON map or array
```

To handle inputs in other formats, a parser must be explicitly specified in the configuration for the `stdin` plugin. See [parser input example](#parser-input-example) for sample configuration.

## Examples

### Json input example

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
Fluent Bit v1.x.x
* Copyright (C) 2019-2020 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2016/10/07 21:44:46] [ info] [engine] started
[0] stdin.0: [1475898286, {"key"=>"some value"}]
[1] stdin.0: [1475898287, {"key"=>"some value"}]
[2] stdin.0: [1475898288, {"key"=>"some value"}]
[3] stdin.0: [1475898289, {"key"=>"some value"}]
[4] stdin.0: [1475898290, {"key"=>"some value"}]
```

### Parser input example <a id="parser-input-example"></a>

To capture inputs in other formats, specify a parser configuration for the
`stdin` plugin.

For example, if you want to read raw messages line-by-line and forward them you
could use a `parser.conf` that captures the whole message line:

```
[PARSER]
    name        stringify_message
    format      regex
    Key_Name    message
    regex       ^(?<message>.*)
```

then use that in the `parser` clause of the stdin plugin in the `fluent-bit.conf`:

```
[INPUT]
    Name    stdin
    Tag     stdin
    Parser  stringify_message

[OUTPUT]
    Name   stdout
    Match  *
```

Fluent Bit will now read each line and emit a single message for each input
line:

```
$ seq 1 5 | /opt/fluent-bit/bin/fluent-bit -c fluent-bit.conf -R parser.conf -q
[0] stdin: [1681358780.517029169, {"message"=>"1"}]
[1] stdin: [1681358780.517068334, {"message"=>"2"}]
[2] stdin: [1681358780.517072116, {"message"=>"3"}]
[3] stdin: [1681358780.517074758, {"message"=>"4"}]
[4] stdin: [1681358780.517077392, {"message"=>"5"}]
$
```

In real-world deployments it is best to use a more realistic parser that splits
messages into real fields and adds appropriate tags.

## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Buffer\_Size | Set the buffer size to read data. This value is used to increase buffer size. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | 16k |
| Parser | The name of the parser to invoke instead of the default json input parser | |
