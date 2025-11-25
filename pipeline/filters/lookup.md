# Lookup

The Lookup plugin searches for a record key's value in a CSV file's first column and adds the matching row's second column value as a new key-value pair if found.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :-- | :---------- | :------ |
| `data_source` | Path to the CSV file that the Lookup filter will use as a lookup table. This file must contain one column of keys and one column of values. See [Key Considerations](#key-considerations) for details. | _none_ (required) |
| `lookup_key` | Specifies the record key whose value to search for in the CSV file's first column. Supports [record accessor](../administration/configuring-fluent-bit/classic-mode/record-accessor) syntax for nested fields and array indexing (for example, `$user['profile']['id']`, `$users[0]['id']`). | _none_ (required) |
| `result_key` | If a CSV entry whose value matches the value of `lookup_key` is found, specifies the name of the new key to add to the output record. This new key uses the corresponding value from the second column of the CSV file in the same row where `lookup_key` was found. If this key already exists in the record, it will be overwritten. | _none_ (required) |
| `ignore_case` | Specifies whether to ignore case when searching for `lookup_key`. If `true`, searches are case-insensitive. If `false`, searches are case-sensitive. Case normalization applies to both the lookup key from the record and the keys in the CSV file. | `false` |
| `skip_header_row` | If `true`, the filter skips the first row of the CSV file, treating it as a header. If `false`, the first row is processed as data. | `false` |

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
      data_source: device-bu.csv
      lookup_key: $hostname
      result_key: business_line
      ignore_case: true
      skip_header_row: true

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
    Name              lookup
    Match             test
    data_source       device-bu.csv
    Lookup_key        $hostname
    Result_key        business_line
    Ignore_case       On
    Skip_header_row   On

[OUTPUT]
    Name   stdout
    Match  test
```

{% endtab %}
{% endtabs %}

The previous configuration reads log records from `devices.log` that includes the following values in the `hostname` field:

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

Because `hostname` was set as the `lookup_key`, the Lookup filter uses the value of each `hostname` key within the record to search for matching values in the first column of the CSV file.

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

For the previous configuration the following output can be expected (when matching case is ignored as `ignore_case` is set to true):

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

## Metrics

When metrics support is enabled, the Lookup filter exposes the following counters to help monitor filter performance and effectiveness:

| Metric Name | Description |
| :---------- | :---------- |
| `fluentbit_filter_lookup_processed_records_total` | Total number of records processed by the filter |
| `fluentbit_filter_lookup_matched_records_total` | Total number of records where a lookup match was found and the result key was added |
| `fluentbit_filter_lookup_skipped_records_total` | Total number of records skipped due to encoding errors or other processing failures |

Each metric includes a `name` label to identify the filter instance.

## Key considerations

- The CSV is used to create an in-memory key value lookup table. Column 1 of the CSV is always used as key, while column 2 is assumed to be the value. All other columns in the CSV are ignored.
- CSV fields can be enclosed in double quotes (`"`). Lines with unmatched quotes are logged as warnings and skipped.
- Multiline values in CSV file aren't currently supported.
- Duplicate keys (values in first column) in the CSV will use the last occurrence (hash table behavior)
- Leading and trailing whitespace is automatically trimmed from both keys and values.
- The `lookup_key` can be of various types: strings are used directly, integers and floats are converted to their string representation, booleans become `true` or `false`, and null becomes `null`. Records with array or object values for the lookup key are passed through unchanged.
- Records without the `lookup_key` field or with no matching CSV entry are passed through unchanged.
- This filter is currently intended for static datasets. CSV is loaded once when Fluent Bit starts and isn't reloaded.
