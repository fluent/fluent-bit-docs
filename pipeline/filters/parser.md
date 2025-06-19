# Parser

The _Parser_ filter allows for parsing fields in event records.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `Key_Name` | Specify field name in record to parse. | _none_ |
| `Parser` | Specify the parser name to interpret the field. Multiple parser entries are allowed (one per line). | _none_ |
| `Preserve_Key` | Keep the original `Key_Name` field in the parsed result. If false, the field will be removed. | `False` |
| `Reserve_Data` | Keep all other original fields in the parsed result. If false, all other original fields will be removed. | `False` |

## Get started

### Configuration file

The plugin needs a parser file which defines how to parse each field.

This is an example of parsing a record `{"data":"100 0.5 true This is example"}`.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
    - name: dummy_test
      format: regex
      regex: '^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

{% endtab %}
{% endtabs %}

The path of the parser file should be written in configuration file under the `[SERVICE]` section.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    parsers_file: /path/to/parsers.yaml

pipeline:
    inputs:
      - name: dummy
        tag: dummy.data
        dummy: '{"data":"100 0.5 true This is example"}'

    filters:
      - name: parser
        match: 'dummy.*'
        key_name: data
        parser: dummy_test

    outputs:
      - name: stdout
        match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test

[OUTPUT]
    Name stdout
    Match *
```

{% endtab %}
{% endtabs %}

The output when running the corresponding configuration is as follows:

```text
# For YAML configuration.
$ ./fluent-bit --config fluent-bit.yaml

# For classic configuration.
$ ./fluent-bit --config fluent-bit.conf

Fluent Bit v4.0.0
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io
______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/

[2025/06/19 10:58:47] [ info] [fluent bit] version=4.0.0, commit=3a91b155d6, pid=76206
[2025/06/19 10:58:47] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/06/19 10:58:47] [ info] [simd    ] disabled
[2025/06/19 10:58:47] [ info] [cmetrics] version=0.9.9
[2025/06/19 10:58:47] [ info] [ctraces ] version=0.6.2
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] initializing
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2025/06/19 10:58:47] [ info] [output:stdout:stdout.0] worker #0 started
[2025/06/19 10:58:47] [ info] [sp] stream processor started
[0] dummy.data: [[1750323528.603308000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[0] dummy.data: [[1750323529.603788000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[0] dummy.data: [[1750323530.604204000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
[0] dummy.data: [[1750323531.603961000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example"}]
```

You can see the records `{"data":"100 0.5 true This is example"}` are parsed.

### Preserve original fields

By default, the parser plugin only keeps the parsed fields in its output.

If you enable `Reserve_Data`, all other fields are preserved. First the contents of the corresponding parsers file, 
depending on the choice for YAML or classic configurations, would be as follows:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
    - name: dummy_test
      format: regex
      regex: '^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$'
```

{% endtab %}

{% tab title="parsers.conf" %}

```text
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

{% endtab %}
{% endtabs %}

Now add `Reserve_Data` to the filter section of the corresponding configuration file as follows:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    parsers_file: /path/to/parsers.yaml

pipeline:
    inputs:
      - name: dummy
        tag: dummy.data
        dummy: '{"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}'

    filters:
      - name: parser
        match: 'dummy.*'
        key_name: data
        parser: dummy_test
        reserve_data: on

    outputs:
      - name: stdout
        match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test
    Reserve_Data On
    
 [OUTPUT]
    Name stdout
    Match *
```

{% endtab %}
{% endtabs %}

The output when running the corresponding configuration is as follows:

```text
# For YAML configuration.
$ ./fluent-bit --config fluent-bit.yaml

# For classic configuration.
$ ./fluent-bit --config fluent-bit.conf

Fluent Bit v4.0.0
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io
______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/

[2025/06/19 10:58:47] [ info] [fluent bit] version=4.0.0, commit=3a91b155d6, pid=76206
[2025/06/19 10:58:47] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/06/19 10:58:47] [ info] [simd    ] disabled
[2025/06/19 10:58:47] [ info] [cmetrics] version=0.9.9
[2025/06/19 10:58:47] [ info] [ctraces ] version=0.6.2
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] initializing
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2025/06/19 10:58:47] [ info] [output:stdout:stdout.0] worker #0 started
[2025/06/19 10:58:47] [ info] [sp] stream processor started
[0] dummy.data: [[1750325238.681398000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1750325239.682090000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1750325240.682903000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "key1"=>"value1", "key2"=>"value2"}]
```

If you enable `Reserve_Data` and `Preserve_Key`, the original key field will also be preserved. First the contents of 
the corresponding parsers file, depending on the choice for YAML or classic configurations, would be as follows:

{% tabs %}
{% tab title="parsers.yaml" %}

```yaml
parsers:
    - name: dummy_test
      format: regex
      regex: '^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$'
```

{% endtab %}

{% tab title="parsers.conf" %}

```text
[PARSER]
    Name dummy_test
    Format regex
    Regex ^(?<INT>[^ ]+) (?<FLOAT>[^ ]+) (?<BOOL>[^ ]+) (?<STRING>.+)$
```

{% endtab %}
{% endtabs %}

Now add `Reserve_Data` and `Preserve_Key`to the filter section of the corresponding configuration file as follows:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    parsers_file: /path/to/parsers.yaml

pipeline:
    inputs:
      - name: dummy
        tag: dummy.data
        dummy: '{"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}'

    filters:
      - name: parser
        match: 'dummy.*'
        key_name: data
        parser: dummy_test
        reserve_data: on
        preserve_key: on

    outputs:
      - name: stdout
        match: '*'
```

{% endtab %}

{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Parsers_File /path/to/parsers.conf

[INPUT]
    Name dummy
    Tag  dummy.data
    Dummy {"data":"100 0.5 true This is example", "key1":"value1", "key2":"value2"}

[FILTER]
    Name parser
    Match dummy.*
    Key_Name data
    Parser dummy_test
    Reserve_Data On
    Preserve_Key On
    
 [OUTPUT]
    Name stdout
    Match *
```

{% endtab %}
{% endtabs %}

The output when running the corresponding configuration is as follows:

```text
# For YAML configuration.
$ ./fluent-bit --config fluent-bit.yaml

# For classic configuration.
$ ./fluent-bit --config fluent-bit.conf

Fluent Bit v4.0.0
* Copyright (C) 2015-2025 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io
______ _                  _    ______ _ _             ___  _____
|  ___| |                | |   | ___ (_) |           /   ||  _  |
| |_  | |_   _  ___ _ __ | |_  | |_/ /_| |_  __   __/ /| || |/' |
|  _| | | | | |/ _ \ '_ \| __| | ___ \ | __| \ \ / / /_| ||  /| |
| |   | | |_| |  __/ | | | |_  | |_/ / | |_   \ V /\___  |\ |_/ /
\_|   |_|\__,_|\___|_| |_|\__| \____/|_|\__|   \_/     |_(_)___/

[2025/06/19 10:58:47] [ info] [fluent bit] version=4.0.0, commit=3a91b155d6, pid=76206
[2025/06/19 10:58:47] [ info] [storage] ver=1.5.2, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2025/06/19 10:58:47] [ info] [simd    ] disabled
[2025/06/19 10:58:47] [ info] [cmetrics] version=0.9.9
[2025/06/19 10:58:47] [ info] [ctraces ] version=0.6.2
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] initializing
[2025/06/19 10:58:47] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
[2025/06/19 10:58:47] [ info] [output:stdout:stdout.0] worker #0 started
[2025/06/19 10:58:47] [ info] [sp] stream processor started
[0] dummy.data: [[1750325678.572817000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1750325679.574538000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
[0] dummy.data: [[1750325680.569750000, {}], {"INT"=>"100", "FLOAT"=>"0.5", "BOOL"=>"true", "STRING"=>"This is example", "data"=>"100 0.5 true This is example", "key1"=>"value1", "key2"=>"value2"}]
```