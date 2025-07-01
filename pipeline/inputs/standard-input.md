# Standard input

The _Standard input_ plugin supports retrieving a message stream from the standard input interface (`stdin`) of the Fluent Bit process.
To use it, specify the plugin name as the input. For example:

```bash
 fluent-bit -i stdin -o stdout
```

If the `stdin` stream is closed (`end-of-file`), the plugin instructs Fluent Bit to exit with success (`0`) after flushing any pending output.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Buffer_Size` | Set the buffer size to read data. This value is used to increase buffer size and must be set according to the [Unit Size](../../administration/configuring-fluent-bit/unit-sizes.md) specification. | `16k` |
| `Parser` | The name of the parser to invoke instead of the default JSON input parser. | _none_ |
| `Threaded` | Indicates whether to run this input in its own [thread](../../administration/multithreading.md#inputs). | `false` |

## Input formats

If no parser is configured for the `stdin` plugin, it expects valid JSON input data in one of the following formats:

- A JSON object with one or more key-value pairs: `{ "key": "value", "key2": "value2" }`
- A 2-element JSON array in [Fluent Bit Event](../../concepts/key-concepts.md#event-or-record) format, which can be:
  - `[TIMESTAMP, { "key": "value" }]` where TIMESTAMP is a floating point value representing a timestamp in seconds.
  - From Fluent Bit v2.1.0, `[[TIMESTAMP, METADATA], { "key": "value" }]` where _`TIMESTAMP`_ has the same meaning as previous and _`METADATA`_ is a JSON object.

Multi-line input JSON is supported.

Any input data which isn't in one of the supported formats will cause the plugin to log errors like:

```text
[debug] [input:stdin:stdin.0] invalid JSON message, skipping
[error] [input:stdin:stdin.0] invalid record found, it's not a JSON map or array
```

To handle inputs in other formats, a parser must be explicitly specified in the configuration for the `stdin` plugin. See [parser input example](#parser-input) for sample configuration.

## Log event timestamps

The Fluent Bit event timestamp will be set from the input record if the two-element event input is used or a custom parser configuration supplies a timestamp. Otherwise the event timestamp will be set to the timestamp at which the record is read by the `stdin` plugin.

## Examples

### JSON input

To demonstrate how the plugin works, you can use a `bash` script that generates messages and writes them to [Fluent Bit](http://fluentbit.io).

1. Write the following content in a file named `test.sh`:

   ```bash
   #!/bin/sh

   for ((i=0; i<=5; i++)); do
     echo -n "{\"key\": \"some value\"}"
     sleep 1
   done
   ```

1. Start the script and [Fluent Bit](http://fluentbit.io):

   ```bash
    bash test.sh | fluent-bit -q -i stdin -o stdout
   ```

The command should return output like the following:

```text
[0] stdin.0: [[1684196745.942883835, {}], {"key"=>"some value"}]
[0] stdin.0: [[1684196746.938949056, {}], {"key"=>"some value"}]
[0] stdin.0: [[1684196747.940162493, {}], {"key"=>"some value"}]
[0] stdin.0: [[1684196748.941392297, {}], {"key"=>"some value"}]
[0] stdin.0: [[1684196749.942644238, {}], {"key"=>"some value"}]
[0] stdin.0: [[1684196750.943721442, {}], {"key"=>"some value"}]
```

### JSON input with timestamp

An input event timestamp can also be supplied. Replace `test.sh` with:

```bash
#!/bin/sh

for ((i=0; i<=5; i++)); do
  echo -n "
    [
      $(date '+%s.%N' -d '1 day ago'),
      {
        \"realtimestamp\": $(date '+%s.%N')
      }
    ]
  "
  sleep 1
done
```

Re-run the sample command. Timestamps output by Fluent Bit are now one day old because Fluent Bit used the input message timestamp.

```bash
bash test.sh | fluent-bit -q -i stdin -o stdout
```

Which returns the following:

```text
[0] stdin.0: [[1684110480.028171300, {}], {"realtimestamp"=>1684196880.030070}]
[0] stdin.0: [[1684110481.033753395, {}], {"realtimestamp"=>1684196881.034741}]
[0] stdin.0: [[1684110482.036730051, {}], {"realtimestamp"=>1684196882.037704}]
[0] stdin.0: [[1684110483.039903879, {}], {"realtimestamp"=>1684196883.041081}]
[0] stdin.0: [[1684110484.044719457, {}], {"realtimestamp"=>1684196884.046404}]
[0] stdin.0: [[1684110485.048710107, {}], {"realtimestamp"=>1684196885.049651}]
```

### JSON input with metadata

Additional metadata is supported in Fluent Bit v2.1.0 and later by replacing the timestamp with a two-element object. For example:

```bash
#!/bin/sh
for ((i=0; i<=5; i++)); do
  echo -n "
    [
      [
        $(date '+%s.%N' -d '1 day ago'),
	{\"metakey\": \"metavalue\"}
      ],
      {
        \"realtimestamp\": $(date '+%s.%N')
      }
    ]
  "
  sleep 1
done
```

Run test using the command:

```bash
bash ./test.sh | fluent-bit -q -i stdin -o stdout
```

Which returns results like the following:

```text
[0] stdin.0: [[1684110513.060139417, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196913.061017}]
[0] stdin.0: [[1684110514.063085317, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196914.064145}]
[0] stdin.0: [[1684110515.066210508, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196915.067155}]
[0] stdin.0: [[1684110516.069149971, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196916.070132}]
[0] stdin.0: [[1684110517.072484016, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196917.073636}]
[0] stdin.0: [[1684110518.075428724, {"metakey"=>"metavalue"}], {"realtimestamp"=>1684196918.076292}]
```

On older Fluent Bit versions records in this format will be discarded. If the log level permits, Fluent Bit will log:

```text
[ warn] unknown time format 6
```

### Parser input

To capture inputs in other formats, specify a parser configuration for the `stdin` plugin.

For example, if you want to read raw messages line by line and forward them, you could use a `parser.conf` that captures the whole message line:

```text
[PARSER]
    name        stringify_message
    format      regex
    Key_Name    message
    regex       ^(?<message>.*)
```

You can then use that in the `parser` clause of the `stdin` plugin in the `fluent-bit.conf` file:

{% tabs %}

{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: stdin
          tag: stdin
          parser: stringify_message
    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name    stdin
    Tag     stdin
    Parser  stringify_message

[OUTPUT]
    Name   stdout
    Match  *
```

{% endtab %}
{% endtabs %}

Fluent Bit will now read each line and emit a single message for each input line, using the following command:

```shell
seq 1 5 | /opt/fluent-bit/bin/fluent-bit -c fluent-bit.conf -R parser.conf -q
```

Which returns output similar to:

```text
[0] stdin: [1681358780.517029169, {"message"=>"1"}]
[1] stdin: [1681358780.517068334, {"message"=>"2"}]
[2] stdin: [1681358780.517072116, {"message"=>"3"}]
[3] stdin: [1681358780.517074758, {"message"=>"4"}]
[4] stdin: [1681358780.517077392, {"message"=>"5"}]
$
```

In production deployments it's best to use a parser that splits messages into real fields and adds appropriate tags.
