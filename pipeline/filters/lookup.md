# Lookup

The Lookup plugin looks up a key value from a record in a specified CSV file and, if a match is found, adds the corresponding value from the CSV as a new key-value pair to the record.

## Configuration parameters

The plugin supports the following configuration parameters

| Key | Description | Default |
| :-- | :---------- | :------ |
| `file` | The CSV file that Fluent Bit will use as a lookup table. The file should contain two columns (key and value), with the first row as an optional header that is skipped. Supports quoted fields and escaped quotes. | _none_ |
| `lookup_key` | The specific key in the input record to look up in the CSV file's first column. Supports [record accessor](../../administration/configuring-fluent-bit/record-accessor). | _none_ |
| `result_key` | The name of the key to add to the output record with the matched value from the CSV file's second column if a match is found. | _none_ |
| `ignore_case` | Ignore case when matching the lookup key against the CSV keys. | `false` |

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

The following configuration reads log records from `devices.log` that includes the following values for device hostnames:

```text
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

It uses the value of the `hostname` field (which has been set as the `lookup_key`) to find matching values in column 1 of the  (`device-bu.csv`) CSV file.

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

Where a match is found the filter adds new key (name of which is set by the `result_key` input) with the value from the second column of the CSV file of the matched row.

For above configuration the following output can be expected (when matching case is ignored as `ignore_case` is set to true):

```text
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

The CSV is used to create an in-memory key value lookup table. Column 1 of the CSV is always used as key, while column 2 is assumed to be the value. All other columns in the CSV are ignored.

This filter is intended for static datasets. CSV is loaded once when Fluent Bit starts and is not reloaded.

Multiline values in CSV file are not currently supported.
