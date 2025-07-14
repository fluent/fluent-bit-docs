# Chronicle

The Chronicle output plugin allows ingesting security logs into [Google Chronicle](https://chronicle.security/) service. This connector is designed to send unstructured security logs.

## Google Cloud Configuration

Fluent Bit streams data into an existing Google Chronicle tenant using a service account that you specify. Therefore, before using the Chronicle output plugin, you must create a service account, create a Google Chronicle tenant, authorize the service account to write to the tenant, and provide the service account credentials to Fluent Bit.

### Creating a Service Account

To stream security logs into Google Chronicle, the first step is to create a Google Cloud service account for Fluent Bit:

* [Creating a Google Cloud Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

### Creating a Tenant of Google Chronicle

Fluent Bit does not create a tenant of Google Chronicle for your security logs, so you must create this ahead of time.

### Retrieving Service Account Credentials

Fluent Bit's Chronicle output plugin uses a JSON credentials file for authentication credentials. Download the credentials file by following these instructions:

* [Creating and Managing Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

## Configurations Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| google\_service\_credentials | Absolute path to a Google Cloud credentials JSON file. | Value of the environment variable _$GOOGLE\_SERVICE\_CREDENTIALS_ |
| service\_account\_email | Account email associated with the service. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_EMAIL_ |
| service\_account\_secret | Private key content associated with the service account. Only available if **no credentials file** has been provided. | Value of environment variable _$SERVICE\_ACCOUNT\_SECRET_ |
| project\_id | The project id containing the tenant of Google Chronicle to stream into. | The value of the `project_id` in the credentials file |
| customer\_id | The customer id to identify the tenant of Google Chronicle to stream into. The value of the `customer_id` should be specified in the configuration file. |  |
| log\_type | The log type to parse logs as. Google Chronicle supports parsing for [specific log types only](https://cloud.google.com/chronicle/docs/ingestion/parser-list/supported-default-parsers). |  |
| region | The GCP region in which to store security logs. Currently, there are several supported regions: `US`, `EU`, `UK`, `ASIA`. Blank is handled as `US`.   |  |
| log\_key | By default, the whole log record will be sent to Google Chronicle. If you specify a key name with this option, then only the value of that key will be sent to Google Chronicle. | |
| workers | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

See Google's [official documentation](https://cloud.google.com/chronicle/docs/reference/ingestion-api) for further details.

## Configuration File

If you are using a _Google Cloud Credentials File_, the following configuration is enough to get you started:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
  inputs:
    - name: dummy
      tag: dummy
          
  outputs:
    - name: chronicle
      match: '*'
      customer_id: my_customer_id
      log_type: my_super_awesome_type
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[INPUT]
  Name dummy
  Tag  dummy

[OUTPUT]
  Name         chronicle
  Match        *
  customer_id  my_customer_id
  log_type     my_super_awesome_type
```

{% endtab %}
{% endtabs %}