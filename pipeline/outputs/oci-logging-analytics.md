---
description: Send logs to Oracle Cloud Infrastructure Logging Analytics Service
---

# Oracle Cloud Infrastructure Logging Analytics

The _Oracle Cloud Infrastructure Logging Analytics_ output plugin lets you ingest your log records into the [Oracle Cloud Infrastructure (OCI) Logging Analytics](https://docs.oracle.com/en-us/iaas/logging-analytics/home.htm) service.

## Configuration parameters

This plugin uses the following configuration parameters:

| Key | Description | Default |
| --- | ----------- | ------- |
| `config_file_location` | The location of the [configuration file](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File) that contains OCI authentication details. | _none_ |
| `profile_name` | The OCI configuration profile name to be used from the configuration file. | `DEFAULT` |
| `namespace` | The OCI tenancy namespace to upload log data to. | _none_ |
| `proxy` | The proxy name, in `http://host:port` format. Only supports HTTP protocol. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |
| `oci_config_in_record` | If set to `true`, the following `oci_la_*` will be read from the record itself instead of the output plugin configuration. | `false` |
| `oci_la_log_group_id` | Required. The Oracle Cloud Identifier (OCID) of the Logging Analytics where you want to store logs. | _none_ |
| `oci_la_log_source_name` | Required. The Logging Analytics Source to use for processing log records. | _none_ |
| `oci_la_entity_id` | The OCID of the Logging Analytics entity. | _none_ |
| `oci_la_entity_type` | The entity type of the Logging Analytics entity. | _none_ |
| `oci_la_log_path` | Specifies the original location of the log files. | _none_ |
| `oci_la_global_metadata` | Specifies additional global metadata along with original log content to Logging Analytics. The format is `key_name value`. This option can be set multiple times. | _none_ |
| `oci_la_metadata` | Specifies additional metadata for a log event along with original log content to Logging Analytics. The format is `key_name value`. This option can be set multiple times. | _none_ |

### TLS/SSL

The OCI Logging Analytics output plugin supports TLS/SSL. For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Get started

### Prerequisites

- You must onboard with the OCI Logging Analytics service for the minimum required policies in the OCI region where you want to monitor. Refer to [Logging Analytics Quick Start](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/quick-start.html) for details.

- You must create one or more OCI Logging Analytics log groups. Refer to [Create Log Group](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-logging-analytics-resources.html#GUID-D1758CFB-861F-420D-B12F-34D1CC5E3E0E) for details.

### Run the output plugin

To insert records into the OCI Logging Analytics service, you can run the plugin from the command line or through a configuration file.

#### Command line

The OCI Logging Analytics plugin can read the parameters from the command line in two ways, through the `-p` (property) argument. For example:

```shell
fluent-bit -i dummy -t dummy -o oci_logan -p config_file_location=<location> -p namespace=<namespace> \
  -p oci_la_log_group_id=<lg_id> -p oci_la_log_source_name=<ls_name> -p tls=on -p tls.verify=off -m '*'
```

#### Configuration file

In your main configuration file append the following:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  outputs:
    - name: oracle_log_analytics
      match: '*'
      namespace: <namespace>
      config_file_location: <location>
      profile_name: ADMIN
      oci_la_log_source_name: <log-source-name>
      oci_la_log_group_id: <log-group-ocid>
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag dummy

[Output]
  Name oracle_log_analytics
  Match *
  Namespace <namespace>
  config_file_location <location>
  profile_name ADMIN
  oci_la_log_source_name <log-source-name>
  oci_la_log_group_id <log-group-ocid>
  tls On
  tls.verify Off
```

{% endtab %}
{% endtabs %}

### Insert `oci_la` configurations in the record

In case of multiple inputs, where `oci_la_*` properties can differ, you can add the properties in the record itself and instruct the plugin to read these properties from the record. The option `oci_config_in_record`, when set to `true` in the output config, will make the plugin read the mandatory and optional `oci_la` properties from the incoming record. The user must ensure that the necessary configurations have been inserted using relevant filters, otherwise the respective chunk will be dropped. The following example inserts `oci_la_log_source_name` and `oci_la_log_group_id` in the record:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  filters:
    - name: modify
      match: '*'
      add:
        - oci_la_log_source_name <LOG_SOURCE_NAME>
        - oci_la_log_group_id <LOG_GROUP_OCID>

  outputs:
    - name: oracle_log_analytics
      match: '*'
      config_file_location: <oci_file_path>
      profile_name: ADMIN
      oci_config_in_record: true
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag dummy

[Filter]
  Name modify
  Match *
  Add oci_la_log_source_name <LOG_SOURCE_NAME>
  Add oci_la_log_group_id <LOG_GROUP_OCID>

[Output]
  Name oracle_log_analytics
  Match *
  config_file_location <oci_file_path>
  profile_name ADMIN
  oci_config_in_record true
  tls On
  tls.verify Off
```

{% endtab %}
{% endtabs %}

### Add optional metadata

You can attach certain metadata to the log events collected from various inputs.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  outputs:
    - name: oracle_log_analytics
      match: '*'
      namespace: example_namespace
      config_file_location: /Users/example_file_location
      profile_name: ADMIN
      oci_la_log_source_name: example_log_source
      oci_la_log_group_id: ocid.xxxxxx
      oci_la_global_metadata:
        - glob_key1 value1
        - glob_key2 value2
      oci_la_metadata:
        - key1 value1
        - key2 value2
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag dummy

[Output]
  Name oracle_log_analytics
  Match *
  Namespace example_namespace
  config_file_location /Users/example_file_location
  profile_name ADMIN
  oci_la_log_source_name example_log_source
  oci_la_log_group_id ocid.xxxxxx
  oci_la_global_metadata glob_key1 value1
  oci_la_global_metadata glob_key2 value2
  oci_la_metadata key1 value1
  oci_la_metadata key2 value2
  tls On
  tls.verify Off
```

{% endtab %}
{% endtabs %}

The previous configuration will generate a payload that resembles the following:

```json
{
  "metadata": {
    "glob_key1": "value1",
    "glob_key2": "value2"
  },
  "logEvents": [
    {
      "metadata": {
        "key1": "value1",
        "key2": "value2"
      },
      "logSourceName": "example_log_source",
      "logRecords": [
        "dummy"
      ]
    }
  ]
}
```

The multiple `oci_la_global_metadata` and `oci_la_metadata` options are turned into a JSON object of key value pairs, nested under the key metadata.

With `oci_config_in_record` option set to `true`, the metadata key/value pairs will need to be injected in the record as an object of key/value pairs nested under the respective metadata field. The following example shows one such configuration:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy

  filters:
    - name: modify
      match: '*'
      add:
        - olgm.key1 val1
        - olgm.key2 val2

    - name: nest
      match: '*'
      operation: olgm.*
      wildcard: olgm.*
      nest_under: oci_la_global_metadata
      remove_prefix: olgm.

    - name: modify
      match: '*'
      add:
        - oci_la_log_source_name <LOG_SOURCE_NAME>
        - oci_la_log_group_id <LOG_GROUP_OCID>

  outputs:
    - name: oracle_log_analytics
      match: '*'
      config_file_location: <oci_file_path>
      namespace: <oci_tenancy_namespace>
      profile_name: ADMIN
      oci_config_in_record: true
      tls: on
      tls.verify: off
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag dummy

[FILTER]
  Name Modify
  Match *
  Add olgm.key1 val1
  Add olgm.key2 val2

[FILTER]
  Name nest
  Match *
  Operation nest
  Wildcard olgm.*
  Nest_under oci_la_global_metadata
  Remove_prefix olgm.

[Filter]
  Name modify
  Match *
  Add oci_la_log_source_name <LOG_SOURCE_NAME>
  Add oci_la_log_group_id <LOG_GROUP_OCID>

[Output]
  Name oracle_log_analytics
  Match *
  config_file_location <oci_file_path>
  namespace <oci_tenancy_namespace>
  profile_name ADMIN
  oci_config_in_record true
  tls On
  tls.verify Off
```

{% endtab %}
{% endtabs %}

The previous configuration first injects the necessary metadata keys and values in the record directly, with a prefix `olgm.` attached to the keys, which segregates the metadata keys from rest of the record keys. Then, using a `nest` filter, only the metadata keys are selected by the filter and nested under the `oci_la_global_metadata` key in the record, and the prefix `olgm.` is removed from the metadata keys.
