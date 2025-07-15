# Lua

The _Lua_ filter lets you modify incoming records (or split one record into multiple records) using custom [Lua](https://www.lua.org/) scripts.

A Lua-based filter requires two steps:

1. Configure the filter in the main configuration.
1. Prepare a Lua script for the filter to use.

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description |
| --- | ----------- |
| `script` | Path to the Lua script that will be used. This can be a relative path against the main configuration file. |
| `call` | The Lua function name that will be triggered to do filtering. It's assumed that the function is declared inside the `script` parameter. |
| `type_int_key` | If these keys are matched, the fields are converted to integers. If more than one key, delimit by space. |
| `type_array_key` | If these keys are matched, the fields are handled as array. If more than one key, delimit by space. The array can be empty. |
| `protected_mode` | If enabled, the Lua script will be executed in protected mode. It prevents Fluent Bit from crashing when an invalid Lua script is executed or the triggered Lua function throws exceptions. Default value: `true`. |
| `time_as_table` | By default, when the Lua script is invoked, the record timestamp is passed as a floating number, which might lead to precision loss when it is converted back. If you need timestamp precision, enabling this option will pass the timestamp as a Lua table with keys `sec` for seconds since epoch and `nsec` for nanoseconds. |
| `code` | Inline Lua code instead of loading from a path defined in `script`. |
| `enable_flb_null` | If enabled, `null` will be converted to `flb_null` in Lua. This helps prevent removing key/value since `nil` is a special value to remove key/value from map in Lua. Default value: `false`. |

## Get started

To test the Lua filter, you can run the plugin from the command line or through the configuration file. The following examples use the [dummy](../inputs/dummy.md) input plugin for data ingestion, invoke Lua filter using the [test.lua](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua) script, and call the [`cb_print()`](https://github.com/fluent/fluent-bit/blob/master/scripts/test.lua#L29) function, which only prints the same information to the standard output.

### Command line

From the command line you can use the following options:

```shell
./fluent-bit -i dummy -F lua -p script=test.lua -p call=cb_print -m '*' -o null
```

### Configuration file

In your main configuration file, append the following `Input`, `Filter`, and `Output` sections:


{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy

  filters:
    - name: lua
      match: '*'
      script: test.lua
      call: cb_print

  outputs:
    - name: null
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name    dummy

[FILTER]
    Name    lua
    Match   *
    script  test.lua
    call    cb_print

[OUTPUT]
    Name    null
    Match   *
```

{% endtab %}
{% endtabs %}

## Lua script filter API

The life cycle of a filter has the following steps:

1. Upon tag matching by this filter, it might process or bypass the record.
1. If the tag matched, it will accept the record and invoke the function defined in the `call` property, which is the name of a function defined in the Lua `script`.
1. It invokes the Lua function and passes each record in JSON format.
1. Upon return, it validates the return value and continues the pipeline.

## Callback prototype

The Lua script can have one or multiple callbacks that can be used by this filter. The function prototype is as follows:

```lua
function cb_print(tag, timestamp, record)
    ...
    return code, timestamp, record
end
```

### Function arguments

| Name | Description |
| ---- | ----------- |
| `tag` | Name of the tag associated with the incoming record. |
| `timestamp` | Unix timestamp with nanoseconds associated with the incoming record. The original format is a double (`seconds.nanoseconds`). |
| `record` | Lua table with the record content. |

### Return values

Each callback must return three values:

| Name | Data type | Description |
| ---- | --------- | ----------- |
| `code` | integer | The code return value represents the result and further actions that might follow. If `code` equals `-1`, this means that the record will be dropped. If `code` equals `0`, the record won't be modified. Otherwise, if `code` equals `1`, this means the original timestamp and record have been modified, so it must be replaced by the returned values from `timestamp` (second return value) and `record` (third return value). If `code` equals `2`, this means the original timestamp won't be modified and the record has been modified, so it must be replaced by the returned values from `record` (third return value). |
| `timestamp` | double | If `code` equals `1`, the original record timestamp will be replaced with this new value. |
| `record` | table | If `code` equals `1`, the original record information will be replaced with this new value. The `record` value must be a valid Lua table. This value can be an array of tables (for example, an array of objects in JSON format), and in that case the input record is effectively split into multiple records. |

## Lua extended callback with groups and metadata support

{% hint style="info" %}
This feature requires Fluent Bit version 4.0.4 or later.
{% endhint %}

For more advanced use cases, especially when working with structured formats like OpenTelemetry logs, Fluent Bit supports an extended callback prototype that provides access to group metadata and record metadata.

### Extended function signature

```lua
function cb_metadata(tag, timestamp, group, metadata, record)
    ...
    return code, timestamp, metadata, record
end
```

#### Extended function arguments

| Name | Description |
| ---- | ----------- |
| `tag` | Name of the tag associated with the incoming record. |
| `timestamp` | Unix timestamp with nanoseconds associated with the incoming record. |
| `group` | A read-only table containing group-level metadata (for example, OpenTelemetry resource or scope info). This will be an empty table if the log is not part of a group. |
| `metadata` | A table representing the record-specific metadata. You can modify this if needed. |
| `record` | Lua table with the record content. |

#### Extended return values

Each extended callback must return four values:

| Name | Data type | Description |
| ---- | --------- | ----------- |
| `code` | integer | The code return value: `-1` (drop record), `0` (no modification), or `1` (record was modified). |
| `timestamp` | double | The updated timestamp. |
| `metadata` | table | A new or modified metadata table. |
| `record` | table | A new or modified log record. This can be an array of tables for splitting records. |

### Function signature detection

At load time, the Lua filter automatically detects which callback prototype to use based on the number of parameters:

- Three arguments: Uses the classic mode (`tag`, `timestamp`, `record`)
- Five arguments: Uses the metadata-aware mode (`tag`, `timestamp`, `group`, `metadata`, `record`)

This ensures backward compatibility with existing Lua scripts.

### Multiple records with metadata

When using the extended prototype, you can return multiple records with their respective metadata:

```lua
function cb_metadata(tag, ts, group, metadata, record)
    -- first record with its metadata
    m1 = {foo = "meta1"}
    r1 = {msg = "first log", old_record = record}

    -- second record with its metadata
    m2 = {foo = "meta2"}
    r2 = {msg = "second log", old_record = record}

    return 1, ts, {m1, m2}, {r1, r2}
end
```

{% hint style="info" %}

The metadata and record arrays must have the same length.

{% endhint %}

### OpenTelemetry example

This example demonstrates processing OpenTelemetry logs with group metadata access:

#### Configuration

```yaml
pipeline:
  inputs:
    - name: opentelemetry
      port: 4318
      processors:
        logs:
          - name: lua
            call: cb_groups_and_metadata
            code: |
              function cb_groups_and_metadata(tag, timestamp, group, metadata, record)
                -- copy the OTLP metadata 'service.name' to the record
                if group['resource']['attributes']['service.name'] then
                  record['service_name'] = group['resource']['attributes']['service.name']
                end

                -- change OTLP Log severity by modifying the record metadata
                if metadata['otlp']['severity_number'] then
                  if metadata['otlp']['severity_number'] == 9 then
                    -- change severity 9 to 13
                    metadata['otlp']['severity_number'] = 13
                    metadata['otlp']['severity_text'] = 'WARN'
                  end
                end

                return 1, timestamp, metadata, record
              end

  outputs:
    - name: stdout
      match: '*'
```

#### Input JSON

```json
{
  "resourceLogs": [
    {
      "resource": {
        "attributes": [
          { "key": "service.name", "value": { "stringValue": "my-app" } },
          { "key": "host.name", "value": { "stringValue": "localhost" } }
        ]
      },
      "scopeLogs": [
        {
          "scope": {
            "name": "example-logger",
            "version": "1.0.0"
          },
          "logRecords": [
            {
              "timeUnixNano": "1717920000000000000",
              "severityNumber": 9,
              "severityText": "INFO",
              "body": {
                "stringValue": "User logged in successfully"
              },
              "attributes": [
                { "key": "user.id", "value": { "stringValue": "12345" } },
                { "key": "env", "value": { "stringValue": "prod" } }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

{% hint style="info" %}

Group metadata is read-only and should not be modified. If you don't need group or metadata support, you can continue using the three-argument prototype.

{% endhint %}

## Features

### Inline configuration

The [Fluent Bit smoke tests](https://github.com/fluent/fluent-bit/tree/master/packaging/testing/smoke/container) include examples to verify during CI.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
  flush: 1
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: random
      tag: test
      samples: 10

  filters:
    - name: lua
      match: '*'
      call: append_tag
      code:  |
          function append_tag(tag, timestamp, record)
             new_record = record
             new_record["my_env"] = FLB_ENV
             return 1, timestamp, new_record
          end

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
	flush 1
	daemon off
	log_level debug

[INPUT]
	Name random
	Tag test
	Samples 10

[FILTER]
	Name Lua
	Match *
	call append_tag
	code function append_tag(tag, timestamp, record) new_record = record new_record["tag"] = tag return 1, timestamp, new_record end

[OUTPUT]
	Name stdout
	Match *
```

{% endtab %}
{% endtabs %}

### Number type

Lua treats numbers as a `double` type, which means an `integer` type containing data like user IDs and log levels will be converted to a `double`. To avoid type conversion, use the `type_int_key` property.

### Protected mode

Fluent Bit supports protected mode to prevent crashes if it executes an invalid Lua script. See [Error Handling in Application Code](https://www.lua.org/pil/24.3.1.html) in the Lua documentation for more information.

## Code examples

For functional examples of this interface, refer to the code samples provided in the source code of the project.

### Processing environment variables

As an example that combines Lua processing with the [Kubernetes filter](./kubernetes.md) that demonstrates using environment variables with Lua regular expressions and substitutions.

Kubernetes pods generally have various environment variables set by the infrastructure automatically, which can contain valuable information.

This example extracts part of the Kubernetes cluster API name.

The environment variable is set as `KUBERNETES_SERVICE_HOST: api.sandboxbsh-a.project.domain.com`.

The goal of this example is to extract the `sandboxbsh` name and add it to the record as a special key.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  filters:
    - name: lua
      alias: filter-iots-lua
      match: iots_thread.*
      script: filters.lua
      call: set_landscape_deployment
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[FILTER]
Name                lua
Alias               filter-iots-lua
Match               iots_thread.*
Script              filters.lua
Call                set_landscape_deployment
```

{% endtab %}
{% endtabs %}

filters.lua:
```lua
-- Use a Lua function to create some additional entries based
-- on substrings from the kubernetes properties.
function set_landscape_deployment(tag, timestamp, record)
    local landscape = os.getenv("KUBERNETES_SERVICE_HOST")
    if landscape then
        -- Strip the landscape name from this field, KUBERNETES_SERVICE_HOST
        -- Should be of this format
        -- api.sandboxbsh-a.project.domain.com
        -- Take off the leading "api."
        -- sandboxbsh-a.project.domain.com
        --print("landscape1:" .. landscape)
        landscape = landscape:gsub("^[^.]+.", "")
        --print("landscape2:" .. landscape)
        -- Take off everything including and after the - in the cluster name
        -- sandboxbsh
        landscape = landscape:gsub("-.*$", "")
        -- print("landscape3:" .. landscape)
        record["iot_landscape"] = landscape
    end
    -- 2 - replace existing record with this update
    return 2, timestamp, record
end
```

### Record split

The Lua callback function can return an array of tables (for example, an array of records) in its third `record` return value. With this feature, the Lua filter can split one input record into multiple records according to custom logic.

For example:

#### Lua script

```lua
function cb_split(tag, timestamp, record)
    if record["x"] ~= nil then
        return 2, timestamp, record["x"]
    else
        return 2, timestamp, record
    end
end
```

#### Configuration

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: stdin

  filters:
    - name: lua
      match: '*'
      script: test.lua
      call: cb_split

  outputs:
    - name: stdout
      match: '*'
```
{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[Input]
    Name    stdin

[Filter]
    Name    lua
    Match   *
    script  test.lua
    call    cb_split

[Output]
    Name    stdout
    Match   *
```

{% endtab %}
{% endtabs %}

#### Input

```text
{"x": [ {"a1":"aa", "z1":"zz"}, {"b1":"bb", "x1":"xx"}, {"c1":"cc"} ]}
{"x": [ {"a2":"aa", "z2":"zz"}, {"b2":"bb", "x2":"xx"}, {"c2":"cc"} ]}
{"a3":"aa", "z3":"zz", "b3":"bb", "x3":"xx", "c3":"cc"}
```

#### Output

```text
[0] stdin.0: [1538435928.310583591, {"a1"=>"aa", "z1"=>"zz"}]
[1] stdin.0: [1538435928.310583591, {"x1"=>"xx", "b1"=>"bb"}]
[2] stdin.0: [1538435928.310583591, {"c1"=>"cc"}]
[3] stdin.0: [1538435928.310588359, {"z2"=>"zz", "a2"=>"aa"}]
[4] stdin.0: [1538435928.310588359, {"b2"=>"bb", "x2"=>"xx"}]
[5] stdin.0: [1538435928.310588359, {"c2"=>"cc"}]
[6] stdin.0: [1538435928.310589790, {"z3"=>"zz", "x3"=>"xx", "c3"=>"cc", "a3"=>"aa", "b3"=>"bb"}]
```

See also [Fluent Bit: PR 811](https://github.com/fluent/fluent-bit/pull/811).

### Response code filtering

This example filters Istio logs to exclude lines with a response code between `1` and `399`. Istio is confiured to write logs in JSON format.

#### Lua script

Script `response_code_filter.lua`

```lua
function cb_response_code_filter(tag, timestamp, record)
  response_code = record["response_code"]
  if (response_code == nil or response_code == '') then
    return 0,0,0
  elseif (response_code ~= 0 and response_code < 400) then
    return -1,0,0
  else
    return 0,0,0
  end
end
```

#### Configuration

Configuration to get Istio logs and apply response code filter to them.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: tail
      path: /var/log/containers/*_istio-proxy-*.log
      multiline.parser: 'docker, cri'
      tag: istio.*
      mem_buf_limit: 64MB
      skip_long_lines: off

  filters:
    - name: lua
      match: istio.*
      script: response_code_filter.lua
      call: cb_response_code_filter

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name                tail
    Path                /var/log/containers/*_istio-proxy-*.log
    multiline.parser    docker, cri
    Tag                 istio.*
    Mem_Buf_Limit       64MB
    Skip_Long_Lines     Off

[FILTER]
    Name                lua
    Match               istio.*
    Script              response_code_filter.lua
    call                cb_response_code_filter

[Output]
    Name                stdout
    Match               *
```

{% endtab %}
{% endtabs %}

#### Input

```json
{
    "log": {
        "response_code": 200,
        "bytes_sent": 111328341,
        "authority": "randomservice.randomservice",
        "duration": 14493,
        "request_id": "2e9d38f8-36a9-40a6-bdb2-47c8eb7d399d",
        "upstream_local_address": "10.11.82.178:42738",
        "downstream_local_address": "10.10.21.17:80",
        "upstream_cluster": "outbound|80||randomservice.svc.cluster.local",
        "x_forwarded_for": null,
        "route_name": "default",
        "upstream_host": "10.11.6.90:80",
        "user_agent": "RandomUserAgent",
        "response_code_details": "via_upstream",
        "downstream_remote_address": "10.11.82.178:51096",
        "bytes_received": 1148,
        "path": "/?parameter=random",
        "response_flags": "-",
        "start_time": "2022-07-28T11:16:51.663Z",
        "upstream_transport_failure_reason": null,
        "method": "POST",
        "connection_termination_details": null,
        "protocol": "HTTP/1.1",
        "requested_server_name": null,
        "upstream_service_time": "6161"
    },
    "stream": "stdout",
    "time": "2022-07-28T11:17:06.704109897Z"
}
```

#### Output

In the output, only the messages with response code `0` or greater than `399` are shown.

### Time format conversion

The following example converts a field's specific type of `datetime` format to the UTC ISO 8601 format.

#### Lua script

Script `custom_datetime_format.lua`:

```lua
function convert_to_utc(tag, timestamp, record)
    local date_time = record["pub_date"]
    local new_record = record
    if date_time then
        if string.find(date_time, ",") then
            local pattern = "(%a+, %d+ %a+ %d+ %d+:%d+:%d+) ([+-]%d%d%d%d)"
            local date_part, zone_part = date_time:match(pattern)

            if date_part and zone_part then
                local command = string.format("date -u -d '%s %s' +%%Y-%%m-%%dT%%H:%%M:%%SZ", date_part, zone_part)
                local handle = io.popen(command)
                local result = handle:read("*a")
                handle:close()
                new_record["pub_date"] = result:match("%S+")
            end
        end
    end
    return 1, timestamp, new_record
end
```

#### Configuration

Use this configuration to obtain a JSON key with `datetime`, and then convert it to another format.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"event": "Restock", "pub_date": "Tue, 30 Jul 2024 18:01:06 +0000"}'
      tag: event_category_a

    - name: dummy
      dummy: '{"event": "Soldout", "pub_date": "Mon, 29 Jul 2024 10:15:00 +0600"}'
      tag: event_category_b

  filters:
    - name: lua
      match: '*'
      code: |
          function convert_to_utc(tag, timestamp, record)
              local date_time = record["pub_date"]
              local new_record = record
              if date_time then
                  if string.find(date_time, ",") then
                      local pattern = "(%a+, %d+ %a+ %d+ %d+:%d+:%d+) ([+-]%d%d%d%d)"
                      local date_part, zone_part = date_time:match(pattern)
                      if date_part and zone_part then
                          local command = string.format("date -u -d '%s %s' +%%Y-%%m-%%dT%%H:%%M:%%SZ", date_part, zone_part)
                          local handle = io.popen(command)
                          local result = handle:read("*a")
                          handle:close()
                          new_record["pub_date"] = result:match("%S+")
                      end
                  end
              end
              return 1, timestamp, new_record
           end
      call: convert_to_utc

  outputs:
    - name: stdout
      match: '*'
```
{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
    Name    dummy
    Dummy   {"event": "Restock", "pub_date": "Tue, 30 Jul 2024 18:01:06 +0000"}
    Tag     event_category_a

[INPUT]
    Name    dummy
    Dummy   {"event": "Soldout", "pub_date": "Mon, 29 Jul 2024 10:15:00 +0600"}
    Tag     event_category_b

[FILTER]
    Name                lua
    Match               *
    Script              custom_datetime_format.lua
    call                convert_to_utc

[Output]
    Name                stdout
    Match               *
```

{% endtab %}
{% endtabs %}

#### Input

```json
{"event": "Restock", "pub_date": "Tue, 30 Jul 2024 18:01:06 +0000"}
```
and

```json
{"event": "Soldout", "pub_date": "Mon, 29 Jul 2024 10:15:00 +0600"}
```
Which are handled by dummy in this example.

#### Output

The output of this process shows the conversion of the `datetime` of two timezones to ISO 8601 format in UTC.

```text
...
[2024/08/01 00:56:25] [ info] [output:stdout:stdout.0] worker #0 started
[0] event_category_a: [[1722452186.727104902, {}], {"event"=>"Restock", "pub_date"=>"2024-07-30T18:01:06Z"}]
[0] event_category_b: [[1722452186.730255842, {}], {"event"=>"Soldout", "pub_date"=>"2024-07-29T04:15:00Z"}]
...
```

### Using configuration variables

Fluent Bit supports definition of configuration variables, which can be done in the following way:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
env:
  myvar1: myvalue1
```

{% endtab %}
{% endtabs %}

These variables can be accessed from the Lua code by referring to the `FLB_ENV` Lua table. Since this is a Lua table, you can access its sub-records through the same syntax (for example, `FLB_ENV['A']`).

#### Configuration

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
env:
  A: aaa
  B: bbb
  C: ccc

service:
  flush: 1
  log_level: info

pipeline:
  inputs:
    - name: random
      tag: test
      samples: 10

  filters:
    - name: lua
      match: '*'
      call: append_tag
      code:  |
          function append_tag(tag, timestamp, record)
             new_record = record
             new_record["my_env"] = FLB_ENV
             return 1, timestamp, new_record
          end

  outputs:
    - name: stdout
      match: '*'
```

{% endtab %}
{% endtabs %}

#### Output

```text
test: [[1731990257.781970977, {}], {"my_env"=>{"A"=>"aaa", "C"=>"ccc", "HOSTNAME"=>"monox-2.lan", "B"=>"bbb"}, "rand_value"=>4805047635809401856}]
```
