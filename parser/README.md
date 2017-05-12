# Parser

The _Parser_ plugin allows you to convert data from unstructured to structured after it has been received through an _input_ plugin such as stdin or tail.

## Configuration Parameters

The plugin supports the following configuration parameters:

| Key         | Description       |
| ------------|-------------------|
| Parser      | The parser name from your Parser configuration file |

## Getting Started

In order to start filtering records, you can run the parser from the command line or through the configuration file. **_NOTE:_** You must specify a parser configuration file.

### Command Line

```bash
$ fluent-bit -v -i stdin -p Parser=apache2 --parser=../conf/parsers.conf -o stdout
```

### Configuration File

In your main configuration file, you must have _SERVICE_ section that specifies the `Parsers_File` as below:

```python
[SERVICE]
    Parsers_File parsers.conf

[INPUT]
    Name  stdin

[OUTPUT]
    Name  stdout
    Match *
```

## Parser Configuration file

The parser configuration file is referenced by either your main configuration file or via command line (as above). You may configure multiple parsers. Below is an example of how to parse apache2 logs into
structured data.

```
[PARSER]
    Name   apache2
    Format regex
    Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z
```

## Testing

You can test parsing an unstructured apache access log message using the parser configuration file provided in the fluent-bit source repository.

```bash
echo '127.0.0.1 - - [03/Apr/2017:15:36:41 +0000] "GET /server-s
tatus?auto HTTP/1.1" 200 499 "-" "collectd/5.4.0.git"' | ./bin/fluent-bit -v -i
stdin -p Parser=apache2 --parser=../conf/parsers.conf -o stdout
```

If you have an actual unstructured log file, you can test your fluent configuration by running:

```bash
cat apache_access.log | fluent-bit -v -i stdin -p Parser=apache2 --parser=parsers.conf -o stdout
```
