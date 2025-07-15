# Chronicle

The _Chronicle_ output plugin lets you ingest security logs into the [Google Chronicle](https://chronicle.security/) service. This connector is designed to send unstructured security logs.

## Google Cloud configuration

Fluent Bit streams data into an existing Google Chronicle tenant using a service account that you specify. Before using the Chronicle output plugin, you must:

1. Create a service account.

   To stream security logs into Google Chronicle, create a [Google Cloud service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) for Fluent Bit:

1. Create a tenant of Google Chronicle

   Fluent Bit doesn't create a tenant of Google Chronicle for your security logs, so you must create this ahead of time.

1. Retrieve service account credentials

   The Fluent Bit Chronicle output plugin uses a JSON credentials file for authentication credentials. Download the credentials file by following the instructions for [Creating and Managing Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

## Configurations parameters

| Key | Description | Default |
| :--- | :--- | :--- |
| `google_service_credentials` | Absolute path to a Google Cloud credentials JSON file. | Value of the environment variable `$GOOGLE_SERVICE_CREDENTIALS`. |
| `service_account_email` | Account email associated with the service. Only available if no credentials file has been provided. | Value of environment variable `$SERVICE_ACCOUNT_EMAIL`. |
| `service_account_secret` | Private key content associated with the service account. Only available if no credentials file has been provided. | Value of environment variable `$SERVICE_ACCOUNT_SECRET`. |
| `project_id` | The project id containing the tenant of Google Chronicle to stream into. | The value of the `project_id` in the credentials file |
| `customer_id` | The customer id to identify the tenant of Google Chronicle to stream into. The value of the `customer_id` should be specified in the configuration file. | _none_ |
| `log_type` | The log type to parse logs as. Google Chronicle supports parsing for [specific log types only](https://cloud.google.com/chronicle/docs/ingestion/parser-list/supported-default-parsers). | _none_ |
| `region` | The GCP region in which to store security logs. Supported regions: `US`, `EU`, `UK`, `ASIA`. Blank is handled as `US`. | _none_ |
| `log_key` | By default, the whole log record will be sent to Google Chronicle. If you specify a key name with this option, then only the value of that key will be sent to Google Chronicle. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

See Google's [official documentation](https://cloud.google.com/chronicle/docs/reference/ingestion-api) for further details.

## Configuration file

If you are using a Google Cloud credentials file, the following configuration will get you started:

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
