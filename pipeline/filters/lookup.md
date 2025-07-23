# Lookup

The _Lookup_ plugin searches for a specified key in a CSV file and, if it finds a match, adds a new key to the output record whose value matches the corresponding CSV value.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :-- | :---------- | :------ |
| `file` | The CSV file that the Lookup filter will use as a lookup table. This file must contain one column of keys and one column of values. The Lookup filter treats the first row as a header and ignores it. Supported quoted fields and escaped quotes. | _none_ |
| `lookup_key` | Specifies the key to search for in the CSV file's first column. Supports [record accessor](../administration/configuring-fluent-bit/classic-mode/record-accessor) syntax. | _none_ |
| `result_key` | If `lookup_key` is found, specifies the name of the new key to add to the output record. This new key uses the corresponding value from the second column of the CSV file in the same row where `lookup_key` was found.  | _none_ |
| `ignore_case` | Specifies whether to ignore case when searching for `lookup_key`. If `true`, searches are case-insensitive. If `false`, searches are case-sensitive. Possible values: `true`, `false`. | `false` |

## Example configuration

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
parsers:
  - name: json
    format: json

pipeline:
  inputs:
    - name: tail
      tag: test
      path: devices.log
      read_from_head: true
      parser: json

  filters:
    - name: lookup
      match: test
      file: device-bu.csv
      lookup_key: $hostname
      result_key: business_line
      ignore_case: true

  outputs:
    - name: stdout
      match: test
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[PARSER]
    Name        json
    Format      json

[INPUT]
    Name              tail
    Tag               test
    Path              devices.log
    Read_from_head    On
    Parser            json

[FILTER]
    Name           lookup
    Match          test
    File           device-bu.csv
    Lookup_key     $hostname
    Result_key     business_line
    Ignore_case    On

[OUTPUT]
    Name   stdout
    Match  test
```

{% endtab %}
{% endtabs %}

The previous configuration reads log records from `devices.log` that includes the following values in the `hostname` field:

```shell
{"hostname": "server-prod-001"}
{"hostname": "Server-Prod-001"}
{"hostname": "db-test-abc"}
{"hostname": 123}
{"hostname": true}
{"hostname": " host with space "}
{"hostname": "quoted \"host\""}
{"hostname": "unknown-host"}
{}
{"hostname": [1,2,3]}
{"hostname": {"sub": "val"}}
{"hostname": " "}
```

It uses the value of the `hostname` field (which was set as the `lookup_key`) to find matching values in the first column of `device-bu.csv`.

```text
hostname,business_line
server-prod-001,Finance
db-test-abc,Engineering
db-test-abc,Marketing
web-frontend-xyz,Marketing
app-backend-123,Operations
"legacy-system true","Legacy IT"
" host with space ","Infrastructure"
"quoted ""host""", "R&D"
no-match-host,Should Not Appear
```

When the filter finds a match, it adds a new key with the name specified by `result_key` and a value from the second column of the CSV file of the row where `lookup_key` was found.

This results in output that resembles the following:

```shell
{"hostname"=>"server-prod-001", "business_line"=>"Finance"}
{"hostname"=>"Server-Prod-001", "business_line"=>"Finance"}
{"hostname"=>"db-test-abc", "business_line"=>"Marketing"}
{"hostname"=>123}
{"hostname"=>true}
{"hostname"=>" host with space ", "business_line"=>"Infrastructure"}
{"hostname"=>"quoted "host"", "business_line"=>"R&D"}
{"hostname"=>"unknown-host"}
{}
{"hostname"=>[1, 2, 3]}
{"hostname"=>{"sub"=>"val"}}
```

## CSV import


Fluent Bit creates an in-memory key/value lookup table from the CSV file that you provide. The first column of this CSV is always treated as a key, and its second column as a value. Any other columns are ignored.

This filter is intended for static datasets. After Fluent Bit loads the CSV file, it won't reload that file, which means the filter's lookup table won't update to reflect any changes.

This filter doesn't support multiline values in CSV files.
