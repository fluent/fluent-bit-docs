# JSON

The _JSON_ parser transforms JSON logs by converting them to internal binary representations.

For example, the default parsers configuration file includes a parser for parsing Docker logs (when the Tail input plugin is used):

```python
[PARSER]
    Name        docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S %z
```

The following log entry is valid content for the previously defined parser:

```javascript
{"key1": 12345, "key2": "abc", "time": "2006-07-28T13:22:04Z"}
```

After processing, its internal representation will be:

```text
[1154103724, {"key1"=>12345, "key2"=>"abc"}]
```

The time was converted to a UTC timestamp and the map was reduced to each component of the original message.
