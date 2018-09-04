# JSON Parser

The JSON parser is the simplest option: if the original log source is a JSON map string, it will take it structure and convert it directly to the internal binary representation.

A simple configuration that can be found in the default parsers configuration file, is the entry to parse Docker log files \(when the tail input plugin is used\):

```python
[PARSER]
    Name        docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S %z
```

The following log entry is a valid content for the parser defined above:

```javascript
{"key1": 12345, "key2": "abc", "time": "28/Jul/2006:10:22:04 -0300"}
```

After processing, it internal representation will be:

```text
[1154103724, {"key1"=>12345, "key2"=>"abc"}]
```

The time has been converted to Unix timestamp \(UTC\) and the map reduced to each component of the original message.

