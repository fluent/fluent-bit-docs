---
description: Send logs to Oracle Cloud Infrastructure Logging Analytics Service
---

# Oracle Cloud Infrastructure Logging Analytics

Oracle Cloud Infrastructure Logging Analytics output plugin allows you to ingest your log records into [OCI Logging Analytics](https://www.oracle.com/manageability/logging-analytics) service.

Oracle Cloud Infrastructure Logging Analytics is a machine learning-based cloud service that monitors, aggregates, indexes, and analyzes all log data from on-premises and multicloud environments. Enabling users to search, explore, and correlate this data to troubleshoot and resolve problems faster and derive insights to make better operational decisions.

For details about OCI Logging Analytics refer to https://docs.oracle.com/en-us/iaas/logging-analytics/index.html

## Configuration Parameters

Following are the top level configuration properties of the plugin:

| Key                  | Description                                                                                                                                                                                                                          | default |
|:---------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| config_file_location | The location of the configuration file containing OCI authentication details. Reference for generating the configuration file - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File |         |
| profile_name         | OCI Config Profile Name to be used from the configuration file                                                                                                                                                                       | DEFAULT |
| namespace            | OCI Tenancy Namespace in which the collected log data is to be uploaded                                                                                                                                                              |         |
| proxy                | define proxy if required, in http://host:port format, supports only http protocol                                                                                                                                                    |         |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `1` |

The following parameters are to set the Logging Analytics resources that must be used to process your logs by OCI Logging Analytics.

| Key                     | Description                                                                                                                                                                                   | default |
|:------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------|
| oci_config_in_record    | If set to true, the following oci_la_* will be read from the record itself instead of the output plugin configuration.                                                                        | false   |
| oci_la_log_group_id     | The OCID of the Logging Analytics Log Group where the logs must be stored. This is a mandatory parameter                                                                                      |         |
| oci_la_log_source_name  | The Logging Analytics Source that must be used to process the log records. This is a mandatory parameter                                                                                      |         |
| oci_la_entity_id        | The OCID of the Logging Analytics Entity	                                                                                                                                                     |         |
| oci_la_entity_type	     | The entity type of the Logging Analytics Entity	                                                                                                                                              |         |
| oci_la_log_path	        | Specify the original location of the log files	                                                                                                                                               |         |
| oci_la_global_metadata	 | Use this parameter to specify additional global metadata along with original log content to Logging Analytics. The format is 'key_name value'. This option can be set multiple times          |         |
| oci_la_metadata	        | Use this parameter to specify additional metadata for a log event along with original log content to Logging Analytics. The format is 'key_name value'. This option can be set multiple times |         |

## TLS/SSL

The OCI Logging Analytics output plugin supports TLS/SSL.
For more details about the properties available and general configuration, see [TLS/SSL](../../administration/transport-security.md).

## Getting Started

### Prerequisites

- OCI Logging Analytics service must be onboarded with the minumum required policies, in the OCI region where you want to monitor. Refer [Logging Analytics Quick Start](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/quick-start.html) for details.
- Create OCI Logging Analytics LogGroup(s) if not done already. Refer [Create Log Group](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-logging-analytics-resources.html#GUID-D1758CFB-861F-420D-B12F-34D1CC5E3E0E) for details.

### Running the output plugin

In order to insert records into the OCI Logging Analytics service, you can run the plugin from the command line or through the configuration file:

#### Command line

The OCI Logging Analytics plugin can read the parameters from the command line in two ways, through the -p argument (property), e.g:

```text
$ fluent-bit -i dummy -t dummy -o oci_logan -p config_file_location=<location> -p namespace=<namespace> \
  -p oci_la_log_group_id=<lg_id> -p oci_la_log_source_name=<ls_name> -p tls=on -p tls.verify=off -m '*'
```

#### Configuration file

In your main configuration file append the following Input & Output sections:

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

### Insert oci_la configs in the record

In case of multiple inputs, where oci_la_* properties can differ, you can add the properties in the record itself and instruct the plugin to read these properties from the record. The option oci_config_in_record, when set to true in the output config, will make the plugin read the mandatory and optional oci_la properties from the incoming record. The user must ensure that the necessary configs have been inserted using relevant filters, otherwise the respective chunk will be dropped. Below is an example to insert oci_la_log_source_name and oci_la_log_group_id in the record:

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

### Add optional metadata

You can attach certain metadata to the log events collected from various inputs.

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

The above configuration will generate a payload that looks like this

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

The multiple oci_la_global_metadata and oci_la_metadata options are turned into a JSON object of key value pairs, nested under the key metadata.

With oci_config_in_record option set to true, the metadata key-value pairs will need to be injected in the record as an object of key value pair nested under the respective metadata field. Below is an example of one such configuration

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

The above configuration first injects the necessary metadata keys and values in the record directly, with a prefix olgm. attached to the keys in order to segregate the metadata keys from rest of the record keys. Then, using a nest filter only the metadata keys are selected by the filter and nested under oci_la_global_metadata key in the record, and the prefix olgm. is removed from the metadata keys.
