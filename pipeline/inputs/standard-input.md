# Standard Input

The **stdin** plugin allows the retrieving of text messages (by default, text text is assumed to be valid JSON)  over the standard input interface \(stdin\). To receive text messages that don't satisfy the default JSON format, we need to define an appropriate parser. In order to use it, specify the plugin name as the input, e.g.:

```bash
$ fluent-bit -i stdin -o stdout
```

As input data, the _stdin_ plugin, by default, recognizes the following JSON data formats:

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

Now let's start the script and [Fluent Bit ](http://fluentbit.io)in the following way:

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

## Stdin with a parser

To handle non-standard content, we need to define a [Parser](../parsers/configuring-parser.md) to use. Within the input plugin we do this with the Parser attribute, which will reference the name of a parser included in the configuration from the Service attributes ([Classic](../../administration/configuring-fluent-bit/classic-mode/configuration-file#config_section) or [YAML](../../administration/configuring-fluent-bit/taml/configuration-file#config_section)). For example if we wanted to treat each complete line as a plain text into the attribute *msg* we would need a parser file like this:

```
parser.conf
```

```
[PARSER]
    Name   plaintext
    Format regex
    Regex  (?<msg>([^\n*])+)
```

### Command Line

We can then run Fluent Bit using the CLI with the command:

`fluent-bit -R ./simple-parser.conf -i stdin -p "parser=plaintext" -o stdout`

The output generated would look like this:

```[2023/05/09 23:13:07] [ info] [output:stdout:stdout.0] worker #0 started
[0] stdin.0: [1683670387.340479896, {"msg"=>"{"key": "some value"}"}]
[0] stdin.0: [1683670388.252968765, {"msg"=>"{"key": "some value"}"}]
[0] stdin.0: [1683670389.253937223, {"msg"=>"{"key": "some value"}"}]
[0] stdin.0: [1683670390.254814061, {"msg"=>"{"key": "some value"}"}]
```

### Config file (Classic format)

The Fluent Bit configuration in Classic format would then look like this:

`
fluent-bit.conf
`

```
[SERVICE]
    flush 1
    grace 1
    log_level info
    http_server off
    parsers_file parser.conf

[INPUT]
    name stdin
    parser plaintext

[OUTPUT]
    name stdout
    match *
```



## Configuration Parameters <a id="config"></a>

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| Buffer\_Size | Set the buffer size to read data. This value is used to increase buffer size. The value must be according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | 16k |
| Parser | The name of the parser to be used if the messages are not standard. To see how parsers are us |  |

